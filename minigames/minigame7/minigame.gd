extends Control


func select_mode(mode):
	if mode == 0:
		get_tree().change_scene("res://minigames/minigame7/royale.scn")
	if mode == 1:
		get_tree().change_scene("res://minigames/minigame7/wipeout.scn")


func _ready():
	if OS.has_feature("web"):
		$royale.disabled = true
		$guide.text = "К сожалению, данная мини-игра не доступна в веб-версии из-за особенностей веб-платформы."


func exit():
	get_tree().change_scene("res://scenes/menu/levels.scn")
