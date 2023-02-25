extends WindowDialog


enum Type {
	SELECT_LEVEL = 0,
	END_LEVEL = 1
}
var curr_lvl = "1_1"
var curr_day = 0
var curr_ut = 0
var prev_classes = []
var end_rewards = {}
var gen : RandomNumberGenerator
export (Type) var type = Type.SELECT_LEVEL
onready var rewards_text = $rc
var AMULET_ICONS = {
	"none" : load("res://textures/items/amulet_none.png"),
	"power" : load("res://textures/items/amulet_power.png"),
	"defense" : load("res://textures/items/amulet_defense.png"),
	"health" : load("res://textures/items/amulet_health.png"),
	"speed" : load("res://textures/items/amulet_speed.png"),
	"reload" : load("res://textures/items/amulet_reload.png"),
	"ulti" : load("res://textures/items/amulet_ulti.png"),
}


func _ready():
	rewards_text.add_color_override("default_color", Color.white)
	rewards_text.add_color_override("font_color_shadow", Color(0, 0, 0, 0))
	gen = RandomNumberGenerator.new()
	gen.randomize()
	if get_tree().current_scene.name == "win" or get_tree().current_scene.name == "game_over":
		get_close_button().connect("pressed", self, "menu")
	if type == Type.END_LEVEL:
		show_d_win()
		return
	$play/menu.get_popup().connect("id_pressed", self, "menu_pressed")
	if OS.has_feature("HTML5"):
		$play/menu.disabled = true
	curr_day = Time.get_datetime_dict_from_system()["day"]
	curr_ut = Time.get_unix_time_from_system()
	for i in range(5):
		$class2.set_item_disabled(i, not G.CLASSES_ID[i] in G.getv("classes", []))
	prev_classes = G.getv("classes", [])


func _process(delta):
	if type == Type.END_LEVEL:
		return
	if curr_day != Time.get_datetime_dict_from_system()["day"] and visible and Time.get_unix_time_from_system() >= curr_ut:
		curr_day = Time.get_datetime_dict_from_system()["day"]
		curr_ut = Time.get_unix_time_from_system()
		hide()
		show_d(curr_lvl)
	if prev_classes != G.getv("classes", []):
		for i in range(5):
			$class2.set_item_disabled(i, not G.CLASSES_ID[i] in G.getv("classes", []))
		prev_classes = G.getv("classes", [])


func select_class(id):
	var selected_class = G.CLASSES_ID[id]
	G.setv("selected_class", selected_class)
	for i in $classes.get_children():
		if i.name != selected_class:
			i.hide()
		else:
			i.show()
	if selected_class == "player":
		$stats.hide()
		$gadget.hide()
		$sp.hide()
		$amulet.hide()
		return
	$gadget.hide()
	$sp.hide()
	$amulet.hide()
	$stats.show()
	if G.getv(selected_class + "_gadget", false):
		$gadget.show()
		$gadget.self_modulate = Color.white
	elif G.getv(selected_class + "_level", 0) >= 15:
		$gadget.show()
		$gadget.self_modulate = Color.webgray
	if G.getv(selected_class + "_soul_power", false):
		$sp.show()
		$sp.self_modulate = Color.white
	elif G.getv(selected_class + "_level", 0) >= 20:
		$sp.show()
		$sp.self_modulate = Color.webgray
	if G.getv(selected_class + "_level", 0) >= 10:
		$amulet.show()
		$amulet.texture_normal = AMULET_ICONS[G.AMULET[G.getv(selected_class + "_amulet", -1)]]
	$stats.text = "Сила: " + str(G.getv(selected_class + "_level", 0)) + " Навык: " + str(G.getv(selected_class + "_ulti_level", 1))


func show_d(lvl = "1_1"):
	select_class(G.CLASSES_BY_ID[G.getv("selected_class", "player")])
	curr_lvl = lvl
	G.current_level = curr_lvl
	popup_centered()
	window_title = "Уровень " + curr_lvl.split("_")[0] + "-" + curr_lvl.split("_")[1]
	$class2.select(G.CLASSES_BY_ID[G.getv("selected_class", "player")])
	display_rewards(lvl)


func show_d_win():
	yield(get_tree(), "idle_frame")
	if AdManager.ad_counter == 1:
		AdManager.showInterstitial()
		AdManager.ad_counter = 0
	else:
		AdManager.ad_counter = 1
	$particles.set_as_toplevel(true)
	curr_lvl = G.current_level
	var next_lvl = curr_lvl.split("_")[0] + "_" + str(int(curr_lvl.split("_")[1]) + 1)
	if curr_lvl.split("_")[1] == "10":
		next_lvl = str(int(curr_lvl.split("_")[0]) + 1) + "_1"
	var max_lvl = G.getv("level", "1_1")
	var set_new = true
	if max_lvl.split("_")[0] == next_lvl.split("_")[0]:
		if int(max_lvl.split("_")[1]) > int(next_lvl.split("_")[1]):
			set_new = false
	elif int(max_lvl.split("_")[0]) > int(next_lvl.split("_")[0]):
		set_new = false
	if set_new:
		G.setv("level", next_lvl)
	for i in $classes2.get_children():
		if i.name != G.getv("selected_class", "player"):
			i.hide()
		else:
			i.show()
			$"../..".get_node("class_%s/%s/anim" % [i.name, i.name]).play("attack")
	popup_centered()
	window_title = "Уровень " + curr_lvl.split("_")[0] + "-" + curr_lvl.split("_")[1] + " пройден!"
	set_win_rewards(G.current_level)


func play():
	if get_tree().current_scene.name == "game_over":
		G.setv("go_chance", true)
	G.change_to_scene("res://scenes/levels/level_" + curr_lvl + ".scn")


func claim_reward():
	hide()
	G.receive_loot(end_rewards)
	yield(G, "loot_end")
	popup_centered()
	G.setv(curr_lvl + "_c", Time.get_datetime_dict_from_system())
	G.setv(curr_lvl + "_c_ut", Time.get_unix_time_from_system())
	$claim.hide()
	$buttons.show()


func next():
	var next_lvl = curr_lvl.split("_")[0] + "_" + str(int(curr_lvl.split("_")[1]) + 1)
	if curr_lvl.split("_")[1] == "10":
		next_lvl = str(int(curr_lvl.split("_")[0]) + 1) + "_1"
	if not ResourceLoader.exists("res://scenes/levels/level_" + next_lvl + ".scn"):
		return
	$"../../select_level/select_level_dialog".show_d(next_lvl)
	hide()


func restart():
	$"../../select_level/select_level_dialog".show_d(G.current_level)
	hide()


func get_power_ulti_classes():
	var CLASSES = ["knight", "butcher", "spearman", "wizard", "archer"]
	var power_classes = []
	var ulti_classes = []
	var classes_to_unlock = CLASSES.duplicate()
	var had_classes = G.getv("classes", [])
	for i in had_classes:
		if i in classes_to_unlock:
			classes_to_unlock.erase(i)
	for i in had_classes:
		if G.getv(i + "_level", 0) < 20:
			power_classes.append(i)
		if G.getv(i + "_ulti_level", 0) < 5:
			ulti_classes.append(i)
	return [not power_classes.empty(), not ulti_classes.empty()]


func display_rewards(level = ""):
	var mod_lvl = 1 + float(level.split("_")[0]) * 0.4
	var mod_day = 1.5 if G.getv(level + "_c", {"day":50})["day"] != Time.get_datetime_dict_from_system()["day"] and G.getv(level + "_c_ut", 0) <= Time.get_unix_time_from_system() else 1
	mod_day = 2 if G.getv(level + "_c", {}).hash() == {}.hash() else mod_day
	mod_day = 5 if G.getv(level + "_c", {}).hash() == {}.hash() and level.split("_")[1] == "10" else mod_day
	var coins_count = str(round(25 * mod_lvl * mod_day / 5) * 5) + "-" + str(round(50 * mod_lvl * mod_day / 5) * 5)
	var tokens_chance = 30 if get_power_ulti_classes()[0] else 0
	var ulti_chance = 20 if get_power_ulti_classes()[1] else 0
	var tokens_count = str(round(4 * mod_lvl * mod_day)) + "-" + str(round(9 * mod_lvl * mod_day))
	var ulti_tokens_count = str(round(1 * mod_lvl * mod_day)) + "-" + str(round(2 * mod_lvl * mod_day))
	var gold_box_chance = clamp(-20 + (mod_day - 1) * 70, 0, 100)
	var box_chance = clamp((mod_lvl - 1) * 25 + (mod_day - 1) * 500, 0, 100)
	var potion_chance = round((mod_lvl - 1) * 2.5)
	var text = "[center][img=24x24]res://textures/items/coin.png[/img] {count} ({chance}%)".format({"count" : coins_count, "chance" : 100 - tokens_chance - ulti_chance})
	if tokens_chance > 0:
		text += "/[img=24x24]res://textures/items/wild_token.png[/img] {count} ({chance}%)".format({"count" : tokens_count, "chance" : tokens_chance})
	if ulti_chance > 0:
		text += "/[img=24x24]res://textures/items/wild_ulti_token.png[/img] {count} ({chance}%)".format({"count" : ulti_tokens_count, "chance" : ulti_chance})
	if gold_box_chance > 0 or box_chance > 0:
		text += "\n"
	if gold_box_chance > 0:
		if box_chance > 0:
			box_chance -= gold_box_chance
		text += "[img=24x24]res://textures/items/gold_box.png[/img] 1 ({chance}%)".format({"chance" : gold_box_chance})
	if box_chance > 0:
		if gold_box_chance > 0:
			text += "/"
		text += "[img=24x24]res://textures/items/box.png[/img] 1 ({chance}%)".format({"chance" : box_chance})
	text += "\n[img=24x24]res://textures/items/small_potion.png[/img] 1 ({chance}%)[/center]".format({"chance" : potion_chance})
	rewards_text.bbcode_text = text


func set_win_rewards(level = ""):
	var mod_lvl = 1 + float(level.split("_")[0]) * 0.4
	var mod_day = 1.5 if G.getv(level + "_c", {"day":50})["day"] != Time.get_datetime_dict_from_system()["day"]  and G.getv(level + "_c_ut", 0) <= Time.get_unix_time_from_system() else 1
	mod_day = 2 if G.getv(level + "_c", {}).hash() == {}.hash() else mod_day
	mod_day = 5 if G.getv(level + "_c", {}).hash() == {}.hash() and level.split("_")[1] == "10" else mod_day
	var coins_count_min = round(25 * mod_lvl * mod_day / 5) * 5
	var coins_count_max = round(50 * mod_lvl * mod_day / 5) * 5
	var tokens_chance = 30 if get_power_ulti_classes()[0] else 0
	var ulti_chance = 20 if get_power_ulti_classes()[1] else 0
	var tokens_count_min = round(4 * mod_lvl * mod_day)
	var tokens_count_max = round(9 * mod_lvl * mod_day)
	var ulti_tokens_count_min = round(1 * mod_lvl * mod_day)
	var ulti_tokens_count_max = round(2 * mod_lvl * mod_day)
	var gold_box_chance = clamp(-20 + (mod_day - 1) * 70, 0, 100)
	var box_chance = clamp((mod_lvl - 1) * 25 + (mod_day - 1) * 500, 0, 100)
	var potion_chance = round((mod_lvl - 1) * 2.5)
	# Generating rewards.
	var give_tokens = percent_chance(tokens_chance)
	gen.randomize()
	var give_ulti_tokens = percent_chance(ulti_chance)
	var give_box = percent_chance(box_chance)
	var give_gold_box = percent_chance(gold_box_chance)
	var give_potion = percent_chance(potion_chance)
	if give_ulti_tokens:
		end_rewards["wild_ulti_tokens"] = gen.randi_range(ulti_tokens_count_min, ulti_tokens_count_max)
	elif give_tokens:
		end_rewards["wild_tokens"] = gen.randi_range(tokens_count_min, tokens_count_max)
	else:
		end_rewards["coins"] = gen.randi_range(coins_count_min / 5, coins_count_max / 5) * 5
	if give_gold_box:
		end_rewards["gold_box"] = 1
	elif give_box:
		end_rewards["box"] = 1
	if give_potion:
		if G.getv("potions1", 0) < 5:
			end_rewards["potions1"] = 1
		else:
			if end_rewards.has("coins"):
				end_rewards["coins"] += 275
			else:
				end_rewards["coins"] = 275
	var text = "[center]"
	for i in end_rewards:
		match i:
			"coins":
				text += "[img=24x24]res://textures/items/coin.png[/img] " + str(end_rewards["coins"])
			"wild_tokens":
				text += "[img=24x24]res://textures/items/wild_token.png[/img] " + str(end_rewards["wild_tokens"])
			"wild_ulti_tokens":
				text += "[img=24x24]res://textures/items/wild_ulti_token.png[/img] " + str(end_rewards["wild_ulti_tokens"])
			"box":
				text += "[img=24x24]res://textures/items/box.png[/img] 1"
			"gold_box":
				text += "[img=24x24]res://textures/items/gold_box.png[/img] 1"
			"potions1":
				text += "[img=24x24]res://textures/items/small_potion.png[/img] 1"
		text += "\n"
	text += "[/center]"
	rewards_text.bbcode_text = text


func percent_chance(in_chance):
	in_chance = clamp(in_chance, 0, 100)
	in_chance *= 10000
	var max_add = 1000000 - in_chance
	var chance_range_start = gen.randi_range(0, max_add)
	var chance_range_end = chance_range_start + in_chance
	var random_number = gen.randi_range(0, 1000000)
	if random_number >= chance_range_start and random_number <= chance_range_end:
		return true
	return false


func menu():
	get_tree().change_scene("res://scenes/menu/menu.scn")


func menu_pressed(id):
	hide()
	match id:
		0:
			$"../lobby_dialog".create()
		1:
			$"../lobby_dialog".join()
