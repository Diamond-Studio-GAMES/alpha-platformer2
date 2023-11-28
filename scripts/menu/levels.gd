extends Control


var CLASS_ICONS = {
	"knight" : load("res://textures/classes/knight_helmet.png"),
	"butcher" : load("res://textures/classes/butcher_helmet.png"),
	"spearman" : load("res://textures/classes/spearman_helmet.png"),
	"wizard" : load("res://textures/classes/wizard_helmet.png"),
	"archer" : load("res://textures/classes/archer_helmet.png"),
	"player" : null
}


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


func _enter_tree():
	G.play_menu_music()


func _exit_tree():
	G.stop_menu_music()
