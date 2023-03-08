extends Boss


var knives_attack = load("res://prefabs/bosses/knife_attack_sheeper.scn")
var big_knife_attack = load("res://prefabs/bosses/knife_sheeper_big.scn")
var sheep_bomb = load("res://prefabs/bosses/sheep_bomb.scn")


func _ready():
	mob = $mob_sh
	fill_x = 57
	attacks = ["knives", "spikes", "throw"]
	tp_pos = Vector2(58, -2)
	mercy_dialog = "Пастух: Ты... щадишь меня?.. Спасибо..."
	death_dialog = "Убить или пощадить?"
	next_attack_time_min = 3
	next_attack_time_max = 5
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ПАСТУХ" + ":"


func do_attack():
	var targ_dist = global_position.distance_squared_to(mob.player.global_position)
	if targ_dist < 5625:
		melee_attack()
		return
	else:
		attacks.shuffle()
		call(attacks[0])


func melee_attack():
	ms.sync_call(self, "melee_attack")
	anim.play("attack")
	yield(get_tree().create_timer(0.4, false), "timeout")
	$visual/body/knife_attack/swing.play()
	$visual/body/knife_attack/visual.show()
	$visual/body/knife_attack/visual.frame = 0
	$visual/body/knife_attack/visual.play("attack")
	$visual/body/knife_attack/shape.disabled = false
	yield(get_tree().create_timer(0.2, false), "timeout")
	$visual/body/knife_attack/shape.disabled = true


func knives():
	ms.sync_call(self, "knives")
	anim.play("knives_summon")


func knives_spawn():
	if not MP.auth(self):
		return
	var n = knives_attack.instance()
	n.global_position = $knife_attack_pos.global_position
	$"../..".add_child(n)


func spikes():
	ms.sync_call(self, "spikes")
	anim.play("spikes_attack")


func throw():
	ms.sync_call(self, "throw")
	anim.play("big_knife")


func big_knife_launch():
	if not MP.auth(self):
		return
	var chance = randi() % 2
	if chance == 0:
		sheep_bombs_launch()
		return
	var n = big_knife_attack.instance()
	n.global_position = $visual/body/arm_left/hand/end.global_position
	$"../..".add_child(n, true)
	n.look_at(player_target.global_position)


func sheep_bombs_launch():
	for i in range(3):
		var n = sheep_bomb.instance()
		n.global_position = $visual/body/arm_left/hand/end.global_position
		n.player = player_target
		$"../..".add_child(n, true)
