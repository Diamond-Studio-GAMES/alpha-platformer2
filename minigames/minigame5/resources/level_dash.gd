extends TileMap


const SPIKE_ID = 21
const SPIKES_ID = 22
const SHIP_PORTAL_ID = 27
const CUBE_PORTAL_ID = 28
const AG_PORTAL_ID = 24
const G_PORTAL_ID = 25
const JUMP_PAD_ID = 23
const ORB_ID = 26
var spike = load("res://minigames/minigame5/spike.scn")
var spikes = load("res://minigames/minigame5/spikes.scn")
var ship_portal = load("res://minigames/minigame5/ship_portal_dash.scn")
var cube_portal = load("res://minigames/minigame5/cube_portal_dash.scn")
var ag_portal = load("res://minigames/minigame5/anti_gravity_portal_dash.scn")
var g_portal = load("res://minigames/minigame5/gravity_portal_dash.scn")
var jump_pad = load("res://minigames/minigame5/jump_pad.scn")
var orb = load("res://minigames/minigame5/orb.scn")


func _ready():
	$end.position.x = get_used_rect().size.x * 32 + get_used_rect().position.x * 32
	$load/bg.show()
	var spikes_poses = get_used_cells_by_id(SPIKE_ID)
	for i in spikes_poses:
		var node = spike.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var spikess_poses = get_used_cells_by_id(SPIKES_ID)
	for i in spikess_poses:
		var node = spikes.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var jps_poses = get_used_cells_by_id(JUMP_PAD_ID)
	for i in jps_poses:
		var node = jump_pad.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var orbs_poses = get_used_cells_by_id(ORB_ID)
	for i in orbs_poses:
		var node = orb.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var sp_poses = get_used_cells_by_id(SHIP_PORTAL_ID)
	for i in sp_poses:
		var node = ship_portal.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var cp_poses = get_used_cells_by_id(CUBE_PORTAL_ID)
	for i in cp_poses:
		var node = cube_portal.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var agp_poses = get_used_cells_by_id(AG_PORTAL_ID)
	for i in agp_poses:
		var node = ag_portal.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	var gp_poses = get_used_cells_by_id(G_PORTAL_ID)
	for i in gp_poses:
		var node = g_portal.instance()
		node.position = map_to_world(i)
		if not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 32
			node.scale = Vector2(-1, 1)
		elif not is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.scale = Vector2(1, -1)
		elif not is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 64
			node.position.x += 32
			node.scale = Vector2(-1, -1)
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.y += 32
			node.scale = Vector2(1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and not is_cell_x_flipped(i.x, i.y) and not is_cell_y_flipped(i.x, i.y):
			node.scale = Vector2(-1, 1)
			node.rotation_degrees = -90
		elif is_cell_transposed(i.x, i.y) and is_cell_x_flipped(i.x, i.y) and is_cell_y_flipped(i.x, i.y):
			node.position.x += 64
			node.scale = Vector2(1, 1)
			node.rotation_degrees = 90
		add_child(node)
		set_cellv(i, -1)
	$load/bg.hide()
	$music.play()
