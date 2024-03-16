extends Level


export (float) var gravity_multiplier = 0.6
export (Vector2) var zoom = Vector2(0.4, 0.4)


func _enter_tree():
	connect("child_entered_tree", self, "_on_child_entered_tree")


func _ready():
	for i in $mobs.get_children():
		if i is Entity:
			i.GRAVITY_SPEED *= gravity_multiplier
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	player.default_camera_zoom = zoom
	player.get_node("camera").zoom = zoom


func _on_child_entered_tree(child):
	if child is Entity:
		child.GRAVITY_SPEED *= gravity_multiplier
