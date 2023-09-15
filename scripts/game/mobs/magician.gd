extends Mob
class_name Magician


export (float) var min_distance = 50
var should_move = true
var attack_scene = load("res://prefabs/mobs/magician_attack.tscn")
onready var jump_ray0 = $jump_ray_cast
onready var jump_ray1 = $jump_ray_cast2
onready var path_ray_left = $path_ray_cast_left
onready var path_ray_right = $path_ray_cast_right
onready var detect_ray = $detect_ray_cast
var _min_distance = 0
var _min_distance_true = 0


func _ready():
	_min_distance = min_distance * min_distance
	_min_distance_true = _min_distance
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)


func attack():
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.6, false), "timeout")
	if is_stunned or current_health <= 0:
		return
	stop()
	should_move = false
	if MP.auth(self):
		# ATTACK
		var tm := detect_ray.get_collider() as TileMap
		if tm:
			var cc = tm.world_to_map(global_position + Vector2.DOWN * 48 * GRAVITY_SCALE)
			spawn_attack(tm.map_to_world(cc))
			for i in range(1, 5):
				if tm.get_cell(cc.x + i, cc.y) >= 0 and tm.get_cell(cc.x + i, cc.y - GRAVITY_SCALE) < 0:
					spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i))
				elif tm.get_cell(cc.x + i, cc.y + GRAVITY_SCALE) >= 0 and tm.get_cell(cc.x + i, cc.y) < 0:
					spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i + Vector2.DOWN))
				elif tm.get_cell(cc.x + i, cc.y - GRAVITY_SCALE) >= 0 and tm.get_cell(cc.x + i, cc.y - GRAVITY_SCALE * 2) < 0:
					spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i + Vector2.UP))
				else:
					break
			for i in range(1, 5):
				if tm.get_cell(cc.x - i, cc.y) >= 0 and tm.get_cell(cc.x - i, cc.y - GRAVITY_SCALE) < 0:
					spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i))
				elif tm.get_cell(cc.x - i, cc.y + GRAVITY_SCALE) >= 0 and tm.get_cell(cc.x - i, cc.y) < 0:
					spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i + Vector2.DOWN))
				elif tm.get_cell(cc.x - i, cc.y - GRAVITY_SCALE) >= 0 and tm.get_cell(cc.x - i, cc.y - GRAVITY_SCALE * 2) < 0:
					spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i + Vector2.UP))
				else:
					break
	yield(get_tree().create_timer(0.4, false), "timeout")
	should_move = true


func spawn_attack(cc: Vector2):
	cc += Vector2.ONE * 16
	var n = attack_scene.instance()
	n.damage = attack_damage
	n.global_position = cc + Vector2.UP * 16 * GRAVITY_SCALE
	n.scale.y = GRAVITY_SCALE
	_level.add_child(n)


func _physics_process(delta):
	if not MP.auth(self):
		return
	find_target()
	if not is_instance_valid(player):
		stop()
		return
	player_timer += delta
	if player_timer > reaction_speed:
		player_timer = 0
		player_distance = global_position.distance_squared_to(player.global_position)
		if player_distance > _vision_distance:
			stop()
			return
		if not should_move:
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
		if under_water and player_distance < _vision_distance/4 and player.global_position.y+20 < global_position.y:
			jump()
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
	attack_timer += delta
	if attack_timer > attack_speed and player_distance < 16384:
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
