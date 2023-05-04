extends Button


export (String, MULTILINE) var info = ""
export (String) var id = ""


func _ready():
	if id in G.getv("learned_ids", []):
		hide()
	$canvas_layer/info.dialog_text = info


func accept():
	G.addv("learned_ids", [id], [])
	hide()
