extends Node



func claim(data = "0"):
	match data:
		"0":
			if G.getv("potions1", 0) > 2:
				G.receive_loot({"coins": 275})
			else:
				G.receive_loot({"potions1": 1})
		"1":
			if G.getv("potions1", 0) > 2:
				G.receive_loot({"coins": 550})
			elif G.getv("potions1", 0) > 1:
				G.receive_loot({"coins": 275,"potions1": 1})
			else:
				G.receive_loot({"potions1": 2})
		"2":
			if G.getv("potions2", 0) > 1:
				G.receive_loot({"coins": 600})
			else:
				G.receive_loot({"potions2": 1})
	queue_free()
