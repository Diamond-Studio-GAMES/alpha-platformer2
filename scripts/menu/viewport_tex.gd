extends TextureRect


export (bool) var use_custom_path = false
export (NodePath) var custom_path
var viewport : Viewport


func _ready():
	if use_custom_path:
		viewport = get_node(custom_path)
	else:
		viewport = get_tree().current_scene.get_node("class_" + name)
	texture = viewport.get_texture()
