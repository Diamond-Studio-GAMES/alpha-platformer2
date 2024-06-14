extends Node2D


export (float) var spawn_interval = 5
var mobs = {
	0 : load("res://minigames/minigame1/mob_knife_man_reznya.tscn"),
	1 : load("res://minigames/minigame1/mob_shooter_reznya.tscn"), 
	3 : load("res://minigames/minigame1/mob_sportsman_reznya.tscn"),
	4 : load("res://minigames/minigame1/mob_knight_reznya.tscn"),
	5 : load("res://minigames/minigame1/mob_doctor_reznya.tscn"),
	6 : load("res://minigames/minigame1/mob_spartan_reznya.tscn"),
	7 : load("res://minigames/minigame1/mob_magician_reznya.tscn"),
	9 : load("res://minigames/minigame1/mob_mechanic_reznya.tscn"),
	10 : load("res://minigames/minigame1/mob_werewolf_human_reznya.tscn")
}
var timer = null
var timer_time = 120
var won = false
var player : Player
var win_timer = 2
var reward_claimed = false
var player_camera: Camera2D
var shake_timer = 0
var spawn_timer = 0


func _ready():
	var current_location = int(G.getv("level", "1_1").split('_')[0])
	for i in mobs.keys():
		if i > current_location:
			mobs.erase(i)
	yield(get_tree(), "idle_frame")
	player = $"../player"
	player.get_node("camera/gui/base/pause_menu/panel/restart").disabled = true
	player_camera = player.get_node("camera")
	player.custom_respawn_scene = "res://minigames/minigame1/minigame.tscn"
	var n = load("res://minigames/minigame1/timer.tscn").instance()
	player.add_child(n)
	timer = n.get_node("timer/bar")
	player.make_dialog(tr("1.music"), 10, Color.red)


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
			player.make_dialog(tr("1.win"), 2, Color.red)
	shake_timer += delta
	timer.value = timer_time
	if won:
		win_timer -= delta
		if win_timer <= 0 and not reward_claimed:
			reward_claimed = true
			G.addv("reznya_completed", 1)
			G.ach.complete(Achievements.REZNYA)
			get_tree().change_scene("res://scenes/menu/menu.tscn")
			G.receive_loot({
				"coins" : G.current_tickets * 75,
				"gems" : G.current_tickets,
				"box" : G.current_tickets,
			})
	spawn_timer += delta
	if spawn_timer > spawn_interval:
		spawn_timer = 0
		_spawn_mob()


func _spawn_mob():
	var pos = Vector2()
	if randi() % 2 == 0:
		pos = $spawn_pos0.global_position
	else:
		pos = $spawn_pos1.global_position
	var node = mobs[mobs.keys().pick_random()].instance() as Mob
	node.global_position = pos
	node.stats_multiplier = 0.5 + player.power * 0.08
	add_child(node, true)
