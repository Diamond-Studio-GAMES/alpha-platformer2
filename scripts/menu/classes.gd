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
	"knight" : load("res://textures/gui/ulti_icon_0.tres"),
	"butcher" : load("res://textures/gui/ulti_icon_1.tres"),
	"spearman" : load("res://textures/gui/ulti_icon_2.tres"),
	"wizard" : load("res://textures/gui/ulti_icon_3.tres"),
	"archer" : load("res://textures/gui/ulti_icon_4.tres")
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
	"spearman" : [4, 4, 5, 4, 4, 5],
	"wizard" : [4, 4, 5, 3, 5, 5],
	"archer" : [6, 4, 4, 5, 4, 5],
}


func _ready():
	select_class(G.getv("selected_class", "player"))
	if not G.getv("learned", false):
		G.setv("classes_visited", true)


func _process(delta):
	$gems.text = str(G.getv("gems", 20))
	$coins.text = str(G.getv("coins", 0))


func select_class(class_n = "player"):
	selected_class = class_n
	for i in $classes.get_children():
		if i.name != selected_class:
			i.hide()
		else:
			i.show()
	$class.text = tr(G.CLASSES[selected_class])
	if selected_class == "player" or not selected_class in G.getv("classes", []):
		$stats.hide()
		$upgrade.hide()
		$gadget.hide()
		$sp.hide()
		$amulet.hide()
		return
	$gadget.hide()
	$sp.hide()
	$amulet.hide()
	$stats.show()
	$stats.text = tr("class.power") + str(G.getv(selected_class + "_level", 0)) + tr("class.skill") + str(G.getv(selected_class + "_ulti_level", 1))
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
	$upgrade.show()
	$upgrade/bar/token.self_modulate = G.CLASS_COLORS[selected_class]
	$upgrade/bar_ulti/token.self_modulate = G.CLASS_COLORS[selected_class]
	$upgrade/bar/token/icon.texture = CLASS_ICONS[selected_class]
	$upgrade/bar_ulti/token/icon.texture = ULTI_ICONS[selected_class]
	$upgrade/bar.tint_progress = Color.magenta if G.getv(selected_class + "_tokens", 0) < G.getv(selected_class + "_level", 0) * 10 + 10 else Color.green
	$upgrade/bar.max_value = G.getv(selected_class + "_level", 0) * 10 + 10
	$upgrade/bar.value = G.getv(selected_class + "_tokens", 0)
	$upgrade/bar/label.text = str($upgrade/bar.value) + "/" + str($upgrade/bar.max_value)
	$upgrade/upgrade.disabled = true
	$upgrade/upgrade.text = str(G.getv(selected_class + "_level", 0) * 50 + 50)
	if $upgrade/bar.tint_progress == Color.green and G.getv(selected_class + "_level", 0) * 50 + 50 <= G.getv("coins", 0):
		$upgrade/upgrade.disabled = false
	if G.getv(selected_class + "_level", 0) >= 20:
		$upgrade/upgrade.disabled = true
		$upgrade/upgrade.text = tr("menu.max")
		$upgrade/bar/label.text = tr("menu.maximum")
		$upgrade/bar.value = 0
		if G.getv(selected_class + "_tokens", 0) > 0:
			$upgrade/upgrade.text = tr("menu.sell")
			$upgrade/upgrade.disabled = false
	$upgrade/bar_ulti.tint_progress = Color.red if G.getv(selected_class + "_ulti_tokens", 0) < G.getv(selected_class + "_ulti_level", 1) * 30 + 30 else Color.green
	$upgrade/bar_ulti.max_value = G.getv(selected_class + "_ulti_level", 1) * 30 + 30
	$upgrade/bar_ulti.value = G.getv(selected_class + "_ulti_tokens", 0)
	$upgrade/bar_ulti/label.text = str($upgrade/bar_ulti.value) + "/" + str($upgrade/bar_ulti.max_value)
	$upgrade/upgrade_ulti.disabled = true
	$upgrade/upgrade_ulti.text = str(G.getv(selected_class + "_ulti_level", 1) * 600 + 600)
	if $upgrade/bar_ulti.tint_progress == Color.green and G.getv(selected_class + "_ulti_level", 1) * 600 + 600 <= G.getv("coins", 0):
		$upgrade/upgrade_ulti.disabled = false
	if G.getv(selected_class + "_ulti_level", 1) >= 5:
		$upgrade/upgrade_ulti.disabled = true
		$upgrade/upgrade_ulti.text = tr("menu.max")
		$upgrade/bar_ulti/label.text = tr("menu.maximum")
		$upgrade/bar_ulti.value = 0
		if G.getv(selected_class + "_ulti_tokens", 0) > 0:
			$upgrade/upgrade_ulti.text = tr("menu.sell")
			$upgrade/upgrade_ulti.disabled = false


func amulet():
	$infos/amulet.window_title = tr("class.amulets") + tr(G.CLASSES[selected_class])
	setup_amulets()
	$infos/amulet.popup_centered()


func gadget():
	$infos/gadget_info.dialog_text = tr(G.GADGETS[selected_class])
	$infos/gadget_info.popup_centered()


func soul_power():
	$infos/sp_info.dialog_text = G.SOUL_POWERS[selected_class]
	$infos/sp_info.popup_centered()


func setup_amulets():
	var am = $infos/amulet/panels
	for i in am.get_child_count():
		var n = am.get_child(i)
		n.self_modulate = Color.white
		n.get_node("craft").disabled = false
		n.get_node("craft").text = tr("amulet.craft")
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
			n.get_node("craft").text = tr("menu.select")
		if i == G.getv(selected_class+"_amulet", -1):
			n.self_modulate = Color.green
			n.get_node("craft").disabled = true
			n.get_node("craft").text = tr("menu.selected")


func craft_amulet(id):
	if id in G.getv(selected_class + "_amulets", []):
		G.setv(selected_class + "_amulet", id)
		setup_amulets()
		select_class(selected_class)
		return
	$amulet_craft/screen/type.text = tr(G.AMULET_NAME[id])
	$amulet_craft/screen/class.text = tr(G.CLASSES[selected_class])
	$amulet_craft/screen/icon.texture = AMULET_ICONS[G.AMULET[id]]
	$amulet_craft/screen/anim.play("craft")
	$infos/amulet.hide()
	G.ach.complete(Achievements.LUCKY_AMULET)
	G.addv("amulet_frags_" + G.AMULET[id], -AMULETS_COUNTS[selected_class][id], 0)
	G.addv(selected_class + "_amulets", [id], [])
	G.save()


func done_amulet():
	amulet()
	$amulet_craft/screen/anim.stop()
	$amulet_craft/screen.hide()


func info(val = true):
	if not val:
		is_upgrading_ulti = false
		var curr_info = get_node("info_" + selected_class)
		curr_info.get_node("health/value").self_modulate = Color.white
		curr_info.get_node("attack/value").self_modulate = Color.white
		curr_info.get_node("defense/value").self_modulate = Color.white
		if curr_info.get_node_or_null("attack2/value") != null:
			curr_info.get_node("attack2/value").self_modulate = Color.white
		if curr_info.get_node_or_null("ulti/value") != null:
			curr_info.get_node("ulti/value").self_modulate = Color.white
		if curr_info.get_node_or_null("ulti_c/value") != null:
			curr_info.get_node("ulti_c/value").self_modulate = Color.white
		$info_archer.hide()
		$info_butcher.hide()
		$info_spearman.hide()
		$info_knight.hide()
		$info_wizard.hide()
		$info_player.hide()
		$classes.show()
	else:
		$classes.hide()
		get_node("info_" + selected_class).show()
	get_node("info_" + selected_class + "/title").text = tr("class.statistics")
	var node = get_node_or_null("info_" + selected_class + "/upgrade") 
	if node != null:
		node.hide()
	match selected_class:
		"knight":
			$info_knight/attack/value.text = str(G.getv(selected_class + "_level", 0) * 5 + 25)
			$info_knight/health/value.text = str(G.getv(selected_class + "_level", 0) * 20 + 100)
			$info_knight/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			var attack_power = 1
			var times = 0
			match G.getv("knight_ulti_level", 1):
				1:
					times = 5
					attack_power = 1
				2:
					times = 7
					attack_power = 1
				3:
					times = 7
					attack_power = 2
				4:
					times = 8
					attack_power = 2
				5:
					times = 10
					attack_power = 2
			$info_knight/ulti/value.text = "x" + str(attack_power)
			$info_knight/ulti_c/value.text = str(times)
		"butcher":
			$info_butcher/attack/value.text = str(G.getv(selected_class + "_level", 0) * 6 + 30)
			$info_butcher/health/value.text = str(G.getv(selected_class + "_level", 0) * 24 + 120)
			$info_butcher/defense/value.text = str(G.getv(selected_class + "_level", 0) * 0 + 0)
			var attack_power = 1
			match G.getv("butcher_ulti_level", 1):
				1:
					attack_power = 5
				2:
					attack_power = 8
				3:
					attack_power = 10
				4:
					attack_power = 12
				5:
					attack_power = 16
			$info_butcher/ulti/value.text = "x" + str(attack_power)
		"spearman":
			$info_spearman/attack/value.text = str(G.getv(selected_class + "_level", 0) * 5 + 25)
			$info_spearman/health/value.text = str(G.getv(selected_class + "_level", 0) * 16 + 80)
			$info_spearman/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			var attack_power = G.getv("spearman_ulti_level", 1)
			var times =  G.getv("spearman_ulti_level", 1) * 1.5 + 1.5
			$info_spearman/ulti/value.text = "x" + str(attack_power)
			$info_spearman/ulti_c/value.text = str(times) + tr("sec")
		"wizard":
			$info_wizard/attack/value.text = str(G.getv(selected_class + "_level", 0) * 6 + 30)
			$info_wizard/attack2/value.text = str(G.getv(selected_class + "_level", 0) * 2 + 10)
			$info_wizard/health/value.text = str(G.getv(selected_class + "_level", 0) * 16 + 80)
			$info_wizard/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			var times =  G.getv("wizard_ulti_level", 1) * 15
			$info_wizard/ulti_c/value.text = str(times) + "%"
		"archer":
			$info_archer/attack/value.text = str(G.getv(selected_class + "_level", 0) * 7 + 35)
			$info_archer/attack2/value.text = str(G.getv(selected_class + "_level", 0) * 2 + 10)
			$info_archer/health/value.text = str(G.getv(selected_class + "_level", 0) * 20 + 100)
			$info_archer/defense/value.text = str(G.getv(selected_class + "_level", 0) * 1 + 5)
			$info_archer/ulti/value.text = "x" + str(G.getv(selected_class + "_ulti_level", 1) * 1)


func upgrade():
	if G.getv(selected_class + "_level", 0) >= 20:
		sell(false)
		return
	info(true)
	var curr_info = get_node("info_" + selected_class)
	curr_info.get_node("title").text = tr("class.upgrade.power") % str(G.getv(selected_class + "_level", 0) + 1)
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
			health_mod = 16
			attack_mod = 5
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
	var curr_info = get_node("info_" + selected_class)
	var prev_h = curr_info.get_node("health/value").text
	var prev_dm = curr_info.get_node("attack/value").text
	var prev_dm2 = 0
	if curr_info.get_node_or_null("attack2/value") != null:
		prev_dm2 = curr_info.get_node("attack2/value").text
	var prev_df = curr_info.get_node("defense/value").text
	if curr_info.get_node_or_null("attack2/value") != null:
		curr_info.get_node("attack2/value").self_modulate = Color.white
	G.addv("coins", -(G.getv(selected_class + "_level", 0) * 50 + 50))
	G.addv(selected_class + "_tokens", -(G.getv(selected_class + "_level", 0) * 10 + 10))
	G.addv(selected_class + "_level", 1)
	if G.getv(selected_class + "_ulti_level", 1) == 5 and G.getv(selected_class + "_level", 0) == 20:
		G.ach.complete(Achievements.IM_POWER)
	G.emit_signal("loot_end") # Update offers
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
	$upgrade/upgrade/title.text = tr(G.CLASSES[selected_class])
	for i in $upgrade/upgrade/panels.get_children():
		i.hide()
		i.get_node("sfx_value").volume_db = -60
	$upgrade/upgrade/panel/title.text = tr("class.stat.level")
	$upgrade/upgrade/panel/previous.text = str(G.getv(selected_class + "_level", 0) - 1)
	$upgrade/upgrade/panel/next.text = str(G.getv(selected_class + "_level", 0))
	$upgrade/upgrade/panels/panel0.show()
	$upgrade/upgrade/panels/panel0/title.text = tr("class.stat.health")
	$upgrade/upgrade/panels/panel0/previous.text = prev_h
	$upgrade/upgrade/panels/panel0/next.text = h
	$upgrade/upgrade/panels/panel0.get_node("sfx_value").volume_db = 0
	if int(prev_df) != 0:
		$upgrade/upgrade/panels/panel1.show()
		$upgrade/upgrade/panels/panel1/title.text = tr("class.stat.defense")
		$upgrade/upgrade/panels/panel1/previous.text = prev_df
		$upgrade/upgrade/panels/panel1/next.text = df
		$upgrade/upgrade/panels/panel1.get_node("sfx_value").volume_db = 0
	$upgrade/upgrade/panels/panel2.show()
	$upgrade/upgrade/panels/panel2/title.text = tr("class.stat.damage")
	$upgrade/upgrade/panels/panel2/previous.text = prev_dm
	$upgrade/upgrade/panels/panel2/next.text = dm
	$upgrade/upgrade/panels/panel2.get_node("sfx_value").volume_db = 0
	if int(prev_dm2) != 0:
		$upgrade/upgrade/panels/panel3.show()
		$upgrade/upgrade/panels/panel3/title.text = tr("class.stat.mdamage")
		$upgrade/upgrade/panels/panel3/previous.text = prev_dm2
		$upgrade/upgrade/panels/panel3/next.text = dm2
		$upgrade/upgrade/panels/panel3.get_node("sfx_value").volume_db = 0
	$upgrade/upgrade/anim.play("upgrade")


func upgrade_ulti():
	if G.getv(selected_class + "_ulti_level", 1) >= 5:
		sell(true)
		return
	is_upgrading_ulti = true
	info(true)
	var curr_info = get_node("info_" + selected_class)
	curr_info.get_node("title").text = tr("class.upgrade.skill") % str(G.getv(selected_class + "_ulti_level", 1) + 1)
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
			ulti_c_mod = "1,5"
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
	var curr_info = get_node("info_" + selected_class)
	var prev_u = curr_info.get_node("ulti/value").text
	var prev_uc = ""
	if curr_info.get_node_or_null("ulti_c/value") != null:
		prev_uc = curr_info.get_node("ulti_c/value").text
	G.addv("coins", -(G.getv(selected_class + "_ulti_level", 1) * 600 + 600))
	G.addv(selected_class + "_ulti_tokens", -(G.getv(selected_class + "_ulti_level", 1) * 30 + 30))
	G.addv(selected_class + "_ulti_level", 1, 1)
	if G.getv(selected_class + "_ulti_level", 1) == 5 and G.getv(selected_class + "_level", 0) == 20:
		G.ach.complete(Achievements.IM_POWER)
	G.emit_signal("loot_end") # Update offers
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
	$upgrade/upgrade/title.text = tr(G.CLASSES[selected_class])
	for i in $upgrade/upgrade/panels.get_children():
		i.hide()
		i.get_node("sfx_value").volume_db = -60
	$upgrade/upgrade/panel/title.text = tr("class.stat.skill")
	$upgrade/upgrade/panel/previous.text = str(G.getv(selected_class + "_ulti_level", 1) - 1)
	$upgrade/upgrade/panel/next.text = str(G.getv(selected_class + "_ulti_level", 1))
	if prev_u != u:
		$upgrade/upgrade/panels/panel0.show()
		$upgrade/upgrade/panels/panel0/title.text = curr_info.get_node("ulti").text
		$upgrade/upgrade/panels/panel0/previous.text = prev_u
		$upgrade/upgrade/panels/panel0/next.text = u
		$upgrade/upgrade/panels/panel0.get_node("sfx_value").volume_db = 0
	if not prev_uc.empty() and prev_uc != uc:
		$upgrade/upgrade/panels/panel1.show()
		$upgrade/upgrade/panels/panel1/title.text = curr_info.get_node("ulti_c").text
		$upgrade/upgrade/panels/panel1/previous.text = prev_uc
		$upgrade/upgrade/panels/panel1/next.text = uc
		$upgrade/upgrade/panels/panel1.get_node("sfx_value").volume_db = 0
	$upgrade/upgrade/anim.play("upgrade")


func close_upgrade():
	$upgrade/upgrade/anim.stop()
	$upgrade/upgrade.hide()
	$upgrade/tint/tint.color = Color(1, 1, 1, 0)


func sell(ulti = false):
	var suffix = "_tokens" if not ulti else "_ulti_tokens"
	var tokens_left = G.getv(selected_class + suffix)
	G.setv(selected_class + suffix, 0)
	var coins_mul = 10 if ulti else 3
	var coins_get = tokens_left * coins_mul
	select_class(selected_class)
	G.receive_loot({"coins":coins_get})


func try():
	G.setv("test_class", selected_class)
	G.change_to_scene("res://scenes/levels/test.tscn")


func quit():
	G.ignore_next_music_stop = true
	get_tree().change_scene("res://scenes/menu/levels.tscn")


func _enter_tree():
	G.play_menu_music()


func _exit_tree():
	G.stop_menu_music()
