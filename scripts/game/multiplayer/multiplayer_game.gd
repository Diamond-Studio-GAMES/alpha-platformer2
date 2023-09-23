extends Node
class_name MultiplayerGame

enum State {
	LOBBY = 0,
	LOADING = 1,
	IN_GAME = 2,
	END = 3,
}
enum Reason {
	VERSION = 0,
	LEVEL = 1,
	BUSY = 2,
}

var state = State.LOBBY
var players_remain_to_load = []
var alive_players = []
var another_dialog = false
var ping = 0.0
var _ping_timer = 0.0
var _ping_time = 0.0
var _next_ping_timer = 0.0
var _is_pinging = false
var _ping_counter: Label
signal game_started
signal player_registered(info)
signal refused(reason, data)


func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	MP.connect("network_closed", self, "close_multiplayer")
	get_tree().connect("network_peer_connected", self, "refuse")
	get_tree().connect("network_peer_disconnected", self, "check")
	if get_tree().is_network_server():
		return
	if not G.getv("show_ping", false):
		return
	var pc = load("res://prefabs/menu/ping_counter.tscn").instance()
	_ping_counter = pc.get_node("label")
	pc.name = "ping_counter"
	add_child(pc)


func check(id):
	if state in [State.LOBBY, State.END]:
		return
	if id in players_remain_to_load:
		players_remain_to_load.erase(id)
	if id in alive_players:
		alive_players.erase(id)
	check_for_done()
	check_for_no_players()
	check_for_end()


func refuse(id):
	if MP.is_active and get_tree().is_network_server() and state != State.LOBBY:
		rpc_id(id, "refused", Reason.BUSY, null)
		return


remote func refused(reason, data):
	MP.close_network()
	emit_signal("refused", reason, data)


func close_multiplayer():
	if state in [State.LOADING, State.IN_GAME]:
		G.dialog_in_menu = tr("menu.players_left") if another_dialog else tr("menu.disconnected")
		get_tree().change_scene("res://scenes/menu/menu.tscn")
	queue_free()


remote func register_player(info):
	emit_signal("player_registered", info)


func begin_game():
	players_remain_to_load = Array(get_tree().get_network_connected_peers())
	players_remain_to_load.append(1)
	rpc("start_load")


remotesync func start_load():
	state = State.LOADING
	G.change_to_scene("res://scenes/levels/level_" + G.current_level + ".tscn")
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


remotesync func start_game():
	yield(get_tree().create_timer(0.1), "timeout")
	state = State.IN_GAME
	emit_signal("game_started")
	get_tree().paused = false
	get_tree().call_group("synchronizer", "start_sync")
	alive_players = Array(get_tree().get_network_connected_peers())
	alive_players.append(get_tree().get_network_unique_id())


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
	if get_tree().get_network_connected_peers().size() < 1:
		return
	if alive_players.empty():
		state = State.END
		get_tree().call_group("player", "remove_from_group", "spawnable")
		if get_tree().is_network_server():
			yield(get_tree().create_timer(4), "timeout")
		else:
			yield(get_tree().create_timer(3), "timeout")
		get_tree().get_nodes_in_group("player")[0].end_game()


func kill_revive_player(id, revive = false):
	if revive:
		if not id in alive_players:
			alive_players.append(id)
	else:
		if id in alive_players:
			alive_players.erase(id)
	check_for_end()


func _process(delta):
	if not MP.is_active:
		return
	if get_tree().is_network_server():
		return
	_next_ping_timer += delta
	if _next_ping_timer > 1 and not _is_pinging:
		ping_server()
	if _is_pinging:
		_ping_timer += delta
		if _ping_timer > 2:
			get_tree().emit_signal("server_disconnected")
		elif _ping_timer > 1:
			ping = 0.999
	if is_instance_valid(_ping_counter):
		_ping_counter.text = tr("menu.ping") % int(ping * 1000)


func ping_server():
	_next_ping_timer = 0
	_ping_timer = 0
	_ping_time = OS.get_ticks_msec()
	_is_pinging = true
	rpc_id(1, "pinged")


remote func pinged():
	rpc_id(get_tree().get_rpc_sender_id(), "response_to_ping")


remote func response_to_ping():
	ping = (OS.get_ticks_msec() - _ping_time) / 1000.0
	_is_pinging = false
