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
var hero_chance = 0.5
var gen
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
	"knight" : load("res://textures/gui/ulti_icon_0.res"),
	"butcher" : load("res://textures/gui/ulti_icon_1.res"),
	"spearman" : load("res://textures/gui/ulti_icon_2.res"),
	"wizard" : load("res://textures/gui/ulti_icon_3.res"),
	"archer" : load("res://textures/gui/ulti_icon_4.res")
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
var you_get = load("res://prefabs/menu/you_get.scn")
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


func _process(delta):
	if items <= 1 and have_bonus:
		have_bonus = false
		items += 1
		item_counter.self_modulate = Color.yellow
		item_counter_label.text = "ОСТАЛОСЬ БОНУСОВ:"
	item_counter_glow.visible = glow_items > 0
	item_counter_count.text = str(items - 1)


func show_loot(what):
#	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), true)
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
	item_counter_label.text = "ОСТАЛОСЬ ПРЕДМЕТОВ:"


func open_select_class_for_tokens(count):
	hide_screens()
	show_screen("wild_card_screen")
	$wild_card_screen/count.text = str(count)
	for i in range(5):
		if not CLASSES[i] in power_classes:
			get_node("wild_card_screen/classes/class" + str(i + 1)).hide()
		else:
			get_node("wild_card_screen/classes/class" + str(i + 1) + "/count").text = str(G.getv(CLASSES[i] + "_tokens", 0)) + "/" + str(G.getv(CLASSES[i] + "_level", 0) * 10 + 10)
	if power_classes.empty():
		$wild_card_screen/classes/to_coins.show()


func open_select_class_for_ulti_tokens(count):
	hide_screens()
	show_screen("wild_ulti_card_screen")
	$wild_ulti_card_screen/count.text = str(count)
	for i in range(5):
		if not CLASSES[i] in ulti_classes:
			get_node("wild_ulti_card_screen/classes/class" + str(i + 1)).hide()
		else:
			get_node("wild_ulti_card_screen/classes/class" + str(i + 1) + "/count").text = str(G.getv(CLASSES[i] + "_ulti_tokens", 0)) + "/" + str(G.getv(CLASSES[i] + "_ulti_level", 1) * 30 + 30)
	if ulti_classes.empty():
		$wild_ulti_card_screen/classes/to_coins.show()


func select_class_for_tokens(sel_class = ""):
	selected_class_for_tokens = sel_class
	hide_screens()
	emit_signal("tokens_class_selected")


func open_gui(what = null):
	hide_screens()
	var loot = {}
	if what == null:
		if box_type == BoxType.STANDARD:
			loot = open_box()
		elif box_type == BoxType.BIG:
			loot = open_big_box()
		elif box_type == BoxType.MEGA:
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
		glow_items += loot["amulet_frags"].size()
	if loot.has("wild_tokens"):
		open_select_class_for_tokens(loot["wild_tokens"])
		yield(self, "tokens_class_selected")
		if selected_class_for_tokens == "coins":
			if not loot.has("coins"):
				loot["coins"] = 0
			loot["coins"] = loot["wild_tokens"] * 3
			G.setv("coins", G.getv("coins", 0) + loot["coins"])
		else:
			if not loot.has("tokens"):
				loot["tokens"] = {}
			loot["tokens"][selected_class_for_tokens] = loot["wild_tokens"]
			G.setv(selected_class_for_tokens + "_tokens", G.getv(selected_class_for_tokens + "_tokens", 0) + loot["wild_tokens"])
		loot.erase("wild_tokens")
	if loot.has("wild_ulti_tokens"):
		open_select_class_for_ulti_tokens(loot["wild_ulti_tokens"])
		yield(self, "tokens_class_selected")
		if selected_class_for_tokens == "coins":
			if not loot.has("coins"):
				loot["coins"] = 0
			loot["coins"] = loot["wild_ulti_tokens"] * 12
			G.setv("coins", G.getv("coins", 0) + loot["coins"])
		else:
			if not loot.has("ulti_tokens"):
				loot["ulti_tokens"] = {}
			loot["ulti_tokens"][selected_class_for_tokens] = loot["wild_ulti_tokens"]
			G.setv(selected_class_for_tokens + "_ulti_tokens", G.getv(selected_class_for_tokens + "_ulti_tokens", 0) + loot["wild_ulti_tokens"])
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
	if items == 0 and have_bonus:
		item_counter.hide()
	if loot.has("coins"):
		hide_screens()
		show_screen("coins_screen")
		$coins_screen/anim.stop()
		$coins_screen/anim.play("anim")
		$coins_screen/visual/count.text = "x " + str(loot["coins"])
		if loot["coins"] < 145:
			$coins_screen/visual/coins.texture = coins_textures[0]
		elif loot["coins"] >= 145 and loot["coins"] < 400:
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
			$amulet_frags_screen/type.text = G.AMULET_NAME[G.AMULET_ID[keys[i]]]
			$amulet_frags_screen/count.text = "x " + str(loot["amulet_frags"][keys[i]])
			$amulet_frags_screen/anim.play("anim")
			$amulet_frags_screen/anim.seek(0, true)
			glow_items -= 1
			yield(self, "next")
			items -= 1
	if loot.has("gadget"):
		hide_screens()
		show_screen("gadget_screen")
		for i in loot["gadget"]:
			$gadget_screen/label/class.text = G.CLASSES[i]
			$gadget_screen/desc/label.text = G.GADGETS[i]
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
		for i in loot["soul_power"]:
			$soul_power_screen/label/class.text = G.CLASSES[i]
			$soul_power_screen/desc/label.text = G.SOUL_POWERS[i]
			$soul_power_screen/anim.play("anim")
			$soul_power_screen/anim.seek(0, true)
			glow_items -= 1
			yield(get_tree().create_timer(2), "timeout")
			yield(self, "next")
			items -= 1
			item_counter_count.text = str(items)
	if loot.has("class"):
		if not has_node("class_screen"):
			var class_screen = load("res://prefabs/menu/box_class_screen.scn").instance()
			class_screen.name = "class_screen"
			screens["class_screen"] = class_screen
			add_child_below_node($soul_power_screen, class_screen)
		hide_screens()
		show_screen("class_screen")
		for i in loot["class"]:
			$class_screen/archer.hide()
			$class_screen/wizard.hide()
			$class_screen/butcher.hide()
			$class_screen/knight.hide()
			$class_screen/spearman.hide()
			get_node("class_screen/" + i).show()
			get_node("class_screen/" + i + "/class/ui/text/class_name/count").text = str(5 - classes_to_unlock.size()) + "-й из 5 классов"
			get_node("class_screen/" + i + "/anim").play("main")
			$roll_out.play()
			glow_items -= 1
			yield(get_tree().create_timer(4), "timeout")
			yield(self, "next")
			items -= 1
			item_counter_count.text = str(items)
	if loot.has("tokens"):
		hide_screens()
		show_screen("tokens_screen")
		var keys = loot["tokens"].keys()
		for i in range(loot["tokens"].size()):
			$tokens_screen/token.self_modulate = G.CLASS_COLORS[keys[i]]
			$tokens_screen/token/class.texture = CLASS_ICONS[keys[i]]
			$tokens_screen/token/label.text = G.CLASSES[keys[i]]
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
			$ulti_tokens_screen/token/label.text = G.ULTIS[keys[i]]
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
		$potions_screen/visual/label.text = "МАЛЕНЬКОЕ ЗЕЛЬЕ"
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
		$potions_screen/visual/label.text = "СРЕДНЕЕ ЗЕЛЬЕ"
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
		$potions_screen/visual/label.text = "БОЛЬШОЕ ЗЕЛЬЕ"
		$potions_screen/visual/count.text = "x " + str(loot["potions3"])
		$potions_screen/visual/potion.texture = POTIONS_ICONS["big"]
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
	if loot.size() == 1:
#		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"),false)
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
#		yield(get_tree().create_timer(0.15), "timeout")
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
#			yield(get_tree().create_timer(0.15), "timeout")
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
			node.get_node("label").text = G.CLASSES[i]
#			yield(get_tree().create_timer(0.15), "timeout")
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
			node.get_node("label").text = G.CLASSES[i]
#			yield(get_tree().create_timer(0.15), "timeout")
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
			node.get_node("label").text = "КЛАСС"
#			yield(get_tree().create_timer(0.15), "timeout")
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
#			yield(get_tree().create_timer(0.15), "timeout")
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
			node.get_node("icon").self_modulate = G.CLASS_COLORS[i]
			node.get_node("label").text = str(loot["ulti_tokens"][i])
#			yield(get_tree().create_timer(0.15), "timeout")
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
#		yield(get_tree().create_timer(0.15), "timeout")
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
#		yield(get_tree().create_timer(0.15), "timeout")
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
#		yield(get_tree().create_timer(0.15), "timeout")
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
#		yield(get_tree().create_timer(0.15), "timeout")
		is_showing_rewards = true
		if items_showed < 8:
			ygsi0.add_child(node)
		else:
			ygsi1.add_child(node)
		items_showed += 1
	yield(get_tree().create_timer(0.05), "timeout")
	yield(self, "next")
#	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
	is_showing_rewards = false
	emit_signal("end")


func open_gui_set_tokens_count(count):
	tokens_bar.value = count
	tokens_bar_label.text = str(round(tokens_bar.value)) + "/" + str(tokens_bar.max_value)
	if tokens_bar.value >= tokens_bar.max_value:
		tokens_bar.tint_progress = Color(0, 1, 0)
		$tokens_screen/bar/upgrade.show()


func open_gui_set_ulti_tokens_count(count):
	ulti_tokens_bar.value = count
	ulti_tokens_bar_label.text = str(round(ulti_tokens_bar.value)) + "/" + str(ulti_tokens_bar.max_value)
	if ulti_tokens_bar.value >= ulti_tokens_bar.max_value:
		ulti_tokens_bar.tint_progress = Color(0, 1, 0)
		$ulti_tokens_screen/bar/upgrade.show()


func _ready():
	gen = RandomNumberGenerator.new()
	get_tree().paused = true
	randomize()
	gen.randomize()
	init_values()
	$tint.set_focus_mode(Control.FOCUS_ALL)
	$tint.grab_focus()
	$tint.grab_click_focus()
	for i in get_children():
		if i.name.ends_with("_screen"):
			screens[i.name] = i


func hide_screens():
	for i in screens.values():
		i.hide()
		i.pause_mode = PAUSE_MODE_STOP


func show_screen(screen):
	screens[screen].show()
	screens[screen].pause_mode = PAUSE_MODE_INHERIT


func prepare(type):
#	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), true)
	$tint.self_modulate = Color(1, 1, 1, 0)
	hide_screens()
	box_type = type
	match type:
		BoxType.STANDARD:
			show_screen("box_screen")
			$box_screen/anim.play("start")
		BoxType.BIG:
			show_screen("big_box_screen")
			$big_box_screen/anim.play("start")
		BoxType.MEGA:
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
	var hero = percent_chance(hero_chance) and not classes_to_unlock.empty()
	var soul_power = percent_chance(2) and not soul_power_classes.empty()
	var gadget = percent_chance(4) and not gadget_classes.empty()
	var amulet_frag = percent_chance(16) and not amulet_types.empty()
	var gem_chance = percent_chance(10)
	var loot = {}
	var gems = 0
	if gem_chance:
		var c = gen.randi_range(0, 100)
		if c < 80:
			gems = gen.randi_range(1, 2)
		else:
			gems = 3
		loot["gems"] = gems
		G.setv("gems", G.getv("gems", 0) + gems)
	if hero:
		hero_chance = 1.5
		G.setv("hero_chance", hero_chance)
		classes_to_unlock.shuffle()
		var class_unlocked = classes_to_unlock[0]
		G.setv("classes", G.getv("classes", []) + [class_unlocked])
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
		G.addv("amulet_frags_"+type, 1, 0)
		G.addv("total_amulet_frags_"+type, 1, 0)
		init_values()
		loot["amulet_frags"] = {type : 1}
	else:
		hero_chance += 0.06
		G.setv("hero_chance", hero_chance)
		power_classes.shuffle()
		var coins_count = 0
		var c = gen.randi_range(0, 100)
		if c < 80:
			coins_count = gen.randi_range(30, 80)
		else:
			coins_count = gen.randi_range(80, 120)
		loot["coins"] = coins_count
		if power_classes.size() >= 0:
			power_classes.shuffle()
		if ulti_classes.size() >= 0:
			ulti_classes.shuffle()
		if power_classes.size() > 1:
			loot["tokens"] = {
				power_classes[0] : gen.randi_range(3, 9),
				power_classes[1] : gen.randi_range(3, 9)
			}
			G.setv(power_classes[0] + "_tokens", G.getv(power_classes[0] + "_tokens", 0) + loot["tokens"][power_classes[0]])
			G.setv(power_classes[1] + "_tokens", G.getv(power_classes[1] + "_tokens", 0) + loot["tokens"][power_classes[1]])
		elif power_classes.size() == 1:
			loot["tokens"] = {
				power_classes[0] : gen.randi_range(4, 12)
			}
			G.setv(power_classes[0] + "_tokens", G.getv(power_classes[0] + "_tokens", 0) + loot["tokens"][power_classes[0]])
		elif power_classes.empty():
			loot["coins"] += gen.randi_range(6, 18) * 3
		if ulti_classes.size() > 0:
			loot["ulti_tokens"] = {
				ulti_classes[0] : gen.randi_range(1, 2) + randi() % 2
			}
			G.setv(ulti_classes[0] + "_ulti_tokens", G.getv(ulti_classes[0] + "_ulti_tokens", 0) + loot["ulti_tokens"][ulti_classes[0]])
		else:
			loot["coins"] += gen.randi_range(1, 2) * 12 + (randi() % 2) * 12
		G.setv("coins", G.getv("coins", 0) + loot["coins"])
		init_values()
	return loot


func open_big_box():
	return open_boxes(3)


func open_megabox():
	return open_boxes(10)


func open_boxes(count):
	var boxes = []
	for i in range(count):
		boxes.append(open_box())
	var loot = {}
	loot["coins"] = 0
	for i in boxes:
		loot["coins"] += i.get("coins", 0)
	if loot["coins"] <= 0:
		loot.erase("coins")
	loot["gems"] = 0
	for i in boxes:
		loot["gems"] += i.get("gems", 0)
	if loot["gems"] <= 0:
		loot.erase("gems")
	loot["tokens"] = {}
	loot["ulti_tokens"] = {}
	loot["amulet_frags"] = {}
	for i in boxes:
		if not i.has("tokens"):
			continue
		var tib = i["tokens"]
		var keys = tib.keys()
		var values = tib.values()
		for j in range(tib.size()):
			if not loot["tokens"].has(keys[j]):
				loot["tokens"][keys[j]] = values[j]
			else:
				loot["tokens"][keys[j]] += values[j]
	for i in boxes:
		if not i.has("ulti_tokens"):
			continue
		var tib = i["ulti_tokens"]
		var keys = tib.keys()
		var values = tib.values()
		for j in range(tib.size()):
			if not loot["ulti_tokens"].has(keys[j]):
				loot["ulti_tokens"][keys[j]] = values[j]
			else:
				loot["ulti_tokens"][keys[j]] += values[j]
	for i in boxes:
		if not i.has("amulet_frags"):
			continue
		var tib = i["amulet_frags"]
		var keys = tib.keys()
		var values = tib.values()
		for j in range(tib.size()):
			if not loot["amulet_frags"].has(keys[j]):
				loot["amulet_frags"][keys[j]] = values[j]
			else:
				loot["amulet_frags"][keys[j]] += values[j]
	if loot["tokens"].empty():
		loot.erase("tokens")
	if loot["ulti_tokens"].empty():
		loot.erase("ulti_tokens")
	if loot["amulet_frags"].empty():
		loot.erase("amulet_frags")
	loot["gadget"] = []
	loot["soul_power"] = []
	loot["class"] = []
	for i in boxes:
		if i.has("gadget"):
			if loot["gadget"].has(i["gadget"][0]):
				continue
			loot["gadget"].append_array(i["gadget"])
	for i in boxes:
		if i.has("soul_power"):
			if loot["soul_power"].has(i["soul_power"][0]):
				continue
			loot["soul_power"].append_array(i["soul_power"])
	for i in boxes:
		if i.has("class"):
			if loot["class"].has(i["class"][0]):
				continue
			loot["class"].append_array(i["class"])
	if loot["gadget"].empty():
		loot.erase("gadget")
	if loot["soul_power"].empty():
		loot.erase("soul_power")
	if loot["class"].empty():
		loot.erase("class")
	return loot


func percent_chance(in_chance):
	in_chance *= 10000
	var max_add = 1000000 - in_chance
	var chance_range_start = gen.randi_range(0, max_add)
	var chance_range_end = chance_range_start + in_chance
	var random_number = gen.randi_range(0, 1000000)
	if random_number >= chance_range_start and random_number <= chance_range_end:
		return true
	return false
