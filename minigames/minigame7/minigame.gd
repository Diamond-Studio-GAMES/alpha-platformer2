extends Control


func select_mode(mode):
	if mode == 0:
		get_tree().change_scene("res://minigames/minigame7/royale.tscn")
	if mode == 1:
		get_tree().change_scene("res://minigames/minigame7/wipeout.tscn")


func _ready():
	$setting_dialog/aim_mode.select(G.getv("shooter_aim_mode"))
	if OS.has_feature("pc"):
		$setting_dialog/guide.text = tr("7.pccontrols")
	if OS.has_feature("web"):
		$royale.disabled = true
		$guide.text = tr("7.web")


func exit():
	get_tree().change_scene("res://scenes/menu/levels.tscn")


func _on_aim_mode_item_selected(index):
	G.setv("shooter_aim_mode", index)
