extends Control


func select_mode(mode):
	if mode == 0:
		get_tree().change_scene("res://minigames/minigame7/royale.tscn")
	if mode == 1:
		get_tree().change_scene("res://minigames/minigame7/wipeout.tscn")


func _ready():
	$setting_dialog/aim_mode.select(G.getv("shooter_aim_mode"))
	if OS.has_feature("pc"):
		$setting_dialog/guide.text = "WASD - движение, Средняя кнопка мыши - смена оружия, правая кнопка мыши - стрельба. Прицеливание джойстиком."
	if OS.has_feature("web"):
		$royale.disabled = true
		$guide.text = "К сожалению, данная мини-игра не доступна в веб-версии из-за особенностей веб-платформы."


func exit():
	get_tree().change_scene("res://scenes/menu/levels.tscn")


func _on_aim_mode_item_selected(index):
	G.setv("shooter_aim_mode", index)
