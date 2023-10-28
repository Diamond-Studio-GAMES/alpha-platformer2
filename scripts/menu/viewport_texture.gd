extends CanvasItem


export (bool) var use_custom_path = false
export (NodePath) var custom_path
var viewport


func _ready():
	if use_custom_path:
		viewport = get_node(custom_path)
	else:
		G.init_class_visuals()
		viewport = G.class_visuals.get_node(name)
	self.texture = viewport.get_texture()


func _exit_tree():
	if not use_custom_path:
		G.end_class_visuals()
