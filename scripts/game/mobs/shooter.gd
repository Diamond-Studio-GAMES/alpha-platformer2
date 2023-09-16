extends Mob
class_name Shooter


export (float) var min_distance = 100
onready var jump_ray0 = $jump_ray_cast
onready var jump_ray1 = $jump_ray_cast2
onready var path_ray_left = $path_ray_cast_left
onready var path_ray_right = $path_ray_cast_right
onready var shoot = $visual/body/arm_right/hand/weapon/shoot
var bullet = load("res://prefabs/mobs/shooter_bullet.tscn")
var _min_distance = 0
var anima
var trck_idx = 0
var key_idx0 = 0
var key_idx1 = 0


func _ready():
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)
	_min_distance = min_distance * min_distance
	anima = _anim.get_animation("attack")
	trck_idx = anima.find_track(@"visual/body/arm_right:rotation_degrees")
	key_idx0 = anima.track_find_key(trck_idx, 0.1)
	key_idx1 = anima.track_find_key(trck_idx, 0.35)


func attack():
	ms.sync_call(self, "attack")
	can_turn = false
	speed_cooficent *= 0.3
	var direction = global_position.direction_to(player.global_position)
	var phi = Vector2(direction.x, direction.y * GRAVITY_SCALE).angle()
	var hand_rotate = rad2deg(phi)
	var weapon_rotate = rad2deg(direction.angle())
	hand_rotate -= 90
	if hand_rotate < -180:
		hand_rotate = 360 + hand_rotate
	if hand_rotate < 0 and hand_rotate > -180:
		_body.scale.x = 1
	if hand_rotate > 0 and hand_rotate < 180:
		_body.scale.x = -1
		hand_rotate = -hand_rotate
	anima.track_set_key_value(trck_idx, key_idx0, hand_rotate)
	anima.track_set_key_value(trck_idx, key_idx1, hand_rotate)
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.2, false), "timeout")
	if MP.auth(self) and current_health > 0:
		for i in range(2):
			var node = bullet.instance()
			node.global_position = Vector2(shoot.global_position.x, shoot.global_position.y)
			node.rotation_degrees = weapon_rotate
			node.get_node("attack").damage = attack_damage
			_level.add_child(node, true)
			yield(get_tree().create_timer(0.05, false), "timeout")
	yield(get_tree().create_timer(0.1, false), "timeout")
	speed_cooficent /= 0.3
	can_turn = true


func _physics_process(delta):
	if current_health <= 0 or is_hurt or is_stunned:
		return
	find_target()
	if not MP.auth(self):
		return
	if not is_instance_valid(player):
		stop()
		return
	player_timer += delta
	attack_timer += delta
	if player_timer > reaction_speed:
		player_timer = 0
		player_distance = global_position.distance_squared_to(player.global_position)
		if player_distance > _vision_distance:
			stop()
			return
		if player_distance > _min_distance:
			if player.global_position.x > global_position.x and _is_move_safe(path_ray_right):
				move_right()
			elif player.global_position.x < global_position.x and _is_move_safe(path_ray_left):
				move_left()
			else:
				stop()
		else:
			if player.global_position.x > global_position.x and _is_move_safe(path_ray_left):
				move_left()
			elif player.global_position.x < global_position.x and _is_move_safe(path_ray_right):
				move_right()
			else:
				stop()
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
		if attack_timer > attack_speed and player_distance < 25600:
			attack()
			attack_timer = 0
	lookup_timer += delta
	if lookup_timer > lookup_speed:
		if ray_colliding(jump_ray0) == Colliding.OK and _move_direction.x > 0 or \
				ray_colliding(jump_ray1) == Colliding.OK and _move_direction.x < 0:
			jump()
		if _move_direction.x > 0 and not _is_move_safe(path_ray_right):
			stop()
		elif _move_direction.x < 0 and not _is_move_safe(path_ray_left):
			stop()
