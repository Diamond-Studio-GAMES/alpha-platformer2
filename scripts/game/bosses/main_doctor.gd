extends Boss


var alive_doctors = []
var doctor = load("res://prefabs/bosses/doctor_boss.scn")
onready var spawn_pos = $doctor_spawn_pos


func _ready():
	mob = $mob_md
	fill_x = 53
	fill_height = 5
	tp_pos = Vector2(54, -2)
	attacks = ["throw", "summon", "heal", "swipes"]
	mercy_dialog = "Хирург: Спасибо... Пойду потренируюсь на других."
	death_dialog = "Хирург: Операция не удалась...\n (убить или пощадить?)"
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ХИРУРГ" + ":"


func death():
	if MP.auth(self):
		for i in alive_doctors:
			i.hurt(i.current_health, 0, false)
	.death()


func do_attack():
	attacks.shuffle()
	call(attacks[0])


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
	pass


func swipes():
	pass
