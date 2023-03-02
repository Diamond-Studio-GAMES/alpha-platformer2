extends Control


var pending_promocode = ""
var promos = load("res://misc/promocodes.res")
onready var line = $line_edit
onready var comment = $comment
onready var http = $http
onready var message = $online/message


func back():
	get_tree().change_scene("res://scenes/menu/levels.scn")


func is_promocode_used(code = ""):
	if code in G.getv("promocodes_used", []):
		return true
	return false


func use_promocode(code = ""):
	G.setv("promocodes_used", G.getv("promocodes_used", []) + [code])


func set_comment(text = ""):
	comment.text = text


func enter():
	var text = line.text.to_lower().strip_edges().strip_escapes()
	line.text = ""
	if is_promocode_used(text):
		set_comment("Этот промокод уже использован!")
		return
	if text.begins_with("online_"):
		fetch_online_promocode(text)
		return
	var found = false
	for i in promos.promocodes:
		var promo = i
		if promo.id == text:
			if not promo.custom_method_pass.empty():
				if not promo.call(promo.custom_method_pass, self):
					continue
			found = true
			set_comment(promo.comment)
			if not promo.reward.empty():
				G.receive_loot(promo.reward)
			if not promo.multiple_uses:
				use_promocode(text)
			if not promo.custom_method.empty():
				promo.call(promo.custom_method, self)
	if not found:
		set_comment("Введён неверный промокод!")


func fetch_online_promocode(text):
	pending_promocode = text
	$online.popup_centered()
	set_message("Загрузка онлайн-промокодов...")
	http.download_file = "user://online_cache.cfg"
	http.connect("request_completed", self, "request0", [], CONNECT_ONESHOT)
	var err = http.request("http://f0695447.xsph.ru/apa2_online.cfg")
	if err:
		set_message("Ошибка загрузки!", true)


func request0(result, code, header, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		set_message("Ошибка загрузки!", true)
		return
	set_message("Поиск промокода в файле...")
	yield(get_tree(), "idle_frame")
	var cf = ConfigFile.new()
	var err = cf.load_encrypted_pass("user://online_cache.cfg", "apa2_online")
	if err:
		set_message("Ошибка чтения файла!", true)
		return
	if not cf.has_section(pending_promocode):
		set_message("Промокод не найден!", true)
		return
	if cf.has_section_key(pending_promocode, "only_for_ids"):
		if not G.getv("save_id", "none") in cf.get_value(pending_promocode, "only_for_ids", []):
			set_message("Промокод не найден!", true)
			return
	var reward = cf.get_value(pending_promocode, "reward", {})
	var comment = cf.get_value(pending_promocode, "comment", "")
	use_promocode(pending_promocode)
	G.receive_loot(reward)
	set_message(comment, true)


func set_message(mes, abort = false):
	if abort:
		set_comment(mes)
		$online.hide()
		return
	message.text = mes


func _exit_tree():
	var dir = Directory.new()
	dir.remove("user://online_cache.cfg")
