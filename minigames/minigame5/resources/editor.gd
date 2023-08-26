extends Node2D


var tilemap : TileMap
onready var camera = $camera
onready var current_tile_id = 0
onready var current_tile_flip_x = $ui/base/panel/options/cont/x
onready var current_tile_flip_y = $ui/base/panel/options/cont/y
onready var current_tile_transposed = $ui/base/panel/options/cont/tr
onready var is_erasing = $ui/base/panel/options/cont/del
onready var cam_moving = $ui/base/panel/options/cont/mov
onready var preview = $ui/base/panel/options/preview
onready var bg = $ui/base/settings_set/names/items_sets/bg
onready var mu = $ui/base/settings_set/names/items_sets/music
onready var gr = $ui/base/settings_set/names/items_sets/ground


func change_current_id(id = 0):
	current_tile_id = id
	update_preview(true)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed and not cam_moving.pressed:
			var id = current_tile_id if not is_erasing.pressed else -1
			var pos = tilemap.world_to_map(get_global_mouse_position())
			tilemap.set_cellv(pos, id, current_tile_flip_x.pressed, current_tile_flip_y.pressed, current_tile_transposed.pressed)


func _ready():
	tilemap = load("user://custom_levels/" + G.getv("save_id", "lol") + ".tscn").instance()
	add_child(tilemap)
	current_tile_flip_x.connect("pressed", self, "update_preview")
	current_tile_flip_y.connect("pressed", self, "update_preview")
	current_tile_transposed.connect("pressed", self, "update_preview")
	update_preview(true)
	level_settings_load()


func zoom_in():
	camera.zoom.x = clamp(camera.zoom.x - 0.2, 0.6, 1.8)
	camera.zoom.y = clamp(camera.zoom.y - 0.2, 0.6, 1.8)


func zoom_out():
	camera.zoom.x = clamp(camera.zoom.x + 0.2, 0.6, 1.8)
	camera.zoom.y = clamp(camera.zoom.y + 0.2, 0.6, 1.8)


func exit():
	get_tree().change_scene("res://minigames/minigame5/minigame.tscn")


func save_and_exit():
	var map = PackedScene.new()
	map.pack(tilemap)
	ResourceSaver.save("user://custom_levels/" + G.getv("save_id", "lol") + ".tscn", map)
	exit()


func level_settings_save():
	G.setv("ld_bg", bg.selected)
	G.setv("ld_m", mu.selected)
	G.setv("ld_gr", gr.selected)


func level_settings_load():
	bg.selected = G.getv("ld_bg", 0)
	mu.selected = G.getv("ld_m", 0)
	gr.selected = G.getv("ld_gr", 0)


func update_preview(arg1 = true):
	preview.set_cellv(Vector2.ZERO, current_tile_id, current_tile_flip_x.pressed, current_tile_flip_y.pressed, current_tile_transposed.pressed)


func _process(delta):
	camera.active = cam_moving.pressed
