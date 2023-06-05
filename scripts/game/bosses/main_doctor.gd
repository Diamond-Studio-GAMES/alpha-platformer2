extends Boss


var alive_doctors = []
var doctor = load("res://prefabs/bosses/doctor_boss.scn")
var knife = load("res://prefabs/bosses/doctor_knife.scn")
var swipe = load("res://prefabs/bosses/doctor_swipe.scn")
onready var timer = $swipe_timer
onready var spawn_pos = $doctor_spawn_pos
onready var spawn_poses = [$swipe_pos0.global_position, $swipe_pos1.global_position, $swipe_pos2.global_position]


func _ready():
	mob = $mob_md
	fill_x = 53
	fill_height = 5
	tp_pos = Vector2(54, -2)
	attacks = ["throw", "summon", "heal", "swipes", "throw", "swipes"]
	mercy_dialog = "Хирург: Спасибо... Пойду потренируюсь на других."
	death_dialog = "Хирург: Операция не удалась...\n (убить или пощадить?)"
	next_attack_time_min = 0.8
	next_attack_time_max = 1.6
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ХИРУРГ" + ":"


func death():
	if MP.auth(self):
		for i in alive_doctors:
			i.hurt(i.current_health, 0, false)
	if timer.time_left > 0:
		timer.stop()
	.death()


func do_attack():
	var targ_dist = global_position.distance_squared_to(mob.player.global_position)
	if targ_dist < 4900:
		melee()
		return
	else:
		attacks.shuffle()
		call(attacks[0])


func melee():
	ms.sync_call(self, "melee")
	next_attack_time += 1
	anim.play("melee")


func summon():
	ms.sync_call(self, "summon")
	next_attack_time += 1
	anim.play("summon")
	yield(get_tree().create_timer(0.8, false), "timeout")
	spawn_pos.get_node("anim").play("summon")
	if MP.auth(self):
		var n = doctor.instance()
		n.global_position = spawn_pos.global_position
		n.connect("tree_exiting", self, "remove_doctor", [n])
		alive_doctors.append(n)
		get_parent().add_child(n, true)


func remove_doctor(d):
	alive_doctors.erase(d)


func heal():
	if MP.auth(self) and alive_doctors.empty():
		do_attack()
		return
	ms.sync_call(self, "heal")
	anim.play("heal")
	next_attack_time += 2
	yield(get_tree().create_timer(1, false), "timeout")
	if MP.auth(self):
		var heal_count = 0
		for i in alive_doctors:
			heal_count += i.current_health
			i.hurt(i.current_health, 0, false)
		if heal_count > 0:
			mob.heal(heal_count)


func throw():
	ms.sync_call(self, "throw")
	anim.play("throw")
	next_attack_time += 2.5
	yield(get_tree().create_timer(0.9, false), "timeout")
	if MP.auth(self):
		mob.find_target(true)
		var n = knife.instance()
		n.global_position = $visual/body/arm_right/hand/weapon.global_position
		get_tree().current_scene.add_child(n, true)
		n.look_at(mob.player.global_position)


func swipes():
	ms.sync_call(self, "swipes")
	next_attack_time += 3
	var angry = false
	if mob.current_health < mob.max_health / 2:
		angry = true
		next_attack_time += 1.6
	spawn_poses.shuffle()
	create_swipe(spawn_poses[0])
	timer.start(0.9)
	yield(timer, "timeout")
	anim.play("swipe")
	timer.start(0.5)
	yield(timer, "timeout")
	create_swipe(spawn_poses[2])
	timer.start(0.9)
	yield(timer, "timeout")
	anim.play_backwards("swipe")
	timer.start(0.5)
	yield(timer, "timeout")
	if not angry:
		timer.start(0.2)
		yield(timer, "timeout")
		anim.play("idle")
		return
	create_swipe(spawn_poses[1])
	timer.start(0.9)
	yield(timer, "timeout")
	anim.play("swipe")
	timer.start(0.7)
	yield(timer, "timeout")
	anim.play("idle")


func create_swipe(pos):
	if not MP.auth(self):
		return
	var node = swipe.instance()
	node.global_position = pos
	get_tree().current_scene.add_child(node, true)
