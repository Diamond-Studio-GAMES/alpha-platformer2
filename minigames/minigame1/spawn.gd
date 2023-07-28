extends Node2D


export (float) var spawn_interval = 5
var mobs = [load("res://minigames/minigame1/mob_knife_man_reznya.scn"),
		load("res://minigames/minigame1/mob_shooter_reznya.scn"), 
		load("res://minigames/minigame1/mob_sportsman_reznya.scn"),
		load("res://minigames/minigame1/mob_knight_reznya.scn"),
		load("res://minigames/minigame1/mob_doctor_reznya.scn"),
		load("res://minigames/minigame1/mob_spartan_reznya.scn")]
var timer = null
var timer_time = 120
var won = false
var player : Player
var win_timer = 2
var reward_claimed = false
var player_camera : Camera2D
var shake_timer = 0
var spawn_timer = 0


func _ready():
	randomize()
	yield(get_tree(), "idle_frame")
	player = $"../player"
	player_camera = player.get_node("camera")
	player.custom_respawn_scene = "res://minigames/minigame1/minigame.scn"
	var n = load("res://minigames/minigame1/timer.scn").instance()
	player.add_child(n)
	timer = n.get_node("timer/bar")
	player.make_dialog("Награда за выживание: 2 золотых ящика", 10, Color.red)
	yield(get_tree().create_timer(10, false), "timeout")
	player.make_dialog("Музыка: KSLV - Override (https://youtu.be/NS8DPG62Fto)", 10, Color.red)


func _process(delta):
	if timer == null:
		return
	if player.current_health > 0:
		timer_time -= delta
		if shake_timer >= 0.2:
			player_camera.offset_h = rand_range(-0.03, 0.03)
			player_camera.offset_v = rand_range(-0.03, 0.03)
		if timer_time <= 0 and not won:
			won = true
			player.make_dialog("ТЫ ПОБЕДИЛ!", 2, Color.red)
	shake_timer += delta
	timer.value = timer_time
	if won:
		win_timer -= delta
		if win_timer <= 0 and not reward_claimed:
			reward_claimed = true
			G.addv("reznya_completed", 1)
			G.ach.complete(Achievements.REZNYA)
			get_tree().change_scene("res://scenes/menu/menu.scn")
			G.receive_loot({"gold_box" : 2})
	spawn_timer += delta
	if spawn_timer > spawn_interval:
		spawn_timer = 0
		var pos = Vector2()
		if randi() % 2 == 0:
			pos = $spawn_pos0.global_position
		else:
			pos = $spawn_pos1.global_position
		var node = mobs[randi() % len(mobs)].instance()
		node.global_position = pos
		add_child(node, true)
