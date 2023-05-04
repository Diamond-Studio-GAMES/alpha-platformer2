extends Node2D


func rocket_exploded(body, id):
	if body is Player:
		return
	get_node("rockets_attack/rocket" + str(id) + "/sprite/anim").play("blast")
