extends Area2D


export (bool) var is_orb = false
export (float) var power = 400


func entered(b):
	if not b is Dasher:
		return
	if is_orb:
		b.is_on_orb = true
	else:
		b.jump(power)


func exited(b):
	if not b is Dasher:
		return
	if is_orb:
		b.is_on_orb = false
