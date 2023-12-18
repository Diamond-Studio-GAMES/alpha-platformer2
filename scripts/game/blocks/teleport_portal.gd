extends Node2D


var teleported_entities = []
var teleported_entities_portal_ids = []
onready var portal0 = $portal0
onready var portal1 = $portal1
onready var portal0anim = $portal0/anim
onready var portal1anim = $portal1/anim


func enter_portal(body, portal_id):
	if body in teleported_entities:
		return
	if not body is Entity:
		return
	teleported_entities.append(body)
	teleported_entities_portal_ids.append(portal_id)
	match portal_id:
		0:
			var fall_distance = body._start_falling_y - body.global_position.y
			body.global_position = portal1.global_position
			body._start_falling_y = body.global_position.y + fall_distance
			portal0anim.play("enter")
			portal1anim.play("exit")
		1:
			var fall_distance = body._start_falling_y - body.global_position.y
			body.global_position = portal0.global_position
			body._start_falling_y = body.global_position.y + fall_distance
			portal1anim.play("enter")
			portal0anim.play("exit")


func exit_portal(body, portal_id):
	if not body is Entity:
		return
	var body_id = teleported_entities.find(body)
	if body_id == -1:
		return
	if teleported_entities_portal_ids[body_id] == portal_id:
		return
	teleported_entities.remove(body_id)
	teleported_entities_portal_ids.remove(body_id)
