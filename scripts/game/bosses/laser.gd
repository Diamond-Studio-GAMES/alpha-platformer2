extends RayCast2D


onready var collision_point = $collision_point
onready var line = $line


func _physics_process(delta):
	enabled = visible
	if not visible:
		return
	if is_colliding():
		var point = get_collision_point()
		collision_point.global_position = point
		line.points[1] = line.to_local(point)
	else:
		collision_point.global_position = Vector2.ZERO
		line.points[1] = Vector2.DOWN * 640
