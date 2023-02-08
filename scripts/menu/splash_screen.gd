extends Control


func go_to_save_loader():
	get_tree().change_scene("res://scenes/menu/save_loader.scn")


func _ready():
	$privacy_policy.get_close_button().hide()
	$age.get_close_button().hide()
	TranslationServer.set_locale(G.file.get_value("main", "lang", "ru"))
	if not G.file.get_value("main", "privacy_policy", false):
		G.file.set_value("main", "lang", "ru" if OS.get_locale_language() == "ru" else "en")
		TranslationServer.set_locale(G.file.get_value("main", "lang", "en"))
		$privacy_policy.popup_centered()
		return
	if not G.file.has_section_key("main", "age"):
		$age.popup_centered()
		return
	AdManager.initialize(G.file.get_value("main", "age", 0))
	$anim.play("splash")
	var file = File.new()
	if file.file_exists(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS, false).get_base_dir().plus_file("apa2_patch.pck")):
		ProjectSettings.load_resource_pack(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS, false).get_base_dir().plus_file("apa2_patch.pck"))


func open_link():
	OS.shell_open("http://diamondstudiogames.tilda.ws/privacy_policy")


func check_toggled(state):
	$privacy_policy/next.disabled = not state


func accept_policy():
	G.file.set_value("main", "privacy_policy", true)
	G.save()
	restart()


func accept_consent():
	G.file.set_value("main", "age", $age/slider.value)
	G.save()
	restart()


func _on_slider_value_changed(value):
	$age/age_panel/text.text = str(value)


func restart():
	get_tree().reload_current_scene()
