extends Area2D

var by_who

func _ready():
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	for i in get_overlapping_bodies():
		if i.has_method("hurt"):
			if MP.has_multiplayer_authority(i):
				i.hurt(80, by_who)
	yield(get_tree().create_timer(0.25, false), "timeout")
	if MP.has_multiplayer_authority(self):
		queue_free()
