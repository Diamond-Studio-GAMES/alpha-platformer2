extends Area2D


export (int) var heal_amount = 10


func _on_heal_body_entered(body):
	if body is ShooterPlayer:
		if MP.has_multiplayer_authority(body):
			body.hp = clamp(body.hp + heal_amount, 0, body.max_hp)
			queue_free()
