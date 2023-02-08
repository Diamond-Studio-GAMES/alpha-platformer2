extends Resource
class_name PlantResource, "res://minigames/minigame6/resources/seed_packet_legendary.png"


enum Rarity {
	COMMON = 0,
	RARE = 1,
	EPIC = 2,
	LEGENDARY = 3,
}


export (String) var name = ""
export (Texture) var texture
export (Vector2) var custom_scale = Vector2.ONE
export (Rarity) var rarity = Rarity.COMMON
export (int) var days_to_grow = 1
export (int) var water_needs = 100
export (int) var fertilizer_needs = 1
export (bool) var custom_reward = false
export (Dictionary) var reward = {}
export (Script) var custom_reward_script
export (String) var custom_reward_script_data = ""
