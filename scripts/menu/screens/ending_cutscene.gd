extends Node2D


export (String, FILE, "*.tscn") var hate_minus_1_next = ""
export (String, FILE, "*.tscn") var hate_0_next = ""
export (String, FILE, "*.tscn") var hate_1_next = ""
export (String, FILE, "*.tscn") var hate_2_next = ""
export (String, FILE, "*.tscn") var hate_3_next = ""
export (String, FILE, "*.tscn") var hate_4_next = ""
var dialog_timer = 0


func _process(delta):
	if dialog_timer > 0:
		dialog_timer -= delta
		if dialog_timer <= 0:
			dialog_timer = 0
			$base/think/base/dialog.text = ""


func make_dialog(text: String, time := 2.5, color := Color.white):
	text = tr(text)
	if G.getv("gender", "male") == "male":
		text = text.replace("%", "")
	else:
		text = text.replace("%", "а")
	$base/think/base/dialog.text = text
	$base/think/base/dialog.add_color_override("font_color", color)
	$base/think/base/dialog.get_font("font").outline_color = Color.black if color.get_luminance() > 0.5 else Color.white
	dialog_timer = time


func next():
	match G.getv("hate_level", -1):
		-1:
			get_tree().change_scene(hate_minus_1_next)
		0:
			get_tree().change_scene(hate_0_next)
		1:
			get_tree().change_scene(hate_1_next)
		2:
			get_tree().change_scene(hate_2_next)
		3:
			get_tree().change_scene(hate_3_next)
		4:
			get_tree().change_scene(hate_4_next)
