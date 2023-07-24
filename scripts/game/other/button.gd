extends Area2D


export (bool) var pressed = false
export (NodePath) var to_manage
var m: CollisionObject2D
var m_mask = 0
var m_layer = 0
onready var sprite = $sprite


func _ready():
	m = get_node(to_manage)
	m_mask = m.collision_mask
	m_layer = m.collision_layer


func _process(delta):
	if pressed and sprite.frame == 1:
		sprite.frame = 0
		m.collision_layer = 0
		m.collision_mask = 0
		m.hide()
	elif not pressed and sprite.frame == 0:
		sprite.frame = 1
		m.collision_layer = m_layer
		m.collision_mask = m_mask
		m.show()


func body_entered(body):
	if body is Pushable:
		pressed = true


func body_exited(body):
	if body is Pushable:
		pressed = false
