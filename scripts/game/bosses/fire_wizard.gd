extends Boss


var fireball_small = load("res://prefabs/bosses/fireball.scn")
var fireball_big = load("res://prefabs/bosses/big_fireball.scn")
var oil = load("res://prefabs/bosses/oil.scn")
onready var timer = $timer


func _ready():
	mob = $mob_fw
	fill_x = 53
	fill_height = 16
	tp_pos = Vector2(54, -2)
	attacks = ["fireball", "fireballs", "oil", "fire_rain"]
	mercy_dialog = "Огненный страж: Иди, ты достоин."
	death_dialog = "Огненный страж: Я... Выгорел?..\n (убить или пощадить?)"
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ХИРУРГ" + ":"


func death():
	G.ach.complete(Achievements.BOSS6)
	.death()


func do_attack():
	attacks.shuffle()
	call(attacks[0])


func fireballs():
	ms.sync_call(self, "fireballs")
	var is_angry = mob.current_health < mob.max_health / 2
	if is_angry:
		anim.play("fireball_angry")
		next_attack_time += 3.2
	else:
		anim.play("fireball")
		next_attack_time += 2.6
	timer.start(0.6)
	yield(timer, "timeout")
	_create_fireball_to_player($visual/body/arm_left/hand/weapon/spawn_pos.global_position)
	timer.start(0.6)
	yield(timer, "timeout")
	_create_fireball_to_player($visual/body/arm_right/hand/weapon/spawn_pos.global_position)
	timer.start(0.6)
	yield(timer, "timeout")
	_create_fireball_to_player($visual/body/arm_left/hand/weapon/spawn_pos.global_position)
	if not is_angry:
		return
	timer.start(0.6)
	yield(timer, "timeout")
	_create_fireball_to_player($visual/body/arm_right/hand/weapon/spawn_pos.global_position)


func fireball():
	ms.sync_call(self, "fireball")
	anim.play("big_fireball")
	next_attack_time += 2
	if not MP.auth(self):
		return
	timer.start(1.5)
	yield(timer, "timeout")
	if not can_mob_move():
		return
	var inacc = deg2rad(rand_range(-5, 5))
	var node = fireball_big.instance()
	node.global_position = $visual/body/arm_left/hand/big_weapon/spawn_pos.global_position
	node.rotation = (player_target.global_position - $visual/body/arm_left/hand/big_weapon/spawn_pos.global_position).angle() + inacc
	node.get_node("fire").rotation = -((player_target.global_position - $visual/body/arm_left/hand/big_weapon/spawn_pos.global_position).angle() + inacc)
	get_tree().current_scene.add_child(node, true)


func fire_rain():
	ms.sync_call(self, "fire_rain")
	var is_angry = mob.current_health < mob.max_health / 2
	anim.play("rain")
	next_attack_time += 1.85 if not is_angry else 2.6
	timer.start(0.6)
	yield(timer, "timeout")
	var idx_list = range(int($fire_rain_spawn_end.global_position.x - $fire_rain_spawn_begin.global_position.x) / 32 + 1)
	idx_list.shuffle()
	for i in range(4 if not is_angry else 7):
		var step_index = idx_list[i]
		_create_fireball_to_down($fire_rain_spawn_begin.global_position + Vector2.RIGHT * 32 * step_index)
		timer.start(0.25)
		yield(timer, "timeout")


func oil():
	if MP.auth(self) and $oils.get_child_count() > 0:
		do_attack()
		return
	ms.sync_call(self, "oil")
	anim.play("oil")
	next_attack_time += 1
	if not MP.auth(self):
		return
	timer.start(0.5)
	yield(timer, "timeout")
	if not can_mob_move():
		return
	var is_angry = mob.current_health < mob.max_health / 2
	var idx_list = range(int($oil_spawn_end.global_position.x - $oil_spawn_begin.global_position.x) / 32 + 1)
	idx_list.shuffle()
	for i in range(idx_list.size() - 5 if not is_angry else idx_list.size() - 2):
		var step_index = idx_list[i]
		_create_oil($oil_spawn_begin.global_position + Vector2.RIGHT * 32 * step_index)


func _create_fireball_to_player(spawn_pos):
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	var inacc = deg2rad(rand_range(-10, 10))
	var node = fireball_small.instance()
	node.global_position = spawn_pos
	node.rotation = (player_target.global_position - spawn_pos).angle() + inacc
	node.get_node("fire").rotation = -((player_target.global_position - spawn_pos).angle() + inacc)
	get_tree().current_scene.add_child(node, true)


func _create_fireball_to_down(spawn_pos):
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	var node = fireball_small.instance()
	node.global_position = spawn_pos
	node.rotation = Vector2.DOWN.angle()
	node.get_node("fire").rotation = Vector2.UP.angle()
	get_tree().current_scene.add_child(node, true)


func _create_oil(spawn_pos):
	ms.sync_call(self, "_create_oil", [spawn_pos])
	var n = oil.instance()
	n.position = spawn_pos
	$oils.add_child(n)
