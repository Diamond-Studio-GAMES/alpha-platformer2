extends Boss


var phases_attacks = {
	1 : ["balls", "big_ball"],
	2 : ["balls", "big_ball", "circle_balls"],
	3 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls"],
	4 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls", "time_erase"]
}
var defeat_phrases = [tr("8_10.boss.death.0"), tr("8_10.boss.death.1"), tr("8_10.boss.death.2")]
var face_defeated = load("res://textures/bosses/egor/head_defeat.tres")
var face_mercy = load("res://textures/bosses/egor/head_mercy.tres")
onready var timer = $timer


func _ready():
	mob = $mob_eg
	fill_x = 54
	fill_height = 16
	tp_pos = Vector2(55, -2)
	mercy_dialog = tr("boss.follower1.mercy")
	death_dialog = tr("boss.follower1.defeat")
	next_attack_time_min = 1
	next_attack_time_max = 2
	if MP.is_active:
		yield($"/root/mg", "game_started")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	boss_bar.get_node("boss_name").text = tr("boss.follower1").to_upper() + ":"
	player.connect("died", self, "death_dialog")


func night():
	get_tree().current_scene.get_node("background_first").hide()
	get_tree().current_scene.get_node("background").show()
	get_tree().current_scene.get_node("dark").show()


func death_dialog():
	player.make_dialog(defeat_phrases.pick_random(), 3, Color.cyan)


func death():
	G.ach.complete(Achievements.BOSS8)
	$visual/body/head.texture = face_defeated
	.death()


func mercy():
	$visual/body/head.texture = face_mercy
	.mercy()


func get_phase():
	if not is_instance_valid(mob):
		return -1
	var health_left = mob.current_health / mob.max_health
	if health_left <= 0:
		return -1
	if health_left < 0.25:
		return 4
	elif health_left < 0.5:
		return 3
	elif health_left < 0.25:
		return 2
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func balls():
	pass


func big_ball():
	pass


func circle_balls():
	pass


func floor_attack():
	pass


func up_balls():
	pass


func time_erase():
	pass
