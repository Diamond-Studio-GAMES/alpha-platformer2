extends Control


var pending_promocode = ""
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
	match text:
		"женщина":
			set_comment("Ах ты натурал")
			G.receive_loot({"gems":-10, "coins":-1000})
			use_promocode(text)
		"gomik":
			set_comment("Одобряю")
			G.receive_loot({"gems":3, "coins":333})
			use_promocode(text)
		"накачанныемужикитоп":
			set_comment("No Homo")
			G.receive_loot({"gems":5, "coins":750})
			use_promocode(text)
		"бастертоп":
			set_comment("Вы потеряли девственность и получили 2-х отцов.")
			G.receive_loot({"gems":-3, "coins":-500})
			use_promocode(text)
		"бастерхуйня":
			set_comment("Вы вернули девственность и лишились лишних пап.")
			G.receive_loot({"gems":5, "coins":1000})
			use_promocode(text)
		"миста4444":
			set_comment("Мииииста, покорми нас!")
			G.receive_loot({"gems":4, "coins":444})
			use_promocode(text)
		"s1r@0o":
			set_comment("O_O")
			G.receive_loot({"gems":25, "coins":4500})
			use_promocode(text)
		"brawlstars":
			set_comment("Фигня для малолеток")
			G.receive_loot({"gems":1, "coins":10})
			use_promocode(text)
		"маленькийящик":
			set_comment("Эль Прима")
			G.receive_loot({"box":1})
			use_promocode(text)
		"matchland":
			set_comment("Первоистоки!")
			G.receive_loot({"diamond_box":1})
			use_promocode(text)
		"мама":
			set_comment("А у меня...")
			G.receive_loot({"diamond_box":1})
			use_promocode(text)
		"феминизм":
			set_comment("НА СУКА!!!")
			G.setv("gems", -4)
			use_promocode(text)
			G.save()
			yield(get_tree().create_timer(0.5, false), "timeout")
			get_tree().quit()
		"отисгандонище":
			set_comment("Фактишь, нёрфите тварь!")
			G.receive_loot({"gems":-59})
			yield(G, "loot_end")
			G.receive_loot({"gems":60})
			use_promocode(text)
		"aestas":
			set_comment("ok.")
			G.receive_loot({"gems":15})
			use_promocode(text)
		"дотатоп":
			set_comment("+3 отца, сладкий, в кроватку идём? <3 <3 <3")
			G.receive_loot({"gems":5, "coins":1000})
			use_promocode(text)
		"сииииии":
			set_comment("Две си.. и пи..")
			G.receive_loot({"gems":7})
			use_promocode(text)
		"хайгитлер":
			set_comment("Рука, опустись! Нацизм - плохо! Я осуждаю!")
			G.receive_loot({"gems":-5, "coins":-500})
			use_promocode(text)
		"еврей":
			set_comment("У меня тоже еврейская душа, не парься... О! Кошелёк!")
			G.receive_loot({"gems":10})
			yield(G, "loot_end")
			G.receive_loot({"gems":-11})
			use_promocode(text)
		"ладно":
			set_comment("ладно")
			G.receive_loot({"gems":1})
			use_promocode(text)
		"алиэкспрессср":
			set_comment("РАСПРОДАЖА НА АЛИЭКСПРЕСС, НА АЛИЭКСПРЕСС, ТОЛЬКО НА АЛИЭКСПРЕСС!!!")
			G.receive_loot({"gold_box":1, "coins":111})
			use_promocode(text)
		"ивангайтоп":
			set_comment("Пидорок он безмамный, хохол-русофоб ёбаный!")
			G.receive_loot({"gems":-10, "coins":-1000})
			use_promocode(text)
		"140мегаящиков":
			set_comment("\"компенсация\"")
			G.receive_loot({"gems":1, "coins":140})
			use_promocode(text)
		"money8800":
			set_comment("Где деньги взять - давно известно!")
			G.receive_loot({"gems":8, "coins":800})
			use_promocode(text)
		"пизда":
			set_comment("Нееееет!")
			G.receive_loot({"gems":10, "gold_box":3})
			use_promocode(text)
		"apa", "aurs", "kitchenchallenge":
			set_comment("имба игра, история...")
		"6класс":
			G.receive_loot({"coins":1})
			set_comment("лучший!")
		"гиа":
			G.receive_loot({"coins":-1})
			set_comment("бррррр, но было весело!")
		"hardcore":
			randomize()
			if not G.getv("hardcore"):
				continue
			if G.getv("classes", []).empty():
				G.receive_loot({"class":[G.CLASSES_ID[randi()%5]]})
			else:
				G.receive_loot({"coins":1000})
			use_promocode(text)
			set_comment("Держи помощь!")
		"дьяволо":
			$diavolo.show()
		"главныймаг":
			set_comment("Он настолько силен, что может управлять самим временем...")
			use_promocode(text)
		"смерть":
			set_comment("Секретный класс, прибывший из другого измерения...")
			use_promocode(text)
		"способности":
			if not is_promocode_used("смерть"):
				continue
			set_comment("Обладает таинственной тёмной энергией, позволяющей прыгать между измерениями и управлять ими...")
			use_promocode(text)
		"время":
			if not is_promocode_used("способности"):
				continue
			set_comment("Управлять им способны лишь полные силы существа...\n И сама СМЕРТЬ 0586785675490468567900100101001001001010010010100101010100100100000000000000000000000000000000000000000000")
			use_promocode(text)
			yield(get_tree().create_timer(0.5), "timeout")
			G.save()
			get_tree().quit()
		"хемек":
			set_comment("NaHCO3 - сода")
			G.receive_loot({"gems":3, "coins":3})
			use_promocode(text)
		"географек":
			set_comment("Это не про меня")
			G.receive_loot({"gems":2, "coins":200})
			use_promocode(text)
		"программест":
			set_comment("0101010101010101010101")
			G.receive_loot({"gems":1, "coins":110})
			yield(G, "loot_end")
			G.receive_loot({"gems":0, "coins":101})
			use_promocode(text)
		"прыжокверы666":
			set_comment("Саввушки 2022 1 сезон референс")
			G.receive_loot({"gems":6, "coins":666})
			use_promocode(text)
		"юляподкамнем":
			set_comment("Саввушки 2021 референс")
			G.receive_loot({"gems":1, "coins":150})
			use_promocode(text)
		"пенис":
			set_comment("я помню ***** большой...")
			G.receive_loot({"wild_tokens":123})
			use_promocode(text)
		"гроб":
			set_comment("борг")
			use_promocode(text)
			G.receive_loot({"box":15})
		"3,14дверь":
			use_promocode(text)
			set_comment("Сам такой :((((")
			G.receive_loot({"gems":3.14, "coins":314})
			yield(G, "loot_end")
			G.receive_loot({"gems":0.86})
			G.save()
		"0":
			use_promocode(text)
			set_comment("ОШИБКА СТОП 0000000000000")
			G.setv("gems", 0)
			G.setv("coins", 0)
		"skiba":
			set_comment("suka")
			use_promocode(text)
			G.receive_loot({"gems":6, "coins":6, "wild_tokens":6})
		"andrey":
			set_comment("не Андрей а ONDREW")
			use_promocode(text)
			G.receive_loot({"gems":11, "coins":1750})
		_:
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
