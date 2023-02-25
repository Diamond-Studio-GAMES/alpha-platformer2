extends Entity
class_name Mob, "res://textures/mobs/mechanic/transform_eye.res"

# HEALTH
export (bool) var immune_to_fall_damage = false
export (float) var stats_multiplier = 1
export (int) var attack_damage = 20
export (float) var reaction_speed = 2
export (float) var vision_distance = 200
export (float) var attack_speed = 2.5
export (NodePath) var head_path
export (String, FILE) var head_sprite_path
export (String, FILE) var head_hurt_sprite_path
var _mob_death = load("res://prefabs/effects/mob_death.scn")
var player
var players = []
var player_distance = 0
var find_target_timer = 0

signal destroyed


enum Colliding {
	OK,
	DANGER,
	NO_BLOCK
}


func _ready():
	max_health = round(stats_multiplier * max_health)
	if MP.is_active:
		var mul = 1 + 0.5 * get_tree().get_network_connected_peers().size()
		max_health = round(max_health * mul)
	defense = round(stats_multiplier * defense)
	_body = $visual/body
	_level = $"../.."
	_health_bar = $bars/progress
	_health_change_bar = $bars/progress/under
	_head = get_node(head_path)
	_head_sprite = load(head_sprite_path)
	_head_hurt_sprite = load(head_hurt_sprite_path)
	_hp_count = $bars/hp
	current_health = max_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health
	if MP.is_active and $"/root/mg".state != 2:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	find_target()
	if player != null:
		player_distance = global_position.distance_to(player.global_position)


func find_target():
	if find_target_timer > reaction_speed:
		find_target_timer = 0
	else:
		return
	players = get_tree().get_nodes_in_group("player")
	var min_dist = 0
	player = null
	for i in players:
		if not i.can_see:
			continue
		var dist = global_position.distance_to(i.global_position)
		if not is_instance_valid(player) or dist < min_dist:
			min_dist = dist
			player = i


func calculate_fall_damage():
	if immune_to_fall_damage:
		return
	.calculate_fall_damage()


func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4, can_ignored = true):
	var state = .hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, can_ignored)
	if state == null:
		return
	if not state.is_valid():
		return
	if current_health <= 0:
		collision_layer = 0b0
		collision_mask = 0b1
	state.connect("completed", self, "post_hurt")
	var state_next = state.resume()


func post_hurt():
	if current_health <= 0:
		yield(get_tree().create_timer(1, false), "timeout")
		var death = _mob_death.instance()
		death.global_position = global_position
		_level.add_child(death)
		emit_signal("destroyed")
		queue_free()
	else:
		can_hurt = true


func move_left():
	ms.sync_call(self, "move_left")
	_move_direction.x = -1


func move_right():
	ms.sync_call(self, "move_right")
	_move_direction.x = 1


func stop():
	ms.sync_call(self, "stop")
	_move_direction.x = 0


func jump(power = 0):
	ms.sync_call(self, "jump")
	if not can_move:
		return false
	if power == 0:
		power = JUMP_POWER
	if is_on_floor() or under_water:
		_move.y = -power * GRAVITY_SCALE
		return true
	return false


func _physics_process(delta):
	find_target_timer += delta


func ray_colliding(ray):
	if not ray.is_colliding():
		return Colliding.NO_BLOCK
	var collider = ray.get_collider()
	if collider is Attack or collider is FireAttack:
		if not ray.get_collider().is_enemy_attack:
			return Colliding.DANGER
	return Colliding.OK
