extends Player
class_name Spearman

var gen = RandomNumberGenerator.new()
var anima
var trck_idx
var key_idx0
var key_idx1
var spear = load("res://prefabs/classes/spear.tscn")
var gadget = load("res://prefabs/classes/spear_attack_gadget.tscn")
onready var joystick = $camera/gui/base/buttons/buttons_1/joystick
onready var aim_line = $aim_line
onready var _attack_visual = $visual/body/spear_attack/visual
onready var _attack_shape = $visual/body/spear_attack/shape
onready var _attack_node = $visual/body/spear_attack


func _ready():
	class_nam = "spearman"
	anima = _anim.get_animation("attack_throw")
	trck_idx = anima.find_track(@"visual/body/arm_right:rotation_degrees")
	key_idx0 = anima.track_find_key(trck_idx, 0.2001)
	key_idx1 = anima.track_find_key(trck_idx, 0.70035)
	if MP.auth(self):
		amulet = G.getv(class_nam + "_amulet", -1)
	power = G.getv(class_nam + "_level", 0)
	ulti_power = G.getv(class_nam + "_ulti_level", 1)
	max_health = power * 20 + 100 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power * 1 + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	_attack_node.damage = power * 4 + 20  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	$camera/gui/base/ulti_use/ulti_name.text = tr(G.ULTIS[class_nam]) + " " + G.RIM_NUMBERS[ulti_power]
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://prefabs/classes/spearman_ulti.tscn")
	RECHARGE_SPEED = 0.75 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen.randomize()
	have_soul_power = G.getv("spearman_soul_power", false)
	have_gadget = G.getv("spearman_gadget", false)
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
	max_health = power * 20 + 100 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	_attack_node.damage = power * 4 + 20  + (15 if  is_amulet(G.Amulet.POWER) else 0)
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
	_is_attacking = true
	if MP.auth(self):
		RECHARGE_SPEED = 0.75 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	attack_cooldown = RECHARGE_SPEED + 0.4
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.2, false), "timeout")
	if have_soul_power and gen.randi_range(0, 100) > 80 and MP.auth(self):
		_attack_node.stuns = true
		_attack_node.modulate = Color.palegreen
	$visual/body/spear_attack/swing.play()
	_attack_visual.show()
	_attack_visual.playing = true
	yield(get_tree().create_timer(0.05, false), "timeout")
	_attack_shape.disabled = false
	yield(get_tree().create_timer(0.15, false), "timeout")
	_attack_node.stuns = false
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
	ms.sync_call(self, "throw", [direction])
	can_attack = false
	_is_attacking = true
	can_turn = false
	speed_cooficent *= 0.5
	if MP.auth(self):
		RECHARGE_SPEED = 1.7 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	attack_cooldown = RECHARGE_SPEED + 0.9
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
	anima.track_set_key_value(trck_idx, key_idx0, hand_rotate)
	anima.track_set_key_value(trck_idx, key_idx1, hand_rotate)
	_anim_tree["parameters/throw_shot/active"] = true
	yield(get_tree().create_timer(0.6, false), "timeout")
	$visual/body/spear_attack/swing.play()
	if MP.auth(self):
		var node = spear.instance()
		node.global_position = Vector2(global_position.x, global_position.y - 12 * GRAVITY_SCALE)
		node.rotation_degrees = weapon_rotate
		node.get_node("attack").damage = G.getv("spearman_level", 0) * 4 + 20  + (15 if  is_amulet(G.Amulet.POWER) else 0)
		_level.add_child(node, true)
	_is_attacking = false
	speed_cooficent /= 0.5
	yield(get_tree(), "idle_frame")
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
		var phi = Vector2(joystick._output.x, joystick._output.y * sign(GRAVITY_SCALE)).angle()
		aim_line.rotation = phi
		aim_line.visible = true
		aim_line.modulate = Color.red if attack_cooldown > 0 else Color.white
	else:
		aim_line.visible = false


func revive(hpc = -1):
	_anim_tree["parameters/throw_shot/active"] = false
	.revive(hpc)


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or is_hurt or is_stunned or _is_attacking or _is_ultiing or not can_control:
		return
	.use_gadget()
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.267, false), "timeout")
	var node = gadget.instance()
	node.global_position = global_position + Vector2.DOWN * 4 * GRAVITY_SCALE
	if _body.scale.x < 0:
		node.scale = Vector2(-1.75, 1.75)
	node.get_node("visual").playing = true
	_level.add_child(node)
