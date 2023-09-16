extends Area2D


var gen = RandomNumberGenerator.new()
var times = 0
var damage_per_time = 0
var level = 1
var power = 0
var attack_power = 25
var has_amulet = false
var _ulti_attack = load("res://prefabs/classes/knight_ulti_attack.tscn")
var _effect = load("res://prefabs/effects/effect_knight_ulti.tscn")
onready var _level = get_tree().current_scene


func _ready():
	gen.randomize()
	randomize()
	attack_power = 25 + power * 5  + (15 if  has_amulet else 0)
	match level:
		1:
			times = 5
			damage_per_time = 1 * attack_power
		2:
			times = 7
			damage_per_time = 1 * attack_power
		3:
			times = 7
			damage_per_time = 2 * attack_power
		4:
			times = 8
			damage_per_time = 2 * attack_power
		5:
			times = 10
			damage_per_time = 2 * attack_power
	yield(get_tree().create_timer(1.1, false), "timeout")
	var enemies = get_overlapping_bodies()
	var enemies_copy = enemies.duplicate()
	for i in enemies_copy:
		if i is Player:
			enemies.erase(i)
		if not i is Entity:
			enemies.erase(i)
	var estimated_times = times
	if enemies.empty():
		queue_free()
		return
	while estimated_times > 0 and enemies.size() > 0 and MP.auth(self):
		enemies.shuffle()
		var selected_enemy = enemies[0]
		if not is_instance_valid(selected_enemy):
			enemies.erase(selected_enemy)
			continue
		if selected_enemy.current_health <= 0:
			enemies.erase(selected_enemy)
			continue
		var node = _ulti_attack.instance()
		node.global_position = selected_enemy.global_position
		var effect_node = _effect.instance()
		effect_node.global_position = selected_enemy.global_position
		_level.add_child(effect_node, true)
		node.damage = damage_per_time
		node.scale = Vector2.ONE * 2
		_level.add_child(node, true)
		estimated_times -= 1
		yield(get_tree().create_timer(0.25, false), "timeout")
	yield(get_tree().create_timer(2, false), "timeout")
	queue_free()
