extends Control


func _ready():
	var file = File.new()
	if not file.file_exists("user://custom_levels/" + G.getv("save_id", "lol") + ".tscn"):
		var dir = Directory.new()
		dir.make_dir_recursive("user://custom_levels/")
		var scene = load("res://minigames/minigame5/level_preset.tscn")
		ResourceSaver.save("user://custom_levels/" + G.getv("save_id", "lol") + ".tscn", scene)
		G.setv("ld_bg", 0)
		G.setv("ld_m", 0)
		G.setv("ld_gr", 0)


func open_level(id):
	get_tree().change_scene("res://minigames/minigame5/level"+id+".tscn")


func back():
	get_tree().change_scene("res://scenes/menu/levels.tscn")
