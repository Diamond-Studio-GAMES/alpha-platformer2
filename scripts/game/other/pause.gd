extends Control


var pause_button
var player


func _ready():
	pause_button = $"../pause"
	player = $"../../../.."


func _process(delta):
	if player.current_health <= 0:
		if pause_button.visible:
			pause_button.hide()
	else:
		if not pause_button.visible:
			pause_button.show()


func pause():
	if get_tree().paused:
		return
	VisualServer.set_shader_time_scale(0)
	if not MP.is_active:
		get_tree().paused = true
	show()
	pause_button.hide()


func unpause():
	VisualServer.set_shader_time_scale(1)
	get_tree().paused = false
	hide()
	pause_button.show()


func restart():
	if MP.is_active:
		return
	VisualServer.set_shader_time_scale(1)
	get_tree().paused = false
	G.change_to_scene(get_tree().current_scene.filename)


func menu():
	if MP.is_active:
		$"/root/mg".state = 3
		MP.close_network()
	VisualServer.set_shader_time_scale(1)
	get_tree().paused = false
	get_tree().change_scene("res://scenes/menu/menu.tscn")
