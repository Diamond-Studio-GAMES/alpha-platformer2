extends CanvasItem


func _ready():
	set_soul_color()
	G.connect("hate_increased", self, "set_soul_color")


func set_soul_color():
	var color = G.SOUL_COLORS[G.getv("soul_type", 6)]
	match G.getv("hate_level", -1):
		1:
			self_modulate = color.darkened(0.1)
		2:
			self_modulate = color.darkened(0.3)
		3:
			self_modulate = color.darkened(0.5)
		4:
			self_modulate = color.darkened(0.7)
		_:
			self_modulate = color
