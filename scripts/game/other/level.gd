class_name Level
extends Node2D


export (String) var location = "Где-то"
export (String) var level_name = "УРОВЕНЬ: ТЕСТ"
onready var pos = $spawn_pos
var tint
var player
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
	if G.percent_chance(chance) and name.begins_with("level"):
		print("death")
		player = load("res://prefabs/classes/death.scn").instance()
	else:
		player = load("res://prefabs/classes/" + G.getv("selected_class", "player") + ".scn").instance()
	player.get_node("camera/gui/base/intro/text/main").text = level_name
	player.get_node("camera/gui/base/intro/text/location").text = location
	player.position = pos.position
	player.name = "player" + (str(get_tree().get_network_unique_id()) if MP.is_active else "")
	add_child(player)
	if has_node("lights"):
		if G.getv("graphics", 15) & G.Graphics.BEAUTY_LIGHT == 0:
			for i in $lights.get_children():
				if i is Light2D:
					i.hide()
				else:
					i.color = Color(0.35, 0.35, 0.35, 1)
	tint.color = Color(1, 1, 1, 0)
