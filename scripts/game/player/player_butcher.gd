extends Player
class_name Butcher

var gen = RandomNumberGenerator.new()
var is_active_gadget = false
var gadget_crack = load("res://prefabs/classes/butcher_gadget.scn")
onready var _attack_visual = $visual/body/knight_attack/visual
onready var _attack_shape = $visual/body/knight_attack/shape


func _ready():
	class_nam = "butcher"
	if MP.auth(self):
		amulet = G.getv(class_nam + "_amulet", -1)
	power = G.getv(class_nam + "_level", 0)
	ulti_power = G.getv(class_nam + "_ulti_level", 1)
	max_health = power * 24 + 120 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = 0 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 6 + 30  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	$camera/gui/base/ulti_use/ulti_name.text = "УДАР " + G.RIM_NUMBERS[ulti_power]
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://prefabs/classes/butcher_ulti.scn")
	RECHARGE_SPEED = 1.1 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen.randomize()
	have_soul_power = G.getv("butcher_soul_power", false)
	have_gadget = G.getv("butcher_gadget", false)
	if not have_gadget:
		$camera/gui/base/buttons/buttons_0/gadget.hide()
	if MP.auth(self):
		if have_soul_power:
			$control_indicator/sp.show()
		else:
			$control_indicator/standard.show()


func apply_data(data):
	.apply_data(data)
	max_health = power * 24 + 120 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense =0 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 6 + 30  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	RECHARGE_SPEED = 0.1
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()


func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 1, custom_immobility_time = 0.8):
	if is_reviving:
		return
	if defense_allowed:
		if damage - defense <= 0:
			return
	if have_soul_power and MP.auth(self):
		var chance = gen.randi_range(0, 100)
		if chance < 21:
			ulti_percentage = clamp(ulti_percentage + 15, 0, 100)
	.hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time)


func attack():
	if is_hurt or is_stunned or _is_ultiing or _is_drinking or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	ms.sync_call(self, "attack")
	can_attack = false
	_is_attacking = true
	attack_cooldown = RECHARGE_SPEED + 0.6
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.35, false), "timeout")
	$visual/body/knight_attack/swing.play()
	_attack_visual.show()
	_attack_visual.playing = true
	_attack_shape.disabled = false
	yield(get_tree().create_timer(0.25, false), "timeout")
	_attack_visual.hide()
	_attack_visual.playing = false
	_attack_visual.frame = 0
	_attack_shape.disabled = true
	_is_attacking = false


func _process(delta):
	if MP.auth(self):
		if Input.is_action_just_pressed("attack1"):
			attack()
		if Input.is_action_just_pressed("ulti"):
			ulti()
		if Input.is_action_just_pressed("gadget") and have_gadget:
			use_gadget()


func _unhandled_input(event):
	if not MP.auth(self):
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			attack()


func _physics_process(delta):
	if is_on_floor() and is_active_gadget:
		var node = gadget_crack.instance()
		var pos = Vector2(global_position.x, 0)
		pos.y = (round(global_position.y / 32) + 1 * sign(GRAVITY_SCALE)) * 32
		node.global_position = pos
		node.scale.y = GRAVITY_SCALE
		_level.add_child(node, true)
		is_active_gadget = false


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or is_stunned or is_hurt or _is_drinking or not is_on_floor() or not can_control:
		return
	jump(375)
	.use_gadget()
	yield(get_tree().create_timer(0.25, false), "timeout")
	is_active_gadget = true
