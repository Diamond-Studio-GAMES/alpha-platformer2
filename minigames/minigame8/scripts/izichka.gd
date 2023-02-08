extends "res://minigames/minigame8/scripts/enemy.gd"


export (float) var time_to_paint = 3
var paint_timer = 0
var painted_cameras = []
var paint = load("res://minigames/minigame8/misc/paint.scn")


func _process(delta):
	if night.is_cameras:
		if current_room == night.current_camera and not current_room in painted_cameras:
			paint_timer += delta
		else:
			paint_timer = 0
		if paint_timer >= time_to_paint:
			paint_timer = 0
			painted_cameras.append(current_room)
			var node = paint.instance() as ColorRect
			node.color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1), 1)
			get_parent().get_parent().add_child(node)
	else:
		paint_timer = 0
