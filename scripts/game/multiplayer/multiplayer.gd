extends Node
class_name Multiplayer


var is_active = false
var players_connected = 1
signal spawned_on_remote
signal network_closed
var synces = {}


func create_client(ip, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer


func create_server(port, max_players = 2):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players-1)
	get_tree().network_peer = peer
	is_active = true


func close_network():
	print("Network closed")
	get_tree().network_peer.close_connection()
	is_active = false
	emit_signal("network_closed")
	for i in get_tree().get_nodes_in_group("spawnable"):
		if is_instance_valid(i):
			i.queue_free()
	yield(get_tree(), "idle_frame")
	get_tree().network_peer = null


func has_multiplayer_authority(node):
	if not is_active:
		return true
	return node.is_network_master()


func auth(node):
	if not is_active:
		return true
	return node.is_network_master()


func _add_synchronizer(path, node):
	synces[path] = node


func _remove_synchronizer(path):
	if path in synces:
		synces.erase(path)


func _sync_properties_unreliable(path, data):
	rpc_unreliable("_remote_sync_unreliable", path, data)


remote func _remote_sync_unreliable(path, data):
	if not path in synces:
		return
	if not is_instance_valid(synces[path]):
		return
	synces[path]._set_sync_properties_unreliable(data)


func _sync_properties(path, data):
	rpc("_remote_sync", path, data)


remote func _remote_sync(path, data):
	if not path in synces:
		return
	if not is_instance_valid(synces[path]):
		return
	synces[path]._set_sync_properties(data)


func _sync_call(path, path_to, func_name, args):
	rpc("_remote_sync_call", path, path_to, func_name, args)


remote func _remote_sync_call(path, path_to, func_name, args):
	if not path in synces:
		return
	if not is_instance_valid(synces[path]):
		return
	synces[path]._sync_call_remote(path_to, func_name, args)


func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	get_tree().connect("node_added", self, "_node_added")
	get_tree().connect("node_removed", self, "_node_removed")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("server_disconnected", self, "close_network")


func _connected_ok():
	is_active = true


func _player_connected(id):
	rpc_id(id, "_add_player")
	for node in get_tree().get_nodes_in_group("spawnable"):
		var spawnable = node.get_node("MultiplayerSpawnable") as MultiplayerSpawnable
		var spawn_data = []
		for i in range(len(spawnable.spawn_sync_data_node_paths)):
			spawn_data.append([str(spawnable.spawn_sync_data_node_paths[i]), spawnable.spawn_sync_data_properties[i], spawnable.get_node(spawnable.spawn_sync_data_node_paths[i]).get(spawnable.spawn_sync_data_properties[i])])
		rpc_id(id, "_sync_spawn", node.name, node.filename, str(node.get_parent().get_path()), spawnable.server_always_master, spawn_data, node.get_network_master())


func _player_disconnected(id):
	players_connected -= 1
	for node in get_tree().get_nodes_in_group("spawnable"):
		if node.get_network_master() == id:
			node.queue_free()


remote func _add_player():
	players_connected += 1


func _node_added(node):
	if not is_active:
		return
	if node.is_in_group("spawnable") and not node.get_meta("spawned_remotely", false):
		var spawnable = node.get_node("MultiplayerSpawnable") as MultiplayerSpawnable
		var spawn_data = []
		for i in range(len(spawnable.spawn_sync_data_node_paths)):
			spawn_data.append([str(spawnable.spawn_sync_data_node_paths[i]), spawnable.spawn_sync_data_properties[i], spawnable.get_node(spawnable.spawn_sync_data_node_paths[i]).get(spawnable.spawn_sync_data_properties[i])])
		if spawnable.server_always_master:
			node.set_network_master(1)
		else:
			node.set_network_master(get_tree().get_network_unique_id())
		rpc("_sync_spawn", node.name, node.filename, str(node.get_path()).get_base_dir(), spawnable.server_always_master, spawn_data, node.get_network_master())


func _node_removed(node):
	if not is_active:
		return
	if node.is_in_group("spawnable"):
		if has_multiplayer_authority(node):
			if node.get_meta("auto_despawn", false):
				rpc("_sync_delete", str(node.get_path()))


remote func _sync_spawn(node_name, file_path, node_path, server_master, spawn_data, netw_m_id):
	if has_node(node_path.plus_file(node_name)):
		return
	var node = load(file_path).instance()
	var spawner = node.get_node("MultiplayerSpawnable")
	node.name = node_name
	for i in spawn_data:
		spawner.get_node(i[0]).set(i[1], i[2])
	if server_master:
		node.set_network_master(1)
	else:
		node.set_network_master(netw_m_id)
	node.set_meta("spawned_remotely", true)
	get_node(node_path).add_child(node, true)


remote func _sync_delete(path):
	var node_to_free = get_node_or_null(path)
	if not is_instance_valid(node_to_free):
		return
	if has_multiplayer_authority(node_to_free):
		return
	get_node(path).queue_free()


func _process(delta):
	if is_active:
		if get_tree().network_peer.get_connection_status() != NetworkedMultiplayerENet.CONNECTION_CONNECTED:
			close_network()
