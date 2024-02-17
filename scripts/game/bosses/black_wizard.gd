extends Boss


var alive_shooters = []
var shield_timer = 0
var under_shield = false
var blackball = load("res://prefabs/bosses/blackball.tscn")
var mob_shooter = load("res://prefabs/bosses/shooter_boss.tscn")
onready var lightnings = $lightnings.get_children()


func _ready():
	mob = $mob_bw
	next_attack_time_min = 1.5
	next_attack_time_max = 2
	mercy_dialog = tr("boss.wizard.mercy") % G.getv("name", "")
	death_dialog = tr("boss.wizard.defeat")
	attacks = ["blackball", "lightnings", "mob_spawn", "blackball", "lightnings"]
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.wizard").to_upper() + ":"


func _process(delta):
	if boss_bar == null:
		return
	if mob == null:
		return
	if not is_instance_valid(mob):
		boss_bar.hide()
		return
	if mob.is_queued_for_deletion():
		boss_bar.hide()
		return
	if under_shield:
		shield_timer += delta
		if shield_timer > 10:
			shield_timer = 0
			under_shield = false
			$visual/body/shield/anim.play("end")


func death():
	if MP.auth(self):
		for i in alive_shooters:
			i.hurt(i.current_health, 0, false)
	if not $visual/body/shield/shape.disabled:
		$visual/body/shield/anim.play("end")
	G.ach.complete(Achievements.BOSS3)
	.death()


func do_attack():
	var variants = attacks.duplicate()
	if not under_shield:
		variants.append("make_shield")
		variants.append("make_shield")
	if alive_shooters.size() >= 3:
		variants.erase("mob_spawn")
	variants.shuffle()
	call(variants[0])


func make_shield():
	ms.sync_call(self, "make_shield")
	next_attack_time += 1
	anim.play("make_shield")
	yield(get_tree().create_timer(0.3, false), "timeout")
	under_shield = true
	shield_timer = 0
	$visual/body/shield/anim.play("make")


func blackball():
	ms.sync_call(self, "blackball")
	next_attack_time += 0.7
	anim.play("blackball")
	yield(get_tree().create_timer(0.5, false), "timeout")
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	var n = blackball.instance()
	n.global_position = $visual/body/arm_right/hand/weapon/shoot.global_position
	n.rotation = $visual/body/arm_right/hand/weapon/shoot.global_position.direction_to(player_target.global_position).angle()
	get_tree().current_scene.add_child(n, true)


func lightnings():
	ms.sync_call(self, "lightnings")
	next_attack_time += 2.5
	anim.play("lightnings")
	yield(get_tree().create_timer(0.5, false), "timeout")
	if not can_mob_move():
		return
	for i in range(0, 15, 2):
		lightnings[i].get_node("anim").play("strike")
	yield(get_tree().create_timer(1, false), "timeout")
	for i in range(1, 16, 2):
		lightnings[i].get_node("anim").play("strike")


func mob_spawn():
	ms.sync_call(self, "mob_spawn")
	next_attack_time += 0.5
	anim.play("summon")
	yield(get_tree().create_timer(0.4, false), "timeout")
	if not MP.auth(self):
		return
	if not can_mob_move():
		return
	var pos = Vector2.ZERO
	if randi() % 2 == 1:
		pos = $"../pos0".global_position
		$"../pos0/sprite/anim".play("summon")
		ms.sync_call($"../pos0/sprite/anim", "play", ["summon"])
	else:
		pos = $"../pos1".global_position
		$"../pos1/sprite/anim".play("summon")
		ms.sync_call($"../pos1/sprite/anim", "play", ["summon"])
	var n = mob_shooter.instance()
	n.global_position = pos
	n.connect("tree_exiting", self, "remove_mob", [n])
	alive_shooters.append(n)
	get_parent().add_child(n, true)


func remove_mob(m):
	alive_shooters.erase(m)
