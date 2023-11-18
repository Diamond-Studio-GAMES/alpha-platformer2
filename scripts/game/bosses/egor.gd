extends Boss


var phases_attacks = {
	1 : ["balls", "big_ball", "floor_attack"],
	2 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls"],
	3 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls"]
}
var defeat_phrases = [tr("8_10.boss.death.0"), tr("8_10.boss.death.1"), tr("8_10.boss.death.2")]
var face_defeated = load("res://textures/bosses/egor/head_defeat.tres")
var face_mercy = load("res://textures/bosses/egor/head_mercy.tres")
var ball = load("res://prefabs/bosses/whiteball.tscn")
var big_ball = load("res://prefabs/bosses/big_whiteball.tscn")
var fall_ball = load("res://prefabs/bosses/falling_ball.tscn")
var circle_ball = load("res://prefabs/bosses/circle_whiteball.tscn")
var time_erase = load("res://prefabs/bosses/time_erase.tscn")
var is_time_erased = false
onready var timer = $timer
onready var pos0 = $pos0.global_position
onready var pos1 = $pos1.global_position
onready var pos2 = $pos2.global_position
onready var fall_balls_y = $fall_balls_poses.global_position.y


func _ready():
	mob = $mob_eg
	fill_x = 53
	fill_height = 16
	tp_pos = Vector2(54, -2)
	mercy_dialog = tr("boss.follower1.mercy")
	death_dialog = tr("boss.follower1.defeat")
	next_attack_time_min = 0.8
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.follower1").to_upper() + ":"
	player.connect("died", self, "death_dialog")


func night():
	get_tree().current_scene.get_node("background_first").hide()
	get_tree().current_scene.get_node("background").show()
	get_tree().current_scene.get_node("dark").show()


func death_dialog():
	player.make_dialog(defeat_phrases.pick_random(), 3, Color.cyan)


func death():
	G.ach.complete(Achievements.BOSS8)
	$visual/body/head.texture = face_defeated
	.death()


func mercy():
	$visual/body/head.texture = face_mercy
	.mercy()


func get_phase():
	if not is_instance_valid(mob):
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
	elif health_left < 0.33:
		next_attack_time_min = 0.65
		next_attack_time_max = 1.5
		return 3
	elif health_left < 0.67:
		next_attack_time_min = 0.8
		next_attack_time_max = 1.8
		return 2
	next_attack_time_min = 1
	next_attack_time_max = 2
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	if phase > 2:
		var new_variants = phases_attacks[phase].duplicate()
		if not is_time_erased:
			new_variants.append("time_erase")
		new_variants.shuffle()
		call(new_variants[0])
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func balls():
	next_attack_time += 1
	ms.sync_call(self, "balls")
	anim.play("balls")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.6, false), "timeout")
	if not can_mob_move():
		return
	_create_ball_at(pos2)
	yield(get_tree().create_timer(0.1, false), "timeout")
	_create_ball_at(pos0)
	yield(get_tree().create_timer(0.1, false), "timeout")
	_create_ball_at(pos1)


func _create_ball_at(pos):
	var n = ball.instance()
	n.global_position = pos
	n.rotation = pos.direction_to(player_target.global_position).angle() + rand_range(-0.314, 0.314)
	get_parent().add_child(n, true)


func big_ball():
	next_attack_time += 0.8
	ms.sync_call(self, "ball")
	anim.play("ball")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.3, false), "timeout")
	if not can_mob_move():
		return
	var n = big_ball.instance()
	n.global_position = pos1
	n.target = player_target
	get_parent().add_child(n, true)


func circle_balls():
	next_attack_time += 3.5
	ms.sync_call(self, "circle_balls")
	anim.play("circle_balls")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.5, false), "timeout")
	if not can_mob_move():
		return
	var R = 128
	var delays = range(1, 5)
	delays.shuffle()
	for i in delays.size():
		delays[i] /= 1.5
	var player_pos = player_target.global_position
	player_pos.y = -16
	var step = PI / 3
	for i in 4:
		var n = circle_ball.instance()
		n.delay = delays[i]
		n.global_position = player_pos + Vector2.LEFT.rotated(step * i) * R
		n.rotation = step * i
		get_parent().add_child(n, true)
		yield(get_tree().create_timer(0.125, false), "timeout")


func floor_attack():
	next_attack_time += 0.7
	ms.sync_call(self, "floor_attack")
	anim.play("floor")
	yield(get_tree().create_timer(0.7, false), "timeout")
	if can_mob_move():
		$floor_attack/anim.play("attack")


func up_balls():
	next_attack_time += 2
	ms.sync_call(self, "up_balls")
	anim.play("falling_balls")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.7, false), "timeout")
	var poses = $fall_balls_poses.get_children()
	poses.shuffle()
	for i in randi() % 3 + get_phase():
		var n = fall_ball.instance()
		n.global_position = Vector2(poses[i].global_position.x, fall_balls_y)
		get_parent().add_child(n, true)
		yield(get_tree().create_timer(0.3, false), "timeout")


func time_erase():
	next_attack_time += 1
	ms.sync_call(self, "time_erase")
	anim.play("idle") #ADD ANIM AND VOICE
	var te = time_erase.instance()
	get_tree().current_scene.add_child(te)
	is_time_erased = true
	player._is_ultiing = true
	set_cutscene(true)
	yield(get_tree().create_timer(2, false), "timeout")
	Engine.time_scale = 3
	next_attack_time_min = 0.5
	next_attack_time_max = 1
	var sfx_bus_idx = AudioServer.get_bus_index("sfx")
	AudioServer.set_bus_mute(sfx_bus_idx, true)
	yield(get_tree().create_timer(3, false), "timeout")
	player._health_timer = 0
	yield(get_tree().create_timer(3, false), "timeout")
	Engine.time_scale = 1
	AudioServer.set_bus_mute(sfx_bus_idx, false)
	yield(get_tree().create_timer(1, false), "timeout")
	next_attack_time_min = 0.65
	next_attack_time_max = 1.5
	player._is_ultiing = false
	is_time_erased = false
	set_cutscene(false)
