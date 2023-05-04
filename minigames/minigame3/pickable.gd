extends RigidBody


enum Item {
	COIN,
	GEM,
}


export (Item) var item_type = Item.COIN


func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			match item_type:
				Item.COIN:
					get_parent().add_coins(1)
				Item.GEM:
					get_parent().add_gems(1)
			queue_free()
