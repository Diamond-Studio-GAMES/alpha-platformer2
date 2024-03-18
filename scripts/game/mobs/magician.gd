extends Mob
class_name Magician


export (float) var min_distance = 50
onready var detect_ray = $detect_ray_cast
var should_move = true
var should_heal = false
var next_attack = false
var _min_distance = 0
var _min_distance_true = 0
var _mobs = []
var attack_scene = load("res://prefabs/mobs/magician_attack.tscn")


func _ready():
	_min_distance = min_distance * min_distance
	_min_distance_true = _min_distance
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)
	$heal_area.heal_amount = attack_damage


func attack():
	ms.sync_call(self, "attack")
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
			var cc = tm.world_to_map(detect_ray.get_collision_point() + Vector2.DOWN * 16 * GRAVITY_SCALE)
			spawn_attack(tm.map_to_world(cc))
			if GRAVITY_SCALE > 0:
				for i in range(1, 5):
					if tm.get_cell(cc.x + i, cc.y) >= 0 and tm.get_cell(cc.x + i, cc.y - 1) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i))
					elif tm.get_cell(cc.x + i, cc.y + 1) >= 0 and tm.get_cell(cc.x + i, cc.y) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i + Vector2.DOWN))
					elif tm.get_cell(cc.x + i, cc.y - 1) >= 0 and tm.get_cell(cc.x + i, cc.y - 2) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i + Vector2.UP))
					else:
						break
				for i in range(1, 5):
					if tm.get_cell(cc.x - i, cc.y) >= 0 and tm.get_cell(cc.x - i, cc.y - 1) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i))
					elif tm.get_cell(cc.x - i, cc.y + 1) >= 0 and tm.get_cell(cc.x - i, cc.y) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i + Vector2.DOWN))
					elif tm.get_cell(cc.x - i, cc.y - 1) >= 0 and tm.get_cell(cc.x - i, cc.y - 2) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i + Vector2.UP))
					else:
						break
			else:
				for i in range(1, 5):
					if tm.get_cell(cc.x + i, cc.y) >= 0 and tm.get_cell(cc.x + i, cc.y + 1) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i))
					elif tm.get_cell(cc.x + i, cc.y + 1) >= 0 and tm.get_cell(cc.x + i, cc.y + 2) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i + Vector2.DOWN))
					elif tm.get_cell(cc.x + i, cc.y - 1) >= 0 and tm.get_cell(cc.x + i, cc.y) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.RIGHT * i + Vector2.UP))
					else:
						break
				for i in range(1, 5):
					if tm.get_cell(cc.x - i, cc.y) >= 0 and tm.get_cell(cc.x - i, cc.y - 1) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i))
					elif tm.get_cell(cc.x - i, cc.y + 1) >= 0 and tm.get_cell(cc.x - i, cc.y + 2) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i + Vector2.DOWN))
					elif tm.get_cell(cc.x - i, cc.y - 1) >= 0 and tm.get_cell(cc.x - i, cc.y) < 0:
						spawn_attack(tm.map_to_world(cc + Vector2.LEFT * i + Vector2.UP))
					else:
						break
	yield(get_tree().create_timer(0.4, false), "timeout")
	should_move = true


func do_heal():
	ms.sync_call(self, "do_heal")
	should_move = false
	_anim_tree["parameters/heal_seek/seek_position"] = 0
	_anim_tree["parameters/heal_shot/active"] = true
	yield(get_tree().create_timer(0.6, false), "timeout")
	process_heal()
	yield(get_tree().create_timer(1, false), "timeout")
	should_move = true


func process_heal():
	if current_health > 0:
		$heal_area/anim.play("heal")


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
		player_visible = player_distance < _vision_distance
		if not player_visible:
			stop()
			return
		if not should_move:
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
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
	
	if not player_visible:
		return
	attack_timer += delta
	if attack_timer > attack_speed:
		if player_distance < _attack_distance:
			if should_heal and not next_attack:
				do_heal()
				next_attack = true
			else:
				attack()
				next_attack = false
		elif should_heal:
			do_heal()
		attack_timer = 0
	lookup_timer += delta
	if lookup_timer > lookup_speed:
		lookup_timer = 0
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
		do_lookup()


func update_strategy():
	if _mobs.empty():
		should_heal = false
		_min_distance = _min_distance_true
		next_attack = false
	else:
		should_heal = true
		_min_distance = min_distance * min_distance


func _on_mob_detector_body_entered(body):
	if not MP.auth(self):
		return
	if body == self:
		return
	if body is Mob:
		_mobs.append(body)
		update_strategy()


func _on_mob_detector_body_exited(body):
	if not MP.auth(self):
		return
	if body in _mobs:
		_mobs.erase(body)
		update_strategy()
