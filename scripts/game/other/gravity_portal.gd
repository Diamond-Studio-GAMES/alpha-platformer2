extends Area2D


export (int) var GRAVITY = -1


func body_entered(body):
	if not body is Entity:
		return
	if body.GRAVITY_SCALE != GRAVITY:
		$anim.play("change_gravity")
		$anim.seek(0, true)
	body.GRAVITY_SCALE = GRAVITY
