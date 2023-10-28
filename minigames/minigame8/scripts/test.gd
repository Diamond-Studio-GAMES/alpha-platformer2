extends ColorRect


export (int) var chance = 8
export (int) var time_to_answer = 5
var current_test = "test0"
onready var night : Night = get_tree().current_scene as Night
var timer = 0
var current_cameras = false
var is_blocked = false
var is_testing = false


func completed():
	hide()
	$test0.hide()
	$test1.hide()
	$test2.hide()
	is_testing = false


func block():
	is_testing = false
	timer = 0
	is_blocked = true
	$test0.hide()
	$test1.hide()
	$test2.hide()
	$failed.show()


func answer():
	match current_test:
		"test0":
			if $"test0/2".pressed:
				completed()
			else:
				block()
		"test1":
			if $"test1/0".pressed:
				completed()
			else:
				block()
		"test2":
			if $"test2/1".pressed:
				completed()
			else:
				block()


func start_test():
	show()
	current_test = "test" + str(randi()%3)
	$test0.hide()
	$test1.hide()
	$test2.hide()
	get_node(current_test).show()
	for i in range(3):
		get_node(current_test + "/" + str(i)).pressed = false
	is_testing = true
	timer = 0


func _process(delta):
	night.is_test = visible
	if is_blocked:
		return
	if current_cameras != night.is_cameras:
		current_cameras = night.is_cameras
		if current_cameras:
			if randi() % chance == 0 and not is_testing:
				start_test()
	if is_testing:
		timer += delta
		get_node(current_test+"/time").value = (time_to_answer - timer) / time_to_answer
		if timer >= time_to_answer:
			block()
