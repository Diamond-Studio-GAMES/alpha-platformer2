extends Attack
class_name FireAttack, "res://textures/blocks/fireMask.png"


export (bool) var is_on_entity = false
var fire_on_entity = load("res://prefabs/effects/fire_on_entity.scn")
var counter = 0


func add_body(node):
	if node.get_collision_layer_bit(5):
		queue_free()
		return
	.add_body(node)


func deal_damage(node):
	if node is Player and is_player_attack:
		return
	if node.is_in_group("mob") and is_enemy_attack:
		return
	.deal_damage(node)
	if not MP.auth(node):
		return
	if is_on_entity:
		counter += 1
		if counter >= 5:
			queue_free()
	else:
		if node.has_node("fire_on_entity"):
			node.get_node("fire_on_entity").counter = 0
		else:
			var n = fire_on_entity.instance()
			n.name = "fire_on_entity"
			node.add_child(n, true)
	
