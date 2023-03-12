extends Sprite

enum ToManage {
	WATER = 0,
	LAVA = 1,
	FIRE = 2,
}

export (ToManage) var to_manage = ToManage.WATER
export (bool) var is_lava_up = true


func _ready():
	match to_manage:
		ToManage.WATER:
			if G.getv("graphics", G.Graphics.BEAUTY_ALL) & G.Graphics.BEAUTY_WATER != 0:
				continue
			material = null
			if has_node("../drops"):
				$"../drops".queue_free()
		ToManage.LAVA:
			if G.getv("graphics", G.Graphics.BEAUTY_ALL) & G.Graphics.BEAUTY_LAVA != 0:
				continue
			material = null
			if is_lava_up:
				$"../smoke".queue_free()
				$"../sparks".queue_free()
				texture = load("res://textures/blocks/lava_up_masked.png")
			else:
				texture = load("res://textures/blocks/lava_masked.png")
		ToManage.FIRE:
			if G.getv("graphics", G.Graphics.BEAUTY_ALL) & G.Graphics.BEAUTY_FIRE != 0:
				continue
			material = null
			texture = load("res://textures/blocks/fire0.png")
			scale = Vector2.ONE * 0.5
			$"../smoke".queue_free()
