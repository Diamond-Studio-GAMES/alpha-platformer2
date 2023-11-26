extends Player
class_name Archer

var gen = RandomNumberGenerator.new()
var anima
var trck_idx0
var trck_idx1
var key_idx0_0
var key_idx0_1
var key_idx1_1
var key_idx2_1
var is_aiming = false
var aim_time = 0
var jout = Vector2()
var cjo = Vector2()
var gadget_attack = load("res://prefabs/classes/arrows.tscn")
var arrow = load("res://prefabs/classes/arrow.tscn")
onready var joystick = $camera/gui/base/buttons/buttons_1/joystick
onready var aim_line = $aim_line
onready var _attack_visual = $visual/body/knight_attack/visual
onready var _attack_shape = $visual/body/knight_attack/shape
onready var _aim_tween = $aim_tween


func _ready():
	class_nam = "archer"
	anima = $anim.get_animation("aiming")
	trck_idx0 = anima.find_track(@"visual/body/arm_right:rotation_degrees")
	trck_idx1 = anima.find_track(@"visual/body/arm_left:rotation_degrees")
	key_idx0_0 = anima.track_find_key(trck_idx0, 0.45)
	key_idx0_1 = anima.track_find_key(trck_idx1, 0.45)
	key_idx1_1 = anima.track_find_key(trck_idx1, 0.55)
	key_idx2_1 = anima.track_find_key(trck_idx1, 0.85)
	if MP.auth(self):
		amulet = G.getv(class_nam + "_amulet", -1)
	power = G.getv(class_nam + "_level", 0)
	ulti_power = G.getv(class_nam + "_ulti_level", 1)
	max_health = power * 20 + 100 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 2 + 10  + (15 if  is_amulet(G.Amulet.POWER) else 0)/3
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	$camera/gui/base/ulti_use/ulti_name.text = tr(G.ULTIS[class_nam]) + " " + G.RIM_NUMBERS[ulti_power]
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://prefabs/classes/archer_ulti.tscn")
	RECHARGE_SPEED = 1.1 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen.randomize()
	have_soul_power = G.getv("archer_soul_power", false)
	have_gadget = G.getv("archer_gadget", false)
	joystick.connect("released", self, "joystick_released")
	if have_soul_power and MP.auth(self):
		$visual/body/knight_attack.connect("hit_enemy", self, "sp_effect")
	if not have_gadget:
		$camera/gui/base/buttons/buttons_0/gadget.hide()
	if MP.auth(self):
		if have_soul_power:
			$control_indicator/sp.show()
		else:
			$control_indicator/standard.show()


func apply_data(data):
	.apply_data(data)
	max_health = power * 20 + 100 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 2 + 10  + (15 if  is_amulet(G.Amulet.POWER) else 0)/3
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	RECHARGE_SPEED = 0.1
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()


func ulti():
	if is_aiming:
		return
	.ulti()


func joystick_released(output):
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "joystick_released", [output])
	var aimed = aim_time
	reset_aim()
	if output == Vector2.ZERO:
		if OS.has_feature("pc"):
			return
		if MP.auth(self):
			attack()
	else:
		throw(output, aimed)


func reset_aim():
	jout = Vector2.ZERO
	if is_aiming:
		speed_cooficent /= 0.5
		can_turn = true
		is_aiming = false
		_anim_tree["parameters/aim_ts/scale"] = -1 if aim_time < 0.55 else 1
		_anim_tree["parameters/aim_seek/seek_position"] = aim_time if aim_time < 0.55 else 2
		aim_time = 0
		_aim_tween.stop_all()
		_aim_tween.remove_all()
		_aim_tween.interpolate_property(_anim_tree, "parameters/aim_blend/blend_amount", _anim_tree["parameters/aim_blend/blend_amount"], 0, 0.3)
		_aim_tween.start()


func sp_effect(remote_call = false):
	if gen.randi_range(0, 100) > 55 or remote_call:
		$knockback/anim.play("def")
		ms.sync_call(self, "sp_effect", [true])


func attack():
	if is_hurt or is_stunned or _is_ultiing or _is_drinking or is_aiming or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "attack")
	can_attack = false
	_is_attacking = true
	if MP.auth(self):
		RECHARGE_SPEED = 1.3 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	attack_cooldown = RECHARGE_SPEED + 0.517
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.267, false), "timeout")
	$visual/body/knight_attack/swing.play()
	_attack_visual.show()
	_attack_visual.playing = true
	_attack_shape.disabled = false
	yield(get_tree().create_timer(0.25, false), "timeout")
	_attack_visual.hide()
	_attack_visual.self_modulate = Color.white
	_attack_visual.playing = false
	_attack_visual.frame = 0
	_attack_shape.disabled = true
	_is_attacking = false


func calc_hand_rotate(direction):
	var hand_rotate = Vector2(direction.x, direction.y * GRAVITY_SCALE).angle()
	var weapon_rotate = direction.angle()
	hand_rotate -= PI / 2
	if hand_rotate < -PI:
		hand_rotate = TAU + hand_rotate
	if hand_rotate < 0 and hand_rotate > -PI:
		_body.scale.x = 1
	if hand_rotate > 0 and hand_rotate < PI:
		_body.scale.x = -1
		hand_rotate = -hand_rotate
	return [hand_rotate, weapon_rotate]


func throw(direction, aimed_time):
	if is_hurt or is_stunned or _is_attacking or _is_drinking or _is_ultiing or not can_control:
		return
	if aimed_time < 0.55:
		attack_cooldown = RECHARGE_SPEED / 2
		can_attack = false
		return
	can_attack = false
	if MP.auth(self):
		RECHARGE_SPEED = 1.1 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	attack_cooldown = RECHARGE_SPEED + 0.25
	var rotates = calc_hand_rotate(direction)
	$visual/body/arm_right/hand/weapon/sfx2.play()
	if MP.auth(self):
		var node = arrow.instance()
		if aimed_time >= 0.55 and aimed_time < 0.85:
			node.SPEED = 150.0
			node.get_node("attack").damage = power * 3 + 15  + (15 if  is_amulet(G.Amulet.POWER) else 0)/3
		else:
			node.SPEED = 225.0
			node.get_node("attack").damage = G.getv("archer_level", 0) * 7 + 35  + (15 if  is_amulet(G.Amulet.POWER) else 0)
		node.global_position = Vector2(global_position.x, global_position.y - 10.5 * GRAVITY_SCALE)
		node.rotation = rotates[1]
		_level.add_child(node, true)


func use_potion(level):
	if is_aiming:
		return
	.use_potion(level)


func _process(delta):
	if MP.auth(self):
		if Input.is_action_just_pressed("attack1"):
			attack()
		if Input.is_action_just_pressed("ulti"):
			ulti()
		if Input.is_action_just_pressed("gadget") and have_gadget:
			use_gadget()
		if joystick._output.length_squared() * current_health > 0:
			aim_line.rotation = Vector2(joystick._output.x, joystick._output.y * GRAVITY_SCALE).angle()
			aim_line.visible = true
			aim_line.modulate = Color.red if attack_cooldown > 0 else Color.white
		else:
			aim_line.visible = false
	if not is_hurt and not is_stunned and not _is_drinking and not _is_ultiing and can_attack and can_control:
		if MP.auth(self):
			jout = joystick._output
		if cjo != jout and jout.length_squared() > 0:
			if not is_zero_approx(_anim_tree["parameters/aim_blend/blend_amount"]) and not is_aiming:
				_aim_tween.stop_all()
				_aim_tween.remove_all()
				_anim_tree["parameters/aim_blend/blend_amount"] = 0
			is_aiming = true
			can_turn = false
			if is_zero_approx(_anim_tree["parameters/aim_blend/blend_amount"]):
				speed_cooficent *= 0.5
				_anim_tree["parameters/aim_ts/scale"] = 1
				_anim_tree["parameters/aim_seek/seek_position"] = 0
				_aim_tween.stop_all()
				_aim_tween.remove_all()
				_aim_tween.interpolate_property(_anim_tree, "parameters/aim_blend/blend_amount", _anim_tree["parameters/aim_blend/blend_amount"], 1, 0.3)
				_aim_tween.start()
			cjo = jout
			var hand_rotate = rad2deg(calc_hand_rotate(jout)[0])
			anima.track_set_key_value(trck_idx0, key_idx0_0, hand_rotate)
			anima.track_set_key_value(trck_idx1, key_idx0_1, hand_rotate + 30)
			anima.track_set_key_value(trck_idx1, key_idx1_1, hand_rotate + 60)
			anima.track_set_key_value(trck_idx1, key_idx2_1, hand_rotate + 80)
		if is_aiming:
			aim_time += delta
			_health_timer = 0
			if aim_time >= 1.1:
				_anim_tree["parameters/aim_ts/scale"] = 0
	if jout.length_squared() <= 0 and is_aiming:
		reset_aim()


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or not can_control:
		return
	.use_gadget()
	var node = gadget_attack.instance()
	node.global_position = global_position + Vector2.UP * 150
	_level.add_child(node)

