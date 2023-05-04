extends Player
class_name MinigameHero

var current_armor = 100
var max_armor = 100
var coins = 0
var gen = RandomNumberGenerator.new()
var anima
var trck_idx0
var trck_idx1
var key_idx0
var key_idx1
var is_using_gadget = false
var bullet = load("res://minigames/minigame4/bullet.scn")
onready var joystick = $camera/gui/base/buttons/buttons_1/joystick
onready var aim_line = $aim_line
onready var _attack_visual = $visual/body/spear_attack/visual
onready var _attack_shape = $visual/body/spear_attack/shape
onready var _attack_node = $visual/body/spear_attack
onready var _armor_bar = $camera/gui/base/hero_panel/armor
onready var _armor_count = $camera/gui/base/hero_panel/armor_count
onready var _armor_indicator = $camera/gui/base/hero_panel/armor_indicator
onready var _armor_timer = $armor_timer
onready var _coins_count = $camera/gui/base/hero_panel/coins


func _ready():
	class_nam = "hero"
	anima = _anim.get_animation("attack_throw")
	trck_idx0 = anima.find_track(@"visual/body/arm_right:rotation_degrees")
	trck_idx1 = anima.find_track(@"visual/body/arm_left:rotation_degrees")
	key_idx0 = anima.track_find_key(trck_idx0, 0.2001)
	key_idx1 = anima.track_find_key(trck_idx1, 0.2001)
	max_health = 100
	defense = 5
	_attack_node.damage = 15
	current_health = max_health
	current_armor = max_armor
	_update_all_bars()
	$camera/gui/base/ulti_use/ulti_name.text = "АВИАУДАР"
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://minigames/minigame4/hero_ulti.scn")
	RECHARGE_SPEED = 1
	gen.randomize()
	have_soul_power = true
	have_gadget = true
	joystick.connect("released", self, "joystick_released")
	$control_indicator/sp.show()


func joystick_released(output):
	if output == Vector2.ZERO:
		attack()
	else:
		throw(output)


func attack():
	if is_hurt or is_stunned or _is_ultiing or _is_drinking or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	can_attack = false
	_is_attacking = true
	RECHARGE_SPEED = 0.8
	attack_cooldown = RECHARGE_SPEED + 0.4
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.2, false), "timeout")
	_attack_node.knockback = 2
	$visual/body/spear_attack/swing.play()
	_attack_visual.show()
	_attack_visual.playing = true
	yield(get_tree().create_timer(0.05, false), "timeout")
	_attack_shape.disabled = false
	yield(get_tree().create_timer(0.15, false), "timeout")
	_attack_visual.hide()
	_attack_node.modulate = Color.white
	_attack_visual.playing = false
	_attack_visual.frame = 0
	_attack_shape.disabled = true
	_is_attacking = false


func throw(direction):
	if is_hurt or is_stunned or _is_ultiing or _is_drinking or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	can_attack = false
	_is_attacking = true
	can_turn = false
	speed_cooficent = 0.5
	RECHARGE_SPEED = 1
	attack_cooldown = RECHARGE_SPEED + 0.55
	var phi = Vector2(direction.x, direction.y * GRAVITY_SCALE).angle()
	var hand_rotate = rad2deg(phi)
	var weapon_rotate = rad2deg(direction.angle())
	hand_rotate -= 90
	if hand_rotate < -180:
		hand_rotate = 360 + hand_rotate
	if hand_rotate < 0 and hand_rotate > -180:
		_body.scale.x = 1
	if hand_rotate > 0 and hand_rotate < 180:
		_body.scale.x = -1
		hand_rotate = -hand_rotate
	anima.track_set_key_value(trck_idx0, key_idx0, hand_rotate)
	anima.track_set_key_value(trck_idx1, key_idx1, hand_rotate)
	_anim_tree["parameters/throw_shot/active"] = true
	yield(get_tree().create_timer(0.2, false), "timeout")
	var node = bullet.instance()
	node.global_position = $visual/body/arm_right/hand/weapon/gun/main/bayok.global_position
	node.rotation_degrees = weapon_rotate
	if is_using_gadget:
		is_using_gadget = false
		node.modulate = Color.red
		node.collides = false
		node.get_node("attack").damage = _attack_node.damage * 4
	else:
		node.get_node("attack").damage = _attack_node.damage * 2
	_level.add_child(node, true)
	yield(get_tree().create_timer(0.2, false), "timeout")
	_is_attacking = false
	speed_cooficent = 1
	can_turn = true


func ulti():
	if ulti_percentage < 100 or is_hurt or is_stunned or _is_attacking or _is_drinking or not can_control:
		return
	ms.sync_call(self, "ulti")
	$skill_use_sfx.play()
	ulti_percentage = 0
	_health_timer = 0
	_is_ultiing = true
	_camera_tween.interpolate_property(camera, "zoom", default_camera_zoom, Vector2(0.6, 0.6), 0.3)
	_camera_tween.start()
	_ulti_tween.interpolate_property(_ulti_bar, "value", 100, 0, 0.5)
	_ulti_tween.start()
	_anim_tree["parameters/ulti_shot/active"] = true
	var node = _ulti.instance()
	node.get_node("rockets_attack").damage = _attack_node.damage * 5
	node.global_position = global_position
	_level.add_child(node, true)
	$camera/gui/base/ulti_use/anim.play("ulti_use")
	yield(get_tree().create_timer(0.8, false), "timeout")
	_is_ultiing = false
	yield(get_tree().create_timer(2, false), "timeout")
	_camera_tween.interpolate_property(camera, "zoom", Vector2(0.6, 0.6), default_camera_zoom, 0.3)
	_camera_tween.start()


func _process(delta):
	if Input.is_action_just_pressed("attack1"):
		attack()
	if Input.is_action_just_pressed("ulti"):
		ulti()
	if Input.is_action_just_pressed("gadget") and have_gadget:
		use_gadget()
	if joystick._output.length_squared() * current_health > 0:
		var phi = Vector2(joystick._output.x, joystick._output.y * sign(GRAVITY_SCALE)).angle()
		aim_line.rotation = phi
		aim_line.visible = true
		aim_line.modulate = Color.red if attack_cooldown > 0 else Color.white
	else:
		aim_line.visible = false
	if _armor_indicator.visible:
		_armor_indicator.value = 20 - _armor_timer.time_left


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or is_hurt or is_stunned or _is_attacking or _is_ultiing or not can_control:
		return
	.use_gadget()
	attack_cooldown = 0
	can_attack = true
	is_using_gadget = true


func revive(hp = -1):
	current_armor = max_armor
	_armor_timer.paused = false
	_armor_timer.stop()
	_update_all_bars()
	.revive(hp)


func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4):
	var past_health = current_health
	var past_armor = current_armor
	var real_defense = defense
	if not defense_allowed:
		real_defense = 0
	if current_armor <= 0:
		current_health = clamp(current_health - max(damage - real_defense, 0), 0, max_health)
		if current_health >= past_health:
			return
	else:
		current_armor = min(current_armor - max(damage - real_defense, 0), max_armor)
		if current_armor < 0:
			current_health = clamp(current_health + current_armor, 0, max_health)
			current_armor = 0
		if current_armor <= 0:
			_armor_indicator.show()
			_armor_timer.start()
		if current_armor >= past_armor:
			return
	if fatal:
		current_health = 0
		damage = max_health
	is_hurt = true
	hurt_counter += 1
	if stuns:
		stun(stun_time)
	_head.texture = _head_hurt_sprite
	_health_timer = 0
	_player_head.texture = _head_hurt_sprite
	if current_health <= 0:
		collision_layer = 0b0
		collision_mask = 0b1
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), true)
		$game_over_sfx.play()
		tint_anim.stop(true)
		tint_anim.play("dying")
		_buttons.hide()
		_soul.texture = _soul_break_sprite
		can_see = false
		_armor_timer.paused = true
	elif current_armor <= 0:
		tint_anim.stop(true)
		tint_anim.play("hurting")
	var node = _hurt_heal_text.instance()
	node.get_node("text").text = str(damage - real_defense)
	_level.add_child(node)
	node.global_position = global_position
	node.position += Vector2(randi() % 13 - 6, randi() % 13 - 6)
	node.global_scale = Vector2(0.5, 0.5)
	_update_all_bars()
	$hurt_sfx.play()
	_health_change_bar.value = past_health
	_tween.interpolate_property(_health_change_bar, "value", past_health, current_health, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT, 0.4)
	_tween.start()
	var died = false
	if current_health > 0:
		emit_signal("hurt")
		_knockback = KNOCKBACK_POWER * knockback_multiplier
		if abs(knockback_multiplier) > 0 and can_turn:
			_body.scale = Vector2(sign(-knockback_multiplier), 1)
		_anim_tree["parameters/hurt_shot/active"] = true
	else:
		emit_signal("died")
		died = true
		if abs(knockback_multiplier) > 0:
			_body.scale = Vector2(sign(-knockback_multiplier), 1)
		_visual.scale = _body.scale
		_visual_scale = _visual.scale
		_body.scale = Vector2(1, 1)
		_anim_tree["parameters/death_trans/current"] = AliveState.DEAD
		if has_node("fire_on_entity"):
			$fire_on_entity.queue_free()
	var time0 = 0
	var time1 = 0
	var difference = 0
	if current_health > 0:
		time0 = clamp(custom_immobility_time, 0, 0.1)
		time1 = max(custom_immobility_time - 0.1, 0)
		difference = max(custom_invincibility_time - custom_immobility_time - 0.05, 0)
	if time0 > 0:
		yield(get_tree().create_timer(time0, false), "timeout")
	_knockback = 0
	if time1 > 0:
		yield(get_tree().create_timer(time1, false), "timeout")
	if current_health > 0:
		is_hurt = false
	if difference > 0:
		yield(get_tree().create_timer(difference, false), "timeout")
	hurt_counter -= 1
	if current_health > 0 and not is_stunned and hurt_counter < 1:
		_head.texture = _head_sprite
	if died:
		yield(get_tree().create_timer(4, false), "timeout")
		if not camera.is_screen_on:
			camera.show_revive_screen()
	elif not is_stunned and hurt_counter < 1:
		_player_head.texture = _head_sprite


func add_max_health(amount):
	max_health += amount
	_update_all_bars()
	heal(amount)


func add_defense(amount):
	defense += amount


func add_armor(amount):
	max_armor += amount
	current_armor = max_armor
	_update_all_bars()


func add_coins(amount):
	coins += amount
	_coins_count.text = str(coins)


func _update_all_bars():
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.value = current_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_armor_bar.max_value = max_armor
	_armor_bar.value = current_armor
	_armor_count.text = str(current_armor) + "/" + str(max_armor)


func _on_armor_timer_timeout():
	current_armor = max_armor
	_update_all_bars()
	_armor_indicator.hide()
