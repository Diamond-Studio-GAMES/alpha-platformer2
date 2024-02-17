extends Control


var hardcore = false
export (float, 0, 1, 0.01) var time_scale = 1


func _ready():
	if G.ad.ad_counter_go > 1:
		G.ad.show_interstitial()
		G.ad.ad_counter_go = 0
	else:
		G.ad.ad_counter_go += 1
	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
	if G.save_file == null:
		return
	hardcore = G.getv("hardcore", false)
	if hardcore:
		$soul/anim.play("defeat2")
		$game_over/retry.hide()
		$select_level.queue_free()
		var id = G.getv("save_id", "unknown")
		G.close_save()
		var d = Directory.new()
		d.remove("user://saves/".plus_file(id + ".apa2save"))
		if d.file_exists("user://custom_levels/" + id + ".scn"):
			d.remove("user://custom_levels/" + id + ".scn")
	else:
		var loc = int(G.getv("level", "1_1").split("_")[0])
		if G.getv("game_completed", false):
			$game_over/followers.texture = null
		elif loc > 9:
			$game_over/followers.texture = load("res://textures/effects/backgrounds/game_over_two_defeated.png")
		elif loc > 8:
			$game_over/followers.texture = load("res://textures/effects/backgrounds/game_over_one_defeated.png")
		else:
			$game_over/followers.texture = load("res://textures/effects/backgrounds/game_over.png")
		$soul/anim.play("defeat")


func _process(delta):
	Engine.time_scale = time_scale


func retry():
	if not G.custom_respawn_scene.empty():
		G.change_to_scene(G.custom_respawn_scene)
		G.custom_respawn_scene = ""
		return
	$select_level/select_level_dialog.show_d(G.current_level)


func _input(event):
	if hardcore:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			$soul/anim.seek(4, true)
			if not $music.playing:
				$music.play(0)


func menu():
	if hardcore:
		get_tree().quit()
		return
	G.custom_respawn_scene = ""
	get_tree().change_scene("res://scenes/menu/menu.tscn")
