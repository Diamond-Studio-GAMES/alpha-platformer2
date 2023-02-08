extends Node
class_name MultiplayerSynchronizer


export (Array, NodePath) var reliable_sync_node_paths = []
export (Array, String) var reliable_sync_properties_names = []
export (Array, NodePath) var unreliable_sync_node_paths = []
export (Array, String) var unreliable_sync_properties_names = []
export (int) var physics_frame_delay = 6
export (int) var physics_frame_delay_unreliable = 3
export (bool) var syncing = true
var reliable_sync_nodes = []
var reliable_sync_properties = []
var unreliable_sync_nodes = []
var unreliable_sync_properties = []
var physics_frame_timer = 0
var physics_frame_timer_unreliable = 0
onready var path = str(get_path())


func _enter_tree():
	MP.add_synchronizer(str(get_path()), self)
	add_to_group("synchronizer")


func _exit_tree():
	MP.remove_synchronizer(str(get_path()))


func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	for i in range(len(reliable_sync_node_paths)):
		reliable_sync_nodes.append(get_node(reliable_sync_node_paths[i]))
		reliable_sync_properties.append(reliable_sync_properties_names[i])
	for i in range(len(unreliable_sync_node_paths)):
		unreliable_sync_nodes.append(get_node(unreliable_sync_node_paths[i]))
		unreliable_sync_properties.append(unreliable_sync_properties_names[i])


func start_sync():
	syncing = true


func _physics_process(delta):
	if not MP.is_active:
		return
	if not MP.has_multiplayer_authority(self):
		return
	if not syncing:
		return
	if physics_frame_timer >= physics_frame_delay:
		physics_frame_timer = 0
		sync_properties()
	physics_frame_timer += 1
	if physics_frame_timer_unreliable >= physics_frame_delay_unreliable:
		physics_frame_timer_unreliable = 0
		sync_properties_unreliable()
	physics_frame_timer_unreliable += 1


func sync_properties_unreliable():
	if unreliable_sync_nodes.empty():
		return
	var sync_data_u = []
	for i in range(len(unreliable_sync_nodes)):
		sync_data_u.append(unreliable_sync_nodes[i].get(unreliable_sync_properties[i]))
	MP.sync_properties_unreliable(path, sync_data_u)


func sync_properties():
	if reliable_sync_nodes.empty():
		return
	var sync_data = []
	for i in range(len(reliable_sync_nodes)):
		sync_data.append(reliable_sync_nodes[i].get(reliable_sync_properties[i]))
	MP.sync_properties(path, sync_data)


func set_sync_properties(data):
	for i in range(len(data)):
		reliable_sync_nodes[i].set(reliable_sync_properties[i], data[i])

func set_sync_properties_unreliable(data):
	for i in range(len(data)):
		unreliable_sync_nodes[i].set(unreliable_sync_properties[i], data[i])


func sync_call(obj : Node, func_name, args = [], forced = false):
	if not MP.is_active:
		return
	if not forced:
		if not MP.has_multiplayer_authority(self):
			return
	if not syncing:
		return
	MP.sync_call(path, str(get_path_to(obj)), func_name, args)


func sync_call_remote(node_path, func_name, args = []):
	get_node(node_path).callv(func_name, args)
