extends Area2D


func _enter_tree():
	pass
var _ulti_attack
var damage = 0
var stun_time = 0
var level = 1
var power = 0
var attack_power = 20
var gen
var has_amulet = false
var _level
var _effect


func _ready():
	_level = $".."
	_ulti_attack = load("res://prefabs/classes/spearman_ulti_attack.scn")
	_effect = load("res://prefabs/effects/effect_spearman_ulti.scn")
	gen = RandomNumberGenerator.new()
	gen.randomize()
	randomize()
	attack_power = 20 + power * 4  + (15 if  has_amulet else 0)
	match level:
		1:
			damage = 1 * attack_power
			stun_time = 2.5
		2:
			damage = 2 * attack_power
			stun_time = 3.75
		3:
			damage = 3 * attack_power
			stun_time = 5
		4:
			damage = 4 * attack_power
			stun_time = 6.25
		5:
			damage = 5 * attack_power
			stun_time = 7.5
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
	var targeted_enemy = null
	for i in enemies:
		if targeted_enemy == null:
			targeted_enemy = i
			continue
		if i.global_position.distance_to(global_position) < targeted_enemy.global_position.distance_to(global_position):
			targeted_enemy = i
	if MP.auth(self):
		var node = _ulti_attack.instance()
		node.global_position = targeted_enemy.global_position
		var effect_node = _effect.instance()
		effect_node.global_position = targeted_enemy.global_position
		_level.add_child(effect_node, true)
		enemies.erase(targeted_enemy)
		node.damage = damage
		node.stun_time = stun_time
#		node.scale = Vector2(2, 2)
		targeted_enemy.can_hurt = true
		_level.add_child(node, true)
		yield(get_tree(), "idle_frame")
		targeted_enemy.can_hurt = true
		yield(get_tree().create_timer(0.25, false), "timeout")
	yield(get_tree().create_timer(2, false), "timeout")
	queue_free()
