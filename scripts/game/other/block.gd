extends KinematicBody2D
class_name Pushable, "res://textures/blocks/ladder.png"


var _move = Vector2()
var MAX_GRAVITY = 250
var GRAVITY_SPEED = 750
onready var ray0 = $ray0
onready var ray1 = $ray1


func _physics_process(delta):
	if _move.x == 0:
		_move = Vector2(0, min(_move.y + GRAVITY_SPEED * delta, MAX_GRAVITY))
	move_and_slide(_move)
	_move.x = 0
	if ray0.is_colliding():
		if ray0.get_collider() is Entity:
			var body = ray0.get_collider()
			_move.x = max(body._move.x, 0)
			_move.y = max(body._move.y, 0)
	if ray1.is_colliding():
		if ray1.get_collider() is Entity:
			var body = ray1.get_collider()
			_move.x = min(body._move.x, 0)
			_move.y = max(body._move.y, 0)
