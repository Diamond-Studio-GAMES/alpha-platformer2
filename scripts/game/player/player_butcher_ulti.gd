extends Area2D


var damage = 0
var level = 1
var power = 0
var attack_power = 25
var has_amulet = false
var _ulti_attack = load("res://prefabs/classes/butcher_ulti_attack.tscn")
var _effect = load("res://prefabs/effects/effect_butcher_ulti.tscn")
onready var _level = get_tree().current_scene


func _ready():
	attack_power = 30 + power * 6  + (15 if  has_amulet else 0)
	match level:
		1:
			damage = 5 * attack_power
		2:
			damage = 7 * attack_power
		3:
			damage = 10 * attack_power
		4:
			damage = 14 * attack_power
		5:
			damage = 18 * attack_power
	yield(get_tree().create_timer(1.1, false), "timeout")
	var enemies = get_overlapping_bodies()
	var enemies_copy = enemies.duplicate()
	for i in enemies_copy:
		if i is Player:
			enemies.erase(i)
		if not i is Entity:
			enemies.erase(i)
	if enemies.empty():
		queue_free()
		return
	var targeted_enemy = null
	for i in enemies:
		if targeted_enemy == null:
			targeted_enemy = i
			continue
		if i.current_health > targeted_enemy.current_health:
			targeted_enemy = i
		if i.current_health == targeted_enemy.current_health and \
				i.global_position.distance_squared_to(global_position) < targeted_enemy.global_position.distance_squared_to(global_position):
			targeted_enemy = i
	if MP.auth(self):
		var node = _ulti_attack.instance()
		node.global_position = targeted_enemy.global_position
		var effect_node = _effect.instance()
		effect_node.global_position = targeted_enemy.global_position
		_level.add_child(effect_node, true)
		enemies.erase(targeted_enemy)
		node.damage = damage
		node.scale = Vector2(2, 2)
		_level.add_child(node, true)
		yield(get_tree().create_timer(0.25, false), "timeout")
	yield(get_tree().create_timer(2, false), "timeout")
	queue_free()
