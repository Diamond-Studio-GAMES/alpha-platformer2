extends Node2D


export (String) var location = "Где-то"
export (String) var level_name = "УРОВЕНЬ: ТЕСТ"
export (Array, PackedScene) var mobs = []
onready var pos = $spawn_pos
onready var st = $spawn_timer
var tint
var wave_numder = 1
var mob_count = 0
var player : MinigameHero
var gen = RandomNumberGenerator.new()
var hh_text = load("res://prefabs/effects/hurt_heal_text.scn")

signal wave_ended


func _enter_tree():
	tint = $tint/tint
	tint.color = Color.black


func get_rewards():
	var loot = {"gems":0, "coins":0, "box":0}
	for i in range(wave_numder-1):
		var type = gen.randi_range(0, 2)
		match type:
			0:
				loot["gems"] += 1 + round(i * 0.01)
			1:
				loot["coins"] += 160 + round(i * 1.6)
			2:
				loot["box"] += 1 + round(i * 0.01)
	if loot["gems"] == 0:
		loot.erase("gems")
	if loot["coins"] == 0:
		loot.erase("coins")
	if loot["box"] == 0:
		loot.erase("box")
	if not loot.empty():
		G.receive_loot(loot)


func _ready():
	gen.randomize()
	G.setv("hated_death", false)
	G.setv("go_chance", false)
	var p = load("res://minigames/minigame4/hero.scn").instance()
	p.get_node("camera/gui/base/intro/text/main").text = level_name
	p.get_node("camera/gui/base/intro/text/location").text = location
	p.position = pos.position
	p.name = "player"
	p.custom_respawn_scene = filename
	p.get_node("camera").connect("gived_up", self, "get_rewards")
	add_child(p)
	player = p
	if has_node("lights"):
		if G.getv("graphics", 15) & G.Graphics.BEAUTY_LIGHT == 0:
			for i in $lights.get_children():
				if i is Light2D:
					i.hide()
				else:
					i.color = Color(0.35, 0.35, 0.35, 1)
	tint.color = Color(1, 1, 1, 0)
	start_wave()


func percent_chance(in_chance):
	in_chance *= 10000
	var max_add = 1000000 - in_chance
	var chance_range_start = gen.randi_range(0, max_add)
	var chance_range_end = chance_range_start + in_chance
	var random_number = gen.randi_range(0, 1000000)
	if random_number >= chance_range_start and random_number <= chance_range_end:
		return true
	return false


func start_wave():
	player.make_dialog("Волна %d началась!" % wave_numder, 5, Color.red)
	mob_count = round(wave_numder * 0.8) + gen.randi_range(0, 3)
	for i in range(mob_count):
		spawn_mob()
		st.start(gen.randf_range(0.7, 1.5))
		yield(st, "timeout")
	player.make_dialog("Все враги появились!")
	yield(self, "wave_ended")
	wave_numder += 1
	start_wave()


func spawn_mob():
	mobs.shuffle()
	var mob = mobs[0].instance()
	mob.vision_distance = 10000
	mob.stats_multiplier = 1 + wave_numder * 0.2 + gen.randf_range(-wave_numder * 0.05, wave_numder * 0.1)
	var spawn_id = str(gen.randi_range(0, 3))
	mob.global_position = get_node("spawn_points/pos" + spawn_id).global_position
	get_node("spawn_points/pos" + spawn_id + "/anim").play("spawn")
	if percent_chance(2):
		mob.stats_multiplier *= 2
		mob.modulate = Color.red
	mob.connect("died", self, "mob_died", [mob])
	$mobs.add_child(mob, true)


func mob_died(node):
	if not node is Mob:
		return
	mob_count -= 1
	player.make_dialog("Врагов осталось: " + str(mob_count))
	if mob_count <= 0:
		emit_signal("wave_ended")
	var amount = round(node.stats_multiplier * gen.randf_range(1, 2)) + gen.randi_range(1, 4)
	player.add_coins(amount)
	var hh = hh_text.instance()
	hh.global_position = node.global_position
	hh.get_node("text").modulate = Color.yellow
	hh.get_node("text").text = "+" + str(amount)
	add_child(hh)
