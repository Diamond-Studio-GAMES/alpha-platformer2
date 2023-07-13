extends Camera2D


var counter
var is_revived = false
var is_gived_up = false
var is_multiplayer = false
var is_screen_on = false
signal gived_up


func _ready():
	is_multiplayer = MP.is_active
	counter = $gui/death_screen/gems/count
	$gui/death_screen/window.get_close_button().connect("pressed", self, "give_up")
	$gui/death_screen/window.popup_exclusive = true


func show_revive_screen():
	if is_multiplayer:
		return
	if is_revived or not $"..".can_revive:
		give_up()
		return
	is_screen_on = true
	zoom = Vector2(0.15, 0.15)
	$gui/base.hide()
	$gui/death_screen.show()
	$gui/death_screen/window.popup_centered()
	counter.text = str(G.getv("gems", 0))
	if G.getv("gems", 0) < 10:
		$gui/death_screen/window/revive.disabled = true
	get_tree().paused = true


func revive_button():
	if G.getv("gems", 0) < 10:
		return
	is_screen_on = false
	get_tree().paused = false
	zoom = $"..".default_camera_zoom
	G.setv("gems", G.getv("gems", 0) - 10)
	G.save()
	$"..".revive()
	$gui/base.show()
	$gui/death_screen.hide()
	$gui/death_screen/window.hide()
	is_revived = true


func give_up():
	if is_gived_up:
		return
	emit_signal("gived_up")
	if MP.is_active:
		$"/root/mg".state = 3
		MP.close_network()
	is_gived_up = true
	G.addv("deaths", 1)
	get_tree().paused = false
	if $"..".custom_respawn_scene.empty():
		get_tree().change_scene("res://scenes/menu/game_over.scn")
	else:
		G.custom_respawn_scene = $"..".custom_respawn_scene
		get_tree().change_scene("res://scenes/menu/game_over.scn")
