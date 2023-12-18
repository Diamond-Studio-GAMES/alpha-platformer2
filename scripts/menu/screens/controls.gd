extends Control


signal reset


func exit():
	get_tree().change_scene("res://scenes/menu/menu.tscn")


func reset_button():
	emit_signal("reset")
