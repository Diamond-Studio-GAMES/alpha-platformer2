extends Control


var done_checking = false
var can_update = false
onready var http = $http
onready var label = $label

signal check_done


func end_splash():
	if done_checking:
		finish()
	else:
		yield(self, "check_done")
		finish()


func finish():
	if can_update:
		$update.popup_centered()
		yield($update, "popup_hide")
	var file = File.new()
	var path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS, false).get_base_dir()
	if file.file_exists(path.plus_file("apa2_patch.pck")):
		if G.main_getv("patch_code", 0) == G.VERSION_CODE:
			ProjectSettings.load_resource_pack(path.plus_file("apa2_patch.pck"))
	get_tree().change_scene("res://scenes/menu/save_loader.scn")


func _ready():
	$update.get_ok().text = tr("ss.update.do")
	$update.get_cancel().text = tr("ss.update.cancel")
	$privacy_policy.get_close_button().hide()
	$age.get_close_button().hide()
	TranslationServer.set_locale(G.main_getv("lang", "ru"))
	if not G.main_getv("privacy_policy", false):
		G.main_setv("lang", "ru" if OS.get_locale_language() == "ru" else "en")
		TranslationServer.set_locale(G.main_getv("lang", "en"))
		$privacy_policy.popup_centered()
		return
	if G.main_getv("age", -1) < 0:
		$age.popup_centered()
		return
	
	var dir = Directory.new()
	var path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS, false).get_base_dir()
	if dir.file_exists(path.plus_file("apa2_patch.pck")):
		if G.main_getv("patch_code", 0) != G.VERSION_CODE:
			dir.remove(path.plus_file("apa2_patch.pck"))
			G.main_setv("patch_version", 0)
			G.main_setv("patch_code", 0)
	
	G.ad.initialize(G.main_getv("age", 0))
	$anim.play("splash")
	check_updates()


func check_updates():
	if not G.main_getv("check_upd", true):
		check_patches()
		return
	label.text = tr("ss.status.check.upd")
	http.connect("request_completed", self, "update_request", [], CONNECT_ONESHOT)
	var err = http.request("http://f0695447.xsph.ru/versions.json")
	if err:
		check_patches()


func update_request(result, code, header, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		check_patches()
		return
	var data = JSON.parse(body.get_string_from_utf8())
	if data.error:
		check_patches()
		return
	if data.result.beta > G.VERSION_CODE and G.main_getv("check_beta", not G.VERSION_STATUS.empty()):
		$update.window_title = tr("ss.update.title") + " (BETA)"
		$update.dialog_text = tr("ss.update.text") + " (BETA)"
		can_update = true
	if data.result.stable > G.VERSION_CODE:
		can_update = true
	check_patches()


func check_patches():
	if not G.main_getv("check_patches", true):
		end_check()
		return
	label.text = tr("ss.status.check.patch")
	http.connect("request_completed", self, "patch_request", [], CONNECT_ONESHOT)
	var err = http.request("http://f0695447.xsph.ru/patches.json")
	if err:
		end_check()


func patch_request(result, code, header, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		end_check()
		return
	var data = JSON.parse(body.get_string_from_utf8())
	if data.error:
		end_check()
		return
	if data.result.has(str(G.VERSION_CODE)):
		if data.result[str(G.VERSION_CODE)] > G.main_getv("patch_version", 0):
			http.download_file = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS, false).get_base_dir().plus_file("apa2_patch.pck")
			http.connect("request_completed", self, "download_patch", [data.result[str(G.VERSION_CODE)]], CONNECT_ONESHOT)
			var err = http.request("http://f0695447.xsph.ru/" + str(G.VERSION_CODE) + "patch.pck")
			label.text = tr("ss.status.download")
			if err:
				end_check()
		else:
			end_check()
	else:
		end_check()


func download_patch(result, code, header, body, version):
	if result != HTTPRequest.RESULT_SUCCESS:
		end_check()
		return
	G.main_setv("patch_version", version)
	G.main_setv("patch_code", G.VERSION_CODE)
	end_check()


func end_check():
	done_checking = true
	emit_signal("check_done")
	label.text = ""


func open_link():
	OS.shell_open("http://diamondstudiogames.tilda.ws/privacy_policy")


func open_update_link():
	OS.shell_open("https://play.google.com/store/apps/details?id=ru.diamondstudio.alphaplatformer2")


func check_toggled(state):
	$privacy_policy/next.disabled = not state


func accept_policy():
	G.main_setv("privacy_policy", true)
	G.save()
	restart()


func accept_consent():
	G.main_setv("age", $age/slider.value)
	G.save()
	restart()


func _on_slider_value_changed(value):
	$age/age_panel/text.text = str(value)


func restart():
	get_tree().reload_current_scene()
