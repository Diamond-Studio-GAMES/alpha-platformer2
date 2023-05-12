extends Area2D
class_name SpeedChange


export (float) var speed_change = 2


func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body):
	if body is Entity:
		body.speed_cooficent *= speed_change


func _on_body_exited(body):
	if body is Entity:
		body.speed_cooficent /= speed_change
