extends Control


func _ready():
	var file = File.new()
	if not file.file_exists("user://custom_level_" + str(G.current_save.hash()) + ".scn"):
		var scene = load("res://minigames/minigame5/level_preset.scn")
		ResourceSaver.save("user://custom_level_" + str(G.current_save.hash()) + ".scn", scene)
		G.setv("ld_bg", 0)
		G.setv("ld_m", 0)
		G.setv("ld_gr", 0)


func open_level(id):
	get_tree().change_scene("res://minigames/minigame5/level"+id+".scn")


func back():
	get_tree().change_scene("res://scenes/menu/levels.scn")
