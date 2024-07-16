extends Node2D


var entity: Entity


func _ready():
	$up.connect("body_entered", self, "body_entered")
	$down.connect("body_entered", self, "body_entered")


func body_entered(body):
	if body is Entity:
		entity = body


func _physics_process(delta):
	if is_instance_valid(entity):
		if entity.current_health > 0 and MP.auth(self):
			if entity is Mob:
				entity.hurt(1, 0, false, true)
			elif entity is Player:
				entity.hurt(entity.max_health * 0.25, 0, false, false, false, 1, 2, 0)
				entity.global_position = entity.last_floor_posiition + Vector2.UP * entity.GRAVITY_SCALE * 32
				entity = null
