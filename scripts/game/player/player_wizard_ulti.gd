extends Area2D


var level = 1
var power = 0
var attack_power = 25
var has_amulet = false
var _ulti_attack = load("res://prefabs/classes/wizard_ulti_attack.tscn")
var _effect = load("res://prefabs/effects/effect_wizard_ulti.tscn")
onready var _level = get_tree().current_scene


func _ready():
	attack_power = (30 + power * 6) * 0.5
	var wizard_max_health = 80 + power * 16 + (60 if has_amulet else 0)
	match level:
		1:
			$heal.heal_amount = round(wizard_max_health * 0.15)
		2:
			$heal.heal_amount = round(wizard_max_health * 0.3)
		3:
			$heal.heal_amount = round(wizard_max_health * 0.45)
		4:
			$heal.heal_amount = round(wizard_max_health * 0.6)
		5:
			$heal.heal_amount = round(wizard_max_health * 0.75)
	yield(get_tree().create_timer(1.1, false), "timeout")
	var enemies = get_overlapping_bodies()
	var enemies_copy = enemies.duplicate()
	for i in enemies_copy:
		if i is Player:
			enemies.erase(i)
		if not i is Entity:
			enemies.erase(i)
	if enemies.empty():
		yield(get_tree().create_timer(2, false), "timeout")
		queue_free()
		return
	for targeted_enemy in enemies:
		if not MP.auth(self):
			continue
		var node = _ulti_attack.instance()
		node.global_position = targeted_enemy.global_position
		var effect_node = _effect.instance()
		effect_node.global_position = targeted_enemy.global_position
		_level.add_child(effect_node, true)
		node.damage = attack_power
		_level.add_child(node, true)
	if not enemies.empty():
		$sfx.play()
	yield(get_tree().create_timer(2.25, false), "timeout")
	queue_free()
