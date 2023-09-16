extends Node2D


var entity: Entity


func _ready():
	$up.connect("body_entered", self, "body_entered")
	$down.connect("body_entered", self, "body_entered")


func body_entered(body):
	if body is Entity:
		entity = body
		if body is Player:
			body.can_revive = false


func _physics_process(delta):
	if is_instance_valid(entity):
		if entity.current_health > 0:
			entity.hurt(1, 0, false, true)
