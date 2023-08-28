extends Node
class_name Globals, "res://textures/gui/alpha_text.png"


const VERSION = "0.9.0"
const VERSION_STATUS = "build"
const VERSION_STATUS_NUMBER = "1"
const VERSION_CODE = 66

var main_file: ConfigFile
var save_file: ConfigFile
var save_timer = 0
var selected_class_to_test = "knight"
var current_level = "1_1"
var current_scene = ""
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
var loading_scene = load("res://scenes/menu/loading.tscn")
var box = load("res://scenes/menu/box.tscn")
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
	"knight" : "gadgets.knight",
	"butcher" : "gadgets.butcher",
	"spearman" : "gadgets.spearman",
	"wizard" : "gadgets.wizard",
	"archer" : "gadgets.archer"
}
const SOUL_POWERS = {
	"knight" : "sp.knight",
	"butcher" : "sp.butcher",
	"spearman" : "sp.spearman",
	"wizard" : "sp.wizard",
	"archer" : "sp.archer"
}
const CLASSES = {
	"knight" : "class.knight",
	"butcher" : "class.butcher",
	"spearman" : "class.spearman",
	"wizard" : "class.wizard",
	"archer" : "class.archer",
	"player" : "class.none"
}
const ULTIS = {
	"knight" : "ulti.flurry",
	"butcher" : "ulti.smash",
	"spearman" : "ulti.stun",
	"wizard" : "ulti.heal",
	"archer" : "ulti.blitz"
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
	-1 : "amulet.none",
	0 : "amulet.power",
	1 : "amulet.defense",
	2 : "amulet.health",
	3 : "amulet.speed",
	4 : "amulet.reload",
	5 : "amulet.ulti",
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
	BEAUTY_DEFAULT = 14,
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
	ach.layer = 128
	ach.pause_mode = PAUSE_MODE_PROCESS
	add_child(ach)
	music = AudioStreamPlayer.new()
	music.name = "menu_music"
	music.bus = "music"
	music.stream = load("res://sounds/music/menu/menu.ogg")
	add_child(music)
	fps_text = load("res://prefabs/menu/fps_counter.tscn").instance()
	fps_text.hide()
	add_child(fps_text)
	time_timer = Timer.new()
	time_timer.name = "timer"
	time_timer.wait_time = 1
	time_timer.pause_mode = PAUSE_MODE_PROCESS
	add_child(time_timer)
	time_timer.connect("timeout", self, "update_timer")
	time_timer.start()
	if OS.has_feature("editor") or OS.has_feature("cheats"):
		var ch = load("res://prefabs/menu/cheats.tscn").instance()
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


func percent_chance(in_chance):
	in_chance *= 10000
	in_chance = int(in_chance)
	var max_add = 1000000 - in_chance
	var chance_range_start = randi() % (max_add + 1)
	var chance_range_end = chance_range_start + in_chance
	var random_number = randi() % 1000001
	return random_number >= chance_range_start and random_number <= chance_range_end


func update_music(node):
	if not is_instance_valid(node):
		music.stop()
		return
	if node.name != current_scene:
		var prev_scene = current_scene
		current_scene = node.name
		if current_scene == "menu" and prev_scene != "levels":
			music.play(0)
		elif current_scene == "levels" and prev_scene != "menu":
			music.play(0)
		elif current_scene != "menu" and current_scene != "levels":
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
