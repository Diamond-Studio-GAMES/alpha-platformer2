extends CanvasItem


func _ready():
	self_modulate = G.SOUL_COLORS[G.getv("soul_type", 6)]
