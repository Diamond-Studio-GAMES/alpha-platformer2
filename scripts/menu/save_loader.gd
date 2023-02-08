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
var save_obj = load("res://prefabs/menu/save.scn")
var id_to_delete = ""


func _ready():
	if not G.file.has_section_key("main", "volume"):
		G.file.set_value("main", "volume", 0.75)
		G.file.set_value("main", "volume_sfx", 1)
		G.file.set_value("main", "fullscr", false)
		G.file.set_value("main", "fps", false)
	TranslationServer.set_locale(G.file.get_value("main", "lang", "ru"))
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
	$settings/mv_s.value = G.file.get_value("main", "volume", 0.75)
	$settings/sfxv_s.value = G.file.get_value("main", "volume_sfx", 1)
	$settings/fullscr.pressed = G.file.get_value("main", "fullscr", false)
	$settings/fps.pressed = G.file.get_value("main", "fps", false)
	$create/name.placeholder_text = tr("sl.create.pname")
	$create/name.set_message_translation(false)
	$create/name.notification(NOTIFICATION_TRANSLATION_CHANGED)
	list_saves()


func list_saves():
	$saves/empty_text.hide()
	for i in $saves/scroll/saves.get_children():
		i.queue_free()
	var list_of_saves = []
	list_of_saves = Array(G.file.get_sections())
	if list_of_saves.has("main"):
		list_of_saves.erase("main")
	if list_of_saves.size() <= 0:
		$saves/empty_text.show()
		return
	for i in list_of_saves:
		var node = save_obj.instance()
		node.get_node("name").text = G.file.get_value(i, "name", "???")
		var date = G.file.get_value(i, "last_opened", Time.get_datetime_dict_from_system())
		var date_str = str(date["day"]) + "/" + str(date["month"]) + "/" + str(date["year"])
		node.get_node("date").text = date_str
		node.get_node("soul").self_modulate = G.SOUL_COLORS[G.file.get_value(i, "soul_type", 6)]
		node.get_node("play").connect("pressed", self, "play", [i])
		node.get_node("copy").connect("pressed", self, "duplicate_save", [i])
		node.get_node("delete").connect("pressed", self, "delete_save", [i])
		$saves/scroll/saves.add_child(node)


func _process(delta):
	$create/soul_type.visible = $create/hardcore.pressed
	$create/soul_type_text.visible = $create/hardcore.pressed
	if $create/hardcore.pressed:
		soul.self_modulate = G.SOUL_COLORS[$create/soul_type.selected]
	else:
		soul.self_modulate = Color.red
	if $create/name.text.strip_edges().empty() or G.file.has_section($create/name.text.strip_edges().to_lower()):
		$create/create.disabled = true
	else:
		$create/create.disabled = false
	
	G.file.set_value("main", "volume", $settings/mv_s.value)
	G.file.set_value("main", "volume_sfx", $settings/sfxv_s.value)
	if OS.has_feature("pc"):
		G.file.set_value("main", "fullscr", $settings/fullscr.pressed)
		OS.window_fullscreen = $settings/fullscr.pressed
	else:
		$settings/fullscr.visible = false
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db($settings/mv_s.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db($settings/sfxv_s.value))


func fps_button_changed(state):
	G.fps_text.visible = state
	G.file.set_value("main", "fps", state)


func create():
	var id = $create/name.text.strip_edges().to_lower()
	G.current_save = id
	G.setv("save_id", make_id(G.current_save))
	G.setv("last_opened", Time.get_datetime_dict_from_system())
	G.setv("name", $create/name.text)
	G.setv("create_date", Time.get_datetime_dict_from_system())
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
	G.setv("volume", G.file.get_value("main", "volume", 0.75))
	G.setv("volume_sfx", G.file.get_value("main", "volume_sfx", 1))
	G.setv("lang", G.file.get_value("main", "lang", OS.get_locale_language()))
	G.setv("hero_chance", 2)
	$enter.interpolate_property($enter_color, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 2)
	$enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	G.save()
	yield(get_tree().create_timer(2.0, false), "timeout")
	TranslationServer.set_locale(G.getv("lang", "ru"))
	get_tree().change_scene("res://scenes/menu/story.scn")


func play(id):
	G.current_save = id
	G.setv("last_opened", Time.get_datetime_dict_from_system())
	if G.getv("save_id", "0") == "0":
		G.setv("save_id", make_id(G.current_save))
	G.save()
	$enter.interpolate_property($enter_color, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 1)
	$enter.start()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_STOP
	yield(get_tree().create_timer(1.0, false), "timeout")
	TranslationServer.set_locale(G.getv("lang", "ru"))
	get_tree().change_scene("res://scenes/menu/menu.scn")


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
	if G.file.get_value("main", "lang", "ru") == "ru":
		G.file.set_value("main", "lang", "en")
		G.save()
		TranslationServer.set_locale(G.file.get_value("main", "lang", "en"))
	else:
		G.file.set_value("main", "lang", "ru")
		G.save()
		TranslationServer.set_locale(G.file.get_value("main","lang", "ru"))
	get_tree().reload_current_scene()


func delete_save(id):
	$delete_window.get_label().text = tr("sl.delete.text") + " \"" + G.file.get_value(id, "name", "") + "\"?"
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
	G.file.erase_section(id_to_delete)
	G.save()
	var dir = Directory.new()
	if dir.file_exists("user://custom_level_" + str(G.current_save.hash()) + ".scn"):
		dir.remove("user://custom_level_" + str(G.current_save.hash()) + ".scn")
	list_saves()
	$enter_color.mouse_filter = Control.MOUSE_FILTER_IGNORE


func quit():
	G.save()
	get_tree().quit()


func duplicate_save(id):
	randomize()
	var keys = Array(G.file.get_section_keys(id))
	var new_id = id + str(randi()%10000)
	for i in keys:
		G.file.set_value(new_id, i, G.file.get_value(id, i))
	G.file.set_value(new_id, "save_id", "0")
	G.file.set_value(new_id, "name", G.file.get_value(new_id, "name", "") + " (копия)")
	G.save()
	list_saves()

func make_id(save_name):
	randomize()
	var model = OS.get_model_name()
	if model == "GenericDevice":
		model = str(randi()%1000000)
	var hash_of_save = str(save_name.hash()).substr(0, 32)
	var random_num = str(randi()%1000000)
	return model + hash_of_save + random_num
