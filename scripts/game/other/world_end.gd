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
		if MP.auth(entity):
			if entity is Mob and entity.current_health > 0:
				entity.hurt(1, 0, false, true)
			elif entity is Player:
				if entity.current_health > 0:
					entity.hurt(entity.max_health * 0.25, 0, false, false, false, 1, 2, 0)
				entity.global_position = entity.last_floor_position + Vector2.UP * entity.last_floor_gravity * 32
				entity.GRAVITY_SCALE = entity.last_floor_gravity
				entity = null
