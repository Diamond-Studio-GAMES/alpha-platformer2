extends KinematicBody2D


export (int) var speed = 200
var player : Player
var direction = Vector2()


func _ready():
	if MP.auth(self):
		direction = Vector2(player.global_position.x - global_position.x - 72 + (randi() % 144), player.global_position.y - global_position.y)
		direction = direction.normalized()


func _physics_process(delta):
	if is_on_floor():
		return
	move_and_slide(direction * speed, Vector2.UP)

