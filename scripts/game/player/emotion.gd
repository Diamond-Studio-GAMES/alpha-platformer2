extends Node2D


var show_timer = 0
onready var think = $think
onready var emote = $think/emote
onready var think_far = $think_far
onready var emote_far = $think_far/emote


func _ready():
	think_far.set_as_toplevel(true)


func _process(delta):
	if visible:
		global_scale = Vector2.ONE
		show_timer -= delta
		if show_timer <= 0:
			hide()
			think_far.hide()
			return
		var transform = get_viewport_transform()
		var rect = Rect2(-transform.get_origin() / transform.get_scale(), get_viewport_rect().size / transform.get_scale())
		if not rect.has_point(emote.global_position):
			think_far.show()
			think.hide()
			var direction = emote.global_position - rect.position - rect.size / 2
			think_far.rotation = direction.angle()
			direction.x = clamp(direction.x, -rect.size.x / 2, rect.size.x / 2)
			direction.y = clamp(direction.y, -rect.size.y / 2, rect.size.y / 2)
			think_far.global_position = rect.position + rect.size / 2 + direction
			emote_far.global_rotation = 0
		else:
			think.show()
			think_far.hide()


remote func show_emote(x, y):
	if MP.auth(self):
		rpc("show_emote", x, y)
	show()
	show_timer = 4
	emote.region_rect = Rect2(x, y, 16, 16)
	emote_far.region_rect = Rect2(x, y, 16, 16)
