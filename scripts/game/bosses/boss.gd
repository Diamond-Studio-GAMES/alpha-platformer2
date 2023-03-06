extends Node2D
class_name Boss

var mob : Mob
var boss_bar : TextureProgress
var boss_hp : Label
var player : Player
var is_attacking = false
var waiting_for_death = false
var death_timer = 0
var is_cutscene = false
var attack_timer = 0
var next_attack_time = 1
var attacks = []
var player_target = null
var death_dialog = ""
var mercy_dialog = ""
var fill_x = 0
var tp_pos = Vector2()
onready var anim = $anim
onready var ms = $MultiplayerSynchronizer


func set_cutscene(val):
	if not is_instance_valid(player):
		return
	if val:
		player.stop()
	player.can_control = not val
	is_cutscene = val


func _ready():
	randomize()
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	player = get_tree().current_scene.get_node("player"+(str(get_tree().get_network_unique_id()) if MP.is_active else ""))
	boss_bar = player.get_boss_bar()
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
		tilemap.set_cell(fill_x, i, 5)
	move_player_to_start()
	if MP.is_active:
		rpc("move_player_to_start")
	$"../../music".play()
	$"../../tint/anim".play("boss_name_appear")
	yield($"../../tint/anim", "animation_finished")
	is_attacking = true
	mob.defense = 0


remote func move_player_to_start():
	player.global_position = $"../../tilemap".map_to_world(tp_pos) + Vector2.ONE * 16
