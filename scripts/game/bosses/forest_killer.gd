extends Node2D


onready var mob : Mob = $mob_fk
onready var anim = $anim
onready var beartrap_points = $beartrap_points
onready var axe_points = $axe_points
var boss_bar : TextureProgress
var boss_hp : Label
var player : Player
var is_attacking = false
var waiting_for_death = false
var death_timer = 0
var is_cutscene = false
var attack_timer = 0
var next_attack_time = 1
var attacks = ["beartraps", "spikes", "charge_axe", "axe_sides", "axe_throw", "axe_throw"]
var beartrap = load("res://prefabs/bosses/boss_beartrap.scn")
var axe = load("res://prefabs/bosses/axe_throw.scn")
var player_target = null
onready var ms : MultiplayerSynchronizer = $MultiplayerSynchronizer


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
	boss_bar.get_node("boss_name").text = "ЛЕСОРУБ" + ":"
	boss_hp = boss_bar.get_node("hp_count")
	boss_hp.text = str(mob.current_health) + "/" + str(mob.max_health)
	boss_bar.max_value = mob.max_health
	boss_bar.value = mob.current_health


func start_fight():
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.default_camera_zoom, Vector2(0.6, 0.6), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.6, 0.6)
	boss_bar.show()
	var tilemap = $"../../tilemap"
	for i in range(-30, 0):
		tilemap.set_cell(57, i, 5)
	for i in range(-30, 0):
		tilemap.set_cell(71, i, 5, true)
	move_player_to_start()
	if MP.is_active:
		rpc("move_player_to_start")
	$"../../music".play()
	$"../../tint/anim".play("boss_name_appear")
	yield($"../../tint/anim", "animation_finished")
	is_attacking = true
	mob.defense = 0


remote func move_player_to_start():
	player.global_position = $"../../tilemap".map_to_world(Vector2(58, -2)) + Vector2.ONE * 16


func _process(delta):
	if is_attacking and player != null:
		process_attack(delta)
	if waiting_for_death:
		death_timer += delta
		if death_timer >= 5:
			waiting_for_death = false
			player.make_dialog("Лесоруб: Чего??? Ну и ладно.", 3)
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
	var tilemap = $"../../tilemap"
	for i in range(-30, 0):
		tilemap.set_cell(71, i, -1, true)
	set_cutscene(true)
	anim.play("death")
	yield(anim, "animation_finished")
	set_cutscene(false)
	if G.getv("boss_" + G.current_level + "_killed", false):
		anim.play("final_death")
	else:
		player.make_dialog("Лесоруб: Что смотришь? Добей уже!\n (убить или пощадить?)", 5)
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
		next_attack_time = rand_range(0.75, 2)
		var targ_dist = global_position.distance_to(mob.player.global_position)
		if targ_dist < 75:
			melee_attack()
			return
		else:
			attacks.shuffle()
			call(attacks[0])


func melee_attack():
	ms.sync_call(self, "melee_attack")
	anim.play("attack")


func beartraps():
	if not MP.auth(self):
		return
	next_attack_time += 1
	var points = [randi() % 7]
	while points.size() < 1:
		var num = randi() % 7
		if num in points:
			continue
		points.append(num)
	for i in points:
		var point = beartrap_points.get_node("pos" + str(i))
		point.get_node("sprite").show()
		yield(get_tree().create_timer(1, false), "timeout")
		point.get_node("sprite").hide()
		var b = beartrap.instance()
		b.global_position = point.global_position
		get_tree().current_scene.add_child(b, true)


func spikes():
	ms.sync_call(self, "spikes")
	next_attack_time += 1.5
	anim.play("spikes")


func charge_axe():
	ms.sync_call(self, "charge_axe")
	next_attack_time += 3.75
	anim.play("attack_charge")


func axe_sides():
	ms.sync_call(self, "axe_sides")
	next_attack_time += 2
	anim.play("attack_sides")


func axe_throw():
	ms.sync_call(self, "axe_throw")
	next_attack_time += 3
	anim.play("axe_throw")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(1, false), "timeout")
	var ids = [0, 1, 2, 3, 4]
	ids.shuffle()
	ids = ids.slice(0, 2)
	for i in ids:
		var point = axe_points.get_node("pos" + str(i))
		point.get_node("sprite").show()
		yield(get_tree().create_timer(0.8, false), "timeout")
		point.get_node("sprite").hide()
		var n = axe.instance()
		n.global_position = point.global_position
		get_tree().current_scene.add_child(n, true)
