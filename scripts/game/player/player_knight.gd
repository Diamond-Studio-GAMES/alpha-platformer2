extends Player
class_name Knight

var gen = RandomNumberGenerator.new()
var is_active_gadget = false
onready var _attack_node = $visual/body/knight_attack
onready var _attack_visual = $visual/body/knight_attack/visual
onready var _attack_shape = $visual/body/knight_attack/shape

func _ready():
	class_nam = "knight"
	if MP.auth(self):
		amulet = G.getv(class_nam + "_amulet", -1)
	power = G.getv(class_nam + "_level", 0)
	ulti_power = G.getv(class_nam + "_ulti_level", 1)
	max_health = power * 20 + 100 + (60 if is_amulet(G.Amulet.HEALTH) else 0)
	defense = power + 5 + (5 if is_amulet(G.Amulet.DEFENSE) else 0)
	$visual/body/knight_attack.damage = power * 5 + 25  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	_ulti = load("res://prefabs/classes/knight_ulti.tscn")
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	$camera/gui/base/ulti_use/ulti_name.text = tr(G.ULTIS[class_nam]) + " " + G.RIM_NUMBERS[ulti_power]
	_attack_visual.hide()
	_attack_shape.disabled = true
	RECHARGE_SPEED = 0.75 * (0.8 if is_amulet(G.Amulet.RELOAD) else 1)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	gen.randomize()
	have_soul_power = G.getv("knight_soul_power", false)
	have_gadget = G.getv("knight_gadget", false)
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
	$visual/body/knight_attack.damage = power * 5 + 25  + (15 if  is_amulet(G.Amulet.POWER) else 0)
	SPEED += (7 if is_amulet(G.Amulet.SPEED) else 0)
	RECHARGE_SPEED = 0.1
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()


func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4, damage_source = "env"):
	if is_reviving:
		return false
	if defense_allowed and damage - defense <= 0:
		return false
	if not defense_allowed or fatal:
		return .hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, damage_source)
	if MP.auth(self):
		if have_soul_power:
			var chance = gen.randi_range(0, 100)
			if chance < 21:
				miss(knockback_multiplier)
				return false
		if is_active_gadget:
			miss(knockback_multiplier)
			return false
	return .hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, damage_source)


func miss(knockback_multiplier):
	ms.sync_call(self, "miss", [knockback_multiplier])
	if MP.auth(self):
		G.ach.complete(Achievements.YOU_MISSED)
	is_hurt = true
	_anim_tree["parameters/miss_shot/active"] = true
	var node = _hurt_heal_text.instance()
	node.position = position
	node.get_node("text").text = tr("miss.miss")
	node.get_node("text").modulate = Color.gray
	_level.add_child(node)
	_knockback = KNOCKBACK_POWER * clamp(sign(knockback_multiplier) * 2 + 1, -1, 1) 
	if abs(knockback_multiplier) > 0:
		_body.scale = Vector2(-sign(knockback_multiplier), 1)
	yield(get_tree().create_timer(0.3, false), "timeout")
	_knockback = 0
	yield(get_tree().create_timer(0.2, false), "timeout")
	is_hurt = false


func attack(fatal = false):
	if is_hurt or is_stunned or _is_drinking or _is_ultiing or not can_control:
		return
	if not can_attack:
		_attack_empty_anim.play("empty")
		return
	if hate_refuse():
		return
	if MP.auth(self):
		fatal = hate_fatal()
	ms.sync_call(self, "attack", [fatal])
	can_attack = false
	_is_attacking = true
	attack_cooldown = RECHARGE_SPEED + 0.6
	_anim_tree["parameters/attack_seek/seek_position"] = 0
	_anim_tree["parameters/attack_shot/active"] = true
	yield(get_tree().create_timer(0.35, false), "timeout")
	$visual/body/knight_attack/swing.play()
	_attack_node.fatal = fatal
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


func use_gadget():
	if is_hurt:
		return
	var success = .use_gadget()
	if not success:
		return
	is_active_gadget = true
	$gadget_active.emitting = true
	yield(get_tree().create_timer(2, false), "timeout")
	is_active_gadget = false
	$gadget_active.emitting = false
