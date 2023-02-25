extends Control


func _enter_tree():
	pass

var hardcore = false
export (float, 0, 1, 0.01) var time_scale = 1


func _ready():
	if AdManager.ad_counter == 1:
		AdManager.showInterstitial()
		AdManager.ad_counter = 0
	else:
		AdManager.ad_counter = 1
	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
	hardcore = G.getv("hardcore", false)
	if hardcore:
		$soul/anim.play("defeat2")
		$game_over/retry.hide()
		G.file.erase_section(G.current_save)
		G.save()
		G.current_save = "main"
	else:
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
	get_tree().change_scene("res://scenes/menu/menu.scn")
