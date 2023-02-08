extends Player
class_name Butcher

var gen
var _attack_visual
var _attack_shape
var _attack_empty_anim
var _ulti
var _ulti_use_effect
var _camera_tween
var is_active_gadget = false
var gadget_crack = load("res://prefabs/classes/butcher_gadget.scn")


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
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health
	$camera/gui/base/ulti_use/ulti_name.text = "УДАР " + G.RIM_NUMBERS[ulti_power]
	_attack_visual = $visual/body/knight_attack/visual
	_attack_shape = $visual/body/knight_attack/shape
	_camera_tween = $camera_tween
	_attack_visual.hide()
	_attack_shape.disabled = true
	_ulti = load("res://prefabs/classes/butcher_ulti.scn")
	_ulti_use_effect = load("res://prefabs/effects/super_use.scn")
	RECHARGE_SPEED = 1.1 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen = RandomNumberGenerator.new()
	gen.randomize()
	_attack_empty_anim = $camera/gui/base/hero_panel/strike_bar/anim
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
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health


func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 1, custom_immobility_time = 0.8, can_ignored = true):
	if is_reviving:
		return
	if defense_allowed:
		if damage - defense <= 0:
			return
	can_hurt = false
	if have_soul_power and MP.auth(self):
		var chance = gen.randi_range(0, 100)
		if chance < 21:
			ulti_percentage = clamp(ulti_percentage + 15, 0, 100)
	can_hurt = true
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
	can_use_potion = true


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
		node.global_position = global_position
		node.level = ulti_power
		node.power = power
		node.has_amulet = is_amulet(G.Amulet.POWER)
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
	node.modulate = Color.yellow
	node.global_position = Vector2(global_position.x + (sign(_body.scale.x) * 15), global_position.y - 35 * GRAVITY_SCALE)
	_level.add_child(node)


func _process(delta):
	if MP.auth(self):
		if Input.is_action_just_pressed("attack1"):
			attack()
		if Input.is_action_just_pressed("ulti"):
			ulti()
		if Input.is_action_just_pressed("gadget") and have_gadget:
			use_gadget()


func _physics_process(delta):
	if is_on_floor() and is_active_gadget:
		var node = gadget_crack.instance()
		var pos = Vector2(global_position.x, 0)
		pos.y = (round(global_position.y / 32) + 1 * GRAVITY_SCALE) * 32
		node.global_position = pos
		node.scale.y = GRAVITY_SCALE
		_level.add_child(node, true)
		is_active_gadget = false


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or not can_move or _is_drinking:
		return
	if not is_on_floor():
		return
	jump(375)
	.use_gadget()
	yield(get_tree().create_timer(0.25, false), "timeout")
	is_active_gadget = true
