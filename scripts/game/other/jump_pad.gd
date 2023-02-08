extends Area2D


export (float) var jump_power = 500
var bodies = []


func add_body(body):
	if body.has_method("jump"):
		bodies.append(body)


func remove_body(body):
	if body in bodies:
		bodies.erase(body)


func _physics_process(delta):
	for i in bodies:
		var s = i.jump(jump_power)
		if s:
			$effect.restart()
