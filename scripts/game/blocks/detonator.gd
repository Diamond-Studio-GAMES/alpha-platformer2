extends StaticBody2D


export (NodePath) var target = @"../tnt"
var bodies = []
var _target


func _ready():
	_target = get_node(target)


func _on_plate_body_entered(body):
	if not MP.auth(self):
		return
	if body is Entity:
		bodies.append(body)
		$sprite.frame = 0
		if is_instance_valid(_target):
			_target.explode()


func _on_plate_body_exited(body):
	if body in bodies:
		bodies.erase(body)
	if bodies.size() < 1:
		$sprite.frame = 1
