extends WindowDialog



func _ready():
	yield(get_tree(), "idle_frame")
	var t = tr($step2.text)
	$step2.text = t
	$step2.text += OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("saves.game.enc.png")


func request():
	OS.request_permissions()


func export_file():
	var dir = Directory.new()
	dir.make_dir_recursive(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	var file = ConfigFile.new()
	file.load("user://saves.game")
	file.save_encrypted_pass(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("saves.game.enc.png"), OS.get_model_name())


func import_file():
	var f = File.new()
	if not f.file_exists(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("saves.game.enc.png")):
		return
	var cf = ConfigFile.new()
	var err = cf.load_encrypted_pass(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("saves.game.enc.png"), OS.get_model_name())
	if err:
		printerr("ERROR WHILE IMPORTING")
		return
	G.file = cf
	G.save()
	get_tree().reload_current_scene()
