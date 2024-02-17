extends Control



func _ready():
	$confirm.get_cancel().text = tr("menu.cancel")
	$confirm.get_ok().text = tr("8.new")
	$confirm.get_label().align = Label.ALIGN_CENTER
	if not G.getv("fnas_bought", false):
		$game_buttons.hide()
		$buy.show()
	if not G.hasv("night"):
		G.setv("night", 1)
	$game_buttons/continue/label.text = tr("8.night") + str(G.getv("night", 1))


func continue_():
	$exit.hide()
	$game_buttons.hide()
	$loading.show()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_tree().change_scene("res://minigames/minigame8/scenes/night{0}.tscn".format([str(G.getv("night", 1))]))


func begin():
	G.setv("night", 1)
	continue_()


func quit():
	get_tree().change_scene("res://scenes/menu/levels.tscn")


func _on_ticket_selector_started():
	G.setv("fnas_bought", true)
	$buy.hide()
	$game_buttons.show()
