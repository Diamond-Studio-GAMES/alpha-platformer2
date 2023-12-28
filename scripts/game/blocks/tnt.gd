extends StaticBody2D
class_name TNT


var explosion_radius = 5
var _is_exploded = false


func explode():
	if _is_exploded:
		return
	$MultiplayerSynchronizer.sync_call(self, "explode")
	_is_exploded = true
	$explosion/shape.set_deferred("disabled", false)
	$explosion/particles.restart()
	$explosion/sfx.play()
	$sprite.hide()
	$shape.set_deferred("disabled", true)
	$timer.start()
	var tilemap = get_tree().current_scene.get_node("tilemap") as TileMap
	var decorate = get_tree().current_scene.get_node("decorate") as TileMap
	var bg = get_tree().current_scene.get_node("bg") as TileMap
	var center = tilemap.world_to_map(global_position)
	var radius_squared = explosion_radius * explosion_radius
	for x in range(-explosion_radius, explosion_radius + 1):
		for y in range(-explosion_radius, explosion_radius + 1):
			if Vector2(x, y).length_squared() >= radius_squared:
				continue
			decorate.set_cellv(center + Vector2(x, y), -1)
			var curr_cell = tilemap.get_cellv(center + Vector2(x, y))
			if curr_cell >= 0:
				bg.set_cellv(center + Vector2(x, y), curr_cell)
			tilemap.set_cellv(center + Vector2(x, y), -1)
	yield(get_tree().create_timer(0.05, false), "timeout")
	for i in $explosion.get_overlapping_bodies():
		if i.has_method("explode") and MP.auth(i):
			i.explode()
		elif not i is Entity and not i is TileMap:
			i.queue_free()
	yield(get_tree().create_timer(0.25, false), "timeout")
	$explosion/shape.set_deferred("disabled", true)
