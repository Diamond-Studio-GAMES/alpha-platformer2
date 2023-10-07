extends Area2D
class_name Attack, "res://textures/gui/attack.png"


export (int) var damage = 25
export (float) var knockback = 1
export (bool) var stuns = false
export (float) var stun_time = 1
export (float) var custom_invincibility_time = 0.5
export (float) var custom_immobility_time = 0.4
export (bool) var defense_allowed = true
export (bool) var fatal = false
export (bool) var is_player_attack = false
export (bool) var is_enemy_attack = false
export (String) var damage_source = ""
export (bool) var emit_hit_attack_signal = false
export (float) var lifetime = 1
var bodies = []
var exceptions = []
var exceptions_timers = []

signal hit_enemy
signal hit_wall
signal hit_player
signal hit_attack
signal hit_attack_with_object(node)


func _ready():
	if damage_source.empty():
		if is_player_attack:
			damage_source = "player"
		elif is_enemy_attack:
			damage_source = "mob"
		else:
			damage_source = "env"
	connect("body_entered", self, "add_body")
	connect("body_exited", self, "remove_body")
	connect("area_entered", self, "add_body")
	connect("area_exited", self, "remove_body")
	if lifetime == 0:
		return
	create_tween().tween_callback(self, "queue_free").set_delay(lifetime)


func add_body(node):
	if node is Entity:
		bodies.append(node)
		if node is Player:
			emit_signal("hit_player")
		elif node.is_in_group("mob"):
			emit_signal("hit_enemy")
	else:
		if node.has_method("deal_damage") and emit_hit_attack_signal:
			emit_signal("hit_attack")
			emit_signal("hit_attack_with_object", node)
			return
		emit_signal("hit_wall")


func remove_body(node):
	bodies.erase(node)


func deal_damage(node):
	exceptions.append(node)
	exceptions_timers.append(custom_invincibility_time)
	if node is Player and is_player_attack:
		return false
	if node.is_in_group("mob") and is_enemy_attack:
		return false
	if MP.auth(node):
		return node.hurt(damage, sign(node.global_position.x - global_position.x) * knockback, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, damage_source)


func _physics_process(delta):
	for i in range(exceptions.size() - 1, -1, -1):
		exceptions_timers[i] -= delta
		if exceptions_timers[i] <= 0:
			exceptions.remove(i)
			exceptions_timers.remove(i)
	for i in bodies:
		if not i in exceptions:
			deal_damage(i)
