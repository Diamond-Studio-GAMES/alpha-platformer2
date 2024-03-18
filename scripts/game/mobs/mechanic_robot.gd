extends Mob
class_name MechanicRobot


signal returned_to_owner(mob_owner)

export (float) var min_distance = 100
export (int) var big_attack_damage = 50
export (String) var owner_path = "res://prefabs/mobs/mechanic.tscn"
onready var arm_big = $visual/body/arm_big
onready var arm_small = $visual/body/arm_small
onready var shoot = $visual/body/arm_small/arm_small/shoot
onready var big_shoot = $visual/body/arm_big/arm_big/ball
var bullet = load("res://prefabs/mobs/robot_bullet.tscn")
var big_bullet = load("res://prefabs/mobs/big_robot_bullet.tscn") # I NEED MORE BULLETS
var _owner
var owner_current_health = 0
var _min_distance = 0
var _animation_attack
var _animation_big
var _attack_track_idx = 0
var _attack_key_idx = 0
var _big_track_idx = 0
var _big_key_idx = 0


func _ready():
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)
	big_attack_damage = round(stats_multiplier * big_attack_damage)
	_min_distance = min_distance * min_distance
	_animation_attack = _anim.get_animation("attack")
	_attack_track_idx = _animation_attack.find_track(@"visual/body/arm_small:rotation_degrees")
	_attack_key_idx = _animation_attack.track_find_key(_attack_track_idx, 0.5)
	_animation_big = _anim.get_animation("attack_big")
	_big_track_idx = _animation_big.find_track(@"visual/body/arm_big:rotation_degrees")
	_big_key_idx = _animation_big.track_find_key(_big_track_idx, 0.8)
	attack_timer = 5
	_owner = load(owner_path)


func attack():
	ms.sync_call(self, "attack")
	can_turn = false
	speed_cooficent *= 0.3
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
	_animation_attack.track_set_key_value(_attack_track_idx, _attack_key_idx, hand_rotate)
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.5, false), "timeout")
	for i in 3:
		if current_health > 0:
			if MP.auth(self):
				var node = bullet.instance()
				node.global_position = shoot.global_position
				node.rotation = direction.angle()
				node.z_index = -1
				node.get_node("attack").damage = attack_damage
				_level.add_child(node, true)
			yield(get_tree().create_timer(0.4, false), "timeout")
	speed_cooficent /= 0.3
	can_turn = true


# NOW IS YOUR CHANCE TO BE BIG SHOT
# BIG BIG BIG BIG BIG BIG SHOT
func big_shot():
	ms.sync_call(self, "big_shot")
	can_turn = false
	speed_cooficent *= 0.2
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
	_animation_big.track_set_key_value(_big_track_idx, _big_key_idx, hand_rotate)
	_anim_tree["parameters/big_seek/seek_position"] = 0
	_anim_tree["parameters/big_shot/active"] = true
	yield(get_tree().create_timer(1.8, false), "timeout")
	if MP.auth(self) and current_health > 0:
		var node = big_bullet.instance()
		node.global_position = big_shoot.global_position
		node.rotation = direction.angle()
		if _body.scale.x < 0:
			node.z_index = -1
		node.get_node("attack").damage = big_attack_damage
		_level.add_child(node, true)
	yield(get_tree().create_timer(0.4, false), "timeout")
	speed_cooficent /= 0.2
	can_turn = true


func _post_hurt(ded):
	if ded:
		yield(get_tree().create_timer(1, false), "timeout")
		var death = mob_death_effect.instance()
		death.global_position = global_position
		death.scale.y = GRAVITY_SCALE
		_level.add_child(death)
		emit_signal("destroyed")
		if MP.auth(self):
			_spawn_owner()


func _spawn_owner():
	ms.sync_call(self, "_spawn_owner")
	var n = _owner.instance()
	n.global_position = global_position
	n.stats_multiplier = stats_multiplier
	n.GRAVITY_SCALE = GRAVITY_SCALE
	n.get_node("MultiplayerSynchronizer").syncing = true
	n.transform_timer = 0
	get_parent().add_child(n, true)
	n.current_health = owner_current_health
	n._update_bars()
	emit_signal("returned_to_owner", n)
	queue_free()


func _process(delta):
	if current_health < 1:
		return
	arm_big.show_behind_parent = _body.scale.x < 0
	arm_small.show_behind_parent = _body.scale.x > 0


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
		if randi() % 2 == 0:
			attack()
			attack_timer = 0
		else:
			big_shot()
			attack_timer = -1
	lookup_timer += delta
	if lookup_timer > lookup_speed:
		lookup_timer = 0
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
		do_lookup()
