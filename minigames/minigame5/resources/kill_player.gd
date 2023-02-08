extends Area2D


func _ready():
	connect("body_entered", self, "entered")


func entered(body):
	if body.name == "dasher":
		body.destroy()
