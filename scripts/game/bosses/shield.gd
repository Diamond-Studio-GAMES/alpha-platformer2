extends Area2D


var rb = load("res://prefabs/bosses/rejected_bullet.scn")


func area_entered(area):
	if not MP.auth(self):
		return
	if area is Attack:
		if area.is_player_attack:
			if area.get_parent() is Throwable:
				var throw = area.get_parent()
				var node = rb.instance()
				node.global_position = area.global_position
				node.rotation = (-throw.angle).angle()
				node.get_node("attack").damage = area.damage
				yield(get_tree(), "idle_frame")
				get_tree().current_scene.add_child(node, true)
				throw.queue_free()
