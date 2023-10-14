extends Boss


var phases_attacks = {
	1 : ["lgbt", "throw"],
	2 : ["lgbt", "throw", "floor_attack"],
	3 : ["lgbt", "throw", "floor_attack", "two_strikes"],
}
onready var timer = $timer


func _ready():
	mob = $mob_rk
	fill_x = 54
	fill_height = 0
	tp_pos = Vector2(55, 2)
	mercy_dialog = tr("boss.king.mercy")
	death_dialog = tr("boss.king.defeat")
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.king").to_upper() + ":"


func death():
	G.ach.complete(Achievements.BOSS6)
	.death()


func get_phase():
	if not is_instance_valid(mob):
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left < 0.33:
		return 3
	elif health_left < 0.67:
		return 2
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	var targ_dist = global_position.distance_squared_to(player_target.global_position)
	if targ_dist < 5625:
		if phase < 3:
			melee_attack()
			return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func lgbt(count = 0):
	if MP.auth(self):
		count = randi() % 2 + get_phase()
	ms.sync_call(self, "lgbt", [count])


func throw():
	ms.sync_call(self, "throw")


func two_strikes():
	next_attack_time += 5.5
	ms.sync_call(self, "two_strikes")
	anim.play("two_side")
	yield(get_tree().create_timer(3.1, false), "timeout")
	if not can_mob_move():
		return
	anim.play("two_side_second")


func floor_attack():
	ms.sync_call(self, "floor_attack")


func melee_attack():
	ms.sync_call(self, "floor_attack")
	anim.play("attack")
	next_attack_time += 0.5
