extends Area2D


var bullet_lifetime = 2
var damage = 5
var speed = 100
var started_move = false
var by_who = ""


func body_entered(body):
	if body.has_method("hurt"):
		if MP.has_multiplayer_authority(body) and not MP.has_multiplayer_authority(self):
			body.hurt(damage, by_who)
	queue_free()


func _physics_process(delta):
	if not started_move:
		started_move = true
		for body in get_overlapping_bodies():
			if body.has_method("hurt"):
				if MP.has_multiplayer_authority(body) and not MP.has_multiplayer_authority(self):
					body.hurt(damage, by_who)
			queue_free()
			break
		return
	global_position += Vector2.RIGHT.rotated(deg2rad(rotation_degrees)) * speed * delta
	bullet_lifetime -= delta
	if bullet_lifetime <= 0:
		queue_free()
