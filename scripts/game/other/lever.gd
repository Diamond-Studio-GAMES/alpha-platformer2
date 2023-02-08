extends Node2D


export (bool) var pressed = false
export (NodePath) var to_manage
var m
var m_mask = 0
var m_layer = 0


func _ready():
	m = get_node(to_manage)
	m_mask = m.collision_mask
	m_layer = m.collision_layer


func _process(delta):
	if pressed and not $pressed.visible:
		$unpressed.hide()
		$pressed.show()
		m.collision_layer = 0
		m.collision_mask = 0
		m.hide()
	elif not pressed and $pressed.visible:
		$unpressed.show()
		$pressed.hide()
		m.collision_layer = m_layer
		m.collision_mask = m_mask
		m.show()


func lever_entered(body):
	if body.name.begins_with("player"):
		pressed = not pressed
