extends Node2D


var SONGS_BY_ID = {
	0 : "res://sounds/music/field.ogg",
	1 : "res://sounds/music/tense.ogg",
	2 : "res://sounds/music/forest_boss.ogg",
}
var BG_BY_ID = {
	0 : "res://prefabs/effects/background.tscn",
	1 : "res://prefabs/effects/background_forest.tscn",
}
var GR_BY_ID = {
	0 : "res://minigames/minigame5/ground_grass.tscn",
	1 : "res://minigames/minigame5/ground_stone.tscn",
}


func _ready():
	var tilemap = load("user://custom_levels/" + G.getv("save_id", "lol") + ".scn").instance()
	add_child(tilemap)
	var load_bg = load("res://minigames/minigame5/load_bg.tscn").instance()
	tilemap.add_child(load_bg)
	var end = load("res://minigames/minigame5/end.tscn").instance()
	tilemap.add_child(end)
	var music = AudioStreamPlayer.new()
	music.name = "music"
	music.bus = "music"
	music.stream = load(SONGS_BY_ID[G.getv("ld_m", 0)])
	tilemap.add_child(music)
	var gr = load(GR_BY_ID[G.getv("ld_gr", 0)]).instance()
	gr.global_position = Vector2(-128, 0)
	tilemap.add_child(gr)
	var bg = load(BG_BY_ID[G.getv("ld_bg", 0)]).instance()
	tilemap.add_child(bg)
	tilemap.set_script(load("res://minigames/minigame5/resources/level_dash.gd"))
	tilemap._ready()
	var dasher = load("res://minigames/minigame5/dasher.tscn").instance()
	dasher.global_position = Vector2(0, -16)
	tilemap.add_child(dasher)
