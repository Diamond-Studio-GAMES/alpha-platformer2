extends Control


enum SoulType  {
	BRAVERY = 0,
	JUSTICE = 1,
	KINDNESS = 2,
	PATIENCE = 3,
	INTEGRITY = 4,
	PERSEVERANCE = 5
}


onready var soul = $create/soul
var save_obj = load("res://prefabs/menu/save.tscn")
var id_to_delete = ""
var saves_objs_dict = {}


func _ready():
	if G.main_getv("volume", -1) < 0:
		G.main_setv("volume", 0.75)
		G.main_setv("volume_sfx", 1)
		G.main_setv("fullscr", false)
	TranslationServer.set_locale(G.main_getv("lang", "ru"))
	$delete_window.get_label().align = Label.ALIGN_CENTER
	$delete_window.get_cancel().text = tr("sl.delete.no")
	$delete_window.get_ok().text = tr("sl.delete.yes")
	$delete_window.get_ok().release_focus()
	$delete_window.connect("popup_hide", self, "cancel")
	$confirm_delete_window.get_cancel().text = tr("sl.delete.con.no")
	$confirm_delete_window.get_ok().text = tr("sl.delete.con.yes")
	$confirm_delete_window.get_ok().release_focus()
	$confirm_delete_window.connect("popup_hide", self, "cancel")
	$enter_color.color = Color.black
	$enter.interpolate_property($enter_color, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	$enter.start()
	$settings/mv_s.value = G.main_getv("volume", 0.75)
	$settings/sfxv_s.value = G.main_getv("volume_sfx", 1)
	$settings/fullscr.pressed = G.main_getv("fullscr", false)
	$misc/check_upd.pressed = G.main_getv("check_upd", true)
	$misc/check_patch.pressed = G.main_getv("check_patches", true)
	$misc/check_beta.pressed = G.main_getv("check_beta", not G.VERSION_STATUS.empty())
	$create/name.placeholder_text = tr("sl.create.pname")
	$create/name.set_message_translation(false)
	$create/name.notification(NOTIFICATION_TRANSLATION_CHANGED)
	list_saves()


func list_saves():
	$saves/empty_text.hide()
	for i in $saves/scroll/saves.get_children():
		i.queue_free()
	var dir = Directory.new()
	dir.open("user://saves/")
	dir.list_dir_begin(true)
	var list = []
	var filename = dir.get_next()
	while filename != "":
		if not dir.current_is_dir():
			list.append(filename)
		filename = dir.get_next()
	if list != G.main_getv("saves_list", []):
		reload_meta_from_saves()
		G.main_setv("saves_list", list)
	saves_objs_dict.clear()
	var list_of_saves = []
	list_of_saves = get_save_ids_list()
	if list_of_saves.size() <= 0:
		$saves/empty_text.show()
		return
	for i in list_of_saves:
		var node = save_obj.instance()
		node.name = i
		node.get_node("name").text = G.get_save_meta(i, "name", "???")
		var date = G.get_save_meta(i, "last_opened", Time.get_date_dict_from_system())
		var date_str = "%02d/%02d/%d" % [date["day"], date["month"], date["year"]]
		node.get_node("date").text = date_str
		node.get_node("soul").self_modulate = G.SOUL_COLORS[G.get_save_meta(i, "soul_type", 6)]
		node.get_node("play").connect("pressed", self, "play", [i])
		node.get_node("copy").connect("pressed", self, "duplicate_save", [i])
		node.get_node("delete").connect("pressed", self, "delete_save", [i])
		$saves/scroll/saves.add_child(node)
		saves_objs_dict[G.get_save_meta(i, "name", "???")] = node
	sort_saves()


func sort_saves():
	var sorted = saves_objs_dict.keys().duplicate()
	sorted.sort()
	for i in range(sorted.size()):
		$saves/scroll/saves.move_child(saves_objs_dict[sorted[i]], i)


func _process(delta):
	$create/soul_type.visible = $create/hardcore.pressed
	$create/soul_type_text.visible = $create/hardcore.pressed
	if $create/hardcore.pressed:
		soul.self_modulate = G.SOUL_COLORS[$create/soul_type.selected]
	else:
		soul.self_modulate = Color.red
	if $create/name.text.strip_edges().empty():
		$create/create.disabled = true
	else:
		$create/create.disabled = false
	
	G.main_setv("volume", $settings/mv_s.value)
	G.main_setv("volume_sfx", $settings/sfxv_s.value)
	if OS.has_feature("pc"):
		G.main_setv("fullscr", $settings/fullscr.pressed)
		OS.window_fullscreen = $settings/fullscr.pressed
	else:
		$settings/fullscr.visible = false
	G.main_setv("check_upd", $misc/check_upd.pressed)
	G.main_setv("check_patches", $misc/check_patch.pressed)
	G.main_setv("check_beta", $misc/check_beta.pressed)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db($settings/mv_s.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db($settings/sfxv_s.value))


func create():
	var id = make_id($create/name.text.strip_edges().to_lower())
	G.open_save(id)
	G.setv("save_id", id)
	G.setv("last_opened", Time.get_date_dict_from_system())
	G.setv("name", $create/name.text)
	G.setv("create_date", Time.get_date_dict_from_system())
	if $create/male.pressed:
		G.setv("gender", "male")
	else:
		G.setv("gender", "female")
	G.setv("hardcore", $create/hardcore.pressed)
	if G.getv("hardcore"):
		G.setv("soul_type", $create/soul_type.selected)
	else:
		G.setv("soul_type", 6)
	G.setv("gems", 10)
	G.setv("coins", 0)
	G.setv("volume", G.main_getv("volume", 0.75))
	G.setv("volume_sfx", G.main_getv("volume_sfx", 1))
	G.setv("lang", G.main_getv("lang", OS.get_locale_language()))
	G.setv("hero_chance", 2)
	$enter.interpolate_property($enter_color, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 2)
	$enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	G.save()
	yield(get_tree().create_timer(2.0, false), "timeout")
	TranslationServer.set_locale(G.getv("lang", "ru"))
	get_tree().change_scene("res://scenes/menu/story.tscn")


func play(id):
	G.open_save(id)
	G.setv("last_opened", Time.get_date_dict_from_system())
	G.set_save_meta(id, "last_opened", Time.get_date_dict_from_system())
	G.save()
	$enter.interpolate_property($enter_color, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 1)
	$enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	yield(get_tree().create_timer(1.0, false), "timeout")
	TranslationServer.set_locale(G.getv("lang", "ru"))
	get_tree().change_scene("res://scenes/menu/menu.tscn")


func cancel_create():
	if $create/enter.is_active() or $saves/enter.is_active():
		return
	$create/enter.interpolate_property($create, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	$create/enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	yield(get_tree().create_timer(0.5, false), "timeout")
	$create.visible = false
	$saves.visible = true
	$saves.modulate = Color(1, 1, 1, 0)
	$saves/enter.interpolate_property($saves, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	$saves/enter.start()
	yield(get_tree().create_timer(0.5, false), "timeout")
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enter_create():
	if $create/enter.is_active() or $saves/enter.is_active():
		return
	$saves/enter.interpolate_property($saves, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	$saves/enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	yield(get_tree().create_timer(0.5, false), "timeout")
	$saves.visible = false
	$create.visible = true
	$create.modulate = Color(1, 1, 1, 0)
	$create/enter.interpolate_property($create, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	$create/enter.start()
	yield(get_tree().create_timer(0.5, false), "timeout")
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func cancel_settings():
	G.save()
	if $settings/enter.is_active() or $saves/enter.is_active():
		return
	$settings/enter.interpolate_property($settings, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	$settings/enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	yield(get_tree().create_timer(0.5, false), "timeout")
	$settings.visible = false
	$saves.visible = true
	$saves.modulate = Color(1, 1, 1, 0)
	$saves/enter.interpolate_property($saves, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	$saves/enter.start()
	yield(get_tree().create_timer(0.5, false), "timeout")
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enter_settings():
	if $settings/enter.is_active() or $saves/enter.is_active():
		return
	$saves/enter.interpolate_property($saves, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5)
	$saves/enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	yield(get_tree().create_timer(0.5, false), "timeout")
	$saves.visible = false
	$settings.visible = true
	$settings.modulate = Color(1, 1, 1, 0)
	$settings/enter.interpolate_property($settings, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	$settings/enter.start()
	yield(get_tree().create_timer(0.5, false), "timeout")
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func lang():
	if G.main_getv("lang", "ru") == "ru":
		G.main_setv("lang", "en")
		G.save()
		TranslationServer.set_locale(G.main_getv("lang", "en"))
	else:
		G.main_setv("lang", "ru")
		G.save()
		TranslationServer.set_locale(G.main_getv("lang", "ru"))


func delete_save(id):
	$delete_window.get_label().text = tr("sl.delete.text") + " \"" + G.get_save_meta(id, "name", "") + "\"?"
	$delete_window.popup_centered()
	$delete_window.get_ok().release_focus()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	id_to_delete = id


func preconfirm_delete():
	$confirm_delete_window.popup_centered()
	$confirm_delete_window.get_ok().release_focus()


func cancel():
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func confirm_delete():
	var dir = Directory.new()
	dir.remove("user://saves/".plus_file(id_to_delete + ".apa2save"))
	if dir.file_exists("user://custom_levels/" + id_to_delete + ".tscn"):
		dir.remove("user://custom_levels/" + id_to_delete + ".tscn")
	list_saves()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func remove_patches():
	var dir = Directory.new()
	var path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS, false).get_base_dir()
	if dir.file_exists(path.plus_file("apa2_patch.pck")):
		dir.remove(path.plus_file("apa2_patch.pck"))
	G.main_setv("patch_version", 0)
	G.main_setv("patch_code", 0)


func quit():
	G.save()
	get_tree().quit()


func get_save_ids_list():
	var list = Array(G.main_file.get_sections())
	list.erase("config")
	return list


func reload_meta_from_saves():
	for i in G.main_file.get_sections():
		if i == "config":
			continue
		G.main_file.erase_section(i)
	var dir = Directory.new()
	dir.open("user://saves/")
	dir.list_dir_begin(true)
	var filename = dir.get_next()
	while filename != "":
		if not dir.current_is_dir():
			var cf = ConfigFile.new()
			var err = cf.load_encrypted_pass("user://saves/".plus_file(filename), "apa2_save")
			if err:
				filename = dir.get_next()
				continue
			var id = cf.get_value("save", "save_id", "nn")
			G.set_save_meta(id, "last_opened", cf.get_value("save", "last_opened", Time.get_date_dict_from_system()))
			G.set_save_meta(id, "name", cf.get_value("save", "name", "Michail"))
			G.set_save_meta(id, "soul_type", cf.get_value("save", "soul_type", 1))
		filename = dir.get_next()


func duplicate_save(id):
	randomize()
	var cf = ConfigFile.new()
	cf.load_encrypted_pass("user://saves/".plus_file(id + ".apa2save"), "apa2_save")
	cf.set_value("save", "name", (cf.get_value("save", "name", "...") + " (копия)").substr(0, 16))
	var new_id = make_id(cf.get_value("save", "name", "..."))
	cf.set_value("save", "save_id", new_id)
	cf.save_encrypted_pass("user://saves/".plus_file(new_id + ".apa2save"), "apa2_save")
	list_saves()


func make_id(save_name):
	randomize()
	var model = OS.get_model_name()
	if model == "GenericDevice":
		model = str(randi() % 1000000)
	model.replace(" ", "")
	var hash_of_save = str(save_name.hash()).substr(0, 32)
	var random_num = str(randi() % 1000000)
	return model + hash_of_save + random_num
