extends Boss


var phases_attacks = {
	1 : ["lgbt", "throw"],
	2 : ["lgbt", "throw", "floor_attack"],
	3 : ["lgbt", "throw", "floor_attack", "two_strikes"],
}
var current_blue = false
var aims = []
var floor_attack_scene = load("res://prefabs/bosses/floor_attack.tscn")
var scythe = load("res://prefabs/bosses/lgbt_scythe.tscn")
var redball = load("res://prefabs/bosses/redball.tscn")
var aim = load("res://prefabs/bosses/aim.tscn")
onready var timer = $timer


func _ready():
	mob = $mob_rk
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
	G.ach.complete(Achievements.BOSS7)
	.death()


func get_phase():
	if not is_instance_valid(mob):
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
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
		melee_attack()
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func lgbt(count = 0):
	if MP.auth(self):
		count = randi() % 2 + get_phase()
	ms.sync_call(self, "lgbt", [count])
	next_attack_time += 0.5 + 1.4 * count
	anim.play("lgbt_start")
	if not can_mob_move():
		anim.play("idle", 0.3)
		return
	for i in range(count):
		if MP.auth(self):
			current_blue = randi() % 2 == 0
			set_attack_color(Color.cyan if current_blue else Color.orange)
		anim.play("lgbt_throw", 0.2)
		anim.seek(0, true)
		yield(get_tree().create_timer(1.4, false), "timeout")
		if not is_mob_alive():
			return
		if not can_mob_move():
			anim.play("idle", 0.3)
			return
	anim.play("idle", 0.3)


func summon_scythe():
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	var sc = scythe.instance()
	sc.get_node("scythe").modulate = Color.cyan if current_blue else Color.orange
	sc.get_node("scythe/trail_point").modulate = Color.cyan if current_blue else Color.orange
	sc.get_node("attack").damage_mode = int(not current_blue)
	sc.global_position = $visual/body/arm_right/hand/weapon2.global_position
	get_parent().add_child(sc)


func set_attack_color(color):
	ms.sync_call(self, "set_attack_color", [color])
	$visual/body/arm_right/hand/weapon2.self_modulate = color


func throw(count = 0):
	if MP.auth(self):
		count = randi() % 2 + get_phase()
	ms.sync_call(self, "throw", [count])
	next_attack_time += 0.7 * count
	for i in count:
		if not can_mob_move():
			if MP.auth(self):
				for j in aims:
					clear_aim(j)
			return
		if MP.auth(self):
			var n = aim.instance()
			n.global_position = player_target.global_position + Vector2.RIGHT * \
					(randi() % 96 - 72) + Vector2.UP * (randi() % 32)
			get_parent().add_child(n, true)
			aims.append(n)
		yield(get_tree().create_timer(0.2, false), "timeout")
	
	for i in count:
		anim.play("throw", 0.2)
		anim.seek(0, true)
		yield(get_tree().create_timer(0.5, false), "timeout")
		if not can_mob_move():
			for j in aims:
				clear_aim(j)
			anim.play("idle", 0.3)
			return
	anim.play("idle", 0.3)


func clear_aim(n):
	var path = n.get_path()
	aims.erase(n)
	do_clear_aim(path)


func do_clear_aim(path_to):
	ms.sync_call(self, "do_clear_aim", [path_to])
	get_node(path_to).get_node("anim").play("end")


func do_throw():
	if not MP.auth(self):
		return
	var curr_aim = aims[0]
	clear_aim(curr_aim)
	var rb = redball.instance()
	rb.global_position = $visual/body/arm_right/hand/weapon/shoot_effect.global_position
	rb.angle = $visual/body/arm_right/hand/weapon/shoot_effect.global_position.direction_to(curr_aim.global_position)
	get_parent().add_child(rb, true)


func two_strikes():
	next_attack_time += 5.5
	ms.sync_call(self, "two_strikes")
	anim.play("two_side")
	yield(get_tree().create_timer(3.1, false), "timeout")
	if not can_mob_move():
		return
	anim.play("two_side_second")


func floor_attack():
	next_attack_time += 1.5
	ms.sync_call(self, "floor_attack")
	anim.play("floor_attack")


func melee_attack():
	ms.sync_call(self, "melee_attack")
	anim.play("attack")
	next_attack_time += 0.5


func do_floor_attack():
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	var fa = floor_attack_scene.instance()
	add_child(fa, true)
	fa.global_position = $floor_attack_spawn_pos.global_position
