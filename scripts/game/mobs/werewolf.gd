extends Mob
class_name Werewolf


export (float) var transform_time = 2
export (String) var transform_to_path = "res://prefabs/mobs/werewolf_human.tscn"
onready var attack_visual = $visual/body/knife_attack/visual
onready var attack_shape = $visual/body/knife_attack/shape
var _is_transforming = false
var transform_timer = 0
var transform_effect = load("res://prefabs/effects/transform_werewolf.tscn")
var transform_to


func _ready():
	reaction_speed += rand_range(-0.05, 0.1)
	attack_speed += rand_range(-0.1, 0.2)
	attack_damage = round(stats_multiplier * attack_damage)
	$visual/body/knife_attack.damage = attack_damage
	transform_to = load(transform_to_path)


func attack():
	ms.sync_call(self, "attack")
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.3, false), "timeout")
	$visual/body/knife_attack/swing.play()
	attack_visual.show()
	attack_visual.frame = 0
	attack_visual.play("attack")
	attack_shape.disabled = false
	yield(get_tree().create_timer(0.2, false), "timeout")
	attack_shape.disabled = true


func do_transform():
	ms.sync_call(self, "do_transform")
	z_index = 20
	immune_counter += 1
	can_turn = false
	_is_transforming = true
	stop()
	$bars.hide()
	_anim_tree["parameters/trans_trans/current"] = 1
	var node = transform_effect.instance()
	node.global_position = global_position
	_level.add_child(node)
	yield(get_tree().create_timer(1, false), "timeout")
	var n = transform_to.instance()
	n.global_position = global_position
	n.stats_multiplier = stats_multiplier
	n.GRAVITY_SCALE = GRAVITY_SCALE
	n.get_node("MultiplayerSynchronizer").syncing = true
	get_parent().add_child(n)
	n.current_health = n.max_health * min(1, float(current_health) / max_health + 0.3)
	n._update_bars()
	n.ms.sync_call(n, "_update_bars")
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
		if player.global_position.x > global_position.x and move_right_safe:
			move_right()
		elif player.global_position.x < global_position.x and move_left_safe:
			move_left()
		else:
			stop()
		if under_water and player_distance < _vision_distance / 4 and \
				player.global_position.y + 20 < global_position.y:
			jump()
	
	if not player_visible:
		transform_timer += delta
		if transform_timer >= transform_time:
			do_transform()
		return
	transform_timer = 0
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
