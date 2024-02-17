extends Sprite


export (int) var AI = 0
export (bool) var another = false
var was_in_cameras = false
var is_defending = false
var masked = false
onready var night := get_tree().current_scene as Night


func _process(delta):
	if not night.is_cameras and was_in_cameras:
		_spawn()
	was_in_cameras = night.is_cameras
	if is_defending and night.is_mask:
		masked = true


func _spawn():
	if randi() % 20 < AI and night.is_in_another_way == another:
		$anim.play("spawn")
		is_defending = true
		masked = false


func _try_to_kill():
	if not masked:
		yield(get_tree().create_timer(1, false), "timeout")
		night.jumpscare(texture, "jumpscare_female")
		return
	is_defending = false
