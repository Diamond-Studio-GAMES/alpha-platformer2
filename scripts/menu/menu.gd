extends Control


func _ready():
	$settings/name_change.get_ok().text = "Сменить"
	$settings/name_change.get_cancel().text = "Отмена"
	$settings/name_change.get_label().align = Label.ALIGN_CENTER
	$settings/conf.get_label().align = Label.ALIGN_CENTER
	$settings/conf.get_cancel().text = "Отмена"
	$settings/conf.get_ok().text = "Да"
	$settings/conf2.get_label().align = Label.ALIGN_CENTER
	$settings/conf2.get_cancel().text = "НЕТ!"
	$settings/conf2.get_ok().text = "да"
	$about/version.text = "Версия: " + G.VERSION + " " + G.VERSION_STATUS + " " + G.VERSION_STATUS_NUMBER
	$settings/mv_s.value = G.getv("volume", 1)
	$settings/sfxv_s.value = G.getv("volume_sfx", 1)
	$settings/efcts_s.selected = G.getv("effects", Globals.EffectsType.STANDARD)
	$settings/dmp_s.value = G.getv("damping", 2.5)
	$settings/smc_c.pressed = G.getv("smooth_camera", true)
	$settings/light_c.pressed = G.getv("beauty_light", true)
	$settings/save_id.text = "ID сохранения: " + G.getv("save_id", "undefined")
	var date = G.getv("create_date", Time.get_datetime_dict_from_system())
	var date_str = "%02d/%02d/%d" % [date["day"], date["month"], date["year"]]
	$settings/creation_date.text = "Дата создания: " + date_str
	if OS.has_feature("pc"):
		$settings/contr.hide()
		$settings/contr_pc.show()


func _process(delta):
	G.setv("volume", $settings/mv_s.value)
	G.setv("volume_sfx", $settings/sfxv_s.value)
	G.setv("damping", $settings/dmp_s.value)
	G.setv("smooth_camera", $settings/smc_c.pressed)
	G.setv("beauty_light", $settings/light_c.pressed)
	G.setv("effects", $settings/efcts_s.selected)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"), linear2db($settings/mv_s.value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("sfx"), linear2db($settings/sfxv_s.value))


func copy_id():
	OS.clipboard = G.getv("save_id", "undefined")


func play():
	get_tree().change_scene("res://scenes/menu/levels.scn")


func achievements(val = true):
	$achievements.visible = val
	$main.visible = not val


func settings(val = true):
	$settings/mv_s.grab_focus()
	$settings.visible = val
	$main.visible = not val


func about(val = true):
	$about.visible = val
	$main.visible = not val


func language():
	if G.getv("lang", "ru") == "ru":
		G.setv("lang", "en")
		G.save()
		TranslationServer.set_locale(G.getv("lang", "en"))
		G.change_to_scene("res://scenes/menu/menu.scn")
	else:
		G.setv("lang", "ru")
		G.save()
		TranslationServer.set_locale(G.getv("lang", "ru"))
		G.change_to_scene("res://scenes/menu/menu.scn")


func more():
	OS.shell_open("https://play.google.com/store/apps/dev?id=6112780680526671052")


func quit():
	G.unload_save()
	get_tree().change_scene("res://scenes/menu/save_loader.scn")


func controls():
	get_tree().change_scene("res://scenes/menu/controls.scn")


func reset():
	var dir = Directory.new()
	var id = G.getv("save_id", "ffff00")
	G.unload_save()
	dir.remove("user://saves/".plus_file(id + ".apa2save"))
	if dir.file_exists("user://custom_levels/" + id + ".scn"):
		dir.remove("user://custom_levels/" + id + ".scn")
	get_tree().change_scene("res://scenes/menu/save_loader.scn")


func change_name():
	$settings/name_change.dialog_text = "Текущее имя: " + G.getv("name", "")
	$settings/name_change/line_edit.text = ""
	$settings/name_change.popup_centered()


func do_change():
	G.setv("name", $settings/name_change/line_edit.text)
	G.set_save_meta(G.getv("save_id", "ffff00"), "name", $settings/name_change/line_edit.text)


func link():
	OS.shell_open("https://t.me/dsgames31")
