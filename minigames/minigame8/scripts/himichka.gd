extends "res://minigames/minigame8/scripts/enemy.gd"


export (float) var time_to_kill = 3
var kill_timer = 0


func _process(delta):
	if night.is_cameras:
		if current_room == night.current_camera and not night.is_test:
			kill_timer += delta
			move_timer -= delta
		else:
			kill_timer = 0
		if kill_timer >= time_to_kill:
			kill_timer = 0
			night.jumpscare(texture, "jumpscare_female")
			hide()
	else:
		kill_timer = 0
