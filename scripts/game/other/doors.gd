extends Node2D


export (float) var max_distance = 8
export (float) var max_vertical_distance = 32
export (float) var max_wait_time = 3
var player: Player
var entering = false
var going_door = null
var going_to_door = -1
var going_to_door_timer = 0

signal entered_door


func _ready():
	var suffix = ""
	if MP.is_active:
		suffix = str(get_tree().get_network_unique_id())
		if $"/root/mg".state != 2:
			yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	player = get_tree().current_scene.get_node("player" + suffix)


func _process(delta):
	if going_to_door >= 0:
		going_to_door_timer += delta
		if abs(going_door.global_position.x - player.global_position.x) < max_distance:
			if player.GRAVITY_SCALE > 0:
				if player.global_position.y - going_door.global_position.y > max_vertical_distance:
					player.force_jump()
			else:
				if going_door.global_position.y - player.global_position.y > max_vertical_distance:
					player.force_jump()
			emit_signal("entered_door")
		if going_to_door_timer > max_wait_time:
			player.global_position = going_door.global_position


func enter(id):
	$door0/button.hide()
	$door1/button.hide()
	entering = true
	going_to_door = id
	player.stop()
	player.can_control = false
	going_door = get_node("door" + str(id))
	going_to_door_timer = 0
	if going_door.global_position.x > player.global_position.x:
		player.force_move_right()
	elif going_door.global_position.x < player.global_position.x:
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
