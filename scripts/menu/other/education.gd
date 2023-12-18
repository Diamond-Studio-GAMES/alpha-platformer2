extends Control


export (NodePath) var next_edu = null
export (bool) var first = false
var next = null
var compl = false


func _ready():
	if G.getv("learned", false):
		return
	if first:
		show()
	if next_edu != null:
		next = get_node(next_edu)


func next():
	if G.getv("learned", false):
		return
	if compl:
		return
	compl = true
	hide()
	if next != null:
		next.show()


func end():
	hide()
	G.setv("learned", true)
