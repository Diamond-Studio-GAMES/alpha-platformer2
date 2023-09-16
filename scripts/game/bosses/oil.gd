extends Area2D


var burned = false
var fire = load("res://prefabs/blocks/fire.tscn")


func _on_oil_area_entered(area):
	if burned:
		return
	if area is FireAttack:
		ignite()


func ignite():
	burned = true
	$anim.play("start")
	yield($anim, "animation_finished")
	$visual.hide()
	var n = fire.instance()
	n.on_entity_damage_ticks = 3
	n.is_enemy_attack = true
	$fire_pos.call_deferred("add_child", n)
	$anim.play("ignite")
