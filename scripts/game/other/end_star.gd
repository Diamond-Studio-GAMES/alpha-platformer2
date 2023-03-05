extends Area2D


var ended = false


func end_level(l):
	if ended:
		return
	if not l is Player:
		return
	ended = true
	$anim.play("end")
	$sfx.play()
	if MP.is_active:
		$"/root/mg".state = 3
	yield(get_tree().create_timer(2, false), "timeout")
	if MP.is_active:
		MP.close_network()
	get_tree().change_scene("res://scenes/menu/win.scn")
