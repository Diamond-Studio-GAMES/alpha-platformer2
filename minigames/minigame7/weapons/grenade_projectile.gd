extends KinematicBody2D


var speed = 600
var bullet_lifetime = 1.5
var blast = load("res://minigames/minigame7/weapons/blast.tscn")
var by_who = ""


func _physics_process(delta):
	move_and_collide(Vector2.RIGHT.rotated(deg2rad(rotation_degrees)) * speed * delta)
	bullet_lifetime -= delta
	if bullet_lifetime <= 0:
		if MP.has_multiplayer_authority(self):
			var node = blast.instance()
			node.by_who = by_who
			node.global_position = global_position
			get_parent().add_child(node, true)
			queue_free()
