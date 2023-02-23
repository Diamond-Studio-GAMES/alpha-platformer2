extends Area2D
class_name Attack, "res://textures/gui/attack.png"


export (bool) var defense_allowed = true
export (bool) var fatal = false
export (int) var damage = 25
export (bool) var is_player_attack = false
export (bool) var is_enemy_attack = false
export (float) var knockback = 1
export (float) var lifetime = 1
export (bool) var stuns = false
export (float) var stun_time = 1
export (float) var custom_invincibility_time = 0.5
export (float) var custom_immobility_time = 0.4
export (bool) var can_ignored = true
export (bool) var emit_hit_attack_signal = false
var bodies = []
var exceptions = []
var exceptions_timers = []

signal hit_enemy
signal hit_wall
signal hit_player
signal hit_attack
signal hit_attack_with_object(node)


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
	if node.has_method("hurt"):
		bodies.append(node)
		if node.name.begins_with("player"):
			emit_signal("hit_player")
		elif node.name.begins_with("mob"):
			emit_signal("hit_enemy")
	else:
		if node.has_method("deal_damage") and emit_hit_attack_signal:
			emit_signal("hit_attack")
			emit_signal("hit_attack_with_object", node)
			return
		emit_signal("hit_wall")


func remove_body(node):
	if node in bodies:
		bodies.erase(node)


func deal_damage(node):
	if node.name.begins_with("player") and is_player_attack:
		return
	if node.name.begins_with("mob") and is_enemy_attack:
		return
	if MP.auth(node):
		if global_position.x < node.global_position.x:
			node.hurt(damage, 1 * knockback, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, can_ignored)
		else:
			node.hurt(damage, -1 * knockback, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, can_ignored)
	exceptions.append(node)
	exceptions_timers.append(custom_invincibility_time)


func _physics_process(delta):
	for i in range(exceptions.size() - 1, -1, -1):
		exceptions_timers[i] -= delta
		if exceptions_timers[i] <= 0:
			exceptions.remove(i)
			exceptions_timers.remove(i)
	for i in bodies:
		if not i in exceptions:
			deal_damage(i)
