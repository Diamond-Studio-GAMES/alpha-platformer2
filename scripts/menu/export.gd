extends WindowDialog



func _ready():
	yield(get_tree(), "idle_frame")
	var t = tr($step2.text)
	$step2.text = t
	$step2.text += OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("apa2_backups")


func request():
	OS.request_permissions()


func export_file():
	var dir = Directory.new()
	dir.make_dir_recursive(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("apa2_backups"))
	var saves_path = "user://saves/"
	var cf = ConfigFile.new()
	dir.open(saves_path)
	dir.list_dir_begin(true)
	var filename = dir.get_next()
	while filename != "":
		if not dir.current_is_dir():
			var cfc = ConfigFile.new()
			cfc.load_encrypted_pass(saves_path.plus_file(filename), "apa2_save")
			for i in cfc.get_section_keys("save"):
				cf.set_value(filename, i, cfc.get_value("save", i))
		filename = dir.get_next()
	cf.save("user://export_cache.apa2saves.uncompressed")
	var of = File.new()
	var nf = File.new()
	of.open("user://export_cache.apa2saves.uncompressed", File.READ)
	nf.open_compressed(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("apa2_backups").plus_file(str(int(Time.get_unix_time_from_system())) + ".apa2saves.png"), File.WRITE, File.COMPRESSION_FASTLZ)
	nf.store_string(of.get_as_text())
	of.close()
	nf.close()
	dir.remove("user://export_cache.apa2saves.uncompressed")


func import_file():
	var dir = Directory.new()
	if not dir.dir_exists(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("apa2_backups")):
		return
	dir.open(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).plus_file("apa2_backups"))
	dir.list_dir_begin(true)
	var list = []
	var list_item = dir.get_next()
	var ext = ""
	while list_item != "":
		if not dir.current_is_dir():
			var splits = list_item.split(".", true, 1)
			list.append(int(splits[0]))
			ext = splits[1]
		list_item = dir.get_next()
	var f = File.new()
	f.open_compressed(dir.get_current_dir().plus_file(str(list.max()) + "." + ext), File.READ, File.COMPRESSION_FASTLZ)
	var cf = ConfigFile.new()
	cf.parse(f.get_as_text())
	f.close()
	for i in cf.get_sections():
		var c = ConfigFile.new()
		for j in cf.get_section_keys(i):
			c.set_value("save", j, cf.get_value(i, j))
		c.save_encrypted_pass("user://saves/".plus_file(i), "apa2_save")
	get_tree().reload_current_scene()
