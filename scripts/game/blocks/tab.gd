extends Node2D


export (String, MULTILINE) var text = ""
export (Color) var color = Color.white
export (bool) var with_leg = true


func _ready():
	if not with_leg:
		$with_leg.hide()
		$without_leg.show()
	$with_leg/for_text_part/label.text = tr(text)
	$without_leg/for_text_part/label.text = tr(text)
	$with_leg/for_text_part/label.add_color_override("font_color", color)
	$without_leg/for_text_part/label.add_color_override("font_color", color)
	
