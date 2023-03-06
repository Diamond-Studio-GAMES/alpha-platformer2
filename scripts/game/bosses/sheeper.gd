extends Boss


onready var mob : Mob = $mob_sh
onready var anim = $anim
var boss_bar : TextureProgress
var boss_hp : Label
var player : Player
var is_attacking = false
var waiting_for_death = false
var death_timer = 0
var is_cutscene = false
var attack_timer = 0
var next_attack_time = 1
var attacks = ["knives", "spikes", "throw"]
var knives_attack = load("res://prefabs/bosses/knife_attack_sheeper.scn")
var big_knife_attack = load("res://prefabs/bosses/knife_sheeper_big.scn")
var sheep_bomb = load("res://prefabs/bosses/sheep_bomb.scn")
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
	boss_bar.get_node("boss_name").text = "ПАСТУХ" + ":"
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
			player.make_dialog("Пастух: Ты... щадишь меня?.. Спасибо...", 3)
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
		player.make_dialog("Убить или пощадить?", 5)
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
		next_attack_time = rand_range(3, 5)
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
	yield(get_tree().create_timer(0.4, false), "timeout")
	$visual/body/knife_attack/swing.play()
	$visual/body/knife_attack/visual.show()
	$visual/body/knife_attack/visual.frame = 0
	$visual/body/knife_attack/visual.play("attack")
	$visual/body/knife_attack/shape.disabled = false
	yield(get_tree().create_timer(0.2, false), "timeout")
	$visual/body/knife_attack/shape.disabled = true


func knives():
	ms.sync_call(self, "knives")
	anim.play("knives_summon")


func knives_spawn():
	if not MP.auth(self):
		return
	var n = knives_attack.instance()
	n.global_position = $knife_attack_pos.global_position
	$"../..".add_child(n)


func spikes():
	ms.sync_call(self, "spikes")
	anim.play("spikes_attack")


func throw():
	ms.sync_call(self, "throw")
	anim.play("big_knife")


func big_knife_launch():
	if not MP.auth(self):
		return
	var chance = randi() % 2
	if chance == 0:
		sheep_bombs_launch()
		return
	var n = big_knife_attack.instance()
	n.global_position = $visual/body/arm_left/hand/end.global_position
	$"../..".add_child(n, true)
	n.look_at(player_target.global_position)


func sheep_bombs_launch():
	for i in range(3):
		var n = sheep_bomb.instance()
		n.global_position = $visual/body/arm_left/hand/end.global_position
		n.player = player_target
		$"../..".add_child(n, true)


