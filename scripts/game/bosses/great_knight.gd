extends Boss


const OFFSET_X = 160
const OFFSET_Y = 128
onready var timer = $swipe_timer
var swords_down_poses = []
var swipe_effect = load("res://prefabs/bosses/sword_swipe.scn")
var sword_throw = load("res://prefabs/bosses/sword_throw.scn")
var sword_down_attack = load("res://prefabs/bosses/sword_down_attack.scn")


func _ready():
	mob = $mob_gk
	fill_x = 53
	tp_pos = Vector2(54, -2)
	attacks = ["crack", "swipes", "throw", "swords_down"]
	mercy_dialog = "Великий рыцарь: Ты спасёшь всех, %s!" % G.getv("name", "")
	death_dialog = "Великий рыцарь: Ну иди...\n (убить или пощадить?)"
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ВЕЛИКИЙ РЫЦАРЬ" + ":"
	for i in $swords_spawn_points.get_children():
		swords_down_poses.append(i.global_position)


func death():
	G.ach.complete(Achievements.BOSS4)
	.death()


func do_attack():
	if global_position.distance_squared_to(player_target.global_position) < 6400:
		melee()
	else:
		attacks.shuffle()
		call(attacks[0])


func melee():
	ms.sync_call(self, "melee")
	anim.play("attack")
	next_attack_time += 0.6


func crack():
	ms.sync_call(self, "crack")
	anim.play("crack")
	next_attack_time += 1.3


func swipes():
	ms.sync_call(self, "swipes")
	next_attack_time += 1.6
	var is_angry = mob.current_health < mob.max_health * 0.5
	if is_angry:
		next_attack_time += 0.4
	var player_pos = player_target.global_position
	create_swipe(player_pos)
	timer.start(0.15)
	yield(timer, "timeout")
	if not is_instance_valid(mob):
		return
	if is_angry:
		anim.play("swipes_angry")
	else:
		anim.play("swipes")
	timer.start(0.3)
	yield(timer, "timeout")
	create_swipe(player_pos)
	timer.start(0.45)
	yield(timer, "timeout")
	create_swipe(player_pos)
	if not is_angry:
		return
	timer.start(0.45)
	yield(timer, "timeout")
	create_swipe(player_pos)
	timer.start(0.45)
	yield(timer, "timeout")
	create_swipe(player_pos)


func create_swipe(player_position):
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	randomize()
	var node = swipe_effect.instance()
	node.global_position = Vector2(rand_range(player_position.x - OFFSET_X, player_position.x + OFFSET_X), rand_range(player_position.y - OFFSET_Y, player_position.y + OFFSET_Y))
	node.rotation_degrees = rand_range(0, 360)
	$"../..".add_child(node, true)


func throw():
	ms.sync_call(self, "throw")
	anim.play("throw")
	next_attack_time += 1.2
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.6, false), "timeout")
	if not can_mob_move():
		return
	var node = sword_throw.instance()
	node.global_position = $visual/body/arm_right/hand/weapon/shoot.global_position
	node.rotation = $visual/body/arm_right/hand/weapon/shoot.global_position.direction_to(player_target.global_position).angle()
	$"../..".add_child(node, true)


func swords_down():
	ms.sync_call(self, "swords_down")
	anim.play("swords_down")
	next_attack_time += 2
	if not MP.auth(self):
		return
	var is_angry = mob.current_health < mob.max_health * 0.5
	yield(get_tree().create_timer(0.6, false), "timeout")
	if not can_mob_move():
		return
	randomize()
	swords_down_poses.shuffle()
	for i in range(8 if is_angry else 6):
		var attack = sword_down_attack.instance()
		attack.global_position = swords_down_poses[i]
		$"../..".add_child(attack)
