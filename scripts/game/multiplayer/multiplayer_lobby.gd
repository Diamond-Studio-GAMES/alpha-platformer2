extends WindowDialog
class_name Lobby


const PORT = 7411
var curr_suff = -1
var ip_preffix = ""
var players_info = {}
onready var timer = $connect/timer
onready var try = $connect/try


func _ready():
	$connect/ip/ip.text = G.cached_ip
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	get_close_button().connect("pressed", self, "do_disconnect")


func create():
	for i in $lobby/scroll/list.get_children():
		i.queue_free()
	popup_centered()
	MP.create_server(PORT, 4)
	init_multiplayer()


func join():
	popup_centered()
	$connect.show()
	var parts_of_level = G.current_level.split("_")
	$connect/title.text = "Присоединиться к комнате с уровнем " + parts_of_level[0] + "-" + parts_of_level[1] + "..."


func connect_ip():
	if timer.time_left > 0:
		return
	var ip = $connect/ip/ip.text
	if not ip.is_valid_ip_address():
		show_alert("Неверный IP-адрес!")
		return
	MP.create_client(ip, PORT)
	G.cached_ip = ip


# Здесь начинается спиженный код.
func connect_auto():
	if timer.time_left > 0:
		return
	var ips = IP.get_local_addresses()
	ip_preffix = ips[0]
	for i in ips:
		if i.begins_with("192.168."):
			ip_preffix = i
			break
	ip_preffix = ip_preffix.get_basename() + "."
	timer.start()
	curr_suff = G.cached_suff-1 if G.cached_suff >= 0 else -1


func do_disconnect():
	if MP.is_active:
		MP.close_network()
	hide()
	$"../select_level_dialog".show_d(G.current_level)


func connected_ok():
	if curr_suff > 0:
		G.cached_suff = curr_suff
	init_multiplayer()


func player_connected(id):
	var my_info = {
		"name" : G.getv("name", ""),
		"class" : G.getv("selected_class", "player"),
		"level" : G.current_level,
		"power" : G.getv(G.getv("selected_class", "player") + "_level", 0),
		"ulti_power" : G.getv(G.getv("selected_class", "player") + "_ulti_level", 1)
	}
	yield(get_tree(), "idle_frame")
	$"/root/mg".rpc_id(id, "register_player", my_info)
	update_start_game_button()


func player_disconnected(id):
	players_info.erase(id)
	update_start_game_button()
	if $lobby/scroll/list.has_node(str(id)):
		$lobby/scroll/list.get_node(str(id)).queue_free()


func server_disconnected():
	do_disconnect()
	show_alert("Разорвано соединение с сервером.\n Возможно, игра в комнате уже началась,\n или выбранный уровень не совпадает с уровнем комнаты.")
	$"../select_level_dialog".show_d(G.current_level)


func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	if id > 1:
		if info["level"] != players_info[get_tree().get_network_unique_id()]["level"] and get_tree().is_network_server():
			get_tree().network_peer.disconnect_peer(id)
			return
	players_info[id] = info
	var label = Label.new()
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.valign = VALIGN_CENTER
	label.text = info["name"] + ": " + G.CLASSES[info["class"]] + ", Сила: " + str(info["power"]) + ",  Навык: " + str(info["ulti_power"])
	label.name = str(id)
	$lobby/scroll/list.add_child(label)


func register_player_self():
	var id = get_tree().get_network_unique_id()
	var info = {
		"name" : G.getv("name", ""),
		"class" : G.getv("selected_class", "player"),
		"level" : G.current_level,
		"power" : G.getv(G.getv("selected_class", "player") + "_level", 0),
		"ulti_power" : G.getv(G.getv("selected_class", "player") + "_ulti_level", 1)
	}
	players_info[id] = info
	var label = Label.new()
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	label.valign = VALIGN_CENTER
	label.text = "(Вы)" + info["name"] + ": " + G.CLASSES[info["class"]] + ", Сила: " + str(info["power"]) + ",  Навык: " + str(info["ulti_power"])
	label.name = str(id)
	$lobby/scroll/list.add_child(label)


func init_multiplayer():
	for i in $lobby/scroll/list.get_children():
		i.queue_free()
	$lobby.show()
	if get_tree().is_network_server():
		$lobby/ip.show()
		$lobby/more.show()
		var ip = ""
		var ips = IP.get_local_addresses()
		ip = ips[0]
		for i in ips:
			if i.begins_with("192.168."):
				ip = i
				break
		if not ip.begins_with("192.168."):
			ip += " (возможно, нет подключения)"
		$lobby/ip.text = "Ваш IP: " + ip
	else:
		$lobby/ip.show()
		$lobby/more.hide()
		$lobby/ip.text = "Начать игру может только сервер."
	$lobby/start_game.disabled = true
	var parts_of_level = G.current_level.split("_")
	$lobby/level.text = "Уровень: " + parts_of_level[0] + "-" + parts_of_level[1]
	register_player_self()
	var node = MultiplayerGame.new()
	node.name = "mg"
	node.connect("player_registered", self, "register_player")
	get_tree().root.add_child(node)


func show_more_ips():
	var ips = IP.get_local_addresses()
	var text = ""
	var counter = 0
	for i in ips:
		counter += 1
		text += i
		text += ", "
		if counter == 3:
			counter = 0
			text += "\n"
	show_alert(text, "Ваши IP-адреса")


func start_game():
	$"/root/mg".begin_game()


func update_start_game_button():
	if not get_tree().is_network_server():
		$lobby/start_game.disabled = true
		return
	$lobby/start_game.disabled = not get_tree().get_network_connected_peers().size() > 0


func show_alert(text, title = "Ошибка!"):
	var pop = AcceptDialog.new()
	$"../alert_layer".add_child(pop)
	pop.dialog_text = text
	pop.window_title = title
	pop.theme = theme
	pop.connect("popup_hide", pop, "queue_free", [], CONNECT_ONESHOT)
	pop.popup_centered()


func _on_timer_timeout():
	if $lobby.visible or not visible:
		timer.stop()
		try.text = ""
		return
	if curr_suff > 254:
		timer.stop()
		show_alert("Не удалось найти сервер.")
		try.text = ""
		curr_suff = 0
	else:
		if curr_suff == G.cached_suff:
			G.cached_suff = -1
			curr_suff = 0
		else:
			curr_suff += 1
		MP.create_client(ip_preffix + str(curr_suff), PORT)
		try.text = "Пробую IP: " + ip_preffix + str(curr_suff)
