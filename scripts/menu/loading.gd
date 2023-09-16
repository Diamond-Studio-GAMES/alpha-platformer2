extends Node


export (String) var load_path = "res://scenes/menu/menu.tscn"
var loader
var time_max = 16
var wait_frames = 3


func _ready():
	start_load()


func start_load():
	if not is_instance_valid(get_tree().current_scene) or get_tree().current_scene == null:
		print("stop")
		queue_free()
		return
	get_tree().current_scene.queue_free()
	loader = ResourceLoader.load_interactive(load_path)
	if loader == null:
		print("Can't load!")
		get_tree().change_scene("res://scenes/splash_screen.tscn")
		queue_free()
		return


func _process(time):
	if loader == null:
		return
	if wait_frames > 0:
		wait_frames -= 1
		return
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			var res = loader.get_resource()
			loader = null
			set_scene(res)
			break
		elif err == OK:
			$loading/bar.value = float(loader.get_stage()) / loader.get_stage_count() * 100
		else:
			print("Can't load: ", err)
			get_tree().change_scene("res://scenes/splash_screen.tscn")
			G.emit_signal("loaded_to_scene", "error")
			queue_free()
			break


func set_scene(scene):
	$loading/bar.value = 100
	get_tree().change_scene_to(scene)
	G.emit_signal("loaded_to_scene", load_path)
	$loading/anim.play("end")
