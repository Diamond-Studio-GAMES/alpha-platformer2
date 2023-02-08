extends Player
class_name Spearman

var gen
var _attack_visual
var _attack_shape
var _attack_empty_anim
var _attack_node
var _ulti
var _ulti_use_effect
var _camera_tween
var is_active_gadget = false
var anima
var spear = load("res://prefabs/classes/spear.scn")
var gadget = load("res://prefabs/classes/spear_attack_gadget.scn")
onready var joystick = $camera/gui/base/buttons/buttons_1/joystick
onready var aim_line = $aim_line
var trck_idx
var key_idx0
var key_idx1


func _ready():
	class_nam = "spearman"
	anima = $anim.get_animation("attack_throw")
	trck_idx = anima.find_track(@"visual/body/arm_right:rotation_degrees")
	key_idx0 = anima.track_find_key(trck_idx, 0.2001)
	key_idx1 = anima.track_find_key(trck_idx, 0.70035)
	if MP.auth(self):
		amulet = G.getv(class_nam + "_amulet", -1)
	power = G.getv(class_nam + "_level", 0)
	ulti_power = G.getv(class_nam + "_ulti_level", 1)
	max_health = power * 20 + 100 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power * 1 + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/spear_attack.damage = power * 4 + 20  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	current_health = max_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health
	$camera/gui/base/ulti_use/ulti_name.text = "ОГЛУШЕНИЕ " + G.RIM_NUMBERS[ulti_power]
	_attack_visual = $visual/body/spear_attack/visual
	_attack_shape = $visual/body/spear_attack/shape
	_camera_tween = $camera_tween
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://prefabs/classes/spearman_ulti.scn")
	_ulti_use_effect = load("res://prefabs/effects/super_use.scn")
	_attack_node = $visual/body/spear_attack
	RECHARGE_SPEED = 0.8 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen = RandomNumberGenerator.new()
	gen.randomize()
	_attack_empty_anim = $camera/gui/base/hero_panel/strike_bar/anim
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
	$visual/body/spear_attack.damage = power * 4 + 20  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	RECHARGE_SPEED = 0.1
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health


func joystick_released(output):
	if output.x == 0 and output.y == 0:
		attack()
	else:
		throw(output)


func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 1, custom_immobility_time = 0.8, can_ignored = true):
	if is_reviving:
		return
	if defense_allowed:
		if damage - defense <= 0:
			return
	.hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, can_ignored)


func attack():
	if not can_move or _is_drinking:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "attack")
	can_attack = false
	can_use_potion = false
	if MP.auth(self):
		RECHARGE_SPEED = 0.8 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
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
	can_use_potion = true


func throw(direction):
	if not can_move or _is_drinking:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "throw", [direction])
	can_attack = false
	can_use_potion = false
	can_turn = false
	speed_cooficent = 0.5
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
	can_use_potion = true
	speed_cooficent = 1
	yield(get_tree(), "idle_frame")
	can_turn = true


func ulti():
	if ulti_percentage < 100 or not can_move or _is_drinking:
		return
	ms.sync_call(self, "ulti")
	$skill_use_sfx.play()
	ulti_percentage = 0
	_health_timer = 0
	_is_ultiing = true
	_camera_tween.interpolate_property($camera, "zoom", default_camera_zoom, Vector2(0.6, 0.6), 0.3)
	_camera_tween.start()
	_ulti_tween.interpolate_property(_ulti_bar, "value", 100, 0, 0.5)
	_ulti_tween.start()
	_anim_tree["parameters/ulti_shot/active"] = true
	if MP.auth(self):
		var node = _ulti.instance()
		node.has_amulet = is_amulet(G.Amulet.POWER)
		node.power = power
		node.level = ulti_power
		node.global_position = global_position
		_level.add_child(node, true)
	$camera/gui/base/ulti_use/anim.play("ulti_use")
	can_use_potion = false
	yield(get_tree().create_timer(0.8, false), "timeout")
	can_use_potion = true
	yield(get_tree().create_timer(1.7, false), "timeout")
	_camera_tween.interpolate_property($camera, "zoom", Vector2(0.6, 0.6), default_camera_zoom, 0.3)
	_camera_tween.start()
	_is_ultiing = false


func make_effect():
	var node = _ulti_use_effect.instance()
	node.modulate = Color.green
	node.global_position = Vector2(global_position.x + (sign(_body.scale.x) * 15), global_position.y - 35 * GRAVITY_SCALE)
	_level.add_child(node)


func _process(delta):
	if not MP.auth(self):
		return
	if Input.is_action_just_pressed("attack1"):
		attack()
	if Input.is_action_just_pressed("ulti"):
		ulti()
	if Input.is_action_just_pressed("gadget") and have_gadget:
		use_gadget()
	if joystick._output.length_squared() > 0 and current_health > 0:
		var phi = Vector2(joystick._output.x, joystick._output.y * GRAVITY_SCALE).angle()
		aim_line.rotation_degrees = rad2deg(phi)
		aim_line.visible = true
	else:
		aim_line.visible = false
	if aim_line.visible:
		if attack_cooldown > 0:
			aim_line.modulate = Color.red
		else:
			aim_line.modulate = Color.white


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or not can_hurt or not can_move or _is_drinking or _anim.current_animation == "attack" or _anim.current_animation == "attack_throw":
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
