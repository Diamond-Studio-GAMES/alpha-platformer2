extends CanvasItem


export (bool) var use_custom_path = false
export (NodePath) var custom_path
var viewport


func _ready():
	if use_custom_path:
		viewport = get_node(custom_path)
	else:
		viewport = get_tree().current_scene.get_node("class_visuals/" + name)
	self.texture = viewport.get_texture()
