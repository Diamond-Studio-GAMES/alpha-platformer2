extends Boss


var phases_attacks = {
	1 : ["laser", "bullets"],
	2 : ["laser", "bullets", "super_floor", "tnt"],
	3 : ["laser", "bullets", "super_floor", "tnt"]
}
var defeat_phrases = [
	tr("9_10.boss.death.0"),
	tr("9_10.boss.death.1"),
	tr("9_10.boss.death.2"),
	tr("9_10.boss.death.3")
]
var face_defeated = load("res://textures/bosses/maxim/head_defeat.tres")
var face_mercy = load("res://textures/bosses/maxim/head_mercy.tres")
onready var break_on_death = {
	$visual/body/controller : load("res://textures/bosses/maxim/controller_broken.tres"),
}
var is_time_faster = false
onready var timer = $timer


func _ready():
	mob = $mob_mx
	fill_x = 53
	fill_height = 32
	tp_pos = Vector2(54, -2)
	mercy_dialog = tr("boss.follower2.mercy")
	death_dialog = tr("boss.follower2.defeat")
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.follower2").to_upper() + ":"
	player.connect("died", self, "death_dialog")


func death_dialog():
	player.make_dialog(defeat_phrases.pick_random(), 3, Color.red)


func death():
	G.ach.complete(Achievements.BOSS9)
	$visual/body/head.texture = face_defeated
	for i in break_on_death:
		i.texture = break_on_death[i]
	.death()


func mercy():
	$visual/body/head.texture = face_mercy
	.mercy()


func get_phase():
	if not is_mob_alive():
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
	elif health_left < 0.3:
		next_attack_time_min = 0.8
		next_attack_time_max = 1.6
		return 3
	elif health_left < 0.6:
		next_attack_time_min = 0.9
		next_attack_time_max = 1.8
		return 2
	next_attack_time_min = 1
	next_attack_time_max = 2
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	if global_position.distance_squared_to(player_target.global_position) < 6400:
		if randi() % 2 == 0:
			melee()
			return
	if phase > 2:
		var new_variants = phases_attacks[phase].duplicate()
		if not is_time_faster:
			new_variants.append("time_fast")
		new_variants.shuffle()
		call(new_variants[0])
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func laser():
	pass


func super_floor():
	pass


func bullets():
	pass


func tnt():
	pass


func melee():
	pass


func time_fast():
	pass
