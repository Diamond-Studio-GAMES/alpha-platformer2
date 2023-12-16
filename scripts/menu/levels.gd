extends Control


var CLASS_ICONS = {
	"knight" : load("res://textures/classes/knight_helmet.png"),
	"butcher" : load("res://textures/classes/butcher_helmet.png"),
	"spearman" : load("res://textures/classes/spearman_helmet.png"),
	"wizard" : load("res://textures/classes/wizard_helmet.png"),
	"archer" : load("res://textures/classes/archer_helmet.png"),
	"player" : null
}
var mobs_parsed = false
var mobs_data = {
	"shroom" : [0, 0, "res://prefabs/mobs/mushroom.tscn"],
	"knife" : [1, 1, "res://prefabs/mobs/knife_man.tscn"],
	"shooter" : [1, 5, "res://prefabs/mobs/shooter.tscn"],
	"sport" : [3, 1, "res://prefabs/mobs/sportsman.tscn"],
	"knight" : [4, 1, "res://prefabs/mobs/knight_mob.tscn"],
	"doctor" : [5, 1, "res://prefabs/mobs/doctor.tscn"],
	"spartan" : [6, 1, "res://prefabs/mobs/spartan.tscn"],
	"magic" : [7, 1, "res://prefabs/mobs/magician.tscn"],
	"mech" : [9, 1, "res://prefabs/mobs/mechanic.tscn"],
	"robot" : [9, 1, "res://prefabs/mobs/mechanic.tscn"],
	"werewolf.human" : [10, 1, "res://prefabs/mobs/mechanic.tscn"],
	"werewolf" : [10, 1, "res://prefabs/mobs/mechanic.tscn"],
}
var mobs_id_mappings = {}
var mobs_scenes = {}


func _ready():
	$multiplayer/location.prefix = tr("multiplayer.loc")
	$multiplayer/level.prefix = tr("multiplayer.lvl")
	$multiplayer/select_level.get_popup().max_height = 240
	$help_dialog.get_cancel().text = tr("menu.cancel")
	if OS.has_feature("HTML5"):
		$multiplayer_button.disconnect("pressed", $multiplayer, "popup_centered")
		$multiplayer_button.connect("pressed", $multiplayer_warn, "popup_centered")
	var max_lvl = false
	for i in $levels/levels/buttons.get_children():
		i.connect("pressed", self, "play_lvl", [i.name])
		var nums = i.name.split("_")
		i.text = nums[0] + "-" + nums[1]
		if max_lvl:
			i.hide()
			continue
		$multiplayer/select_level.add_item(nums[0] + "-" + nums[1])
		if i.name == G.getv("level", "1_1"):
			max_lvl = true
			if G.getv("learned", false):
				i.grab_focus()
				$levels.call_deferred("ensure_control_visible", i)
	if not G.getv("learned", false):
		if not G.getv("classes_visited", false):
			$education0.show()
		elif not G.getv("shop_visited", false):
			$education2.show()
		else:
			$education4.show()
	# COMPENSATION
	if G.getv("compensated_tickets", false):
		return
	G.setv("compensated_tickets", true)
	var costs = {
		1 : 0,
		2 : 2,
		3 : 13,
		4 : 5,
		5 : 0,
		6 : 10,
		7 : 0,
		8 : 17
	}
	var comp_amount = 0
	for i in range(1, 9):
		if G.getv("minigame" + str(i) + "_bought", false):
			G.save_file.erase_section_key("save", "minigame" + str(i) + "_bought")
			comp_amount += costs[i]
	if comp_amount == 0:
		return
	var dialog = AcceptDialog.new()
	dialog.name = "compensation"
	dialog.popup_exclusive = true
	dialog.window_title = tr("compensation.title")
	dialog.rect_size = Vector2(360, 160)
	dialog.dialog_text = tr("compensation.desc") % comp_amount
	dialog.dialog_autowrap = true
	dialog.get_ok().text = tr("win.claim")
	dialog.connect("popup_hide", G, "receive_loot", [{"tickets" : comp_amount}])
	add_child(dialog)
	dialog.popup_centered()


func _process(delta):
	$classes_button.icon = CLASS_ICONS[G.getv("selected_class", "player")]


func play_lvl(lvl = "1_1"):
	$select_level/select_level_dialog.show_d(lvl)


func exit():
	G.ignore_next_music_stop = true
	get_tree().change_scene("res://scenes/menu/menu.tscn")


func classes():
	G.ignore_next_music_stop = true
	get_tree().change_scene("res://scenes/menu/classes.tscn")


func shop():
	G.ignore_next_music_stop = true
	get_tree().change_scene("res://scenes/menu/shop.tscn")


func open_minigame(id):
	get_tree().change_scene("res://minigames/minigame" + id + "/minigame.tscn")


func help():
	G.setv("learned", false)
	G.setv("shop_visited", false)
	G.setv("classes_visited", false)
	G.setv("learned_ids", [])
	get_tree().change_scene("res://scenes/menu/story.tscn")


func mobs():
	if not mobs_parsed:
		mobs_parsed = true
		var current_level = G.getv("level", "1_1").split('_')
		var location = int(current_level[0])
		var level = int(current_level[1])
		var idx = 0
		for i in mobs_data:
			if mobs_data[i][0] > location:
				break
			if mobs_data[i][0] == location:
				if mobs_data[i][1] >= level:
					break
			mobs_scenes[i] = load(mobs_data[i][2])
			mobs_id_mappings[idx] = i
			$mobs_dialog/base/mobs_selection/select.add_item(tr("mob." + i))
			idx += 1
		_on_mob_select_item_selected(0)
	$mobs_dialog.popup_centered()


func create_room():
	$multiplayer.hide()
	play_lvl(str($multiplayer/location.value) + "_" + str($multiplayer/level.value))
	$select_level/select_level_dialog.menu_pressed(0)


func join_room():
	$multiplayer.hide()
	play_lvl(str($multiplayer/location.value) + "_" + str($multiplayer/level.value))
	$select_level/select_level_dialog.menu_pressed(1)


func _on_select_level_item_selected(idx):
	var nums = $multiplayer/select_level.get_item_text(idx).split("-")
	$multiplayer/location.value = int(nums[0])
	$multiplayer/level.value = int(nums[1])


func _on_level_location_value_changed(value):
	var new_lvl = str($multiplayer/location.value) + "_" + str($multiplayer/level.value)
	if not $levels/levels/buttons.has_node(new_lvl):
		$multiplayer/create.disabled = true
		$multiplayer/join.disabled = true
		return
	elif not $levels/levels/buttons.get_node(new_lvl).visible:
		$multiplayer/create.disabled = true
		$multiplayer/join.disabled = true
		return
	$multiplayer/create.disabled = false
	$multiplayer/join.disabled = false
	var nums = new_lvl.split("_")
	$multiplayer/select_level.selected = (int(nums[0]) - 1) * 10 + int(nums[1]) - 1


func _on_mob_select_item_selected(index):
	var mob_name = mobs_id_mappings[index]
	$mobs_dialog/base/mob_info/description.bbcode_text = "[b]" + tr("mob." + mob_name) + \
			"[/b]\n" + tr("mob." + mob_name + ".desc")
	if $mobs_dialog/base/mob_info/mob_visual/viewport/root.has_node("visual"):
		$mobs_dialog/base/mob_info/mob_visual/viewport/root/visual.free()
		$mobs_dialog/base/mob_info/mob_visual/viewport/root/anim.free()
	var scene = mobs_scenes[mob_name].instance()
	var visual = scene.get_node("visual")
	var anim = scene.get_node("anim")
	scene.remove_child(visual)
	scene.remove_child(anim)
	$mobs_dialog/base/mob_info/mob_visual/viewport/root.add_child(visual)
	$mobs_dialog/base/mob_info/mob_visual/viewport/root.add_child(anim)
	visual.owner = self
	anim.owner = self
	anim.play("idle")
	scene.free()


func _enter_tree():
	G.play_menu_music()


func _exit_tree():
	G.stop_menu_music()
