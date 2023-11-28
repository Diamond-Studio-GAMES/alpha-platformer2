extends TextureButton


export (String) var id = "0"
onready var garden: Garden = $".."
var current_plant = ""
var current_day = Time.get_date_dict_from_system()["day"]
var current_unix_time = Time.get_unix_time_from_system()
var current_plant_data: PlantResource
var plant_mini_tex = load("res://minigames/minigame6/resources/plant_start.png")


func _pressed():
	if garden.going_to_plant and current_plant.empty():
		plant()
	elif garden.going_to_dig_up and not current_plant.empty():
		dig_up()
	elif garden.going_to_fertilize and not current_plant.empty():
		fertilize()


func plant():
	var gid = "garden_plant" + id
	current_plant = garden.selected_plant
	G.setv(gid, current_plant)
	G.setv(gid + "_days_grow", 0)
	G.setv(gid + "_watered_day", current_day)
	G.setv(gid + "_watered", false)
	var current_plants = G.getv("garden_plants", [])
	current_plants.erase(current_plant)
	G.setv("garden_plants", current_plants)
	garden.plant_pressed()
	setup_plant()


func remove_plant():
	var gid = "garden_plant" + id
	current_plant = ""
	current_plant_data = null
	G.setv(gid, "")
	G.setv(gid + "_days_grow", 0)
	G.setv(gid + "_watered_day", current_day)
	G.setv(gid + "_watered", false)
	setup_plant()


func dig_up():
	remove_plant()
	garden.dig_up_pressed()


func fertilize():
	var gid = "garden_plant" + id
	if G.getv(gid + "_days_grow", 0) >= current_plant_data.days_to_grow:
		garden.show_warning(tr("6.cant.grown"))
		return
	if not G.getv(gid + "_watered", false):
		garden.show_warning(tr("6.cant.nowater"))
		return
	if G.getv("garden_fert", 0) < current_plant_data.fertilizer_needs:
		garden.show_warning(tr("6.no.fert").format([current_plant_data.fertilizer_needs]))
		return
	G.addv("garden_fert", -current_plant_data.fertilizer_needs, 0)
	G.setv(gid + "_watered_day", current_day - 1)
	$fertilizing.play()
	garden.fert_up_pressed()
	setup_plant()


func do_water():
	var gid = "garden_plant" + id
	if G.getv("garden_water", 0) < current_plant_data.water_needs:
		garden.show_warning(tr("6.no.water"))
		return
	G.addv("garden_water", -current_plant_data.water_needs, 0)
	G.setv(gid + "_watered_day", current_day)
	G.setv(gid + "_watered", true)
	$watering.play(0)
	setup_plant()


func _ready():
	setup_plant()
	$water.connect("pressed", self, "do_water")
	$claim.connect("pressed", self, "claim")


func _process(delta):
	if Time.get_date_dict_from_system()["day"] != current_day and Time.get_unix_time_from_system() >= current_unix_time:
		current_day = Time.get_date_dict_from_system()["day"]
		current_unix_time = Time.get_unix_time_from_system()
		setup_plant()


func setup_plant():
	$plant.hide()
	$glow.hide()
	$claim.hide()
	$water.hide()
	var gid = "garden_plant" + id
	current_plant = G.getv(gid, "")
	if current_plant.get_extension() == "res":
		var new_plant = current_plant.get_basename() + ".tres"
		G.setv(gid, new_plant)
		setup_plant()
		return
	if current_plant.empty():
		current_plant_data = null
		$watered.hide()
		return
	current_plant_data = load(current_plant) as PlantResource
	var days_grow = G.getv(gid + "_days_grow", 0)
	if G.getv(gid + "_watered_day", current_day) != current_day and G.getv(gid + "_watered_day_time", current_unix_time) <= current_unix_time and G.getv(gid + "_watered", false):
		days_grow += 1
		G.setv(gid + "_days_grow", days_grow)
		G.setv(gid + "_watered_day", current_day)
		G.setv(gid + "_watered_day_time", current_unix_time)
		G.setv(gid + "_watered", false)
	$plant.show()
	if days_grow == 0:
		$plant.rect_scale = Vector2.ONE
		$plant.texture = plant_mini_tex
	else:
		$plant.texture = current_plant_data.texture
		$plant.rect_scale = current_plant_data.custom_scale * days_grow/current_plant_data.days_to_grow
	match current_plant_data.rarity:
		0:
			$glow.modulate = Color.white
			$glow/light.hide()
			$glow/stars.hide()
		1:
			$glow.show()
			$glow.modulate = Color.green
			$glow/light.hide()
			$glow/stars.hide()
		2:
			$glow.show()
			$glow.modulate = Color.magenta
			$glow/light.hide()
			$glow/stars.show()
		3:
			$glow.show()
			$glow.modulate = Color.yellow
			$glow/light.show()
			$glow/stars.show()
	if days_grow == current_plant_data.days_to_grow:
		$claim.show()
		$watered.hide()
	else:
		$water.text = str(current_plant_data.water_needs)
		if not G.getv(gid + "_watered", false):
			$water.show()
			$watered.hide()
		else:
			$watered.show()


func claim():
	G.addv("garden_looted", 1)
	G.ach.check(Achievements.LOOT)
	if current_plant_data.custom_reward:
		custom_claim()
		return
	G.receive_loot(current_plant_data.reward)
	remove_plant()


func custom_claim():
	var node = Node.new()
	node.set_script(current_plant_data.custom_reward_script)
	add_child(node)
	yield(get_tree(), "idle_frame")
	node.claim(current_plant_data.custom_reward_script_data)
	remove_plant()
