extends KinematicBody2D
class_name Pushable, "res://textures/blocks/ladder.png"


export (float) var push_speed = 50
var _move = Vector2()
var MAX_GRAVITY = 150
var GRAVITY_SPEED = 350
var player : Player


func _ready():
	$player_area.connect("body_entered", self, "body_entered")
	$player_area.connect("body_exited", self, "body_exited")


func _physics_process(delta):
	_move = Vector2(_move.x, min(_move.y + GRAVITY_SPEED * delta, MAX_GRAVITY))
	_move = move_and_slide(_move)
	_move.x = 0
	if player:
		for i in player.get_slide_count():
			var col = player.get_slide_collision(i)
			if col.collider == self:
				_move.x += col.remainder.x * push_speed


func body_entered(body):
	if body is Player:
		player = body


func body_exited(body):
	if body is Player:
		player = null
