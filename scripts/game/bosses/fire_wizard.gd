extends Boss


func _ready():
	mob = $mob_fw
	fill_x = 53
	fill_height = 16
	tp_pos = Vector2(54, -2)
	attacks = ["fireball", "fireballs", "oil", "fire_rain"]
	mercy_dialog = "Огненный страж: Иди, ты достоин."
	death_dialog = "Огненный страж: Я... Выгорел?..\n (убить или пощадить?)"
	next_attack_time_min = 0.8
	next_attack_time_max = 1.6
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ХИРУРГ" + ":"


func death():
	G.ach.complete(Achievements.BOSS6)
	.death()


func do_attack():
	var targ_dist = global_position.distance_squared_to(mob.player.global_position)
	attacks.shuffle()
	call(attacks[0])


func fireballs():
	pass


func fireball():
	pass


func fire_rain():
	pass


func oil():
	pass
