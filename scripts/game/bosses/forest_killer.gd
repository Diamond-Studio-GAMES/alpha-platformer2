extends Boss


onready var beartrap_points = $beartrap_points
onready var axe_points = $axe_points
var beartrap = load("res://prefabs/bosses/boss_beartrap.scn")
var axe = load("res://prefabs/bosses/axe_throw.scn")


func _ready():
	mob = $mob_fk
	attacks = ["beartraps", "spikes", "charge_axe", "axe_sides", "axe_throw", "axe_throw"]
	fill_x = 57
	tp_pos = Vector2(58, -2)
	mercy_dialog = "Лесоруб: Чего??? Ну и ладно."
	death_dialog = "Лесоруб: Что смотришь? Добей уже!\n (убить или пощадить?)"
	next_attack_time_min = 0.75
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ЛЕСОРУБ" + ":"


func death():
	G.ach.complete(Achievements.BOSS2)
	.death()


func do_attack():
	var targ_dist = global_position.distance_squared_to(player_target.global_position)
	if targ_dist < 5625:
		melee_attack()
		return
	else:
		attacks.shuffle()
		call(attacks[0])


func melee_attack():
	ms.sync_call(self, "melee_attack")
	anim.play("attack")


func beartraps():
	if not MP.auth(self):
		return
	next_attack_time += 1
	var points = [randi() % 7]
	while points.size() < 1:
		var num = randi() % 7
		if num in points:
			continue
		points.append(num)
	for i in points:
		var point = beartrap_points.get_node("pos" + str(i))
		point.get_node("sprite").show()
		yield(get_tree().create_timer(1, false), "timeout")
		point.get_node("sprite").hide()
		var b = beartrap.instance()
		b.global_position = point.global_position
		get_tree().current_scene.add_child(b, true)


func spikes():
	ms.sync_call(self, "spikes")
	next_attack_time += 1.5
	anim.play("spikes")


func charge_axe():
	ms.sync_call(self, "charge_axe")
	next_attack_time += 3.75
	anim.play("attack_charge")


func axe_sides():
	ms.sync_call(self, "axe_sides")
	next_attack_time += 2
	anim.play("attack_sides")


func axe_throw():
	ms.sync_call(self, "axe_throw")
	next_attack_time += 3
	anim.play("axe_throw")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(1, false), "timeout")
	var ids = [0, 1, 2, 3, 4]
	ids.shuffle()
	ids = ids.slice(0, 2)
	for i in ids:
		if not is_mob_alive():
			return
		var point = axe_points.get_node("pos" + str(i))
		point.get_node("sprite").show()
		yield(get_tree().create_timer(0.8, false), "timeout")
		point.get_node("sprite").hide()
		var n = axe.instance()
		n.global_position = point.global_position
		get_tree().current_scene.add_child(n, true)
