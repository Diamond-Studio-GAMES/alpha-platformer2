extends Control


onready var pm = $settings/grph_s.get_popup()


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
	pm.hide_on_checkable_item_selection = false
	pm.hide_on_item_selection = false
	pm.hide_on_state_item_selection = false
	pm.connect("id_pressed", self, "graphics_menu_id_pressed")
	pm.set_item_checked(pm.get_item_index(10 + G.getv("effects")), true)
	pm.set_item_checked(pm.get_item_index(20 + G.getv("grass_anim")), true)
	for i in range(4):
		var p = int(pow(2, i))
		if G.getv("graphics", G.Graphics.BEAUTY_ALL) & p == 0:
			pm.set_item_checked(pm.get_item_index(i + 30), false)
	$about/version.text = "Версия: " + G.VERSION + " " + G.VERSION_STATUS + " " + G.VERSION_STATUS_NUMBER
	$settings/mv_s.value = G.getv("volume", 1)
	$settings/sfxv_s.value = G.getv("volume_sfx", 1)
	$settings/dmp_s.value = G.getv("damping", 2.5)
	$settings/smc_c.pressed = G.getv("smooth_camera", true)
	$settings/save_id.text = "ID сохранения: " + G.getv("save_id", "undefined")
	var date = G.getv("create_date", Time.get_date_dict_from_system())
	var date_str = "%02d/%02d/%d" % [date["day"], date["month"], date["year"]]
	$settings/creation_date.text = "Дата создания: " + date_str
	if OS.has_feature("pc"):
		$settings/contr.hide()
		$settings/contr_pc.show()
	if not G.dialog_in_menu.empty():
		var dialog = $dialog
		dialog.dialog_text = G.dialog_in_menu
		G.dialog_in_menu = ""
		dialog.popup_centered()


func _process(delta):
	G.setv("volume", $settings/mv_s.value)
	G.setv("volume_sfx", $settings/sfxv_s.value)
	G.setv("damping", $settings/dmp_s.value)
	G.setv("smooth_camera", $settings/smc_c.pressed)
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
	G.close_save()
	get_tree().change_scene("res://scenes/menu/save_loader.scn")


func controls():
	get_tree().change_scene("res://scenes/menu/controls.scn")


func reset():
	var dir = Directory.new()
	var id = G.getv("save_id", "ffff00")
	G.close_save()
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


func graphics_menu_id_pressed(id):
	if id in range(1, 4):
		return
	var idx = pm.get_item_index(id)
	if id >= 10 and id < 20:
		G.setv("effects", id - 10)
		for i in range(10, 13):
			pm.set_item_checked(pm.get_item_index(i), false)
		pm.set_item_checked(idx, true)
	elif id >= 20 and id < 30:
		G.setv("grass_anim", id - 20)
		for i in range(20, 23):
			pm.set_item_checked(pm.get_item_index(i), false)
		pm.set_item_checked(idx, true)
	else:
		if pm.is_item_checked(idx):
			pm.set_item_checked(idx, false)
			G.setv("graphics", G.getv("graphics", G.Graphics.BEAUTY_ALL) & ~(1 << (id - 30)))
		else:
			pm.set_item_checked(idx, true)
			G.setv("graphics", G.getv("graphics", G.Graphics.BEAUTY_ALL) | (1 << (id - 30)))
