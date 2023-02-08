extends KinematicBody2D
class_name Pushable, "res://textures/blocks/ladder.png"


var _move = Vector2()
var _y = 0
var MAX_GRAVITY = 250
var GRAVITY_SPEED = 15
var test_move = 5


func _physics_process(delta):
	_y = clamp(_move.y + GRAVITY_SPEED, -9999, MAX_GRAVITY)
	_move = Vector2(_move.x, _y)
	_move = move_and_slide(_move, Vector2.UP, false, 4, 0.785398, true)
	_move.x = 0
	var col = move_and_collide(Vector2(test_move, 0), true, true, true)
	if col:
		if col.collider_velocity.x < 0:
			_move.x = col.collider_velocity.x
	col = move_and_collide(Vector2(-test_move, 0), true, true, true)
	if col:
		if col.collider_velocity.x > 0:
			_move.x = col.collider_velocity.x
