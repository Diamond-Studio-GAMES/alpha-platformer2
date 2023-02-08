extends Control


var gen : RandomNumberGenerator = RandomNumberGenerator.new()
signal next
var pack_c = load("res://minigames/minigame6/resources/seed_packet_common.png")
var pack_r = load("res://minigames/minigame6/resources/seed_packet_rare.png")
var pack_e = load("res://minigames/minigame6/resources/seed_packet_epic.png")
var pack_l = load("res://minigames/minigame6/resources/seed_packet_legendary.png")


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("next")


func _ready():
	randomize()
	gen.randomize()
	yield(self, "next")
	$box_screen/anim.play("open")


func open_box():
	$box_screen.hide()
	$water_screen.show()
	var water_get = 10*gen.randi_range(5, 20)
	$water_screen/water/label.text = "x " + str(water_get)
	G.addv("garden_water", water_get)
	$water_screen/anim.play("get")
	G.save()
	yield(self, "next")
	$water_screen.hide()
	$fert_screen.show()
	var fert_get_two = percent_chance(15)
	var fert_get = 1
	if fert_get_two:
		fert_get = 2
	$fert_screen/fert/label.text = "x " + str(fert_get)
	G.addv("garden_fert", fert_get)
	$fert_screen/anim.play("get")
	G.save()
	yield(self, "next")
	var common = percent_chance(90)
	var rare = percent_chance(25)
	var epic = percent_chance(15)
	var legendary = percent_chance(6.5)
	var got_rarity = ""
	if legendary:
		got_rarity = "legendary"
		$semen_screen/pack/rarity.add_color_override("font_color", Color.yellow)
		$semen_screen/pack.texture = pack_l
		$semen_screen/pack/glow.show()
	elif epic:
		$semen_screen/pack/rarity.add_color_override("font_color", Color.magenta)
		got_rarity = "epic"
		$semen_screen/pack.texture = pack_e
		$semen_screen/pack/rarity.text = "Эпическое"
	elif rare:
		got_rarity = "rare"
		$semen_screen/pack/rarity.add_color_override("font_color", Color.green)
		$semen_screen/pack.texture = pack_r
		$semen_screen/pack/rarity.text = "Редкое"
	elif common:
		$semen_screen/pack/rarity.text = "Обычное"
		got_rarity = "common"
		$semen_screen/pack.texture = pack_c
	else:
		get_tree().change_scene("res://minigames/minigame6/minigame.scn")
		return
	$fert_screen.hide()
	$semen_screen.show()
	var dir = Directory.new()
	dir.open("res://minigames/minigame6/plants/{0}/".format([got_rarity]))
	var files = []
	dir.list_dir_begin(true)
	var file_name = dir.get_next()
	while file_name != "":
		files.append(file_name)
		file_name = dir.get_next()
	files.shuffle()
	var got_plant_path = dir.get_current_dir().plus_file(files[0])
	G.addv("garden_plants", [got_plant_path], [])
	var got_plant : PlantResource = ResourceLoader.load(got_plant_path) as PlantResource
	$semen_screen/pack/plant.texture = got_plant.texture
	$semen_screen/pack/label.text = got_plant.name
	$semen_screen/anim.play("get")
	yield(self, "next")
	get_tree().change_scene("res://minigames/minigame6/minigame.scn")
	


func percent_chance(in_chance):
	in_chance *= 10000
	var max_add = 1000000 - in_chance
	var chance_range_start = gen.randi_range(0, max_add)
	var chance_range_end = chance_range_start + in_chance
	var random_number = gen.randi_range(0, 1000000)
	if random_number >= chance_range_start and random_number <= chance_range_end:
		return true
	return false
