extends Control


var selected_class = "player"
var is_upgrading_ulti = false
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
	"none" : load("res://textures/items/amulet_none.png"),
	"power" : load("res://textures/items/amulet_power.png"),
	"defense" : load("res://textures/items/amulet_defense.png"),
	"health" : load("res://textures/items/amulet_health.png"),
	"speed" : load("res://textures/items/amulet_speed.png"),
	"reload" : load("res://textures/items/amulet_reload.png"),
	"ulti" : load("res://textures/items/amulet_ulti.png"),
}
const AMULETS_COUNTS = {
	"knight" : [4, 4, 4, 5, 4, 5],
	"butcher" : [5, 3, 5, 4, 4, 5],
	"spearman" : [3, 4, 4, 4, 3, 5],
	"wizard" : [4, 4, 5, 3, 5, 5],
	"archer" : [6, 4, 4, 5, 4, 5],
}


func _ready():
	$help_dialog.get_cancel().text = "Отмена"
	$other.get_popup().connect("id_pressed", self, "menu_pressed")
	if OS.has_feature("HTML5"):
		$multiplayer_guide.dialog_text = "Мультиплеер не доступен в веб-версии. Установи игру на телефон, чтобы сыграть в него!"
	var max_lvl = false
	for i in $levels/levels.get_children():
		if i.name == "bg":
			continue
		i.connect("pressed", self, "play_lvl", [i.name])
		var nums = i.name.split("_")
		i.text = nums[0] + "-" + nums[1]
		if max_lvl:
			i.hide()
		if i.name == G.getv("level", "1_1"):
			max_lvl = true
			if G.getv("learned", false):
				i.grab_focus()


func menu_pressed(id):
	match id:
		0:
			$multiplayer_guide.popup_centered()
		1:
			$select_minigame.popup_centered()


func play_lvl(lvl = "1_1"):
	$select_level/select_level_dialog.show_d(lvl)


func _process(delta):
	$classes/gems.text = str(G.getv("gems", 20))
	$shop/gems.text = str(G.getv("gems", 20))
	$classes/coins.text = str(G.getv("coins", 1000))
	$shop/coins.text = str(G.getv("coins", 1000))


func exit():
	get_tree().change_scene("res://scenes/menu/menu.scn")


func classes(val = true):
	$classes.visible = val
	select_class()


func select_class(class_n = "player"):
	selected_class = class_n
	for i in $classes/classes.get_children():
		if i.name != selected_class:
			i.hide()
		else:
			i.show()
	$classes/class.text = G.CLASSES[selected_class]
	if selected_class == "player" or not selected_class in G.getv("classes", []):
		$classes/stats.hide()
		$classes/upgrade.hide()
		$classes/gadget.hide()
		$classes/sp.hide()
		$classes/amulet.hide()
		return
	$classes/gadget.hide()
	$classes/sp.hide()
	$classes/amulet.hide()
	$classes/stats.show()
	$classes/stats.text = "Сила: " + str(G.getv(selected_class + "_level", 0)) + " Навык: " + str(G.getv(selected_class + "_ulti_level", 1))
	if G.getv(selected_class + "_gadget", false):
		$classes/gadget.show()
		$classes/gadget.self_modulate = Color.white
	elif G.getv(selected_class + "_level", 0) >= 15:
		$classes/gadget.show()
		$classes/gadget.self_modulate = Color.webgray
	if G.getv(selected_class + "_soul_power", false):
		$classes/sp.show()
		$classes/sp.self_modulate = Color.white
	elif G.getv(selected_class + "_level", 0) >= 20:
		$classes/sp.show()
		$classes/sp.self_modulate = Color.webgray
	if G.getv(selected_class + "_level", 0) >= 10:
		$classes/amulet.show()
		$classes/amulet.texture_normal = AMULET_ICONS[G.AMULET[G.getv(selected_class + "_amulet", -1)]]
	$classes/upgrade.show()
	$classes/upgrade/bar/token.self_modulate = G.CLASS_COLORS[selected_class]
	$classes/upgrade/bar_ulti/token.self_modulate = G.CLASS_COLORS[selected_class]
	$classes/upgrade/bar/token/icon.texture = CLASS_ICONS[selected_class]
	$classes/upgrade/bar_ulti/token/icon.texture = ULTI_ICONS[selected_class]
	$classes/upgrade/bar.tint_progress = Color.magenta if G.getv(selected_class + "_tokens", 0) < G.getv(selected_class + "_level", 0) * 10 + 10 else Color.green
	$classes/upgrade/bar.max_value = G.getv(selected_class + "_level", 0) * 10 + 10
	$classes/upgrade/bar.value = G.getv(selected_class + "_tokens", 0)
	$classes/upgrade/bar/label.text = str($classes/upgrade/bar.value) + "/" + str($classes/upgrade/bar.max_value)
	$classes/upgrade/upgrade.disabled = true
	$classes/upgrade/upgrade.text = str(G.getv(selected_class + "_level", 0) * 50 + 50)
	if $classes/upgrade/bar.tint_progress == Color.green and G.getv(selected_class + "_level", 0) * 50 + 50 <= G.getv("coins", 0):
		$classes/upgrade/upgrade.disabled = false
	if G.getv(selected_class + "_level", 0) >= 20:
		$classes/upgrade/upgrade.disabled = true
		$classes/upgrade/upgrade.text = "МАКС."
		$classes/upgrade/bar/label.text = "МАКСИМУМ"
		$classes/upgrade/bar.value = 0
		if G.getv(selected_class + "_tokens", 0) > 0:
			$classes/upgrade/upgrade.text = "Прод."
			$classes/upgrade/upgrade.disabled = false
	$classes/upgrade/bar_ulti.tint_progress = Color.red if G.getv(selected_class + "_ulti_tokens", 0) < G.getv(selected_class + "_ulti_level", 1) * 30 + 30 else Color.green
	$classes/upgrade/bar_ulti.max_value = G.getv(selected_class + "_ulti_level", 1) * 30 + 30
	$classes/upgrade/bar_ulti.value = G.getv(selected_class + "_ulti_tokens", 0)
	$classes/upgrade/bar_ulti/label.text = str($classes/upgrade/bar_ulti.value) + "/" + str($classes/upgrade/bar_ulti.max_value)
	$classes/upgrade/upgrade_ulti.disabled = true
	$classes/upgrade/upgrade_ulti.text = str(G.getv(selected_class + "_ulti_level", 1) * 600 + 600)
	if $classes/upgrade/bar_ulti.tint_progress == Color.green and G.getv(selected_class + "_ulti_level", 1) * 600 + 600 <= G.getv("coins", 0):
		$classes/upgrade/upgrade_ulti.disabled = false
	if G.getv(selected_class + "_ulti_level", 1) >= 5:
		$classes/upgrade/upgrade_ulti.disabled = true
		$classes/upgrade/upgrade_ulti.text = "МАКС."
		$classes/upgrade/bar_ulti/label.text = "МАКСИМУМ"
		$classes/upgrade/bar_ulti.value = 0
		if G.getv(selected_class + "_ulti_tokens", 0) > 0:
			$classes/upgrade/upgrade_ulti.text = "Прод."
			$classes/upgrade/upgrade_ulti.disabled = false


func amulet():
	$classes/infos/amulet.window_title = "Амулеты класса " + G.CLASSES[selected_class]
	setup_amulets()
	$classes/infos/amulet.popup_centered()


func gadget():
	$classes/infos/gadget_info.dialog_text = G.GADGETS[selected_class]
	$classes/infos/gadget_info.popup_centered()


func soul_power():
	$classes/infos/sp_info.dialog_text = G.SOUL_POWERS[selected_class]
	$classes/infos/sp_info.popup_centered()


func setup_amulets():
	var am = $classes/infos/amulet/panels
	for i in am.get_child_count():
		var n = am.get_child(i)
		n.self_modulate = Color.white
		n.get_node("craft").disabled = false
		n.get_node("craft").text = "Создать"
		n.get_node("bar").show()
		var count = G.getv("amulet_frags_"+G.AMULET[i], 0)
		var max_count = AMULETS_COUNTS[selected_class][i]
		if not i in G.getv(selected_class+"_amulets", []):
			n.get_node("bar").max_value = max_count
			n.get_node("bar").value = count
			n.get_node("bar/count").text = str(count)+"/"+str(max_count)
			n.get_node("bar").tint_progress = Color.green if count >= max_count else Color(0.5, 1, 0.5)
			if count < max_count:
				n.get_node("craft").disabled = true
		else:
			n.get_node("bar").hide()
			n.get_node("craft").text = "Выбрать"
		if i == G.getv(selected_class+"_amulet", -1):
			n.self_modulate = Color.green
			n.get_node("craft").disabled = true
			n.get_node("craft").text = "Выбрано"


func craft_amulet(id):
	if id in G.getv(selected_class+"_amulets", []):
		G.setv(selected_class+"_amulet", id)
		setup_amulets()
		select_class(selected_class)
		return
	$amulet_craft/screen/type.text = G.AMULET_NAME[id]
	$amulet_craft/screen/class.text = G.CLASSES[selected_class]
	$amulet_craft/screen/icon.texture = AMULET_ICONS[G.AMULET[id]]
	$amulet_craft/screen/anim.play("craft")
	$classes/infos/amulet.hide()
	G.addv("amulet_frags_"+G.AMULET[id], -AMULETS_COUNTS[selected_class][id], 0)
	G.addv(selected_class+"_amulets", [id], [])
	G.save()


func done_amulet():
	amulet()
	$amulet_craft/screen/anim.stop()
	$amulet_craft/screen.hide()


func info(val = true):
	if not val:
		is_upgrading_ulti = false
		var curr_info = get_node("classes/info_" + selected_class)
		curr_info.get_node("health/value").self_modulate = Color.white
		curr_info.get_node("attack/value").self_modulate = Color.white
		curr_info.get_node("defense/value").self_modulate = Color.white
		if curr_info.get_node_or_null("attack2/value") != null:
			curr_info.get_node("attack2/value").self_modulate = Color.white
		if curr_info.get_node_or_null("ulti/value") != null:
			curr_info.get_node("ulti/value").self_modulate = Color.white
		if curr_info.get_node_or_null("ulti_c/value") != null:
			curr_info.get_node("ulti_c/value").self_modulate = Color.white
		$classes/info_archer.hide()
		$classes/info_butcher.hide()
		$classes/info_spearman.hide()
		$classes/info_knight.hide()
		$classes/info_wizard.hide()
		$classes/info_player.hide()
		$classes/classes.show()
	else:
		$classes/classes.hide()
		get_node("classes/info_" + selected_class).show()
	get_node("classes/info_" + selected_class + "/title").text = "ПОКАЗАТЕЛИ"
	var node = get_node_or_null("classes/info_" + selected_class + "/upgrade") 
	if node != null:
		node.hide()
	match selected_class:
		"knight":
			$classes/info_knight/attack/value.text = str(G.getv(selected_class + "_level", 0) * 5 + 25)
			$classes/info_knight/health/value.text = str(G.getv(selected_class + "_level", 0) * 20 + 100)
			$classes/info_knight/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			var attack_power = 1
			var times = 0
			match G.getv("knight_ulti_level", 1):
				1:
					times = 5
					attack_power = 1 * attack_power
				2:
					times = 7
					attack_power = 1 * attack_power
				3:
					times = 7
					attack_power = 2 * attack_power
				4:
					times = 8
					attack_power = 2 * attack_power
				5:
					times = 10
					attack_power = 2 * attack_power
			$classes/info_knight/ulti/value.text = "x" + str(attack_power)
			$classes/info_knight/ulti_c/value.text = str(times)
		"butcher":
			$classes/info_butcher/attack/value.text = str(G.getv(selected_class + "_level", 0) * 6 + 30)
			$classes/info_butcher/health/value.text = str(G.getv(selected_class + "_level", 0) * 24 + 120)
			$classes/info_butcher/defense/value.text = str(G.getv(selected_class + "_level", 0) * 0 + 0)
			var attack_power = 1
			match G.getv("butcher_ulti_level", 1):
				1:
					attack_power = 5 * attack_power
				2:
					attack_power = 8 * attack_power
				3:
					attack_power = 10 * attack_power
				4:
					attack_power = 12 * attack_power
				5:
					attack_power = 16 * attack_power
			$classes/info_butcher/ulti/value.text = "x" + str(attack_power)
		"spearman":
			$classes/info_spearman/attack/value.text = str(G.getv(selected_class + "_level", 0) * 4 + 20)
			$classes/info_spearman/health/value.text = str(G.getv(selected_class + "_level", 0) * 20 + 100)
			$classes/info_spearman/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			var attack_power = G.getv("spearman_ulti_level", 1)
			var times =  G.getv("spearman_ulti_level", 1) * 1.25 + 1.25
			$classes/info_spearman/ulti/value.text = "x" + str(attack_power)
			$classes/info_spearman/ulti_c/value.text = str(times) + " с."
		"wizard":
			$classes/info_wizard/attack/value.text = str(G.getv(selected_class + "_level", 0) * 6 + 30)
			$classes/info_wizard/attack2/value.text = str(G.getv(selected_class + "_level", 0) * 2 + 10)
			$classes/info_wizard/health/value.text = str(G.getv(selected_class + "_level", 0) * 16 + 80)
			$classes/info_wizard/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			var times =  G.getv("wizard_ulti_level", 1) * 15
			$classes/info_wizard/ulti_c/value.text = str(times) + "%"
		"archer":
			$classes/info_archer/attack/value.text = str(G.getv(selected_class + "_level", 0) * 7 + 35)
			$classes/info_archer/attack2/value.text = str(G.getv(selected_class + "_level", 0) * 2 + 10)
			$classes/info_archer/health/value.text = str(G.getv(selected_class + "_level", 0) * 20 + 100)
			$classes/info_archer/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			$classes/info_archer/ulti/value.text = "x" + str(G.getv(selected_class + "_ulti_level", 1) * 1)


func upgrade():
	if G.getv(selected_class + "_level", 0) >= 20:
		sell(false)
		return
	info(true)
	var curr_info = get_node("classes/info_" + selected_class)
	curr_info.get_node("title").text = "УЛУЧШИТЬ ДО " + str(G.getv(selected_class + "_level", 0) + 1) + "-Й СИЛЫ?"
	curr_info.get_node("upgrade").show() 
	var health_mod = 0
	var defense_mod = 0
	var attack_mod = 0
	var attack2_mod = 0
	match selected_class:
		"knight":
			health_mod = 20
			attack_mod = 5
			defense_mod = 1
		"butcher":
			health_mod = 24
			attack_mod = 6
			defense_mod = 0
		"spearman":
			health_mod = 20
			attack_mod = 4
			defense_mod = 1
		"wizard":
			health_mod = 16
			attack_mod = 6
			defense_mod = 1
			attack2_mod = 2
		"archer":
			health_mod = 20
			attack_mod = 7
			defense_mod = 1
			attack2_mod = 2
	curr_info.get_node("health/value").text = curr_info.get_node("health/value").text + " +" + str(health_mod)
	curr_info.get_node("health/value").self_modulate = Color(0.5, 1, 0.5)
	curr_info.get_node("attack/value").text = curr_info.get_node("attack/value").text + " +" + str(attack_mod)
	curr_info.get_node("attack/value").self_modulate = Color(0.5, 1, 0.5)
	if defense_mod != 0:
		curr_info.get_node("defense/value").text = curr_info.get_node("defense/value").text + " +" + str(defense_mod)
		curr_info.get_node("defense/value").self_modulate = Color(0.5, 1, 0.5)
	if attack2_mod != 0:
		curr_info.get_node("attack2/value").text = curr_info.get_node("attack2/value").text + " +" + str(attack2_mod)
		curr_info.get_node("attack2/value").self_modulate = Color(0.5, 1, 0.5)


func confirm_upgrade():
	if is_upgrading_ulti:
		confirm_upgrade_ulti()
		return
	info(false)
	var curr_info = get_node("classes/info_" + selected_class)
	var prev_h = curr_info.get_node("health/value").text
	var prev_dm = curr_info.get_node("attack/value").text
	var prev_dm2 = 0
	if curr_info.get_node_or_null("attack2/value") != null:
		prev_dm2 = curr_info.get_node("attack2/value").text
	var prev_df = curr_info.get_node("defense/value").text
	if curr_info.get_node_or_null("attack2/value") != null:
		curr_info.get_node("attack2/value").self_modulate = Color.white
	G.setv("coins", G.getv("coins") - (G.getv(selected_class + "_level", 0) * 50 + 50))
	G.setv(selected_class + "_tokens", G.getv(selected_class + "_tokens") - (G.getv(selected_class + "_level", 0) * 10 + 10))
	G.setv(selected_class + "_level", G.getv(selected_class + "_level", 0) + 1)
	select_class(selected_class)
	info(false)
	var h = curr_info.get_node("health/value").text
	var dm = curr_info.get_node("attack/value").text
	var dm2 = 0
	if curr_info.get_node_or_null("attack2/value") != null:
		dm2 = curr_info.get_node("attack2/value").text
	var df = curr_info.get_node("defense/value").text
	for i in $upgrade/upgrade/classes.get_children():
		if i.name.begins_with("p"):
			continue
		i.hide()
	get_node("upgrade/upgrade/classes/" + selected_class).show()
	$upgrade/upgrade/bg.self_modulate = G.CLASS_COLORS_LIGHT[selected_class]
	$upgrade/upgrade/glow.self_modulate = G.CLASS_COLORS_HIGHLIGHT[selected_class]
	$upgrade/upgrade/title.text = G.CLASSES[selected_class]
	for i in $upgrade/upgrade/panels.get_children():
		i.hide()
		i.get_node("sfx_value").volume_db = linear2db(0)
	$upgrade/upgrade/panel/title.text = "Уровень"
	$upgrade/upgrade/panel/previous.text = str(G.getv(selected_class + "_level", 0) - 1)
	$upgrade/upgrade/panel/next.text = str(G.getv(selected_class + "_level", 0))
	$upgrade/upgrade/panels/panel0.show()
	$upgrade/upgrade/panels/panel0/title.text = "Здоровье"
	$upgrade/upgrade/panels/panel0/previous.text = prev_h
	$upgrade/upgrade/panels/panel0/next.text = h
	$upgrade/upgrade/panels/panel0.get_node("sfx_value").volume_db = linear2db(1)
	if int(prev_df) != 0:
		$upgrade/upgrade/panels/panel1.show()
		$upgrade/upgrade/panels/panel1/title.text = "Защита"
		$upgrade/upgrade/panels/panel1/previous.text = prev_df
		$upgrade/upgrade/panels/panel1/next.text = df
		$upgrade/upgrade/panels/panel1.get_node("sfx_value").volume_db = linear2db(1)
	$upgrade/upgrade/panels/panel2.show()
	$upgrade/upgrade/panels/panel2/title.text = "Урон"
	$upgrade/upgrade/panels/panel2/previous.text = prev_dm
	$upgrade/upgrade/panels/panel2/next.text = dm
	$upgrade/upgrade/panels/panel2.get_node("sfx_value").volume_db = linear2db(1)
	if int(prev_dm2) != 0:
		$upgrade/upgrade/panels/panel3.show()
		$upgrade/upgrade/panels/panel3/title.text = "Урон(бл.)"
		$upgrade/upgrade/panels/panel3/previous.text = prev_dm2
		$upgrade/upgrade/panels/panel3/next.text = dm2
		$upgrade/upgrade/panels/panel3.get_node("sfx_value").volume_db = linear2db(1)
	$upgrade/upgrade/anim.play("upgrade")


func upgrade_ulti():
	if G.getv(selected_class + "_ulti_level", 1) >= 5:
		sell(true)
		return
	is_upgrading_ulti = true
	info(true)
	var curr_info = get_node("classes/info_" + selected_class)
	curr_info.get_node("title").text = "УЛУЧШИТЬ ДО " + str(G.getv(selected_class + "_ulti_level", 1) + 1) + "-ГО НАВЫКА?"
	curr_info.get_node("upgrade").show() 
	var lvl = G.getv(selected_class + "_ulti_level", 1) + 1
	var ulti_mod = ""
	var ulti_c_mod = ""
	match selected_class:
		"knight":
			match lvl:
				2, 5:
					ulti_c_mod = "2"
				3:
					ulti_mod = "x1"
				4:
					ulti_c_mod = "1"
		"butcher":
			match lvl:
				2:
					ulti_mod = "x3"
				3, 4:
					ulti_mod = "x2"
				5:
					ulti_mod = "x4"
		"spearman":
			ulti_mod = "x1"
			ulti_c_mod = "1,25"
		"wizard":
			ulti_c_mod = "15%"
		"archer":
			ulti_mod = "x1"
	if not ulti_mod.empty():
		curr_info.get_node("ulti/value").text = curr_info.get_node("ulti/value").text + " +" + str(ulti_mod)
		curr_info.get_node("ulti/value").self_modulate = Color(0.5, 1, 0.5)
	if not ulti_c_mod.empty():
		curr_info.get_node("ulti_c/value").text = curr_info.get_node("ulti_c/value").text + " +" + str(ulti_c_mod)
		curr_info.get_node("ulti_c/value").self_modulate = Color(0.5, 1, 0.5)


func confirm_upgrade_ulti():
	is_upgrading_ulti = false
	info(false)
	var curr_info = get_node("classes/info_" + selected_class)
	var prev_u = curr_info.get_node("ulti/value").text
	var prev_uc = ""
	if curr_info.get_node_or_null("ulti_c/value") != null:
		prev_uc = curr_info.get_node("ulti_c/value").text
	G.setv("coins", G.getv("coins") - (G.getv(selected_class + "_ulti_level", 1) * 600 + 600))
	G.setv(selected_class + "_ulti_tokens", G.getv(selected_class + "_ulti_tokens") - (G.getv(selected_class + "_ulti_level", 1) * 30 + 30))
	G.setv(selected_class + "_ulti_level", G.getv(selected_class + "_ulti_level", 1) + 1)
	select_class(selected_class)
	info(false)
	var u = curr_info.get_node("ulti/value").text
	var uc = ""
	if curr_info.get_node_or_null("ulti_c/value") != null:
		uc = curr_info.get_node("ulti_c/value").text
	for i in $upgrade/upgrade/classes.get_children():
		if i.name.begins_with("p"):
			continue
		i.hide()
	get_node("upgrade/upgrade/classes/" + selected_class).show()
	$upgrade/upgrade/bg.self_modulate = G.CLASS_COLORS_LIGHT[selected_class]
	$upgrade/upgrade/glow.self_modulate = G.CLASS_COLORS_HIGHLIGHT[selected_class]
	$upgrade/upgrade/title.text = G.CLASSES[selected_class]
	for i in $upgrade/upgrade/panels.get_children():
		i.hide()
		i.get_node("sfx_value").volume_db = linear2db(0)
	$upgrade/upgrade/panel/title.text = "Навык"
	$upgrade/upgrade/panel/previous.text = str(G.getv(selected_class + "_ulti_level", 1) - 1)
	$upgrade/upgrade/panel/next.text = str(G.getv(selected_class + "_ulti_level", 1))
	if prev_u != u:
		$upgrade/upgrade/panels/panel0.show()
		$upgrade/upgrade/panels/panel0/title.text = curr_info.get_node("ulti").text
		$upgrade/upgrade/panels/panel0/previous.text = prev_u
		$upgrade/upgrade/panels/panel0/next.text = u
		$upgrade/upgrade/panels/panel0.get_node("sfx_value").volume_db = linear2db(1)
	if not prev_uc.empty() and prev_uc != uc:
		$upgrade/upgrade/panels/panel1.show()
		$upgrade/upgrade/panels/panel1/title.text = curr_info.get_node("ulti_c").text
		$upgrade/upgrade/panels/panel1/previous.text = prev_uc
		$upgrade/upgrade/panels/panel1/next.text = uc
		$upgrade/upgrade/panels/panel1.get_node("sfx_value").volume_db = linear2db(1)
	$upgrade/upgrade/anim.play("upgrade")


func close_upgrade():
	$upgrade/upgrade/anim.stop()
	$upgrade/upgrade.hide()
	$upgrade/tint/tint.color = Color(1, 1, 1, 0)


func sell(ulti = false):
	var suffix = "_tokens" if not ulti else "_ulti_tokens"
	var tokens_left = G.getv(selected_class + suffix)
	G.setv(selected_class + suffix, 0)
	var coins_mul = 12 if ulti else 3
	var coins_get = tokens_left * coins_mul
	select_class(selected_class)
	var n = load("res://scenes/menu/box.scn").instance()
	G.receive_loot({"coins":coins_get})


func shop(val = true):
	$shop.visible = val


func help():
	G.setv("learned", false)
	G.setv("learned_ids", [])
	get_tree().change_scene("res://scenes/menu/story.scn")


func try():
	G.selected_class_to_test = selected_class
	G.change_to_scene("res://scenes/levels/test.scn")


