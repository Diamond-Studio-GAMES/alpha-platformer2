extends Sprite


export (float) var wind_speed = 1
export (float) var wind_power = 0.25
export (float) var origin_x_change = 4
export (Vector2) var offset_to_origin = Vector2()
var time = 0.0
var cpu = false


func _ready():
	match G.getv("grass_anim"):
		G.GrassType.GPU:
			material.set_shader_param("time_offset", float(randi()%1000))
		G.GrassType.CPU:
			material = null
			cpu = true
			randomize()
			time = randi() % 10000
		G.GrassType.STATIC:
			material = null


func _process(delta):
	if not cpu:
		return
	if time > 1000000000:
		time = 0.0
	time += delta * wind_speed
	var form = transform
	form.y = Vector2(sin(time) * wind_power, 1)
	form.origin = Vector2( - sin(time) * origin_x_change, 0) + offset_to_origin
	transform = form
