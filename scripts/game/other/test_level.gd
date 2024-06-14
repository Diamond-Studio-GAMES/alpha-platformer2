extends Level


export (Array, PackedScene) var standard_mobs = []
var died = false
var previous_class = "player"


func _enter_tree():
	previous_class = G.getv("selected_class", "player")
	G.setv("selected_class", G.getv("test_class", "player"))


func _ready():
	player.connect("died", self, "_on_died")
	G.setv("selected_class", previous_class)
	# Remove not meeted mobs, create list for adding
	var current_location = int(G.getv("level", "1_1").split('_')[0])
	var mobs_to_add = []
	for i in $mobs.get_children():
		var can_add = true
		for j in i.get_groups():
			if j.is_valid_integer():
				var location = int(j)
				if location > current_location:
					can_add = false
					break
		var data = {
			"pos" : i.global_position,
		}
		if can_add:
			data["path"] = i.filename
			data["hp"] = i.max_health
		else:
			data["path"] = standard_mobs.pick_random().resource_path
		mobs_to_add.append(data)
	yield(get_tree(), "idle_frame")
	for i in $mobs.get_children():
		i.queue_free()
	# Add mobs
	var stats_multiplier = 1 + player.power * 0.2
	for i in mobs_to_add:
		var mob = load(i["path"]).instance()
		mob.global_position = i["pos"]
		if i.has("hp"):
			mob.max_health = i["hp"]
		mob.stats_multiplier = stats_multiplier
		$mobs.add_child(mob, true)


func _on_died():
	if died:
		return
	if player.current_health <= 0:
		died = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
		get_tree().change_scene("res://scenes/menu/levels.tscn")
