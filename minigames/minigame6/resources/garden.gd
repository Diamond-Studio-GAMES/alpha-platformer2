extends Control
class_name Garden


var RARITY_COLORS = [Color.white, Color.green, Color.magenta, Color.yellow]
var going_to_plant = false
var going_to_fertilize = false
var going_to_dig_up = false
var selected_plant = ""
var plant_element = load("res://minigames/minigame6/element_of_plant_list.scn")
onready var current_day = Time.get_date_dict_from_system()["day"]
onready var current_unix_time = Time.get_unix_time_from_system()
signal plant_selected(canceled)


func _ready():
	$base_list_of_plants/list_of_plants.get_close_button().connect("pressed", self, "select_plant", [""])
	$base_buy/buy.get_cancel().text = "Отмена"
	$base_buy/buy.get_ok().text = "Купить"
	$base_gift/gift.get_ok().text = "Забрать"
	check_for_gift()


func open_box():
	$base_buy/buy.dialog_text = "Действительно хочешь купить садовый ящик за 5 кристаллов?\nУ тебя: " + str(G.getv("gems", 10))
	$base_buy/buy.popup_centered()


func buy_box():
	if G.getv("gems", 10) < 5:
		show_warning("Недостаточно кристаллов!")
		return
	G.addv("gems", -5, 10)
	get_box()


func get_box():
	get_tree().change_scene("res://minigames/minigame6/plant_box_open.scn")


func exit():
	get_tree().change_scene("res://scenes/menu/levels.scn")


func check_for_gift():
	if G.getv("garden_get_gift", current_day-1) != current_day and \
			G.getv("garden_get_gift_time", 0) <= current_unix_time:
		G.setv("garden_get_gift", current_day)
		G.setv("garden_get_gift_time", current_unix_time)
		$base_gift/gift.popup_centered()


func _process(delta):
	$fert.text = str(G.getv("garden_fert", 0))
	$water.text = str(G.getv("garden_water", 0))
	if Time.get_date_dict_from_system()["day"] != current_day:
		current_day = Time.get_date_dict_from_system()["day"]
		current_unix_time = Time.get_unix_time_from_system()
		check_for_gift()


func plant_pressed():
	going_to_fertilize = false
	going_to_dig_up = false
	going_to_plant = not going_to_plant
	if not going_to_plant:
		$tip.hide()
		return
	open_list_of_plants()
	var canceled = yield(self, "plant_selected")
	if canceled:
		going_to_plant = false
		return
	$tip.text = "Выбери горшок для посадки (нажми кнопку ещё раз, чтобы отменить)"
	$tip.visible = going_to_plant


func dig_up_pressed():
	going_to_fertilize = false
	going_to_plant = false
	going_to_dig_up = not going_to_dig_up
	$tip.text = "Выбери растение для выкапыванния (нажми кнопку ещё раз, чтобы отменить)"
	$tip.visible = going_to_dig_up


func fert_up_pressed():
	going_to_plant = false
	going_to_dig_up = false
	going_to_fertilize = not going_to_fertilize
	$tip.text = "Выбери растение для удобрения (нажми кнопку ещё раз, чтобы отменить)"
	$tip.visible = going_to_fertilize


func open_list_of_plants():
	for i in $base_list_of_plants/list_of_plants/scroll/grid.get_children():
		i.queue_free()
	var plant_showed = []
	var plants = G.getv("garden_plants", []) as Array
	for i in plants:
		if i in plant_showed:
			continue
		if i.get_extension() != "res" and i.get_extension() != "tres":
			var new_plants = plants.duplicate(true)
			new_plants.erase(i)
			G.setv("garden_plants", new_plants)
			continue
		if i.get_extension() == "tres":
			var new_plants = plants.duplicate(true)
			new_plants.erase(i)
			new_plants.append((i as String).get_basename() + ".res")
			G.setv("garden_plants", new_plants)
			continue
		plant_showed.append(i)
		var plant_data = load(i) as PlantResource
		var node = plant_element.instance()
		node.get_node("tex").texture_normal = plant_data.texture
		node.get_node("name").text = plant_data.name + " x " + str(G.getv("garden_plants", []).count(i))
		node.get_node("name").add_color_override("font_color", RARITY_COLORS[plant_data.rarity])
		node.get_node("tex").connect("pressed", self, "select_plant", [i])
		$base_list_of_plants/list_of_plants/scroll/grid.add_child(node)
	$base_list_of_plants/list_of_plants.popup_centered()


func select_plant(plant):
	$base_list_of_plants/list_of_plants.hide()
	if plant.empty():
		selected_plant = ""
		emit_signal("plant_selected", true)
		return
	selected_plant = plant
	emit_signal("plant_selected", false)


func show_warning(text = ""):
	$warn.text = text
	for i in get_tree().get_processed_tweens():
		i.kill()
	var tween = create_tween()
	tween.tween_property($warn, "self_modulate", Color.red, 0.25)
	tween.tween_property($warn, "self_modulate", Color(1,0,0,0), 1).set_delay(1)
