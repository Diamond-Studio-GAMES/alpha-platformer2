extends Boss


var shield_timer = 0
var under_shield = false
var blackball = load("res://prefabs/bosses/blackball.scn")
var mob_shooter = load("res://prefabs/bosses/shooter_boss.scn")
onready var lightnings = $lightnings.get_children()


func _ready():
	mob = $mob_bw
	fill_x = 53
	tp_pos = Vector2(54, -2)
	mercy_dialog = "Чёрный маг: Слава тебе, %s!" % G.getv("name", "")
	death_dialog = "Чёрный маг: Я был не прав...\n (убить или пощадить?)"
	attacks = ["blackball", "lightnings", "mob_spawn", "blackball", "lightnings"]
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = "ЧЁРНЫЙ МАГ" + ":"


func _process(delta):
	if is_attacking and player != null:
		process_attack(delta)
	if waiting_for_death:
		death_timer += delta
		if death_timer >= 5:
			waiting_for_death = false
			player.make_dialog("Чёрный маг: Слава тебе, %s!" % G.getv("name", ""), 3)
			anim.play("mercy")
			set_cutscene(true)
			yield(anim, "animation_finished")
			set_cutscene(false)
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
	boss_hp.text = str(mob.current_health) + "/" + str(mob.max_health)
	boss_bar.value = mob.current_health


func get_hit(area):
	if waiting_for_death:
		if not MP.auth(area):
			return
		waiting_for_death = false
		anim.play("final_death")
		G.setv("boss_" + G.current_level + "_killed", true)


func death():
	if not $visual/body/shield/shape.disabled:
		$visual/body/shield/anim.play("end")
	$"../../music".stop()
	player.get_node("camera_tween").stop_all()
	player.get_node("camera_tween").remove_all()
	player.get_node("camera_tween").interpolate_property(player.get_node("camera"), "zoom", player.get_node("camera").zoom, Vector2(0.3, 0.3), 1)
	player.get_node("camera_tween").start()
	player.default_camera_zoom = Vector2(0.3, 0.3)
	is_attacking = false
	set_cutscene(true)
	anim.play("death")
	yield(anim, "animation_finished")
	set_cutscene(false)
	if G.getv("boss_" + G.current_level + "_killed", false):
		anim.play("final_death")
	else:
		player.make_dialog("Чёрный маг: Я был не прав...\n (убить или пощадить?)", 5)
		waiting_for_death = true


func process_attack(delta):
	if mob.is_stunned:
		return
	if not MP.auth(self):
		return
	attack_timer += delta
	if attack_timer >= next_attack_time:
		mob.find_target()
		if mob.player == null:
			return
		player_target = mob.player
		attack_timer = 0
		next_attack_time = rand_range(1.5, 2)
		var variants = attacks.duplicate()
		if not under_shield:
			variants.append("make_shield")
			variants.append("make_shield")
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
	var n = blackball.instance()
	n.global_position = $visual/body/arm_right/hand/weapon/shoot.global_position
	get_tree().current_scene.add_child(n, true)
	n.look_at(player_target.global_position)


func lightnings():
	ms.sync_call(self, "lightnings")
	next_attack_time += 2.5
	anim.play("lightnings")
	yield(get_tree().create_timer(0.5, false), "timeout")
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
	var pos = Vector2.ZERO
	if randi() % 2 == 1:
		pos = $"../pos0".global_position
		$"../pos0/sprite/anim".play("summon")
		ms.sync_call($"../pos0/sprite/anim", "play", ["summon"])
	else:
		pos = $"../pos1".global_position
		$"../pos1/sprite/anim".play("summon")
		ms.sync_call($"../pos1/sprite/anim", "play", ["summon"])
	var node = mob_shooter.instance()
	node.global_position = pos
	get_parent().add_child(node, true)
