extends Node2D


func _enter_tree():
	pass

func _ready():
	if G.getv("gender", "male") == "male":
		$visual/body/head/hair/hair_man.show()
		$visual/body/head/hair/hair_woman.hide()
	else:
		$visual/body/head/hair/hair_man.hide()
		$visual/body/head/hair/hair_woman.show()
