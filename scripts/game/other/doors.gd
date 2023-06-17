extends Node2D


export (float) var max_distance = 10
var player : Player
var entering = false
var going_to_door = -1

signal entered_door


func _ready():
	max_distance *= max_distance
	var suffix = ""
	if MP.is_active and $"/root/mg".state != 2:
		suffix = str(get_tree().get_network_unique_id())
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	player = get_tree().current_scene.get_node("player" + suffix)


func _process(delta):
	if going_to_door >= 0:
		if get_node("door" + str(going_to_door)).global_position.distance_squared_to(player.global_position) < max_distance:
			emit_signal("entered_door")


func enter(id):
	$door0/button.hide()
	$door1/button.hide()
	entering = true
	going_to_door = id
	player.stop()
	player.can_control = false
	if get_node("door" + str(id)).global_position.x > player.global_position.x:
		player.force_move_right()
	elif get_node("door" + str(id)).global_position.x < player.global_position.x:
		player.force_move_left()
	yield(self, "entered_door")
	going_to_door = -1
	player.force_stop()
	$anim.play("enter")
	$MultiplayerSynchronizer.sync_call($anim, "play", ["enter"], true)
	$layer/anim.play("enter")
	yield(get_tree().create_timer(0.5, false), "timeout")
	match id:
		0:
			var fall_distance = player._start_falling_y - player.global_position.y
			player.global_position = $door1.global_position
			player._start_falling_y = player.global_position.y + fall_distance
		1:
			var fall_distance = player._start_falling_y - player.global_position.y
			player.global_position = $door0.global_position
			player._start_falling_y = player.global_position.y + fall_distance
	yield(get_tree().create_timer(1.5, false), "timeout")
	entering = false
	player.can_control = true
	if id == 1:
		$door0/button.show()
	else:
		$door1/button.show()


func _on_door_body_entered(body, id):
	if entering:
		return
	if body == player:
		if id == 0:
			$door0/button.show()
		else:
			$door1/button.show()


func _on_door_body_exited(body, id):
	if body == player:
		if id == 0:
			$door0/button.hide()
		else:
			$door1/button.hide()
