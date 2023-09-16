extends Area2D


var damaged_count = 0
var ended = false


func _ready():
	damaged_count = G.getv("damaged")


func end_level(l):
	if ended:
		return
	if not l is Player:
		return
	var my_player = get_node("../player" + str(get_tree().get_network_unique_id()) if MP.is_active else "../player")
	ended = true
	$anim.play("end")
	$sfx.play()
	if MP.is_active:
		$"/root/mg".state = 3
	if MP.is_active and my_player.current_health <= 0:
		G.ach.complete(Achievements.SCREW_IT)
	elif my_player.current_health <= my_player.max_health * 0.1:
		G.ach.complete(Achievements.ON_THE_EDGE)
	if damaged_count == G.getv("damaged"):
		G.ach.complete(Achievements.UNTOUCHED)
	yield(get_tree().create_timer(2, false), "timeout")
	if get_tree().is_network_server():
		yield(get_tree().create_timer(0.5, false), "timeout")
	G.addv("levels_completed", 1)
	if MP.is_active:
		G.addv("mp_levels", 1)
		G.ach.complete(Achievements.BETTER_TOGETHER)
		MP.close_network()
	else:
		if my_player.current_health <= 0:
			G.ach.complete(Achievements.WHAT_A_WASTE)
	get_tree().change_scene("res://scenes/menu/win.tscn")
