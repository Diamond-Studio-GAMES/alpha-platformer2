extends Player
class_name Wizard

var gen = RandomNumberGenerator.new()
var anima
var trck_idx
var key_idx0
var key_idx1
var wizard_attack = load("res://prefabs/classes/wizard_attack.tscn")
onready var _attack_visual = $visual/body/knight_attack/visual
onready var _attack_shape = $visual/body/knight_attack/shape
onready var joystick = $camera/gui/base/buttons/buttons_1/joystick
onready var aim_line = $aim_line


func _ready():
	class_nam = "wizard"
	anima = _anim.get_animation("attack_throw")
	trck_idx = anima.find_track(@"visual/body/arm_right:rotation_degrees")
	key_idx0 = anima.track_find_key(trck_idx, 0.2001)
	key_idx1 = anima.track_find_key(trck_idx, 0.4002)
	if MP.auth(self):
		amulet = G.getv(class_nam + "_amulet", -1)
	ulti_amulet = G.Amulet.HEALTH
	power = G.getv(class_nam + "_level", 0)
	ulti_power = G.getv(class_nam + "_ulti_level", 1)
	max_health = power * 16 + 80 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 2 + 10  + (15 if  is_amulet(G.Amulet.POWER) else 0)/3
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	$camera/gui/base/ulti_use/ulti_name.text = tr(G.ULTIS[class_nam]) + " " + G.RIM_NUMBERS[ulti_power]
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://prefabs/classes/wizard_ulti.tscn")
	RECHARGE_SPEED = 1.4 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen.randomize()
	have_soul_power = G.getv("wizard_soul_power", false)
	have_gadget = G.getv("wizard_gadget", false)
	joystick.connect("released", self, "joystick_released")
	if not have_gadget:
		$camera/gui/base/buttons/buttons_0/gadget.hide()
	if MP.auth(self):
		if have_soul_power:
			$control_indicator/sp.show()
		else:
			$control_indicator/standard.show()


func apply_data(data):
	.apply_data(data)
	max_health = power * 16 + 80 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 2 + 10  + (15 if  is_amulet(G.Amulet.POWER) else 0)/3
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	RECHARGE_SPEED = 0.1
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()


func joystick_released(output):
	if output == Vector2.ZERO:
		if OS.has_feature("pc"):
			return
		attack()
	else:
		throw(output)


func attack():
	if is_hurt or is_stunned or _is_ultiing or _is_drinking or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "attack")
	can_attack = false
	if MP.auth(self):
		RECHARGE_SPEED = 1.8 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	_is_attacking = true
	attack_cooldown = RECHARGE_SPEED + 0.525
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.275, false), "timeout")
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


func throw(direction):
	if is_hurt or is_stunned or _is_ultiing or _is_drinking or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "throw", [direction])
	can_attack = false
	_is_attacking = true
	speed_cooficent *= 0.5
	if MP.auth(self):
		RECHARGE_SPEED = 1.6 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	can_turn = false
	attack_cooldown = RECHARGE_SPEED + 0.5
	var hand_rotate = Vector2(direction.x, direction.y * GRAVITY_SCALE).angle()
	hand_rotate -= PI / 2
	if hand_rotate < -PI:
		hand_rotate = TAU + hand_rotate
	if hand_rotate < 0 and hand_rotate > -PI:
		_body.scale.x = 1
	if hand_rotate > 0 and hand_rotate < PI:
		_body.scale.x = -1
		hand_rotate = -hand_rotate
	hand_rotate = rad2deg(hand_rotate)
	anima.track_set_key_value(trck_idx, key_idx0, hand_rotate)
	anima.track_set_key_value(trck_idx, key_idx1, hand_rotate)
	_anim_tree["parameters/throw_shot/active"] = true
	yield(get_tree().create_timer(0.267, false), "timeout")
	$visual/body/arm_right/hand/weapon/sfx.play()
	$visual/body/arm_right/hand/weapon/effect.restart()
	if MP.auth(self):
		var node = wizard_attack.instance()
		node.global_position = Vector2(global_position.x, global_position.y - 12 * GRAVITY_SCALE)
		node.rotation = direction.angle()
		var heals = gen.randi_range(0, 100) > 85 and have_soul_power
		node.get_node("attack").damage = G.getv("wizard_level", 0) * 6 + 30  + (15 if  is_amulet(G.Amulet.POWER) else 0)
		if heals:
			node.get_node("attack").connect("hit_enemy", self, "heal", [round(max_health * 0.1)])
		_level.add_child(node, true)
	yield(get_tree().create_timer(0.167, false), "timeout")
	_is_attacking = false
	speed_cooficent /= 0.5
	can_turn = true


func _process(delta):
	if not MP.auth(self):
		return
	if Input.is_action_just_pressed("attack1"):
		attack()
	if Input.is_action_just_pressed("ulti"):
		ulti()
	if Input.is_action_just_pressed("gadget") and have_gadget:
		use_gadget()
	if joystick._output.length_squared() * current_health > 0:
		var phi = Vector2(joystick._output.x, joystick._output.y * GRAVITY_SCALE).angle()
		aim_line.rotation = phi
		aim_line.visible = true
		aim_line.modulate = Color.red if attack_cooldown > 0 else Color.white
	else:
		aim_line.visible = false


func revive(hpc = -1):
	_anim_tree["parameters/throw_shot/active"] = false
	.revive(hpc)


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or not can_control:
		return
	if ulti_percentage >= 100:
		return
	.use_gadget()
	ulti_percentage = clamp(ulti_percentage + 40, 0, 100)
