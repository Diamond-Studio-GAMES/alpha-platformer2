class_name Achievements
extends CanvasLayer


const BOSS1 = "boss1"

signal effect_completed
var blocked_counter = 0
var achievement_get = load("res://prefabs/menu/achievement_complete.scn")
var achievements = {
	BOSS1 : {
		"icon" : load("res://textures/mobs/sheeper/sheep_bomb.png"),
		"name" : "Это мои овцы",
		"desc" : "Победите Пастуха."
	}
}


func complete(id):
	if is_completed(id):
		return
	G.setv("achv_" + id + "_done", true)
	for i in blocked_counter:
		yield(self, "effect_completed")
	var effect = achievement_get.instance()
	effect.get_node("panel/name").text = achievements[id]["name"] + "!"
	effect.get_node("panel/desc").text = achievements[id]["desc"]
	effect.get_node("panel/bg/icon").texture = achievements[id]["icon"]
	add_child(effect)


func is_completed(id):
	return G.getv("achv_" + id + "_done", false)
