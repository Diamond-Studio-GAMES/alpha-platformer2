extends Boss


const SOUL_TRAITS = {
	6 : "trait.det",
	0 : "trait.bra",
	1 : "trait.jus",
	2 : "trait.kin",
	3 : "trait.pat",
	4 : "trait.int",
	5 : "trait.per",
}
var phases_attacks = {
	1 : ["sword", "shield", "knife"],
	2 : ["sword", "shield", "knife", "big_ball"],
	3 : ["sword", "shield", "knife", "big_ball"]
}
export(Array, Vector2) var phases_points = []
export(Array, PackedScene) var mobs_to_spawn = []
var defeat_phrases = [tr("10_10.boss.death.0"), tr("10_10.boss.death.1")]
var is_time_stopped = false
var time_stopped_attacks = 0
var is_soul_free = false
var is_shield_up = false
var current_phase = 1
var immune_timer = -1
var mobs_idxs = []
var alive_mobs = []
var face_defeated = load("res://textures/bosses/gleb/head_defeat.tres")
var soul_mode = load("res://prefabs/bosses/soul_mode.tscn")
var soul_attack_eight = load("res://prefabs/bosses/soul_attack_eight.tscn")
var soul_attack_bullet = load("res://prefabs/bosses/soul_attack_bullet.tscn")
var soul_attack_area = load("res://prefabs/bosses/soul_attack_area.tscn")
var knife = load("res://prefabs/bosses/knife_final.tscn")
var ball = load("res://prefabs/bosses/big_redball.tscn")
onready var timer = $timer


func _ready():
	if not G.getv("boss_met", false) or G.getv("boss_started", false):
		$"../../decor/think_respawn".queue_free()
	if G.getv("boss_started", false):
		$"../../decor/think".text = tr("10_10.boss.start.again")
	G.setv("boss_met", true)
	
	mobs_idxs = range(mobs_to_spawn.size())
	mobs_idxs.shuffle()
	mob = $mob_gl
	death_dialog = ""
	mercy_dialog = ""
	var phrase = tr("10_10.boss.death.2")
	defeat_phrases.append(phrase % tr(SOUL_TRAITS[G.getv("soul_type", 6)]))
	if G.getv("hardcore", false):
		defeat_phrases.append(tr("10_10.boss.death.hdc"))
	else:
		defeat_phrases.append(tr("10_10.boss.death.det"))
	next_attack_time_min = 0.8
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.main").to_upper() + ":"
	player.connect("died", self, "death_dialog")


func _process(delta):
	if immune_timer < -0.5:
		return
	immune_timer -= delta
	if immune_timer < 0:
		mob.immune_counter -= 1
		mob.collision_layer = 0b101
		mob.collision_mask = 0b10011
		immune_timer = -1


func death_dialog():
	player.make_dialog(defeat_phrases.pick_random(), 3, Color.white)


func start_fight():
	G.setv("boss_started", true)
	.start_fight()


func death():
	G.ach.complete(Achievements.BOSS10)
	$visual/body/head.texture = face_defeated
	$"../../music".stop()
	var tilemap = $"../../tilemap"
	if create_left_barrier:
		for i in range(-barrier_left_height + barrier_left_start.y, barrier_left_start.y + 1):
			tilemap.set_cell(barrier_left_start.x, i, -1)
	player_border.queue_free()
	player.get_node("camera_tween").stop_all()
	player.get_node("camera_tween").remove_all()
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.get_node("camera").zoom, Vector2(0.4, 0.4), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.4, 0.4)
	is_attacking = false
	anim.play("idle")
	anim.advance(0)
	yield(get_tree(), "idle_frame")
	anim.play("death")
	G.addv("boss_kills", 1)
	G.addv("kills", -1)
	yield(anim, "animation_finished")
	anim.play("final_death")


func get_phase():
	if not is_mob_alive():
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
	elif health_left < 0.34:
		next_attack_time_min = 0.6
		next_attack_time_max = 1.4
		return 3
	elif health_left < 0.67:
		next_attack_time_min = 0.75
		next_attack_time_max = 1.6
		return 2
	next_attack_time_min = 0.9
	next_attack_time_max = 1.8
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	if is_soul_free:
		do_soul_attack()
		return
	if is_time_stopped:
		if time_stopped_attacks == 2:
			zero()
			return
		var vars = ["sword", "knife", "big_ball"]
		vars.shuffle()
		call(vars[0])
		time_stopped_attacks += 1
		return
	if phase != current_phase:
		switch_to_phase(phase)
		current_phase = phase
		return
	var attacks = phases_attacks[phase].duplicate()
	if alive_mobs.empty():
		if randi() % (4 - current_phase) == 0:
			attacks.append("enter_soul_mode")
		if phase == 3:
			attacks.append("stop_time")
	attacks.shuffle()
	call(attacks[0])


func switch_to_phase(phase):
	ms.sync_call(self, "switch_to_phase", [phase])
	next_attack_time += 1.5
	anim.play("phase%d" % phase)
	teleport_position = phases_points[phase - 2]
	yield(get_tree().create_timer(1.3, false), "timeout")
	move_player_to_start()
	if MP.auth(self):
		spawn_mob(mobs_idxs[(phase - 2) * 2], $spawn_mob_pos0.global_position)
		spawn_mob(mobs_idxs[1 + (phase - 2) * 2], $spawn_mob_pos1.global_position)
	attack_timer -= 15
	immune_timer = 15
	mob.immune_counter += 1
	mob.collision_layer = 0
	mob.collision_mask = 0b101


func spawn_mob(idx, position):
	ms.sync_call(self, "spawn_mob", [idx, position])
	var mob = mobs_to_spawn[idx].instance()
	mob.global_position = position
	mob.stats_multiplier = 5
	mob.get_node("MultiplayerSynchronizer").syncing = true
	get_parent().add_child(mob, true)
	alive_mobs.append(mob)
	mob.connect("died", self, "_on_mob_died", [mob])


func sword():
	ms.sync_call(self, "sword")
	next_attack_time += 2
	anim.play("sword")


func shield():
	ms.sync_call(self, "shield")
	next_attack_time += 2
	anim.play("shield")
	yield(get_tree().create_timer(0.3, false), "timeout")
	mob.immune_counter += 1
	is_shield_up = true
	yield(get_tree().create_timer(1.5, false), "timeout")
	if is_shield_up:
		is_shield_up = false
		mob.immune_counter -= 1


func knife():
	ms.sync_call(self, "knife")
	next_attack_time += 1.5
	anim.play("knife_throw")


func summon_knife():
	if not MP.auth(self):
		return
	var kf = knife.instance()
	kf.global_position = $visual/body/arm_right/hand/knife.global_position
	var direction = $visual/body/arm_right/hand/knife.global_position.direction_to(player_target.global_position)
	kf.get_node("projectile").rotation = direction.angle()
	get_tree().current_scene.add_child(kf, true)


func big_ball():
	ms.sync_call(self, "big_ball")
	next_attack_time += 1.4
	anim.play("ball")


func summon_ball():
	if not MP.auth(self):
		return
	var b = ball.instance()
	b.global_position = $visual/body/arm_left/hand/ball.global_position
	var direction = $visual/body/arm_left/hand/ball.global_position.direction_to(player_target.global_position + Vector2.UP * 32)
	b.rotation = direction.angle()
	get_tree().current_scene.add_child(b, true)


func stop_time():
	ms.sync_call(self, "stop_time")
	next_attack_time += 2.5
	anim.play("time_stop")
	mob.immune_counter += 1
	yield(get_tree().create_timer(1, false), "timeout")
	pause_mode = PAUSE_MODE_PROCESS
	get_tree().paused = true
	Physics2DServer.set_active(true)
	VisualServer.set_shader_time_scale(0)
	is_time_stopped = true
	time_stopped_attacks = 0


func zero():
	ms.sync_call(self, "zero")
	next_attack_time += 2
	$THEWORLD/anim.play("ZERO")
	yield(get_tree().create_timer(0.5), "timeout")
	pause_mode = PAUSE_MODE_INHERIT
	get_tree().paused = false
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(Engine, "time_scale", 1, 0.3).from(0.1)
	mob.immune_counter -= 1
	VisualServer.set_shader_time_scale(1)
	is_time_stopped = false


func enter_soul_mode():
	ms.sync_call(self, "enter_soul_mode")
	next_attack_time += 1
	anim.play("soul_mode")
	yield(get_tree().create_timer(0.5, false), "timeout")
	if not can_mob_move():
		return
	var sm = soul_mode.instance()
	sm.player = player
	sm.connect("soul_returned", self, "_on_soul_returned")
	add_child(sm)
	is_soul_free = true
	mob.immune_counter += 1


func do_soul_attack():
	ms.sync_call(self, "do_soul_attack")
	var attack_idx = randi() % current_phase + 1
	match attack_idx:
		1:
			for i in range(8):
				var sab = soul_attack_bullet.instance()
				$soul_mode.add_child(sab)
				sab.global_position = $soul_mode/soul.global_position
				sab.rotation = rand_range(-PI, PI)
		2:
			var list = range(4)
			list.shuffle()
			for i in 2:
				var saa = soul_attack_area.instance()
				$soul_mode.add_child(saa)
				saa.global_position = $soul_mode/soul_point.global_position - Vector2.RIGHT * \
						(120 - list[i] * 80)
		3:
			var sae = soul_attack_eight.instance()
			$soul_mode.add_child(sae)
			sae.global_position = $soul_mode/soul_point.global_position
			sae.global_position.x += rand_range(-128, 128)
			sae.global_position.y += rand_range(-64, 64)
			sae.rotation = rand_range(-PI, PI)


func parry():
	if is_shield_up:
		mob.immune_counter -= 1
	is_shield_up = false
	anim.play("shield_parry")


func _on_soul_returned():
	is_soul_free = false
	mob.immune_counter -= 1


func _on_mob_died(mob):
	alive_mobs.erase(mob)
	if alive_mobs.empty() and immune_timer > -0.5:
		immune_timer = -0.1


func _on_blocked_damage():
	if is_shield_up:
		parry()
