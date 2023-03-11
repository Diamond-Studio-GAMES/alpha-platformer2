extends Node2D


export (String) var location = "Где-то"
export (String) var level_name = "УРОВЕНЬ: ТЕСТ"
export (bool) var testing = false
onready var pos = $spawn_pos
var tint
var pl
var gen = RandomNumberGenerator.new()


func _enter_tree():
	tint = $tint/tint
	tint.color = Color.black


func _ready():
	if MP.is_active:
		yield($"/root/mg", "game_started")
	gen.randomize()
	var chance = 7 if G.getv("go_chance", false) else 2
	chance = 100 if G.getv("hated_death", false) else chance
	G.setv("hated_death", false)
	G.setv("go_chance", false)
	var p
	if percent_chance(chance) and get_tree().current_scene.name.begins_with("level"): #and not MP.is_active:
		print("death")
		p = load("res://prefabs/classes/death.scn").instance()
	else:
		p = load("res://prefabs/classes/" + (G.getv("selected_class", "player") if not testing else G.selected_class_to_test) + ".scn").instance()
	p.get_node("camera/gui/base/intro/text/main").text = level_name
	p.get_node("camera/gui/base/intro/text/location").text = location
	p.position = pos.position
	p.name = "player" + (str(get_tree().get_network_unique_id()) if MP.is_active else "")
	add_child(p)
	if has_node("lights"):
		if not G.getv("beauty_light", true):
			for i in $lights.get_children():
				if i is Light2D:
					i.hide()
				else:
					i.color = Color(0.35, 0.35, 0.35, 1)
	tint.color = Color(1, 1, 1, 0)
	if testing:
		pl = p


func _physics_process(delta):
	if not testing:
		return
	if pl.current_health <= 0:
		testing = false
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
		get_tree().change_scene("res://scenes/menu/levels.scn")


func percent_chance(in_chance):
	in_chance *= 10000
	var max_add = 1000000 - in_chance
	var chance_range_start = gen.randi_range(0, max_add)
	var chance_range_end = chance_range_start + in_chance
	var random_number = gen.randi_range(0, 1000000)
	if random_number >= chance_range_start and random_number <= chance_range_end:
		return true
	return false
