extends Node2D


var got_death = true


func reward():
	G.setv("hated_death", got_death)
	G.addv("dyh_completed", 1)
	G.ach.complete(Achievements.CLEARED)
	get_tree().change_scene("res://scenes/menu/menu.tscn")
	G.receive_loot({
		"coins" : 100 * G.current_tickets,
		"gems" : round(G.current_tickets / 2.0),
		"box" : round(G.current_tickets / 1.5),
	})
	G.current_tickets = 0
