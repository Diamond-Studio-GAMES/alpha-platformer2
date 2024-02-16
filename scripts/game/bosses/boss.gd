extends Node2D
class_name Boss


export (bool) var create_left_barrier = true
export (Vector2) var barrier_left_start = Vector2()
export (int) var barrier_left_height = 0
export (Vector2) var teleport_position = Vector2()
var mob: Mob
var boss_bar: TextureProgress
var boss_hp: Label
var player: Player
var is_attacking = false
var waiting_for_death = false
var is_cutscene = false
var death_timer = 0
var attack_timer = 0
var next_attack_time = 1
var next_attack_time_min = 1
var next_attack_time_max = 2
var attacks = []
var death_dialog = ""
var mercy_dialog = ""
var player_target = null
var hurt_part = load("res://prefabs/effects/hurt_part.tscn")
onready var anim = $anim
onready var player_border = $player_border
onready var ms := $MultiplayerSynchronizer as MultiplayerSynchronizer


func _ready():
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	player = get_tree().current_scene.get_node("player" + (str(get_tree().get_network_unique_id()) if MP.is_active else ""))
	boss_bar = player.get_boss_bar()
	boss_hp = boss_bar.get_node("hp_count")
	boss_hp.text = str(mob.current_health) + "/" + str(mob.max_health)
	boss_bar.max_value = mob.max_health
	boss_bar.value = mob.current_health
	mob.connect("hurt", self, "_on_mob_hurt")
	mob.connect("died", self, "_on_mob_hurt")
	mob.connect("healed", self, "_on_mob_healed")


func _process(delta):
	if is_attacking and player != null:
		process_attack(delta)
	if waiting_for_death:
		death_timer += delta
		if death_timer >= 10:
			mercy()
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


func set_cutscene(value):
	if not is_instance_valid(player):
		return
	if value:
		player.force_stop()
	player.can_control = not value
	is_cutscene = value


func start_fight():
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.default_camera_zoom, Vector2(0.6, 0.6), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.6, 0.6)
	boss_bar.show()
	var tilemap = $"../../tilemap"
	if create_left_barrier:
		for i in range(-barrier_left_height + barrier_left_start.y + 1, barrier_left_start.y + 1):
			tilemap.set_cell(barrier_left_start.x, i, 5)
	move_player_to_start()
	if MP.is_active:
		rpc("move_player_to_start")
	$"../../music".play()
	$"../../tint/anim".play("boss_name_appear")
	yield($"../../tint/anim", "animation_finished")
	is_attacking = true
	mob.defense = 0


remote func move_player_to_start():
	player.global_position = $"../../tilemap".map_to_world(teleport_position) + Vector2.ONE * 16


func get_hit(area):
	if waiting_for_death:
		if not MP.auth(area):
			return
		if not area is Attack:
			return
		if not area.is_player_attack:
			return
		waiting_for_death = false
		anim.play("final_death")
		G.setv("boss_" + G.current_level + "_killed", true)
		G.connect("hate_increased", player, "make_dialog", [tr("hate.up"), 5, Color.black])
		G.addv("kills", 1)
		yield(get_tree().create_timer(2, false), "timeout")
		G.calculate_hate_level()


func mercy():
	waiting_for_death = false
	player.make_dialog(mercy_dialog, 3)
	anim.play("mercy")
	set_cutscene(true)
	yield(anim, "animation_finished")
	set_cutscene(false)


func process_attack(delta):
	if not can_mob_move():
		return
	if not MP.auth(self):
		return
	attack_timer += delta
	if attack_timer >= next_attack_time:
		set_target()
		if player_target == null:
			return
		attack_timer = 0
		next_attack_time = rand_range(next_attack_time_min, next_attack_time_max)
		do_attack()


func set_target():
	ms.sync_call(self, "set_target")
	mob.find_target()
	player_target = mob.player


func do_attack():
	pass


func death():
	$"../../music".stop()
	var tilemap = $"../../tilemap"
	if create_left_barrier:
		for i in range(-barrier_left_height + barrier_left_start.y, barrier_left_start.y + 1):
			tilemap.set_cell(barrier_left_start.x, i, -1)
	player_border.queue_free()
	player.get_node("camera_tween").stop_all()
	player.get_node("camera_tween").remove_all()
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.get_node("camera").zoom, Vector2(0.3, 0.3), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.3, 0.3)
	is_attacking = false
	anim.play("idle")
	anim.advance(0)
	yield(get_tree(), "idle_frame")
	if anim.has_animation("RESET"):
		anim.play("RESET")
		anim.advance(0)
		yield(get_tree(), "idle_frame")
	anim.play("death")
	G.addv("boss_kills", 1)
	G.addv("kills", -1)
	yield(anim, "animation_finished")
	if G.getv("boss_" + G.current_level + "_killed", false):
		anim.play("final_death")
	else:
		player.make_dialog(death_dialog, 5)
		waiting_for_death = true


func can_mob_move():
	if not is_instance_valid(mob):
		return false
	if mob.current_health <= 0 or mob.is_stunned:
		return false
	return true


func is_mob_alive():
	if not is_instance_valid(mob):
		return false
	if mob.current_health <= 0:
		return false
	return true


func _on_mob_hurt():
	var prev_hp = boss_bar.value
	var curr_hp = mob.current_health
	boss_hp.text = str(curr_hp) + "/" + str(mob.max_health)
	boss_bar.value = curr_hp
	var hp = hurt_part.instance()
	hp.get_node("part").anchor_left = curr_hp / mob.max_health
	hp.get_node("part").anchor_right = prev_hp / mob.max_health
	boss_bar.add_child(hp)


func _on_mob_healed():
	boss_hp.text = str(mob.current_health) + "/" + str(mob.max_health)
	boss_bar.value = mob.current_health
