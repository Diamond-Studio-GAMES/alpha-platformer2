extends Node2D


export (PackedScene) var kn : PackedScene
export var bounds_x = 160
var timer = 0
export var times = 20
export var interval = 0.5


func _process(delta):
	timer += delta
	if timer >= interval:
		timer = 0
		times -= 1
		var n = kn.instance()
		n.global_position = Vector2(global_position.x - bounds_x + randi() % (bounds_x * 2), global_position.y)
		n.rotation_degrees = 90
		$"..".add_child(n, true)
	if times <= 0:
		queue_free()

