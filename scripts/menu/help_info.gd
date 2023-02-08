extends Button



func _enter_tree():
	pass
export (String, MULTILINE) var info = ""
export (String) var id = ""


func _ready():
	if id in G.getv("learned_ids", []):
		hide()
	$canvas_layer/info.dialog_text = info


func accept():
	G.setv("learned_ids", G.getv("learned_ids", []) + [id])
	hide()
