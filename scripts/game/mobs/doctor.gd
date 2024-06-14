extends Mob
class_name Doctor


export (float) var min_distance = 100
onready var shoot = $visual/body/arm_right/hand/weapon/shoot
var bullet = load("res://prefabs/mobs/syringe.tscn")
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
	key_idx0 = anima.track_find_key(trck_idx, 0.15)
	key_idx1 = anima.track_find_key(trck_idx, 0.4)


func attack():
	ms.sync_call(self, "attack")
	can_turn = false
	speed_cooficent *= 0.4
	var direction = global_position.direction_to(player.global_position)
	var hand_rotate = Vector2(direction.x, direction.y * GRAVITY_SCALE).angle()
	hand_rotate -= PI / 2
	if hand_rotate < -PI:
		hand_rotate = TAU + hand_rotate
	if hand_rotate < 0 and hand_rotate > -PI:
		_body.scale.x = 1
	if hand_rotate > 0 and hand_rotate < PI:
		_body.scale.x = -1
		hand_rotate = -hand_rotate
	hand_rotate = rad2deg(hand_rotate)
	anima.track_set_key_value(trck_idx, key_idx0, hand_rotate)
	anima.track_set_key_value(trck_idx, key_idx1, hand_rotate)
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.4, false), "timeout")
	if MP.auth(self) and current_health > 0:
		var node = bullet.instance()
		node.global_position = shoot.global_position
		node.rotation = direction.angle()
		node.get_node("attack").damage = attack_damage
		node.get_node("attack").on_entity_damage = round(attack_damage / 2)
		_level.add_child(node, true)
	yield(get_tree().create_timer(0.1, false), "timeout")
	speed_cooficent /= 0.4
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
	if player_timer > reaction_speed:
		player_timer = 0
		player_distance = global_position.distance_squared_to(player.global_position)
		player_visible = player_distance < _vision_distance
		if not player_visible:
			stop()
			return
		if player_distance > _min_distance:
			if player.global_position.x > global_position.x and move_right_safe:
				move_right()
			elif player.global_position.x < global_position.x and move_left_safe:
				move_left()
			else:
				stop()
		else:
			if player.global_position.x > global_position.x and move_left_safe:
				move_left()
			elif player.global_position.x < global_position.x and move_right_safe:
				move_right()
			else:
				stop()
	
	if not player_visible:
		return
	attack_timer += delta
	if attack_timer > attack_speed and player_distance < _attack_distance:
		attack()
		attack_timer = 0
	lookup_timer += delta
	if lookup_timer > lookup_speed:
		lookup_timer = 0
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
		do_lookup()
