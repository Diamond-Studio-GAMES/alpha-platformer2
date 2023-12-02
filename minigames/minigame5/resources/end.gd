extends Area2D


func be(b):
	if b is Dasher:
		if get_tree().current_scene.name != "level_custom":
			G.ach.complete(Achievements.DASHER)
			G.addv("pd_levels", 1)
			var level = int(get_tree().current_scene.name[5])
			if G.current_tickets != 1:
				level = 0
			match level:
				1:
					G.receive_loot({"coins" : 150, "gems" : 1, "box" : 1})
				2:
					G.receive_loot({"coins" : 225, "gems" : 1, "box" : 2})
				3:
					G.receive_loot({"coins" : 300, "gems" : 2, "gold_box" : 1})
		get_tree().change_scene("res://minigames/minigame5/minigame.tscn")
