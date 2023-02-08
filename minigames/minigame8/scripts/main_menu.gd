extends Control



func _ready():
	$continue/label.text = "НОЧЬ " + str(G.getv("night", 1))


func continue_():
	$exit.hide()
	$new_game.hide()
	$continue.hide()
	$loading.show()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	get_tree().change_scene("res://minigames/minigame8/scenes/night{0}.scn".format([str(G.getv("night", 1))]))


func begin():
	G.setv("night", 1)
	continue_()


func quit():
	get_tree().change_scene("res://scenes/menu/levels.scn")
