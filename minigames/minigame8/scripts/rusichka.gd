extends "res://minigames/minigame8/scripts/enemy.gd"


func start_moving():
	move_timer = 0
	time_to_next_move = AI_time_custom
	var random_num = randi() % len(paths)
	enemy_type = random_num
	current_path = paths[random_num]
	move_to_room(current_path[0])
	is_defending = false
	defended_time = 0
