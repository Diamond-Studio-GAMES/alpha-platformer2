extends Node2D


const OFFSET_X = 160
const OFFSET_Y = 128
onready var mob : Mob = $mob_gk
onready var anim = $anim
onready var timer = $swipe_timer
var boss_bar : TextureProgress
var boss_hp : Label
var player : Player
var is_attacking = false
var waiting_for_death = false
var death_timer = 0
var is_cutscene = false
var attack_timer = 0
var next_attack_time = 1
var swords_down_poses = []
var attacks = ["crack", "swipes", "throw", "swords_down"]
var player_target = null
var swipe_effect = load("res://prefabs/bosses/sword_swipe.scn")
var sword_throw = load("res://prefabs/bosses/sword_throw.scn")
var sword_down_attack = load("res://prefabs/bosses/sword_down_attack.scn")

onready var ms = $MultiplayerSynchronizer


func set_cutscene(val):
	if not is_instance_valid(player):
		return
	player.can_move = not val
	is_cutscene = val


func _ready():
	randomize()
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	player = get_tree().current_scene.get_node("player"+(str(get_tree().get_network_unique_id()) if MP.is_active else ""))
	boss_bar = player.get_boss_bar()
	boss_bar.get_node("boss_name").text = "ВЕЛИКИЙ РЫЦАРЬ" + ":"
	boss_hp = boss_bar.get_node("hp_count")
	boss_hp.text = str(mob.current_health) + "/" + str(mob.max_health)
	boss_bar.max_value = mob.max_health
	boss_bar.value = mob.current_health
	for i in $swords_spawn_points.get_children():
		swords_down_poses.append(i.global_position)


func start_fight():
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.default_camera_zoom, Vector2(0.6, 0.6), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.6, 0.6)
	boss_bar.show()
	var tilemap = $"../../tilemap"
	for i in range(-30, 0):
		tilemap.set_cell(53, i, 5)
	move_player_to_start()
	if MP.is_active:
		rpc("move_player_to_start")
	$"../../music".play()
	$"../../tint/anim".play("boss_name_appear")
	yield($"../../tint/anim", "animation_finished")
	is_attacking = true
	mob.defense = 0


remote func move_player_to_start():
	player.global_position = $"../../tilemap".map_to_world(Vector2(54, -2)) + Vector2.ONE * 16


func _process(delta):
	if is_attacking and player != null:
		process_attack(delta)
	if waiting_for_death:
		death_timer += delta
		if death_timer >= 5:
			waiting_for_death = false
			player.make_dialog("Великий рыцарь: Ты спасёшь всех, %s!" % G.getv("name", ""), 3)
			anim.play("mercy")
			set_cutscene(true)
			yield(anim, "animation_finished")
			set_cutscene(false)
	if player != null:
		if is_cutscene:
			player.can_move = false
	if boss_bar == null:
		return
	if mob == null:
		return
	if not is_instance_valid(mob):
		boss_bar.hide()
		return
	if mob.is_queued_for_deletion():
		boss_bar.hide()
		return
	boss_hp.text = str(mob.current_health) + "/" + str(mob.max_health)
	boss_bar.value = mob.current_health


func get_hit(area):
	if waiting_for_death:
		if not MP.auth(area):
			return
		waiting_for_death = false
		anim.play("final_death")
		G.setv("boss_" + G.current_level + "_killed", true)


func death():
	$"../../music".stop()
	player.get_node("camera_tween").stop_all()
	player.get_node("camera_tween").remove_all()
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.get_node("camera").zoom, Vector2(0.3, 0.3), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.3, 0.3)
	is_attacking = false
	set_cutscene(true)
	anim.play("death")
	yield(anim, "animation_finished")
	set_cutscene(false)
	if G.getv("boss_" + G.current_level + "_killed", false):
		anim.play("final_death")
	else:
		player.make_dialog("Великий рыцарь: Ну иди...\n (убить или пощадить?)", 5)
		waiting_for_death = true


func process_attack(delta):
	if mob.is_stunned:
		return
	if not MP.auth(self):
		return
	attack_timer += delta
	if attack_timer >= next_attack_time:
		mob.find_target()
		if mob.player == null:
			return
		player_target = mob.player
		attack_timer = 0
		next_attack_time = rand_range(1, 2)
		if global_position.distance_to(mob.player.global_position) < 80:
			melee()
		else:
			attacks.shuffle()
			call(attacks[0])


func melee():
	ms.sync_call(self, "melee")
	anim.play("attack")
	next_attack_time += 0.6


func crack():
	ms.sync_call(self, "crack")
	anim.play("crack")
	next_attack_time += 1.3


func swipes():
	ms.sync_call(self, "swipes")
	next_attack_time += 1.6
	var is_angry = mob.current_health < mob.max_health * 0.5
	if is_angry:
		next_attack_time += 0.4
	var player_pos = mob.player.global_position
	create_swipe(player_pos)
	timer.start(0.15)
	yield(timer, "timeout")
	if is_angry:
		anim.play("swipes_angry")
	else:
		anim.play("swipes")
	timer.start(0.3)
	yield(timer, "timeout")
	create_swipe(player_pos)
	timer.start(0.45)
	yield(timer, "timeout")
	create_swipe(player_pos)
	if not is_angry:
		return
	timer.start(0.45)
	yield(timer, "timeout")
	create_swipe(player_pos)
	timer.start(0.45)
	yield(timer, "timeout")
	create_swipe(player_pos)


func create_swipe(player_position):
	if not MP.auth(self):
		return
	randomize()
	var node = swipe_effect.instance()
	node.global_position = Vector2(rand_range(player_position.x - OFFSET_X, player_position.x + OFFSET_X), rand_range(player_position.y - OFFSET_Y, player_position.y + OFFSET_Y))
	node.rotation_degrees = rand_range(0, 360)
	$"../..".add_child(node, true)


func throw():
	ms.sync_call(self, "throw")
	anim.play("throw")
	next_attack_time += 1.2
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.6, false), "timeout")
	var node = sword_throw.instance()
	node.global_position = $visual/body/arm_right/hand/weapon/shoot.global_position
	$"../..".add_child(node, true)
	node.look_at(mob.player.global_position)


func swords_down():
	ms.sync_call(self, "swords_down")
	anim.play("swords_down")
	next_attack_time += 2
	if not MP.auth(self):
		return
	var is_angry = mob.current_health < mob.max_health * 0.5
	yield(get_tree().create_timer(0.6, false), "timeout")
	randomize()
	swords_down_poses.shuffle()
	for i in range(10 if is_angry else 7):
		var attack = sword_down_attack.instance()
		attack.global_position = swords_down_poses[i]
		$"../..".add_child(attack)
