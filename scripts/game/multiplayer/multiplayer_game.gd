extends Node
class_name MultiplayerGame

enum State {
	LOBBY = 0,
	LOADING = 1,
	IN_GAME = 2,
	END = 3,
}

var state = State.LOBBY
var players_remain_to_load = []
var alive_players = []
var another_dialog = false
signal game_started
signal player_registered(info)


func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	MP.connect("network_closed", self, "close_multiplayer")
	get_tree().connect("network_peer_connected", self, "refuse")
	get_tree().connect("network_peer_disconnected", self, "check")


func check(id):
	if state in [State.LOBBY, State.END]:
		return
	if id in players_remain_to_load:
		players_remain_to_load.erase(id)
	if id in alive_players:
		alive_players.erase(id)
	check_for_done()
	check_for_end()
	check_for_no_players()


func refuse(id):
	if MP.is_active and get_tree().is_network_server() and state != State.LOBBY:
		get_tree().network_peer.disconnect_peer(id)
		return


func close_multiplayer():
	if state in [State.LOADING, State.IN_GAME]:
		G.dialog_in_menu = "Все игроки отключились!" if another_dialog else "Разорвано соединение с сервером!"
		get_tree().change_scene("res://scenes/menu/menu.scn")
	queue_free()


remote func register_player(info):
	emit_signal("player_registered", info)


func begin_game():
	players_remain_to_load = Array(get_tree().get_network_connected_peers())
	players_remain_to_load.append(1)
	rpc("start_load")


remotesync func start_load():
	state = State.LOADING
	G.change_to_scene("res://scenes/levels/level_" + G.current_level + ".scn")
	yield(G, "loaded_to_scene")
	if get_tree().is_network_server():
		loaded(1)
	else:
		rpc_id(1, "loaded", get_tree().get_network_unique_id())
	get_tree().paused = true


remote func loaded(id):
	if id in players_remain_to_load:
		players_remain_to_load.erase(id)
	check_for_done()
	check_for_no_players()


func check_for_no_players():
	if state in [State.LOBBY, State.END]:
		return
	if not get_tree().is_network_server():
		return
	if get_tree().get_network_connected_peers().size() < 1:
		another_dialog = true
		yield(get_tree(), "idle_frame")
		MP.close_network()


func check_for_done():
	if state != State.LOADING or not get_tree().is_network_server():
		return
	if players_remain_to_load.size() == 0:
		rpc("start_game")


func check_for_end():
	if state != State.IN_GAME:
		return
	if alive_players.empty():
		state = State.END
		get_tree().call_group("player", "remove_from_group", "spawnable")
		yield(get_tree().create_timer(4), "timeout")
		get_tree().get_nodes_in_group("player")[0].end_game()


func kill_revive_player(id, revive = false):
	if revive:
		if not id in alive_players:
			alive_players.append(id)
	else:
		if id in alive_players:
			alive_players.erase(id)
	check_for_end()


remotesync func start_game():
	yield(get_tree().create_timer(0.1), "timeout")
	state = State.IN_GAME
	emit_signal("game_started")
	get_tree().paused = false
	get_tree().call_group("synchronizer", "start_sync")
	alive_players = Array(get_tree().get_network_connected_peers())
	alive_players.append(get_tree().get_network_unique_id())
