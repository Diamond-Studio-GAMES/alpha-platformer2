extends Area2D


var _ulti_attack
var damage = 0
var level = 1
var power = 0
var attack_power = 25
var gen
var has_amulet = false
var _level
var _effect


func _ready():
	_level = $".."
	_ulti_attack = load("res://prefabs/classes/archer_ulti_attack.scn")
	_effect = load("res://prefabs/effects/effect_archer_ulti.scn")
	gen = RandomNumberGenerator.new()
	gen.randomize()
	randomize()
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
		if i.name.begins_with("player"):
			enemies.erase(i)
		if not i.has_method("hurt"):
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
		i.can_hurt = true
		yield(get_tree(), "idle_frame")
		i.can_hurt = true
		node.damage = damage
		node.scale = Vector2(1.5, 1.5)
		_level.add_child(node, true)
		yield(get_tree().create_timer(0.1, false), "timeout")
	yield(get_tree().create_timer(1, false), "timeout")
	queue_free()
