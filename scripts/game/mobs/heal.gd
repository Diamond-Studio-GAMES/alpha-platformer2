extends Area2D
class_name Heal, "res://textures/effects/other/heal_plus.png"


export (int) var heal_amount = 25
export (bool) var is_player_heal = false
export (bool) var is_enemy_heal = false
export (float) var lifetime = 0
export (bool) var emit_hit_attack_signal = false
var bodies = []

signal hit_enemy
signal hit_wall
signal hit_player
signal hit_attack


func _ready():
	connect("body_entered", self, "add_body")
	connect("body_exited", self, "remove_body")
	connect("area_entered", self, "add_body")
	connect("area_exited", self, "remove_body")
	if lifetime == 0:
		return
	yield(get_tree().create_timer(lifetime, false), "timeout")
	queue_free()


func add_body(node):
	if node.has_method("heal"):
		bodies.append(node)
		if node is Player:
			emit_signal("hit_player")
		elif node.is_in_group("mob"):
			emit_signal("hit_enemy")
	else:
		if node.has_method("deal_damage") and emit_hit_attack_signal:
			emit_signal("hit_attack")
			return
		emit_signal("hit_wall")


func remove_body(node):
	bodies.erase(node)


func heal(node):
	if node is Player and not is_player_heal:
		return
	if node.name.begins_with("mob") and not is_enemy_heal:
		return
	if not MP.auth(node):
		return
	node.heal(heal_amount)


func _physics_process(delta):
	for i in bodies:
		heal(i)
		bodies.erase(i)
