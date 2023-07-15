extends Node2D


const PORT = 41511
var player = load("res://minigames/minigame7/player.scn")
var heal = load("res://minigames/minigame7/heal.scn")
var started = false
var alive_players = []
var players_names = {}
var my_player


func alert(text = ""):
	$lobby/gui/alert.dialog_text = text
	$lobby/gui/alert.popup_centered()


func _ready():
	$lobby/gui/panel/port.text = "Порт: " + str(PORT)
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("connection_failed", self, "alert", ["Ошибка подключения!"])
	get_tree().connect("server_disconnected", self, "server_disconnect")
	get_tree().connect("network_peer_disconnected", self, "kill_player", ["disconnect"])
	get_tree().connect("network_peer_connected", self, "refuse")
	MP.connect("network_closed", self, "disconnected")


func refuse(id):
	if MP.is_active and get_tree().is_network_server() and started:
		get_tree().network_peer.disconnect_peer(id, true)


func server_disconnect():
	alert("Разорвано соединение с сервером или игра уже началась.")
	$lobby.show()


func connected_ok():
	$lobby.hide()
	spawn_player()


func server():
	started = false
	MP.create_server(PORT, 10)
	spawn_player()
	$lobby.hide()


func spawn_player():
	var n = player.instance()
	randomize()
	var random_spawn_point_id = randi() % $spawn_poses.get_child_count()
	n.global_position = $spawn_poses.get_child(random_spawn_point_id).global_position
	n.name = "player" + str(get_tree().get_network_unique_id())
	n.player_name = G.getv("name", "Player")
	add_child(n, true)
	my_player = n


func kill_player(id, by):
	if not started:
		return
	alive_players.erase(id)
	if alive_players.size() == 1:
		if alive_players[0] == get_tree().get_network_unique_id():
			G.addv("royale_victories", 1)
			G.ach.complete(Achievements.VICTORY_ROYALE)
			my_player.make_text("ВЫ ПОБЕДИЛИ!")
		else:
			my_player.make_text("ПОБЕДИТЕЛЬ: " + players_names[alive_players[0]])
	else:
		if by == "disconnect":
			my_player.make_text("Игрок %s отключился!" % players_names[id])
			return
		my_player.make_text(by + " убивает игрока " + players_names[id] + "!")


remotesync func start_game():
	$border0/anim.play("move0")
	$border1/anim.play("move0")
	$border2/anim.play("move0")
	$border3/anim.play("move0")
	if get_tree().is_network_server():
		$heal_timer.start()
	started = true
	alive_players = Array(get_tree().get_network_connected_peers())
	alive_players.append(get_tree().get_network_unique_id())
	players_names = {}
	for i in alive_players:
		players_names[i] = get_node("player" + str(i) + "/label").text
	my_player.make_text("Игра началась!")


remotesync func player_died(id, by):
	kill_player(id, by)


func client():
	if not $lobby/gui/panel/ip.text.is_valid_ip_address():
		alert("Введён неверный IP-адрес!")
		return
	started = false
	MP.create_client($lobby/gui/panel/ip.text, PORT)


func disconnected():
	my_player = null
	$lobby.show()
	$heal_timer.stop()
	$border0/anim.seek(0, true)
	$border1/anim.seek(0, true)
	$border2/anim.seek(0, true)
	$border3/anim.seek(0, true)
	$border0/anim.stop(true)
	$border1/anim.stop(true)
	$border2/anim.stop(true)
	$border3/anim.stop(true)


func exit():
	get_tree().change_scene("res://minigames/minigame7/minigame.scn")


func _on_heal_timer_timeout():
	if not get_tree().is_network_server():
		return
	var h = heal.instance()
	var random_spawn_point_id = randi() % $heal_points.get_child_count()
	h.global_position = $heal_points.get_child(random_spawn_point_id).global_position 
	h.name = "heal" + str(randi())
	add_child(h, true)
