extends Area2D
class_name FireAttack, "res://textures/blocks/fireMask.png"


export (bool) var defense_allowed = true
export (bool) var fatal = false
export (int) var damage = 25
export (bool) var is_player_attack = false
export (bool) var is_enemy_attack = false
export (int) var knockback = 1
export (float) var lifetime = 1
export (bool) var stuns = false
export (float) var stun_time = 1
export (float) var custom_invincibility_time = 1
export (float) var custom_immobility_time = 0.8
var bodies = []
var timers = []
export (bool) var is_on_entity = false
var fire_on_entity = load("res://prefabs/effects/fire_on_entity.scn")
var target
var iterations = []


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
		timers.append(50)
		iterations.append(0)
	if node.get_collision_layer_bit(5):
		queue_free()


func remove_body(node):
	if node in bodies:
		var idx = bodies.find(node)
		bodies.erase(node)
		timers.remove(idx)
		iterations.remove(idx)


func deal_damage(node):
	if node.name.begins_with("player") and is_player_attack:
		return
	if node.name.begins_with("mob") and is_enemy_attack:
		return
	if MP.auth(node):
		if global_position.x < node.global_position.x:
			node.hurt(damage, 1 * knockback, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time)
		else:
			node.hurt(damage, -1 * knockback, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time)
	if is_on_entity or node.current_health <= 0:
		return
	if not node.has_node("fire_on_entity"):
		var foe = fire_on_entity.instance()
		foe.name = "fire_on_entity"
		foe.target = node
		node.add_child(foe)
	else:
		var foe = node.get_node("fire_on_entity")
		var idx = foe.bodies.find(node)
		if idx != -1:
			foe.iterations[idx] = 0


func _physics_process(delta):
	for i in range(0, bodies.size()):
		if is_on_entity:
			timers[i] += delta*60
			global_position = target.global_position
			if iterations[i] >= 5:
				queue_free()
			if timers[i] >= 70:
				timers[i] = 10
				iterations[i] += 1
				deal_damage(bodies[i])
		else:
			timers[i] += delta*60
			if timers[i] >= 60:
				timers[i] = 0
				deal_damage(bodies[i])
	
