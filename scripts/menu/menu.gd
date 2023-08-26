extends Control


var ach_panel = load("res://prefabs/menu/achievement_panel.tscn")
onready var pm = $settings/grph_s.get_popup()


func _ready():
	$settings/name_change.get_ok().text = tr("menu.change")
	$settings/name_change.get_cancel().text = tr("menu.cancel")
	$settings/name_change.get_label().align = Label.ALIGN_CENTER
	$settings/conf.get_label().align = Label.ALIGN_CENTER
	$settings/conf.get_cancel().text = tr("menu.cancel")
	$settings/conf.get_ok().text = tr("menu.yes")
	$settings/conf2.get_label().align = Label.ALIGN_CENTER
	$settings/conf2.get_cancel().text = tr("menu.noo")
	$settings/conf2.get_ok().text = tr("menu.yess")
	pm.hide_on_checkable_item_selection = false
	pm.hide_on_item_selection = false
	pm.hide_on_state_item_selection = false
	pm.connect("id_pressed", self, "graphics_menu_id_pressed")
	pm.set_item_checked(pm.get_item_index(10 + G.getv("effects")), true)
	pm.set_item_checked(pm.get_item_index(20 + G.getv("grass_anim")), true)
	for i in range(4):
		var p = int(pow(2, i))
		if G.getv("graphics", G.Graphics.BEAUTY_DEFAULT) & p == 0:
			pm.set_item_checked(pm.get_item_index(i + 30), false)
	$about/version.text = tr("menu.version") + G.VERSION + " " + G.VERSION_STATUS + " " + G.VERSION_STATUS_NUMBER
	$settings/mv_s.value = G.getv("volume", 1)
	$settings/sfxv_s.value = G.getv("volume_sfx", 1)
	$settings/dmp_s.value = G.getv("damping", 2.5)
	$settings/smc_c.pressed = G.getv("smooth_camera", true)
	$settings/save_id.text = tr("menu.save_id") + G.getv("save_id", "undefined")
	$settings/name_change/line_edit.set_message_translation(false)
	$settings/name_change/line_edit.notification(NOTIFICATION_TRANSLATION_CHANGED)
	$settings/name_change/line_edit.placeholder_text = tr("menu.change_name.placeholder")
	var date = G.getv("create_date", Time.get_date_dict_from_system())
	var date_str = "%02d/%02d/%d" % [date["day"], date["month"], date["year"]]
	$settings/creation_date.text = tr("menu.creation_date") + date_str
	for i in G.ach.achievements:
		var n = ach_panel.instance()
		n.get_node("name").text = tr(G.ach.achievements[i]["name"])
		n.get_node("desc").text = tr(G.ach.achievements[i]["desc"])
		n.get_node("bg/icon").texture = G.ach.achievements[i]["icon"]
		if not G.ach.is_completed(i):
			n.modulate = Color(0.5, 0.5, 0.5)
			n.get_node("bg").color = Color.black
			n.get_node("bg/icon").self_modulate = Color.darkblue
		$achievements/scroll/v_box.add_child(n)
	for i in $achievements/stats_window/base/column0.get_children():
		if i.name == "classes_opened":
			i.get_node("count").text = str(G.getv("classes", []).size())
			continue
		i.get_node("count").text = str(G.getv(i.name, 0))
	for i in $achievements/stats_window/base/column1.get_children():
		if i.name == "classes_opened":
			i.get_node("count").text = str(G.getv("classes", []).size())
			continue
		i.get_node("count").text = str(G.getv(i.name, 0))
	var ach_get = 0
	for i in G.ach.achievements:
		if G.ach.is_completed(i):
			ach_get += 1
	$achievements/stats_window/base/achievements_completed/count.text = str(ach_get)
	var secs = G.getv("time")
	var mins = 0
	var hours = 0
	if secs < 60:
		$achievements/stats_window/base/time/count.text = "%02d:%02d" % [mins, secs]
	else:
		mins = floor(secs / 60)
		secs -= mins * 60
		$achievements/stats_window/base/time/count.text = "%02d:%02d" % [mins, secs]
	if mins >= 60:
		hours = floor(mins / 60)
		mins -= hours * 60
		$achievements/stats_window/base/time/count.text = "%d:%02d:%02d" % [hours, mins, secs]
	if OS.has_feature("pc"):
		$settings/contr.hide()
		$settings/contr_pc.show()
	if not G.dialog_in_menu.empty():
		var dialog = $dialog
		dialog.dialog_text = G.dialog_in_menu
		G.dialog_in_menu = ""
		dialog.popup_centered()
	
	if not G.getv("rated", false):
		var curr_lvl = G.getv("level", "1_1")
		var lvls = curr_lvl.split("_")
		if int(lvls[0]) > 1:
			show_rate_dialog()
		elif int(lvls[1]) >= 5:
			show_rate_dialog()


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
	get_tree().change_scene("res://scenes/menu/levels.tscn")


func achievements(val = true):
	$achievements.visible = val
	$main.visible = not val


func settings(val = true):
	$settings/mv_s.grab_focus()
	$settings.visible = val
	$main.visible = not val


func about(val = true):
	G.ach.complete(Achievements.SOME_PEOPLES)
	$about.visible = val
	$main.visible = not val


func license():
	OS.shell_open("https://godotengine.org/license/")


func language():
	if G.getv("lang", "ru") == "ru":
		G.setv("lang", "en")
		G.save()
		TranslationServer.set_locale(G.getv("lang", "en"))
		G.change_to_scene("res://scenes/menu/menu.tscn")
	else:
		G.setv("lang", "ru")
		G.save()
		TranslationServer.set_locale(G.getv("lang", "ru"))
		G.change_to_scene("res://scenes/menu/menu.tscn")


func more():
	OS.shell_open("https://play.google.com/store/apps/dev?id=6112780680526671052")


func quit():
	G.close_save()
	get_tree().change_scene("res://scenes/menu/save_loader.tscn")


func controls():
	get_tree().change_scene("res://scenes/menu/controls.tscn")


func reset():
	var dir = Directory.new()
	var id = G.getv("save_id", "ffff00")
	G.close_save()
	dir.remove("user://saves/".plus_file(id + ".apa2save"))
	if dir.file_exists("user://custom_levels/" + id + ".tscn"):
		dir.remove("user://custom_levels/" + id + ".tscn")
	get_tree().change_scene("res://scenes/menu/save_loader.tscn")


func change_name():
	$settings/name_change.dialog_text = tr("menu.current_name") + G.getv("name", "")
	$settings/name_change/line_edit.text = ""
	$settings/name_change.popup_centered()


func do_change():
	G.setv("name", $settings/name_change/line_edit.text)
	G.set_save_meta(G.getv("save_id", "ffff00"), "name", $settings/name_change/line_edit.text)


func link():
	OS.shell_open("https://t.me/dsgames31")


func show_rate_dialog():
	G.setv("rated", true)
	$rate.get_cancel().text = tr("menu.cancel")
	$rate.get_ok().text = tr("menu.rate")
	$rate.connect("confirmed", self, "rate")
	$rate.popup_centered()


func rate():
	OS.shell_open("https://play.google.com/store/apps/details?id=ru.diamondstudio.alphaplatformer2")


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
			G.setv("graphics", G.getv("graphics", G.Graphics.BEAUTY_DEFAULT) & ~(1 << (id - 30)))
		else:
			if id == 30:
				$settings/beauty_lights_warn.popup_centered()
			pm.set_item_checked(idx, true)
			G.setv("graphics", G.getv("graphics", G.Graphics.BEAUTY_DEFAULT) | (1 << (id - 30)))
