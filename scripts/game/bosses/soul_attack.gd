extends Area2D


func _ready():
	connect("body_entered", self, "_on_body_entered")


func _on_body_entered(body):
	if body.name == "soul":
		body.get_parent().hurt()
