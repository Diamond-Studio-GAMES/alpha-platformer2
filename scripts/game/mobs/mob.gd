extends Entity
class_name Mob

# HEALTH
signal destroyed

const X_DIFF = 32
const Y_DIFF = 16
const FLOOR_DIFF = 4
const RAY_LENGTH = 320
const DANGER_LENGTH = 112
export (bool) var immune_to_fall_damage = false
export (float) var stats_multiplier = 1.0
export (int) var attack_damage = 20
export (float) var reaction_speed = 2.0
export (float) var lookup_speed = 0.1
export (float) var vision_distance = 200.0
export (float) var attack_distance = 80.0
export (float) var attack_speed = 2.5
export (NodePath) var head_path
export (String, FILE) var head_sprite_path = ""
export (String, FILE) var head_hurt_sprite_path = ""
export (String, FILE) var custom_mob_death_effect_path = ""
var _vision_distance = 0
var _attack_distance = 0
var player
var players = []
var player_distance = 0
var find_target_timer = 0
var player_visible = false
var panic_timer = 0
var player_timer = 0
var attack_timer = 0
var lookup_timer = 0
var move_right_safe = true
var move_left_safe = true
var move_ray: RayCast2D
var mob_death_effect = load("res://prefabs/effects/mob_death.tscn")

enum RayState {
	OK,
	HIGH,
	NO_BLOCK,
	ATTACK,
}

func _ready():
	add_to_group("mob")
	max_health = round(stats_multiplier * max_health)
	if MP.is_active:
		var mul = 1 + 0.75 * get_tree().get_network_connected_peers().size()
		max_health = round(max_health * mul)
	defense = round(stats_multiplier * defense)
	_vision_distance = vision_distance * vision_distance
	_attack_distance = attack_distance * attack_distance
	if not custom_mob_death_effect_path.empty():
		mob_death_effect = load(custom_mob_death_effect_path)
	_body = $visual/body
	_health_bar = $bars/progress
	_health_change_bar = $bars/progress/under
	_head = get_node(head_path)
	_head_sprite = load(head_sprite_path)
	_head_hurt_sprite = load(head_hurt_sprite_path)
	_hp_count = $bars/hp
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	player_timer = reaction_speed * randf()
	lookup_timer = lookup_speed * randf()
	
	move_ray = RayCast2D.new()
	move_ray.collide_with_areas = true
	move_ray.collision_mask = 0b11001
	move_ray.name = "move_ray"
	move_ray.set_as_toplevel(true)
	add_child(move_ray)
	
	if MP.is_active and $"/root/mg".state != 2:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	find_target()


func find_target(force = false):
	if find_target_timer <= 0 or force:
		find_target_timer = reaction_speed
	else:
		return
	players = get_tree().get_nodes_in_group("player")
	var min_dist = 0
	player = null
	for i in players:
		if not i.can_see:
			continue
		var dist = global_position.distance_squared_to(i.global_position)
		if not is_instance_valid(player) or dist < min_dist:
			min_dist = dist
			player = i


func calculate_fall_damage():
	if immune_to_fall_damage:
		return
	.calculate_fall_damage()


func _hurt_intermediate(damage_source, died):
	panic_timer = 1
	if died:
		if damage_source == "fire":
			G.ach.complete(Achievements.BURN_HER_FASTER)
		elif damage_source == "fall":
			G.ach.complete(Achievements.THIS_IS_SPARTA)
		elif damage_source == "tnt":
			G.ach.complete(Achievements.BOMBER)
		collision_layer = 0b0
		collision_mask = 0b1


func _post_hurt(ded):
	if ded:
		yield(get_tree().create_timer(1, false), "timeout")
		G.addv("kills", 1)
		G.ach.check(Achievements.KILLER)
		var death = mob_death_effect.instance()
		death.global_position = global_position
		death.scale.y = GRAVITY_SCALE
		_level.add_child(death)
		emit_signal("destroyed")
		queue_free()


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
	ms.sync_call(self, "jump", [power])
	if is_hurt or is_stunned:
		return false
	if power == 0:
		power = JUMP_POWER
	if is_on_floor() or under_water:
		_move.y = -power * GRAVITY_SCALE
		return true
	return false


func _process(delta):
	find_target_timer -= delta
	panic_timer -= delta


func do_lookup():
	var left_x = stepify(global_position.x - 16, 32) - 16
	var right_x = stepify(global_position.x - 16, 32) + 48
	var center_x = stepify(global_position.x - 16, 32) + 16
	var y = global_position.y - 32 * GRAVITY_SCALE
	move_ray.enabled = true
	move_ray.global_position = Vector2(left_x, y)
	move_ray.cast_to = Vector2.DOWN * RAY_LENGTH * GRAVITY_SCALE
	move_ray.force_raycast_update()
	var left_ray_state = _get_ray_state()
	var left_ray_y = move_ray.get_collision_point().y
	move_ray.global_position = Vector2(right_x, y)
	move_ray.force_raycast_update()
	var right_ray_state = _get_ray_state()
	var right_ray_y = move_ray.get_collision_point().y
	move_ray.global_position = Vector2(center_x, y)
	move_ray.force_raycast_update()
	var floor_y = move_ray.get_collision_point().y
	move_ray.enabled = false
	
	match left_ray_state:
		RayState.OK:
			move_left_safe = true
			if (floor_y - left_ray_y) * GRAVITY_SCALE >= FLOOR_DIFF and \
					_move_direction.x < 0:
				jump()
		RayState.HIGH:
			move_left_safe = under_water or not is_on_floor()
		RayState.NO_BLOCK:
			move_left_safe = under_water
		RayState.ATTACK:
			move_left_safe = panic_timer > 0
	match right_ray_state:
		RayState.OK:
			move_right_safe = true
			if (floor_y - right_ray_y) * GRAVITY_SCALE >= FLOOR_DIFF and \
					_move_direction.x > 0:
				jump()
		RayState.HIGH:
			move_right_safe = under_water or not is_on_floor()
		RayState.NO_BLOCK:
			move_right_safe = under_water
		RayState.ATTACK:
			move_right_safe = panic_timer > 0
	
	if _move_direction.x > 0 and not move_right_safe:
		stop()
	elif _move_direction.x < 0 and not move_left_safe:
		stop()
	if abs(player.global_position.x - global_position.x) < X_DIFF and \
			(global_position.y - player.global_position.y) * GRAVITY_SCALE > Y_DIFF:
		jump()


func _get_ray_state():
	if not move_ray.is_colliding():
		return RayState.NO_BLOCK
	if abs(move_ray.get_collision_point().y - global_position.y) > DANGER_LENGTH:
		return RayState.HIGH
	var collider = move_ray.get_collider()
	if collider is Attack:
		if not collider.is_enemy_attack:
			return RayState.ATTACK
		move_ray.add_exception(collider)
		move_ray.force_raycast_update()
		return _get_ray_state()
	elif collider is Area2D:
		move_ray.add_exception(collider)
		move_ray.force_raycast_update()
		return _get_ray_state()
	return RayState.OK
