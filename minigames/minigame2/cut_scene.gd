extends Node2D

var got_death = true

func _ready():
	randomize()
	if randi() % 6 < 4:
		got_death = false
		$tint/tint/label.hide()


func reward():
	G.setv("hated_death", got_death)
	get_tree().change_scene("res://scenes/menu/menu.scn")
	G.receive_loot({"gold_box" : 1})
