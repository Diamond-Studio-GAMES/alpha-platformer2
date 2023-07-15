extends Node
class_name Globals, "res://textures/gui/alpha_text.png"


const VERSION = "0.8.0"
const VERSION_STATUS = "сборка"
const VERSION_STATUS_NUMBER = "4"
const VERSION_CODE = 57

var main_file: ConfigFile
var save_file: ConfigFile
var save_timer = 0
var selected_class_to_test = "knight"
var current_level = "1_1"
var curr_scene = ""
var cached_ip = ""
var cached_suff = 0
var custom_respawn_scene = ""
var dialog_in_menu = ""
var time_scale_change = 1
var fps_text
var music
var time_timer
var ad: AdsManager
var ach: Achievements
var loading_scene = load("res://scenes/menu/loading.scn")
var box = load("res://scenes/menu/box.scn")
const CLASSES_ID = {
	-1 : "player",
	0 : "knight",
	1 : "butcher",
	2 : "spearman",
	3 : "wizard",
	4 : "archer",
	5 : "player"
}
const CLASSES_BY_ID = {
	"knight" : 0,
	"butcher" : 1,
	"spearman" : 2,
	"wizard" : 3,
	"archer" : 4,
	"player" : 5
}
const RIM_NUMBERS = {
	1 : "I",
	2 : "II",
	3 : "III",
	4 : "IV",
	5 : "V"
}
const GADGETS = {
	"knight" : "При активации следующие 2 секунды Рыцарь уклониться от любых атак.",
	"butcher" : "При активации Мясник прыгает на среднюю высоту, и при приземлении отбрасывает близжайщих врагов, нанося им 110 ед. урона.",
	"spearman" : "При активация Копьеносец наносит мощный удар вблизи, сильно отбрасывая врага и нанося ему 250 ед. урона.",
	"wizard" : "При активация Маг немедленно заряжает особый навык на 40%.",
	"archer" : "При активации Лучник создаёт град стрел над собой, летящих вниз, даже сквозь препятствия. Наносит 150 ед. урона и отбрасывает."
}
const SOUL_POWERS = {
	"knight" : "Даёт 20% шанс уклониться от атаки.",
	"butcher" : "Шанс 20% зарядить навык на 15% при получении урона.",
	"spearman" : "20% шанс атакой вблизи оглушить врага на 1.25 секунды.",
	"wizard" : "Даёт 15% шанс исцелиться на 10% при попадании дальнобойной атаки.",
	"archer" : "45% шанс при попадании ближней атакой нанести этот урон всем врагам в радиусе 2 блоков."
}
const CLASSES = {
	"knight" : "РЫЦАРЬ",
	"butcher" : "МЯСНИК",
	"spearman" : "КОПЬЕНОСЕЦ",
	"wizard" : "МАГ",
	"archer" : "ЛУЧНИК",
	"player" : "НЕТ"
}
const ULTIS = {
	"knight" : "ШКВАЛ",
	"butcher" : "УДАР",
	"spearman" : "ОГЛУШЕНИЕ",
	"wizard" : "ЛЕЧЕНИЕ",
	"archer" : "НАЛЁТ"
}
const CLASS_COLORS = {
	"knight" : Color(0.8, 0, 0),
	"butcher" : Color(0.8, 0.8, 0),
	"spearman" : Color(0, 0.8, 0),
	"wizard" : Color(0.8, 0, 0.8),
	"archer" : Color(0, 0.8, 0.8)
}
const CLASS_COLORS_LIGHT = {
	"knight" : Color(1, 0, 0),
	"butcher" : Color(1, 1, 0),
	"spearman" : Color(0, 1, 0),
	"wizard" : Color(1, 0, 1),
	"archer" : Color(0, 1, 1)
}
const CLASS_COLORS_HIGHLIGHT = {
	"knight" : Color(1, 0.25, 0.25),
	"butcher" : Color(1, 1, 0.25),
	"spearman" : Color(0.25, 1, 0.25),
	"wizard" : Color(1, 0.25, 1),
	"archer" : Color(0.25, 1, 1)
}
const SOUL_COLORS = {
	6 : Color.red,
	0 : Color.orange,
	1 : Color.yellow,
	2 : Color.green,
	3 : Color.cyan,
	4 : Color.blue,
	5 : Color.magenta
}
const AMULET = {
	-1 : "none",
	0 : "power",
	1 : "defense",
	2 : "health",
	3 : "speed",
	4 : "reload",
	5 : "ulti",
}
const AMULET_ID = {
	"none" : -1,
	"power" : 0,
	"defense" : 1,
	"health" : 2,
	"speed" : 3,
	"reload" : 4,
	"ulti" : 5,
}
const AMULET_NAME = {
	-1 : "Нет",
	0 : "Сила",
	1 : "Защита",
	2 : "Здоровье",
	3 : "Скорость",
	4 : "Перезарядка",
	5 : "Навык",
}
const AMULET_MAX = {
	-1 : 0,
	0 : 22,
	1 : 19,
	2 : 22,
	3 : 21,
	4 : 20,
	5 : 25,
}
enum EffectsType {
	STANDARD = 0,
	SIMPLE = 1,
	DISABLED = 2,
}
enum GrassType {
	GPU = 0,
	CPU = 1,
	STATIC = 2,
}
enum Graphics {
	BEAUTY_LIGHT = 1,
	BEAUTY_WATER = 2,
	BEAUTY_LAVA = 4,
	BEAUTY_FIRE = 8,
	BEAUTY_ALL = 15,
}
enum Amulet {
	POWER = 0,
	DEFENSE = 1,
	HEALTH = 2,
	SPEED = 3,
	RELOAD = 4,
	ULTI = 5,
	NONE = -1,
}
signal loot_end
signal loaded_to_scene(path)


func _ready():
	main_file = ConfigFile.new()
	main_file.load_encrypted_pass("user://main.apa2", "main")
	var dir = Directory.new()
	if not dir.dir_exists("user://saves/"):
		dir.make_dir_recursive("user://saves/")
	if dir.file_exists("user://saves.game"):
		var cf = ConfigFile.new()
		cf.load("user://saves.game")
		for i in cf.get_sections():
			if i == "main":
				continue
			var file = ConfigFile.new()
			for j in cf.get_section_keys(i):
				file.set_value("save", j, cf.get_value(i, j))
			file.save_encrypted_pass("user://saves/".plus_file(cf.get_value(i, "save_id", "file" + str(randi())) + ".apa2save"), "apa2_save")
		dir.remove("user://saves.game")
	
	randomize()
	get_tree().connect("node_added", self, "_node_added")
	ad = AdsManager.new()
	ad.name = "ads"
	add_child(ad)
	ach = Achievements.new()
	ach.name = "achievements"
	ach.layer = 80
	ach.pause_mode = PAUSE_MODE_PROCESS
	add_child(ach)
	music = AudioStreamPlayer.new()
	music.name = "menu_music"
	music.bus = "music"
	music.stream = load("res://sounds/music/menu/menu.ogg")
	add_child(music)
	fps_text = load("res://prefabs/menu/fps_counter.scn").instance()
	fps_text.visible = G.main_getv("fps", false)
	add_child(fps_text)
	time_timer = Timer.new()
	time_timer.name = "timer"
	time_timer.wait_time = 1
	time_timer.pause_mode = PAUSE_MODE_PROCESS
	add_child(time_timer)
	time_timer.connect("timeout", self, "update_timer")
	time_timer.start()
	if OS.has_feature("editor") or OS.has_feature("cheats"):
		var ch = load("res://prefabs/menu/cheats.scn").instance()
		add_child(ch)


func _process(delta):
	save_timer += delta
	if save_timer >= 20:
		save()
		save_timer = 0


func _notification(what):
	match what:
		NOTIFICATION_APP_PAUSED, NOTIFICATION_PAUSED, \
		NOTIFICATION_WM_GO_BACK_REQUEST, NOTIFICATION_WM_UNFOCUS_REQUEST, \
		NOTIFICATION_WM_QUIT_REQUEST, NOTIFICATION_EXIT_TREE:
			Engine.time_scale = time_scale_change
			save()


func _node_added(node):
	if node == get_tree().current_scene:
		update_music(node)


func getv(name, default_value = 0):
	return save_file.get_value("save", name, default_value)


func setv(name, value):
	save_file.set_value("save", name, value)


func addv(name, value, default_value = 0):
	save_file.set_value("save", name, save_file.get_value("save", name, default_value) + value)


func main_setv(name, value):
	main_file.set_value("config", name, value)


func main_getv(name, default_value = 0):
	return main_file.get_value("config", name, default_value)


func main_addv(name, value, default_value = 0):
	main_file.set_value("config", name, main_file.get_value("config", name, default_value) + value)


func set_save_meta(id, meta, data):
	main_file.set_value(id, meta, data)


func get_save_meta(id, meta, data):
	return main_file.get_value(id, meta, data)


func save():
	main_file.save_encrypted_pass("user://main.apa2", "main")
	if save_file != null:
		save_file.save_encrypted_pass("user://saves/".plus_file(getv("save_id", "pass") + ".apa2save"), "apa2_save")


func open_save(id):
	save_file = ConfigFile.new()
	save_file.load_encrypted_pass("user://saves/".plus_file(id + ".apa2save"), "apa2_save")


func close_save():
	save()
	save_file = null


func change_to_scene(path):
	if has_node("/root/loading"):
		if $"/root/loading".load_path == path:
			return
	var node = loading_scene.instance()
	node.load_path = path
	get_tree().root.add_child(node)


func update_music(node):
	if not is_instance_valid(node):
		music.stop()
		return
	if node.name != curr_scene:
		var prev_scene = curr_scene
		curr_scene = node.name
		if curr_scene == "menu" and prev_scene != "levels":
			music.play(0)
		elif curr_scene == "levels" and prev_scene != "menu":
			music.play(0)
		elif curr_scene != "menu" and curr_scene != "levels":
			music.stop()


func update_timer():
	if save_file == null:
		return
	G.addv("time", 1)


func receive_ad_reward():
	receive_loot({"gold_box":1})


func receive_loot(looted):
	var loot_to_show = {}
	var rec = looted.duplicate(true)
	var another_rec = rec.duplicate(true)
	for i in rec:
		if i.ends_with("box"):
			continue
		if i == "coins" or i == "gems" or i.begins_with("potions") or i.begins_with("garden"):
			addv(i, rec[i])
		if getv("potions1", 0) > 5:
			if another_rec.has("potions1"):
				another_rec["potions1"] = another_rec["potions1"] - getv("potions1", 0) + 5
				if another_rec["potions1"] <= 0:
					another_rec.erase("potions1")
			if not another_rec.has("coins"):
				another_rec["coins"] = 0
			another_rec["coins"] += (getv("potions1", 0) - 5) * 275
			addv("coins", (getv("potions1", 0) - 5) * 275)
			setv("potions1", 5)
		if getv("potions2", 0) > 5:
			if another_rec.has("potions2"):
				another_rec["potions2"] = another_rec["potions2"] - getv("potions2", 0) + 5
				if another_rec["potions2"] <= 0:
					another_rec.erase("potions2")
			if not another_rec.has("coins"):
				another_rec["coins"] = 0
			another_rec["coins"] += (getv("potions2", 0) - 5) * 600
			addv("coins", (getv("potions2", 0) - 5) * 600)
			setv("potions2", 5)
		if getv("potions3", 0) > 5:
			if another_rec.has("potions3"):
				another_rec["potions3"] = another_rec["potions3"] - getv("potions3", 0) + 5
				if another_rec["potions3"] <= 0:
					another_rec.erase("potions3")
			if not another_rec.has("coins"):
				another_rec["coins"] = 0
			another_rec["coins"] += (getv("potions3", 0) - 5) * 925
			addv("coins", (getv("potions3", 0) - 5) * 925)
			setv("potions3", 5)
		if i == "class":
			for j in rec[i]:
				addv("classes", [j], [])
		if i == "gadget":
			for j in rec[i]:
				setv(j + "_gadget", true)
		if i == "soul_power":
			for j in rec[i]:
				setv(j + "_soul_power", true)
		if i == "amulet_frags":
			for j in rec[i]:
				addv("amulet_frags_"+j, rec[i][j])
				addv("total_amulet_frags_"+j, rec[i][j])
		if i == "tokens":
			for j in rec[i]:
				addv(j + "_tokens", rec[i][j])
		if i == "ulti_tokens":
			for j in rec[i]:
				addv(j + "_ulti_tokens", rec[i][j])
	if another_rec.hash() != rec.hash():
		rec = another_rec
	for i in rec:
		loot_to_show[i] = rec[i]
	ach.check(Achievements.PROZAPASS)
	if not loot_to_show.empty():
		var n = box.instance()
		get_tree().root.add_child(n)
		n.show_loot(loot_to_show)
		yield(n, "end_loot")
		emit_signal("loot_end")
