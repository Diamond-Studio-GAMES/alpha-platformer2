extends Level


var died = false
var previous_class = "player"


func _enter_tree():
	previous_class = G.getv("selected_class", "player")
	G.setv("selected_class", G.getv("test_class", "player"))


func _ready():
	player.connect("died", self, "_on_died")
	G.setv("selected_class", previous_class)


func _on_died():
	if died:
		return
	if player.current_health <= 0:
		died = true
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
		get_tree().change_scene("res://scenes/menu/levels.tscn")
