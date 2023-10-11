class_name Trail2D
extends Line2D


export (int) var length = 100
export (bool) var inherit_visibility = true
export (bool) var inherit_modulate = true
var node


func _ready():
	node = get_parent()
	set_as_toplevel(true)
	global_position = Vector2.ZERO


func _physics_process(delta):
	if node == null:
		queue_free()
		return
	if inherit_visibility:
		visible = node.visible
	if inherit_modulate:
		self_modulate = node.modulate
	add_point(node.global_position)
	if points.size() > length:
		remove_point(0)
