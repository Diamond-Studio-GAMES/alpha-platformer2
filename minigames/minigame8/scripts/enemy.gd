extends Sprite


enum EnemyType {
	DOOR = 0,
	LIGHT = 1,
	MASK = 2,
}
enum Scream {
	FEMALE = 0,
	MALE = 1,
	DT = 2
}
enum ComeInOut {
	STEPS = 0,
	RUN = 1
}


export (EnemyType) var enemy_type = EnemyType.DOOR
export (Scream) var scream_type = Scream.FEMALE
export (ComeInOut) var steps_type = ComeInOut.STEPS
export (Array, Array, String) var paths = []
export (int) var AI = 0
export (int) var AI_time_custom = 5
export (int) var time_to_awake = 0
export (float) var time_to_defend = 10
export (float) var defense_time = 3
export (bool) var kill_on_monitor = true
var current_room = "base"
var current_path = []
var move_timer = 0
var started_moving = false
var time_to_next_move = 5
var is_in_another = false
var is_defending = false
var defended_time = 0
var monitor_was_up = false
onready var night := get_tree().current_scene as Night


func move_to_room(room):
	current_room = room
	var next_pos = night.get_room_pos(current_room)
	get_parent().remove_child(self)
	next_pos.add_child(self)


func start_moving():
	move_timer = 0
	time_to_next_move = AI_time_custom
	current_path = paths[randi() % len(paths)]
	move_to_room(current_path[0])
	is_defending = false
	defended_time = 0


func do_move():
	var curr_id = current_path.find(current_room)
	if current_path[curr_id] == "main" or current_path[curr_id] == "another_way":
		hide()
		var sound = ""
		match scream_type:
			Scream.FEMALE:
				sound = "jumpscare_female"
			Scream.MALE:
				sound = "jumpscare_male"
			Scream.DT:
				sound = "jumpscare_dt"
		night.jumpscare(texture, sound)
		return
	time_to_next_move = AI_time_custom
	if randi() % 20 > AI - 1:
		return
	if curr_id + 1 == len(current_path):
		start_moving()
		return
	move_to_room(current_path[curr_id+1])
	if current_room == "main" or current_room == "another_way":
		match steps_type:
			ComeInOut.STEPS:
				night.play_sound("steps_in")
			ComeInOut.RUN:
				night.play_sound("run_in")
		is_in_another = current_room == "another_way"
		night.break_flashlight(is_in_another)
		time_to_next_move = time_to_defend
		is_defending = true
		monitor_was_up = night.is_cameras


func _process(delta):
	if night.time >= time_to_awake and not started_moving:
		start_moving()
		started_moving = true
	move_timer += delta
	if move_timer >= time_to_next_move and started_moving:
		move_timer = 0
		do_move()
	if is_defending:
		match enemy_type:
			EnemyType.DOOR:
				if night.is_door:
					if time_to_defend - move_timer < defense_time - defended_time:
						move_timer = 0
						defense_time = 999
					defended_time += delta
				elif defense_time >= 990:
					move_timer = 999
			EnemyType.LIGHT:
				if night.is_flashlight and night.is_in_another_way == is_in_another:
					if time_to_defend - move_timer < defense_time - defended_time:
						move_timer = 999
					defended_time += delta
			EnemyType.MASK:
				if night.is_mask:
					if time_to_defend - move_timer < defense_time - defended_time:
						move_timer = 0
						defense_time = 999
					defended_time += delta
				elif defense_time >= 990:
					move_timer = 999
		if monitor_was_up and not night.is_cameras:
			monitor_was_up = false
		if kill_on_monitor and night.is_cameras and not monitor_was_up and move_timer > time_to_defend * 0.3:
			move_timer = 999
			is_defending = false
		if defended_time >= defense_time:
			match enemy_type:
				EnemyType.DOOR:
					night.play_sound("door_locked")
				_:
					match steps_type:
						ComeInOut.STEPS:
							night.play_sound("steps_out")
						ComeInOut.RUN:
							night.play_sound("run_out")
			night.break_flashlight(is_in_another)
			start_moving()
