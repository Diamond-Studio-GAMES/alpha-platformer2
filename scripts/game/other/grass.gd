extends Sprite


func _ready():
	material.set_shader_param("time_offset", float(randi()%1000))
