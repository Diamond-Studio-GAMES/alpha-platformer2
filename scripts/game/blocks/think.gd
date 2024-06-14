extends Area2D


export (String) var text = "что-то"
export (float) var time = 2.0
export (Color) var color = Color.white

signal player_entered


func _ready():
	if G.getv("lore_disabled", false) and modulate == Color.white and self_modulate == Color.white:
		hide()
	connect("body_entered", self, "player_entered")
	connect("area_entered", self, "player_entered")


func player_entered(body):
	if body is Player and MP.auth(body):
		body.make_dialog(tr(text), time, color)
		emit_signal("player_entered")
		queue_free()
