extends Control


func _ready():
	for i in range(1, 10):
		G.setv("boss_%d_10_killed" % i, false)
	G.ach.complete(Achievements.HERO)
	if not G.getv("game_completed", false):
		G.main_setv("last_completed_color", $bg.self_modulate)
		G.main_setv("last_completed_hate", G.getv("hate_level", -1) == 4)
	G.set_save_meta(G.getv("save_id", "ffff00"), "completed", true)
	G.setv("game_completed", true)
	G.save()


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if not $anim.is_playing():
				$anim.play_backwards("fade_in")
				yield($anim, "animation_finished")
				G.close_save()
				get_tree().change_scene("res://scenes/menu/save_loader.tscn")
