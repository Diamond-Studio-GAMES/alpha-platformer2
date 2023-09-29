tool
extends Line2D


export (int) var speed = 170
var is_moving = true
const START_POS = Vector2.ZERO


func _ready():
	if not Engine.editor_hint:
		hide()


func _process(delta):
	if not Engine.editor_hint:
		visible = false
		return
	if Input.is_key_pressed(KEY_INSERT):
		if not $"../music".playing:
			$"../music".play()
			is_moving = true
		else:
			$"../music".stop()
			is_moving = false
	if $"../music".playing:
		position.x += speed * delta
	else:
		position = START_POS
	
