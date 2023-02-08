extends Camera2D


var active = true
export (float) var camera_speed = 5
var pressed = false
onready var screen_size = get_viewport_rect().size


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if pressed and active:
			position = position - event.relative * camera_speed * zoom.x
	elif event is InputEventMouseButton:
		if event.pressed:
			pressed = true

func _input(event):
	if event is InputEventMouseButton:
		if not event.pressed:
			pressed = false


func _process(delta):
	position.y = clamp(position.y, limit_top + zoom.y * screen_size.y / 2, limit_bottom - zoom.y * screen_size.y / 2)
	position.x = clamp(position.x, limit_left + zoom.x * screen_size.x / 2, limit_right - zoom.x * screen_size.x / 2)
