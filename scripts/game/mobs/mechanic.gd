extends Mob
class_name Mechanic


signal transformed(robot)

export (float) var min_distance = 100
export (PackedScene) var to_spawn
onready var attack_visual = $visual/body/knife_attack/visual
onready var attack_shape = $visual/body/knife_attack/shape
var _min_distance = 0
var transform_effect = load("res://prefabs/effects/transform_mechanic.tscn")
var transform_timer = 1
var _is_transforming = false


func _ready():
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)
	_min_distance = min_distance * min_distance
	$visual/body/knife_attack.damage = attack_damage
	if transform_timer > 0:
		transform_timer = rand_range(1, 3)


func attack():
	ms.sync_call(self, "attack")
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.4, false), "timeout")
	$visual/body/knife_attack/swing.play()
	attack_visual.show()
	attack_visual.frame = 0
	attack_visual.play("attack")
	attack_shape.disabled = false
	yield(get_tree().create_timer(0.2, false), "timeout")
	attack_shape.disabled = true


func do_transform():
	ms.sync_call(self, "do_transform")
	collision_layer = 0
	collision_mask = 0b1
	z_index = 20
	immune_counter += 1
	can_turn = false
	_is_transforming = true
	stop()
	$bars.hide()
	_anim_tree["parameters/trans_shot/active"] = true
	var node = transform_effect.instance()
	node.global_position = Vector2(global_position.x, global_position.y + 30 * GRAVITY_SCALE)
	node.scale.y = GRAVITY_SCALE
	_level.add_child(node)
	yield(get_tree().create_timer(1.1, false), "timeout")
	var n = to_spawn.instance()
	n.global_position = global_position
	n.owner_current_health = current_health
	n.stats_multiplier = stats_multiplier
	n.GRAVITY_SCALE = GRAVITY_SCALE
	get_parent().add_child(n, true)
	emit_signal("transformed", n)
	queue_free()


func _physics_process(delta):
	if current_health <= 0 or is_stunned or _is_transforming:
		attack_shape.disabled = true
		attack_visual.hide()
		return
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
		if player.global_position.x > global_position.x:
			move_right()
			lookup_timer += 10
		else:
			move_left()
			lookup_timer += 10
		attack()
		attack_timer = 0
		player_timer = -0.4
	transform_timer += delta
	if transform_timer >= 10 and hurt_counter < 1 and not is_stunned and _move.y == 0:
		do_transform()
		transform_timer = 0
	lookup_timer += delta
	if lookup_timer > lookup_speed:
		lookup_timer = 0
		if under_water and breath_time < 2 and not immune_to_water:
			jump()
		do_lookup()
