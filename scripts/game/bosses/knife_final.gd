extends Node2D


var part = load("res://prefabs/bosses/part.tscn")

func _on_projectile_destroyed(position):
	if not MP.auth(self):
		return
	yield(get_tree(), "idle_frame")
	$sfx.play()
	for i in range(3):
		var p = part.instance()
		p.position = to_local(position)
		p.velocity = Vector2(rand_range(-128, 128), rand_range(-80, -250))
		add_child(p, true)
	yield(get_tree().create_timer(4.0, false), "timeout")
	queue_free()
