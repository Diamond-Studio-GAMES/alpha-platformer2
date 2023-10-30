extends Node
class_name Box, "res://textures/items/box.png"


enum BoxType {
	STANDARD = 0,
	BIG = 1,
	MEGA = 2
}
export (BoxType) var box_type = BoxType.STANDARD
const CLASSES = ["knight", "butcher", "spearman", "wizard", "archer"]
var classes_to_unlock = []
var gadget_classes = []
var power_classes = []
var ulti_classes = []
var soul_power_classes = []
var amulet_types = []
var hero_chance = 1.5
var gen := RandomNumberGenerator.new()
var tokens_tween
onready var box_anim = $box_screen/anim
onready var box_anim2 = $big_box_screen/anim
onready var box_anim3 = $mega_box_screen/anim
onready var item_counter = $item_counter
onready var item_counter_count = $item_counter/count
onready var item_counter_label = $item_counter/label
onready var item_counter_glow = $item_counter/glow
onready var tokens_bar = $tokens_screen/bar
onready var ulti_tokens_bar = $ulti_tokens_screen/bar
onready var tokens_bar_label = $tokens_screen/bar/label
onready var ulti_tokens_bar_label = $ulti_tokens_screen/bar/label
onready var ygsi0 = $you_get_screen/items0
onready var ygsi1 = $you_get_screen/items1
var screens = {}
var coins_textures = [load("res://textures/items/small_coins.png"),
		load("res://textures/items/normal_coins.png"), 
		load("res://textures/items/big_coins.png")]
var CLASS_ICONS = {
	"knight" : load("res://textures/classes/knight_helmet.png"),
	"butcher" : load("res://textures/classes/butcher_helmet.png"),
	"spearman" : load("res://textures/classes/spearman_helmet.png"),
	"wizard" : load("res://textures/classes/wizard_helmet.png"),
	"archer" : load("res://textures/classes/archer_helmet.png") 
}
var ULTI_ICONS = {
	"knight" : load("res://textures/gui/ulti_icon_0.tres"),
	"butcher" : load("res://textures/gui/ulti_icon_1.tres"),
	"spearman" : load("res://textures/gui/ulti_icon_2.tres"),
	"wizard" : load("res://textures/gui/ulti_icon_3.tres"),
	"archer" : load("res://textures/gui/ulti_icon_4.tres")
}
var AMULET_ICONS = {
	"power" : load("res://textures/items/amulet_power_frag.png"),
	"defense" : load("res://textures/items/amulet_defense_frag.png"),
	"health" : load("res://textures/items/amulet_health_frag.png"),
	"speed" : load("res://textures/items/amulet_speed_frag.png"),
	"reload" : load("res://textures/items/amulet_reload_frag.png"),
	"ulti" : load("res://textures/items/amulet_ulti_frag.png"),
}
var POTIONS_ICONS = {
	"small" : load("res://textures/items/small_potion.png"),
	"normal" : load("res://textures/items/normal_potion.png"),
	"big" : load("res://textures/items/big_potion.png")
}
var ulti_token = load("res://textures/items/ulti_token.png")
var token = load("res://textures/items/token.png")
var coin = load("res://textures/items/coin.png")
var gem = load("res://textures/items/gem.png")
var you_get = load("res://prefabs/menu/you_get.tscn")
var gadget = load("res://textures/items/gadget.png")
var soul_power = load("res://textures/items/soul_power.png")
var items = 0
var glow_items = 0
var have_bonus = false
var is_showing_rewards = false
var is_showing_loot = false
var started = false
var started_opening = false
var selected_class_for_tokens

signal next
signal tokens_class_selected
signal end
signal end_loot


func _input(event):
	if not started:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			click()
	elif event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			click()


func _ready():
	get_tree().paused = true
	gen.randomize()
	init_values()
	$tint.set_focus_mode(Control.FOCUS_ALL)
	$tint.grab_focus()
	$tint.grab_click_focus()
	for i in get_children():
		if i.name.ends_with("_screen"):
			screens[i.name] = i


func _process(delta):
	if items <= 1 and have_bonus:
		have_bonus = false
		items += 1
		item_counter.self_modulate = Color.yellow
		item_counter_label.text = tr("box.remains.bonus")
	item_counter_glow.visible = glow_items > 0 and glow_items == items - 1
	item_counter_count.text = str(items - 1)


func click():
	if not is_showing_loot:
		if not started_opening:
			match box_type:
				BoxType.STANDARD:
					box_anim.play("open")
				BoxType.BIG:
					box_anim2.play("open")
				BoxType.MEGA:
					box_anim3.play("open")
		started_opening = true
	emit_signal("next")


func show_loot(what):
	var loot = {}
	for i in what:
		if i.ends_with("box"):
			continue
		loot[i] = what[i]
	started = true
	if not loot.empty():
		is_showing_loot = true
		open_gui(loot)
		yield(self, "end")
		reset_values()
	for i in what:
		if not i.ends_with("box"):
			continue
		if i == "box":
			for j in range(what[i]):
				prepare(BoxType.STANDARD)
				yield(self, "end")
				reset_values()
		if i == "gold_box":
			for j in range(what[i]):
				prepare(BoxType.BIG)
				yield(self, "end")
				reset_values()
		if i == "diamond_box":
			for j in range(what[i]):
				prepare(BoxType.MEGA)
				yield(self, "end")
				reset_values()
	get_tree().paused = false
	emit_signal("end_loot")
	queue_free()


func reset_values():
	started_opening = false
	is_showing_loot = false
	is_showing_rewards = false
	items = 0
	glow_items = 0
	have_bonus = false
	init_values()
	for i in $you_get_screen/items0.get_children():
		i.queue_free()
	for i in $you_get_screen/items1.get_children():
		i.queue_free()
	item_counter.self_modulate = Color.red
	item_counter_label.text = tr("box.remains")


func open_select_class_for_tokens(count):
	hide_screens()
	show_screen("wild_card_screen")
	$wild_card_screen/count.text = str(count)
	for i in range(5):
		if not CLASSES[i] in power_classes:
			get_node("wild_card_screen/classes/class" + str(i + 1)).hide()
		else:
			get_node("wild_card_screen/classes/class" + str(i + 1)).connect("pressed", self, "select_class_for_tokens", [G.CLASSES_ID[i]])
			get_node("wild_card_screen/classes/class" + str(i + 1) + "/count").text = str(G.getv(CLASSES[i] + "_tokens", 0)) + "/" + str(G.getv(CLASSES[i] + "_level", 0) * 10 + 10)
	if power_classes.empty():
		$wild_card_screen/classes/to_coins.show()
		$wild_card_screen/classes/to_coins.connect("pressed", self, "select_class_for_tokens", ["coins"])


func open_select_class_for_ulti_tokens(count):
	hide_screens()
	show_screen("wild_ulti_card_screen")
	$wild_ulti_card_screen/count.text = str(count)
	for i in range(5):
		if not CLASSES[i] in ulti_classes:
			get_node("wild_ulti_card_screen/classes/class" + str(i + 1)).hide()
		else:
			get_node("wild_ulti_card_screen/classes/class" + str(i + 1)).connect("pressed", self, "select_class_for_tokens", [G.CLASSES_ID[i]])
			get_node("wild_ulti_card_screen/classes/class" + str(i + 1) + "/count").text = str(G.getv(CLASSES[i] + "_ulti_tokens", 0)) + "/" + str(G.getv(CLASSES[i] + "_ulti_level", 1) * 30 + 30)
	if ulti_classes.empty():
		$wild_ulti_card_screen/classes/to_coins.show()
		$wild_ulti_card_screen/classes/to_coins.connect("pressed", self, "select_class_for_tokens", ["coins"])


func select_class_for_tokens(sel_class = ""):
	selected_class_for_tokens = sel_class
	hide_screens()
	emit_signal("tokens_class_selected")


func open_gui(what = null):
	hide_screens()
	var loot = {}
	if what == null:
		G.addv("boxes_opened", 1)
		G.ach.check(Achievements.HACKER)
		match box_type:
			BoxType.STANDARD:
				loot = open_box()
			BoxType.BIG:
				loot = open_big_box()
			BoxType.MEGA:
				loot = open_megabox()
	else:
		loot = what
	print(loot)
	items = loot.size()
	if loot.has("tokens"):
		items += loot["tokens"].size() - 1
	if loot.has("ulti_tokens"):
		items += loot["ulti_tokens"].size() - 1
	if loot.has("amulet_frags"):
		items += loot["amulet_frags"].size() - 1
	if loot.has("wild_tokens"):
		open_select_class_for_tokens(loot["wild_tokens"])
		yield(self, "tokens_class_selected")
		if selected_class_for_tokens == "coins":
			if not loot.has("coins"):
				loot["coins"] = 0
			loot["coins"] = loot["wild_tokens"] * 3
			G.addv("coins", loot["coins"])
		else:
			if not loot.has("tokens"):
				loot["tokens"] = {}
			loot["tokens"][selected_class_for_tokens] = loot["wild_tokens"]
			G.addv(selected_class_for_tokens + "_tokens", loot["wild_tokens"])
		loot.erase("wild_tokens")
	if loot.has("wild_ulti_tokens"):
		open_select_class_for_ulti_tokens(loot["wild_ulti_tokens"])
		yield(self, "tokens_class_selected")
		if selected_class_for_tokens == "coins":
			if not loot.has("coins"):
				loot["coins"] = 0
			loot["coins"] = loot["wild_ulti_tokens"] * 10
			G.addv("coins", loot["coins"])
		else:
			if not loot.has("ulti_tokens"):
				loot["ulti_tokens"] = {}
			loot["ulti_tokens"][selected_class_for_tokens] = loot["wild_ulti_tokens"]
			G.addv(selected_class_for_tokens + "_ulti_tokens", loot["wild_ulti_tokens"])
		loot.erase("wild_ulti_tokens")
	if loot.has("gadget"):
		items += loot["gadget"].size() - 1
		glow_items += loot["gadget"].size()
	if loot.has("soul_power"):
		items += loot["soul_power"].size() - 1
		glow_items += loot["soul_power"].size()
	if loot.has("class"):
		items += loot["class"].size() - 1
		glow_items += loot["class"].size()
	if loot.has("gems"):
		have_bonus = true
		items -= 1
	if items > 1 or have_bonus:
		item_counter.show()
		item_counter_count.text = str(items)
	if what != null:
		item_counter.hide()
	if loot.has("coins"):
		hide_screens()
		show_screen("coins_screen")
		$coins_screen/anim.stop()
		$coins_screen/anim.play("anim")
		$coins_screen/visual/count.text = "x " + str(loot["coins"])
		if loot["coins"] <= 200:
			$coins_screen/visual/coins.texture = coins_textures[0]
		elif loot["coins"] > 200 and loot["coins"] < 550:
			$coins_screen/visual/coins.texture = coins_textures[1]
		else:
			$coins_screen/visual/coins.texture = coins_textures[2]
		yield(self, "next")
		items -= 1
		item_counter_count.text = str(items)
	if loot.has("amulet_frags"):
		hide_screens()
		show_screen("amulet_frags_screen")
		var keys = loot["amulet_frags"].keys()
		for i in range(loot["amulet_frags"].size()):
			$amulet_frags_screen/token.texture = AMULET_ICONS[keys[i]]
			$amulet_frags_screen/type.text = tr(G.AMULET_NAME[G.AMULET_ID[keys[i]]])
			$amulet_frags_screen/count.text = "x " + str(loot["amulet_frags"][keys[i]])
			$amulet_frags_screen/anim.play("anim")
			$amulet_frags_screen/anim.seek(0, true)
			yield(self, "next")
			items -= 1
	if loot.has("tokens"):
		hide_screens()
		show_screen("tokens_screen")
		var keys = loot["tokens"].keys()
		for i in range(loot["tokens"].size()):
			$tokens_screen/token.self_modulate = G.CLASS_COLORS[keys[i]]
			$tokens_screen/token/class.texture = CLASS_ICONS[keys[i]]
			$tokens_screen/token/label.text = tr(G.CLASSES[keys[i]])
			$tokens_screen/count.text = "x " + str(loot["tokens"][keys[i]])
			var real_tokens = G.getv(keys[i] + "_tokens", 0)
			tokens_bar.max_value = G.getv(keys[i] + "_level", 0) * 10 + 10
			tokens_bar.value = real_tokens - loot["tokens"][keys[i]]
			tokens_bar_label.text = str(tokens_bar.value) + "/" + str(tokens_bar.max_value)
			tokens_bar.tint_progress = Color(1, 0, 1)
			$tokens_screen/bar/upgrade.hide()
			if tokens_bar.value >= tokens_bar.max_value:
				tokens_bar.tint_progress = Color(0, 1, 0)
				$tokens_screen/bar/upgrade.show()
			$tokens_screen/anim.play("anim")
			$tokens_screen/anim.seek(0, true)
			if tokens_tween:
				tokens_tween.kill()
			tokens_tween = create_tween()
			tokens_tween.tween_method(self, "open_gui_set_tokens_count", tokens_bar.value, float(real_tokens), 0.8).set_delay(0.4)
			yield(self, "next")
			items -= 1
	if loot.has("ulti_tokens"):
		hide_screens()
		show_screen("ulti_tokens_screen")
		var keys = loot["ulti_tokens"].keys()
		for i in range(loot["ulti_tokens"].size()):
			$ulti_tokens_screen/token.self_modulate = G.CLASS_COLORS[keys[i]]
			$ulti_tokens_screen/token/class.texture = ULTI_ICONS[keys[i]]
			$ulti_tokens_screen/token/label.text = tr(G.ULTIS[keys[i]])
			$ulti_tokens_screen/count.text = "x " + str(loot["ulti_tokens"][keys[i]])
			var real_tokens = G.getv(keys[i] + "_ulti_tokens", 0)
			ulti_tokens_bar.max_value = G.getv(keys[i] + "_ulti_level", 1) * 30 + 30
			ulti_tokens_bar.value = real_tokens - loot["ulti_tokens"][keys[i]]
			ulti_tokens_bar_label.text = str(ulti_tokens_bar.value) + "/" + str(ulti_tokens_bar.max_value)
			ulti_tokens_bar.tint_progress = Color(1, 0, 0)
			$ulti_tokens_screen/bar/upgrade.hide()
			if ulti_tokens_bar.value >= ulti_tokens_bar.max_value:
				$ulti_tokens_screen/bar/upgrade.show()
				ulti_tokens_bar.tint_progress = Color(0, 1, 0)
			$ulti_tokens_screen/anim.play("anim")
			$ulti_tokens_screen/anim.seek(0, true)
			if tokens_tween:
				tokens_tween.kill()
			tokens_tween = create_tween()
			tokens_tween.tween_method(self, "open_gui_set_ulti_tokens_count", ulti_tokens_bar.value, float(real_tokens), 0.8).set_delay(0.4)
			yield(self, "next")
			items -= 1
	if loot.has("potions1"):
		hide_screens()
		show_screen("potions_screen")
		$potions_screen/anim.play("anim")
		$potions_screen/anim.seek(0)
		$potions_screen/visual/label.text = tr("item.potion1")
		$potions_screen/visual/count.text = "x " + str(loot["potions1"])
		$potions_screen/visual/potion.texture = POTIONS_ICONS["small"]
		yield(self, "next")
		items -= 1
		item_counter_count.text = str(items)
	if loot.has("potions2"):
		hide_screens()
		show_screen("potions_screen")
		$potions_screen/anim.play("anim")
		$potions_screen/anim.seek(0)
		$potions_screen/visual/label.text = tr("item.potion2")
		$potions_screen/visual/count.text = "x " + str(loot["potions2"])
		$potions_screen/visual/potion.texture = POTIONS_ICONS["normal"]
		yield(self, "next")
		items -= 1
		item_counter_count.text = str(items)
	if loot.has("potions3"):
		hide_screens()
		show_screen("potions_screen")
		$potions_screen/anim.play("anim")
		$potions_screen/anim.seek(0)
		$potions_screen/visual/label.text = tr("item.potion3")
		$potions_screen/visual/count.text = "x " + str(loot["potions3"])
		$potions_screen/visual/potion.texture = POTIONS_ICONS["big"]
		yield(self, "next")
		items -= 1
		item_counter_count.text = str(items)
	if loot.has("gadget"):
		hide_screens()
		show_screen("gadget_screen")
		G.ach.complete(Achievements.HELP_FROM_INSIDE)
		for i in loot["gadget"]:
			$gadget_screen/label/class.text = tr(G.CLASSES[i])
			$gadget_screen/desc/label.text = tr(G.GADGETS[i])
			$gadget_screen/anim.play("anim")
			$gadget_screen/anim.seek(0, true)
			glow_items -= 1
			yield(get_tree().create_timer(2), "timeout")
			yield(self, "next")
			items -= 1
			item_counter_count.text = str(items)
	if loot.has("soul_power"):
		hide_screens()
		show_screen("soul_power_screen")
		G.ach.complete(Achievements.SOUL_MASTER)
		for i in loot["soul_power"]:
			$soul_power_screen/label/class.text = tr(G.CLASSES[i])
			$soul_power_screen/desc/label.text = tr(G.SOUL_POWERS[i])
			$soul_power_screen/anim.play("anim")
			$soul_power_screen/anim.seek(0, true)
			glow_items -= 1
			yield(get_tree().create_timer(2), "timeout")
			yield(self, "next")
			items -= 1
			item_counter_count.text = str(items)
	if loot.has("class"):
		hide_screens()
		show_screen("class_screen")
		G.ach.complete(Achievements.WHAT_IS_IT)
		if classes_to_unlock.size() == 0:
			G.ach.complete(Achievements.MASTER_OF_WEAPONS)
		for i in loot["class"]:
			$class_screen/archer.hide()
			$class_screen/wizard.hide()
			$class_screen/butcher.hide()
			$class_screen/knight.hide()
			$class_screen/spearman.hide()
			get_node("class_screen/" + i).show()
			get_node("class_screen/" + i + "/class/ui/text/class_name/count").text = str(5 - classes_to_unlock.size()) + tr("box.class_num")
			get_node("class_screen/" + i + "/anim").play("main")
			$class_screen/roll_out.play()
			glow_items -= 1
			yield(get_tree().create_timer(4), "timeout")
			yield(self, "next")
			items -= 1
			item_counter_count.text = str(items)
	if loot.has("gems"):
		hide_screens()
		show_screen("gems_screen")
		$gems_screen/anim.play("anim")
		$gems_screen/anim.seek(0, true)
		$gems_screen/visual/count.text = "x " + str(loot["gems"])
		yield(self, "next")
		items -= 1
	if loot.size() == 1 or what != null:
		is_showing_rewards = false
		emit_signal("end")
		return
	hide_screens()
	item_counter.hide()
	show_screen("you_get_screen")
	$you_get_screen/anim.play("anim")
	var items_showed = 0
	if loot.has("coins"):
		var node = you_get.instance()
		node.self_modulate = Color.gold
		node.get_node("icon").texture = coin
		node.get_node("label").text = str(loot["coins"])
		is_showing_rewards = true
		if items_showed < 8:
			ygsi0.add_child(node)
		else:
			ygsi1.add_child(node)
		items_showed += 1
	if loot.has("amulet_frags"):
		for i in loot["amulet_frags"].keys():
			var node = you_get.instance()
			node.self_modulate = Color(0, 0.5, 0, 1)
			node.get_node("icon").texture = AMULET_ICONS[i]
			node.get_node("label").text = str(loot["amulet_frags"][i])
			if items_showed < 8:
				ygsi0.add_child(node)
			else:
				ygsi1.add_child(node)
			items_showed += 1
	if loot.has("tokens"):
		for i in loot["tokens"].keys():
			var node = you_get.instance()
			node.self_modulate = Color.magenta
			node.get_node("icon").texture = token
			node.get_node("icon/center").texture = CLASS_ICONS[i]
			node.get_node("icon").self_modulate = G.CLASS_COLORS[i]
			node.get_node("label").text = str(loot["tokens"][i])
			if items_showed < 8:
				ygsi0.add_child(node)
			else:
				ygsi1.add_child(node)
			items_showed += 1
	if loot.has("ulti_tokens"):
		for i in loot["ulti_tokens"].keys():
			var node = you_get.instance()
			node.self_modulate = Color.darkred
			node.get_node("icon").texture = ulti_token
			node.get_node("icon/center").texture = ULTI_ICONS[i]
			node.get_node("icon/center").margin_left = -20
			node.get_node("icon/center").margin_right = 20
			node.get_node("icon/center").margin_top = -20
			node.get_node("icon/center").margin_bottom = 20
			node.get_node("icon").self_modulate = G.CLASS_COLORS[i]
			node.get_node("label").text = str(loot["ulti_tokens"][i])
			if items_showed < 8:
				ygsi0.add_child(node)
			else:
				ygsi1.add_child(node)
			items_showed += 1
	if loot.has("potions1"):
		var node = you_get.instance()
		node.self_modulate = Color.darkred
		node.get_node("icon").texture = POTIONS_ICONS["small"]
		node.get_node("label").text = str(loot["potions1"])
		if items_showed < 8:
			ygsi0.add_child(node)
		else:
			ygsi1.add_child(node)
		items_showed += 1
	if loot.has("potions2"):
		var node = you_get.instance()
		node.self_modulate = Color.darkred
		node.get_node("icon").texture = POTIONS_ICONS["normal"]
		node.get_node("label").text = str(loot["potions2"])
		if items_showed < 8:
			ygsi0.add_child(node)
		else:
			ygsi1.add_child(node)
		items_showed += 1
	if loot.has("potions3"):
		var node = you_get.instance()
		node.self_modulate = Color.darkred
		node.get_node("icon").texture = POTIONS_ICONS["big"]
		node.get_node("label").text = str(loot["potions3"])
		if items_showed < 8:
			ygsi0.add_child(node)
		else:
			ygsi1.add_child(node)
		items_showed += 1
	if loot.has("gadget"):
		for i in loot["gadget"]:
			var node = you_get.instance()
			node.self_modulate = Color.aquamarine
			node.get_node("icon").texture = gadget
			node.get_node("label").text = tr(G.CLASSES[i])
			if items_showed < 8:
				ygsi0.add_child(node)
			else:
				ygsi1.add_child(node)
			items_showed += 1
	if loot.has("soul_power"):
		for i in loot["soul_power"]:
			var node = you_get.instance()
			node.self_modulate = Color.darkorange
			node.get_node("icon").texture = soul_power
			node.get_node("label").text = tr(G.CLASSES[i])
			if items_showed < 8:
				ygsi0.add_child(node)
			else:
				ygsi1.add_child(node)
			items_showed += 1
	if loot.has("class"):
		for i in loot["class"]:
			var node = you_get.instance()
			node.self_modulate = G.CLASS_COLORS[i]
			node.get_node("icon").texture = CLASS_ICONS[i]
			node.get_node("label").text = tr("item.class")
			if items_showed < 8:
				ygsi0.add_child(node)
			else:
				ygsi1.add_child(node)
			items_showed += 1
	if loot.has("gems"):
		var node = you_get.instance()
		node.self_modulate = Color.webpurple
		node.get_node("icon").texture = gem
		node.get_node("label").text = str(loot["gems"])
		is_showing_rewards = true
		if items_showed < 8:
			ygsi0.add_child(node)
		else:
			ygsi1.add_child(node)
		items_showed += 1
	yield(get_tree().create_timer(0.05), "timeout")
	yield(self, "next")
	is_showing_rewards = false
	emit_signal("end")


func open_gui_set_tokens_count(count):
	tokens_bar.value = count
	tokens_bar_label.text = str(floor(tokens_bar.value)) + "/" + str(tokens_bar.max_value)
	if tokens_bar.value >= tokens_bar.max_value:
		tokens_bar.tint_progress = Color(0, 1, 0)
		$tokens_screen/bar/upgrade.show()


func open_gui_set_ulti_tokens_count(count):
	ulti_tokens_bar.value = count
	ulti_tokens_bar_label.text = str(floor(ulti_tokens_bar.value)) + "/" + str(ulti_tokens_bar.max_value)
	if ulti_tokens_bar.value >= ulti_tokens_bar.max_value:
		ulti_tokens_bar.tint_progress = Color(0, 1, 0)
		$ulti_tokens_screen/bar/upgrade.show()


func hide_screens():
	for i in screens.values():
		i.hide()
		i.pause_mode = PAUSE_MODE_STOP


func show_screen(screen):
	if not screens.has(screen):
		var _screen = load("res://prefabs/menu/box_screens/%s.tscn" % screen).instance()
		_screen.name = screen
		screens[screen] = _screen
		add_child_below_node($mega_box_screen, _screen)
	screens[screen].show()
	screens[screen].pause_mode = PAUSE_MODE_INHERIT


func prepare(type):
	$tint.self_modulate = Color(1, 1, 1, 0)
	hide_screens()
	box_type = type
	match type:
		BoxType.STANDARD:
			if $box_screen/box_visual is InstancePlaceholder:
				$box_screen/box_visual.replace_by_instance()
			show_screen("box_screen")
			$box_screen/anim.play("start")
		BoxType.BIG:
			if $big_box_screen/box_visual is InstancePlaceholder:
				$big_box_screen/box_visual.replace_by_instance()
			show_screen("big_box_screen")
			$big_box_screen/anim.play("start")
		BoxType.MEGA:
			if $mega_box_screen/box_visual is InstancePlaceholder:
				$mega_box_screen/box_visual.replace_by_instance()
			show_screen("mega_box_screen")
			$mega_box_screen/anim.play("start")


func init_values():
	power_classes = []
	gadget_classes = []
	soul_power_classes = []
	ulti_classes = []
	amulet_types = []
	hero_chance = G.getv("hero_chance", 0.5)
	classes_to_unlock = CLASSES.duplicate()
	var had_classes = G.getv("classes", [])
	var has_amulet = false
	for i in had_classes:
		if i in classes_to_unlock:
			classes_to_unlock.erase(i)
	for i in had_classes:
		if G.getv(i + "_level", 0) >= 10:
			has_amulet = true
		if G.getv(i + "_level", 0) < 20:
			power_classes.append(i)
		if G.getv(i + "_ulti_level", 0) < 5:
			ulti_classes.append(i)
		if G.getv(i + "_level", 0) >= 15 and not G.getv(i + "_gadget", false):
			gadget_classes.append(i)
		if G.getv(i + "_level", 0) == 20 and not G.getv(i + "_soul_power", false):
			soul_power_classes.append(i)
	if has_amulet:
		for i in range(6):
			if G.getv("total_amulet_frags_"+G.AMULET[i], 0) < G.AMULET_MAX[i]:
				amulet_types.append(G.AMULET[i])
	G.save()


func open_box():
	return open_boxes(1, 2, 2)


func open_big_box():
	return open_boxes(3, 3, 3)


func open_megabox():
	return open_boxes(10, 4, 4)


func open_boxes(count, power_count, ulti_count):
	var boxes = []
	var had_pclasses: Array = power_classes.duplicate()
	var had_uclasses: Array = ulti_classes.duplicate()
	for i in range(count):
		boxes.append(get_box_rewards())
	var loot = {}
	loot["coins"] = 0
	loot["gadget"] = []
	loot["soul_power"] = []
	loot["class"] = []
	loot["gems"] = 0
	loot["amulet_frags"] = {}
	loot["tokens"] = {}
	loot["ulti_tokens"] = {}
	
	var tokens_array = []
	if power_count > had_pclasses.size():
		tokens_array.resize(had_pclasses.size())
		tokens_array.fill(0)
	else:
		tokens_array.resize(power_count)
		tokens_array.fill(0)
	var utokens_array = []
	if ulti_count > had_uclasses.size():
		utokens_array.resize(had_uclasses.size())
		utokens_array.fill(0)
	else:
		utokens_array.resize(ulti_count)
		utokens_array.fill(0)
	for i in boxes:
		loot["coins"] += i.get("coins", 0)
		loot["gems"] += i.get("gems", 0)
		if i.has("amulet_frags"):
			for j in i["amulet_frags"]:
				loot["amulet_frags"][j] = i["amulet_frags"][j] + loot["amulet_frags"].get(j, 0)
		if i.has("gadget"):
			loot["gadget"] += i["gadget"]
		if i.has("soul_power"):
			loot["soul_power"] += i["soul_power"]
		if i.has("class"):
			loot["class"] += i["class"]
		if i.has("tokens0"):
			if tokens_array.size() > 1:
				var id = gen.randi_range(0, tokens_array.size() - 1)
				tokens_array[id] += i["tokens0"]
				tokens_array[posmod(id + 1, tokens_array.size())] += i["tokens1"]
			elif tokens_array.size() == 1:
				tokens_array[0] += i["tokens0"]
				loot["coins"] += i["tokens1"] * 3
				G.addv("coins", i["tokens1"] * 3)
			else:
				loot["coins"] += i["tokens1"] * 3 + i["tokens0"] * 3
				G.addv("coins", i["tokens1"] * 3 + i["tokens0"] * 3)
			
			if utokens_array.size() > 1:
				var id = gen.randi_range(0, utokens_array.size() - 1)
				utokens_array[id] += i["ulti_tokens0"]
				utokens_array[posmod(id + 1, utokens_array.size())] += i["ulti_tokens1"]
			elif utokens_array.size() == 1:
				utokens_array[0] += i["ulti_tokens0"]
				loot["coins"] += i["ulti_tokens1"] * 10
				G.addv("coins", i["ulti_tokens1"] * 10)
			else:
				loot["coins"] += i["ulti_tokens1"] * 10 + i["ulti_tokens0"] * 10
				G.addv("coins", i["ulti_tokens1"] * 10 + i["ulti_tokens0"] * 10)
	
	tokens_array.sort()
	utokens_array.sort()
	had_pclasses.shuffle()
	had_uclasses.shuffle()
	had_pclasses.resize(tokens_array.size())
	had_uclasses.resize(utokens_array.size())
	for i in tokens_array.size():
		if tokens_array[i] < 1:
			continue
		loot["tokens"][had_pclasses[i]] = tokens_array[i]
	for i in utokens_array.size():
		if utokens_array[i] < 1:
			continue
		loot["ulti_tokens"][had_uclasses[i]] = utokens_array[i]
	for i in loot["tokens"]:
		G.addv(i + "_tokens", loot["tokens"][i])
	for i in loot["ulti_tokens"]:
		G.addv(i + "_ulti_tokens", loot["ulti_tokens"][i])
	
	if loot["amulet_frags"].empty():
		loot.erase("amulet_frags")
	if loot["tokens"].empty():
		loot.erase("tokens")
	if loot["ulti_tokens"].empty():
		loot.erase("ulti_tokens")
	if loot["gems"] <= 0:
		loot.erase("gems")
	if loot["coins"] <= 0:
		loot.erase("coins")
	if loot["gadget"].empty():
		loot.erase("gadget")
	if loot["soul_power"].empty():
		loot.erase("soul_power")
	if loot["class"].empty():
		loot.erase("class")
	return loot


func get_box_rewards():
	var hero = G.percent_chance(hero_chance) and not classes_to_unlock.empty()
	var soul_power = G.percent_chance(2) and not soul_power_classes.empty()
	var gadget = G.percent_chance(4) and not gadget_classes.empty()
	var amulet_frag = G.percent_chance(16) and not amulet_types.empty()
	var gem_chance = G.percent_chance(10)
	var loot = {}
	var gems = 0
	if gem_chance:
		var c = gen.randi_range(0, 100)
		if c < 90:
			gems = gen.randi_range(1, 2)
		else:
			gems = 4
		loot["gems"] = gems
		G.addv("gems", gems)
	if hero:
		hero_chance = 1.5
		G.setv("hero_chance", hero_chance)
		classes_to_unlock.shuffle()
		var class_unlocked = classes_to_unlock[0]
		G.addv("classes", [class_unlocked], [])
		init_values()
		loot["class"] = [class_unlocked]
	elif soul_power:
		soul_power_classes.shuffle()
		var soul_power_unlocked = soul_power_classes[0]
		G.setv(soul_power_unlocked + "_soul_power", true)
		init_values()
		loot["soul_power"] = [soul_power_unlocked]
	elif gadget:
		gadget_classes.shuffle()
		var gadget_unlocked = gadget_classes[0]
		G.setv(gadget_unlocked + "_gadget", true)
		init_values()
		loot["gadget"] = [gadget_unlocked]
	elif amulet_frag:
		amulet_types.shuffle()
		var type = amulet_types[0]
		G.addv("amulet_frags_" + type, 1, 0)
		G.addv("total_amulet_frags_" + type, 1, 0)
		init_values()
		loot["amulet_frags"] = {type : 1}
	else:
		hero_chance += 0.06
		G.setv("hero_chance", hero_chance)
		power_classes.shuffle()
		var coins_count = 0
		var c = gen.randi_range(0, 100)
		if c <= 70:
			coins_count = gen.randi_range(40, 110)
		elif c > 70 and c <= 92:
			coins_count = 130
		else:
			coins_count = 170
		loot["coins"] = coins_count
		G.addv("coins", coins_count)
		loot["tokens"] = []
		var t0 = gen.randi_range(0, 100)
		if t0 <= 70:
			loot["tokens0"] = gen.randi_range(2, 7)
		elif t0 > 70 and t0 <= 92:
			loot["tokens0"] = 10
		else:
			loot["tokens0"] = 15
		var t1 = gen.randi_range(0, 100)
		if t1 <= 70:
			loot["tokens1"] = gen.randi_range(2, 7)
		elif t1 > 70 and t1 <= 92:
			loot["tokens1"] = 10
		else:
			loot["tokens1"] = 15
		var ut0 = gen.randi_range(0, 100)
		if ut0 < 70:
			loot["ulti_tokens0"] = gen.randi_range(1, 2)
		elif ut0 > 70 and ut0 <= 92:
			loot["ulti_tokens0"] = 3
		else:
			loot["ulti_tokens0"] = 4
		var ut1 = gen.randi_range(0, 100)
		if ut1 < 80:
			loot["ulti_tokens1"] = 1
		elif ut1 > 80 and ut1 <= 95:
			loot["ulti_tokens1"] = 2
		else:
			loot["ulti_tokens1"] = 3
		init_values()
	return loot
