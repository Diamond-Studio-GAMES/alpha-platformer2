extends Boss


var phases_attacks = {
	1 : ["balls", "big_ball", "floor_attack"],
	2 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls"],
	3 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls"]
}
var defeat_phrases = [tr("8_10.boss.death.0"), tr("8_10.boss.death.1"), tr("8_10.boss.death.2")]
onready var timer = $timer


func _ready():
	mob = $mob_gl
	mercy_dialog = tr("boss.follower1.mercy")
	death_dialog = tr("boss.follower1.defeat")
	next_attack_time_min = 0.8
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.follower1").to_upper() + ":"
	player.connect("died", self, "death_dialog")


func death_dialog():
	player.make_dialog(defeat_phrases.pick_random(), 3, Color.red)


func death():
	G.ach.complete(Achievements.BOSS10)
	.death()


func get_phase():
	if not is_mob_alive():
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
	elif health_left < 0.33:
		next_attack_time_min = 0.65
		next_attack_time_max = 1.5
		return 3
	elif health_left < 0.67:
		next_attack_time_min = 0.8
		next_attack_time_max = 1.8
		return 2
	next_attack_time_min = 1
	next_attack_time_max = 2
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])
