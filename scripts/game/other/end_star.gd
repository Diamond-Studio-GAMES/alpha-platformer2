extends Area2D


var damaged_count = 0
var kills_count = 0
var boss_kills_count = 0
var ended = false


func _ready():
	damaged_count = G.getv("damaged")
	kills_count = G.getv("kills")
	boss_kills_count = G.getv("boss_kills")
	var mob_count = 0
	for i in $"../mobs".get_children():
		if i is Mob or i is Boss:
			mob_count += 1
	if mob_count == 0:
		damaged_count = -1
		kills_count = -1


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
	if kills_count == G.getv("kills") and boss_kills_count == G.getv("boss_kills"):
		G.ach.complete(Achievements.PACIFIST)
	yield(get_tree().create_timer(2, false), "timeout")
	if get_tree().is_network_server():
		yield(get_tree().create_timer(0.5, false), "timeout")
	G.addv("levels_completed", 1)
	if MP.is_active:
		G.cached_multiplayer_role = G.MultiplayerRole.SERVER if get_tree().is_network_server() \
				else G.MultiplayerRole.CLIENT
		G.addv("mp_levels", 1)
		G.ach.complete(Achievements.BETTER_TOGETHER)
		MP.close_network()
	else:
		if my_player.current_health <= 0:
			G.ach.complete(Achievements.WHAT_A_WASTE)
	get_tree().change_scene("res://scenes/menu/win.tscn")
