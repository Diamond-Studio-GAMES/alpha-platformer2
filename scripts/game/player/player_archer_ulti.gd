extends Area2D


var damage = 0
var level = 1
var power = 0
var attack_power = 25
var has_amulet = false
onready var _level = get_tree().current_scene
var _ulti_attack = load("res://prefabs/classes/archer_ulti_attack.tscn")
var _effect = load("res://prefabs/effects/effect_archer_ulti.tscn")


func _ready():
	attack_power = 35 + power * 7  + (15 if  has_amulet else 0)
	match level:
		1:
			damage = 1 * attack_power
		2:
			damage = 2 * attack_power
		3:
			damage = 3 * attack_power
		4:
			damage = 4 * attack_power
		5:
			damage = 5 * attack_power
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
	for i in enemies:
		if not is_instance_valid(i):
			continue
		if i.current_health <= 0:
			continue
		if not MP.auth(self):
			continue
		var node = _ulti_attack.instance()
		node.global_position = i.global_position
		var effect_node = _effect.instance()
		effect_node.global_position = i.global_position
		_level.add_child(effect_node, true)
		node.damage = damage
		node.scale = Vector2(1.5, 1.5)
		_level.add_child(node, true)
		yield(get_tree().create_timer(0.1, false), "timeout")
	yield(get_tree().create_timer(1, false), "timeout")
	queue_free()
