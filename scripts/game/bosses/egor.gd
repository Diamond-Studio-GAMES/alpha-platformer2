extends Boss


var phases_attacks = {
	1 : ["balls", "big_ball", "floor_attack"],
	2 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls"],
	3 : ["balls", "big_ball", "circle_balls", "floor_attack", "up_balls", "time_erase"]
}
var defeat_phrases = [tr("8_10.boss.death.0"), tr("8_10.boss.death.1"), tr("8_10.boss.death.2")]
var face_defeated = load("res://textures/bosses/egor/head_defeat.tres")
var face_mercy = load("res://textures/bosses/egor/head_mercy.tres")
var ball = load("res://prefabs/bosses/whiteball.tscn")
var big_ball = load("res://prefabs/bosses/big_whiteball.tscn")
onready var timer = $timer
onready var pos0 = $pos0.global_position
onready var pos1 = $pos1.global_position
onready var pos2 = $pos2.global_position


func _ready():
	mob = $mob_eg
	fill_x = 54
	fill_height = 16
	tp_pos = Vector2(55, -2)
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
	elif health_left < 0.33:
		return 3
	elif health_left < 0.67:
		return 2
	return 1


func do_attack():
	var phase = get_phase()
	if phase < 0:
		return
	phases_attacks[phase].shuffle()
	call(phases_attacks[phase][0])


func balls():
	next_attack_time += 1
	ms.sync_call(self, "balls")
	anim.play("balls")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.6, false), "timeout")
	if can_mob_move():
		_create_ball_at(pos2)
	yield(get_tree().create_timer(0.1, false), "timeout")
	if can_mob_move():
		_create_ball_at(pos0)
	yield(get_tree().create_timer(0.1, false), "timeout")
	if can_mob_move():
		_create_ball_at(pos1)


func _create_ball_at(pos):
	var n = ball.instance()
	n.global_position = pos
	n.rotation = pos.direction_to(player_target.global_position).angle() + rand_range(-0.314, 0.314)
	get_parent().add_child(n, true)


func big_ball():
	next_attack_time += 0.8
	ms.sync_call(self, "ball")
	anim.play("ball")
	if not MP.auth(self):
		return
	yield(get_tree().create_timer(0.3, false), "timeout")
	if not can_mob_move():
		return
	var n = big_ball.instance()
	n.global_position = pos1
	n.target = player_target
	get_parent().add_child(n, true)


func circle_balls():
	pass


func floor_attack():
	pass


func up_balls():
	pass


func time_erase():
	pass
