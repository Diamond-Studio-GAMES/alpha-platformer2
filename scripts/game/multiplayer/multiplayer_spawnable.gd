extends Node
class_name MultiplayerSpawnable


export (Array, NodePath) var spawn_sync_data_node_paths = []
export (Array, String) var spawn_sync_data_properties = []
export (bool) var server_always_master = false
export (bool) var auto_despawn = true


func _enter_tree():
	pause_mode = PAUSE_MODE_PROCESS
	get_parent().set_meta("auto_despawn", auto_despawn)
