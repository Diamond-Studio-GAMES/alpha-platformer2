extends Attack
class_name FireAttack, "res://textures/blocks/fireMask.png"


export (bool) var is_on_entity = false
export (bool) var immune_to_water = false
export (String) var on_entity_node_name = "fire_on_entity"
export (int) var on_entity_damage_ticks = 5
export (int) var on_entity_damage = -1
export (String, FILE) var custom_path = "" 
var fire_on_entity
var counter = 0
var damage_ticks = 0


func _ready():
	if is_on_entity:
		return
	if custom_path.empty():
		fire_on_entity = load("res://prefabs/effects/fire_on_entity.tscn")
	else:
		fire_on_entity = load(custom_path)


func _process(delta):
	if is_on_entity:
		if get_parent().current_health <= 0:
			queue_free()


func add_body(node):
	if node.get_collision_layer_bit(5) and is_on_entity and not immune_to_water:
		queue_free()
		return
	.add_body(node)


func deal_damage(node):
	if node is Player and is_player_attack:
		return false
	if node.is_in_group("mob") and is_enemy_attack:
		return false
	var success = .deal_damage(node)
	if not MP.auth(node):
		return success
	
	if is_on_entity:
		counter += 1
		if counter >= damage_ticks:
			queue_free()
	else:
		if success:
			if node.has_node(on_entity_node_name):
				node.get_node(on_entity_node_name).counter = 0
			else:
				var n = fire_on_entity.instance()
				n.name = on_entity_node_name
				if on_entity_damage > 0:
					n.damage = on_entity_damage
				n.damage_ticks = on_entity_damage_ticks
				n.immune_to_water = immune_to_water
				node.add_child(n, true)
	return success
