extends Boss


var phases_attacks = {
	1 : ["bullets", "super_floor", "melee"],
	2 : ["laser", "bullets", "super_floor", "tnt", "melee"],
	3 : ["laser", "bullets", "super_floor", "tnt", "melee"]
}
var defeat_phrases = [
	tr("9_10.boss.death.0"),
	tr("9_10.boss.death.1"),
	tr("9_10.boss.death.2"),
	tr("9_10.boss.death.3")
]
var face_defeated = load("res://textures/bosses/maxim/head_defeat.tres")
var face_mercy = load("res://textures/bosses/maxim/head_mercy.tres")
var greenball = load("res://prefabs/bosses/greenball.tscn")
var time_fast = load("res://prefabs/bosses/time_fast.tscn")
var blue_tnt = load("res://prefabs/bosses/blue_tnt.tscn")

onready var break_on_death = {
	$visual/body/controller : load("res://textures/bosses/maxim/controller_broken.tres"),
	$visual/body/arm_right/hand : load("res://textures/bosses/maxim/weapon_arm_broken.tres"),
	$visual/body/leg_left/foot : load("res://textures/bosses/maxim/weapon_leg_broken.tres"),
}
var is_time_faster = false
var time_fasting
var animation
var track_idx
var key_idx0
var key_idx1
onready var timer = $timer
onready var floor_attack = $"../floor_attack/anim"
onready var shoot = $visual/body/arm_right/hand/shoot
onready var ball_spawns = [
	$visual/body/arm_right/hand/ball_spawn2,
	$visual/body/arm_right/hand/ball_spawn3,
	$visual/body/arm_right/hand/ball_spawn4,
]


func _ready():
	animation = anim.get_animation("bullets")
	track_idx = animation.find_track(@"visual/body/arm_right:rotation_degrees")
	key_idx0 = animation.track_find_key(track_idx, 0.4)
	key_idx1 = animation.track_find_key(track_idx, 1)
	mob = $mob_mx
	mercy_dialog = tr("boss.follower2.mercy")
	death_dialog = tr("boss.follower2.defeat")
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.follower2").to_upper() + ":"
	player.connect("died", self, "death_dialog")


remote func stop_fast_time():
	is_time_faster = false
	Engine.time_scale = 1
	time_fasting.get_node("anim").seek(13.2, true)


func death_dialog():
	if is_time_faster:
		var has_alive = false
		if MP.is_active:
			for i in get_tree().get_nodes_in_group("player"):
				if i.current_health > 0:
					has_alive = true
		if not has_alive:
			stop_fast_time()
			if MP.is_active:
				rpc("stop_fast_time")
	player.make_dialog(defeat_phrases.pick_random(), 3, Color.red)


func death():
	G.ach.complete(Achievements.BOSS9)
	$visual/body/head.texture = face_defeated
	for i in break_on_death:
		i.texture = break_on_death[i]
	if is_time_faster:
		stop_fast_time()
	.death()


func mercy():
	$visual/body/head.texture = face_mercy
	.mercy()


func get_phase():
	if not is_mob_alive():
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
	elif health_left < 0.3:
		next_attack_time_min = 0.6
		next_attack_time_max = 1.2
		return 3
	elif health_left < 0.6:
		next_attack_time_min = 0.8
		next_attack_time_max = 1.6
		return 2
	next_attack_time_min = 0.9
	next_attack_time_max = 1.8
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	if phase > 2:
		var new_variants = phases_attacks[phase].duplicate()
		if not is_time_faster:
			new_variants.append("time_fast")
			new_variants.append("time_fast")
		new_variants.shuffle()
		call(new_variants[0])
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func bullets():
	next_attack_time += 1.3
	ms.sync_call(self, "bullets")
	var direction = (global_position + Vector2.UP * 32).direction_to(player_target.global_position)
	var angle = rad2deg(direction.angle_to(Vector2.DOWN))
	animation.track_set_key_value(track_idx, key_idx0, angle)
	animation.track_set_key_value(track_idx, key_idx1, angle)
	anim.play("bullets")
	yield(get_tree().create_timer(0.6, false), "timeout")
	if not can_mob_move():
		return
	shoot.restart()
	if not MP.auth(self):
		return
	for i in ball_spawns:
		var gb = greenball.instance()
		gb.global_position = i.global_position
		gb.rotation = direction.angle()
		get_tree().current_scene.add_child(gb, true)


func laser(id = 0):
	if MP.auth(self):
		id = randi() % 2
		ms.sync_call(self, "laser", [id])
	anim.play("laser" + str(id))
	next_attack_time += 2.6


func super_floor(orange = false):
	if MP.auth(self):
		orange = randi() % 2 == 1
		ms.sync_call(self, "super_floor", [orange])
	next_attack_time += 4
	anim.play("floor_attack")
	yield(get_tree().create_timer(1.3, false), "timeout")
	if not can_mob_move():
		return
	if orange:
		floor_attack.play("attack_orange")
	else:
		floor_attack.play("attack_blue")


func tnt():
	next_attack_time += 2
	ms.sync_call(self, "tnt")
	anim.play("tnt")
	yield(get_tree().create_timer(0.7, false), "timeout")
	if not can_mob_move() or not MP.auth(self):
		return
	shoot.restart()
	var tnt = blue_tnt.instance()
	tnt.global_position = shoot.global_position
	tnt.velocity = Vector2(rand_range(-160, -32), rand_range(-250, 0))
	get_tree().current_scene.add_child(tnt, true)


func melee():
	next_attack_time += 1.6
	ms.sync_call(self, "melee")
	anim.play("kick")
	yield(get_tree().create_timer(0.55, false), "timeout")
	if not can_mob_move():
		return
	var to_pos = Vector2()
	to_pos.x = min(player_target.global_position.x - global_position.x + 34, 0)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($visual, "position", to_pos, 0.25).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mob, "position", to_pos, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.75)
	tween.tween_property($visual, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(mob, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_OUT)


func time_fast():
	next_attack_time += 2
	ms.sync_call(self, "time_fast")
	anim.play("time_fast")
	yield(get_tree().create_timer(0.6, false), "timeout")
	if not can_mob_move():
		return
	var tf = time_fast.instance()
	get_tree().current_scene.add_child(tf)
	time_fasting = tf
	yield(get_tree().create_timer(1.3, false), "timeout")
	Engine.time_scale = 1.5
	is_time_faster = true
	yield(get_tree().create_timer(12, false), "timeout")
	Engine.time_scale = 1
	is_time_faster = false
