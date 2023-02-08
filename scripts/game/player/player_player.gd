extends Player
class_name PlayerPlayer

var gen
var _attack_empty_anim
var _ulti
var _ulti_use_effect
var _camera_tween
var is_active_gadget = false
onready var attack_sprite0 = $visual/body/attack0/sprite
onready var attack_shape0 = $visual/body/attack0/shape
onready var attack_sprite1 = $visual/body/attack1/sprite
onready var attack_shape1 = $visual/body/attack1/shape


func _ready():
	max_health = 75
	defense = 0
	current_health = max_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health
	$camera/gui/base/ulti_use/ulti_name.text = "КРИК"
	_camera_tween = $camera_tween
	RECHARGE_SPEED = 0.65
	gen = RandomNumberGenerator.new()
	gen.randomize()
	_attack_empty_anim = $camera/gui/base/hero_panel/strike_bar/anim
	have_soul_power = false
	have_gadget = false
	$camera/gui/base/buttons/buttons_0/gadget.hide()
	if MP.auth(self):
		$control_indicator/standard.show()

func apply_data(data):
	.apply_data(data)
	max_health = 75
	defense = 0
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
	yield(get_tree().create_timer(0.3, false), "timeout")
	attack_sprite0.show()
	attack_shape0.disabled = false
	yield(get_tree().create_timer(0.1, false), "timeout")
	attack_sprite0.hide()
	attack_shape0.disabled = true
	yield(get_tree().create_timer(0.1, false), "timeout")
	attack_sprite1.show()
	attack_shape1.disabled = false
	yield(get_tree().create_timer(0.1, false), "timeout")
	attack_sprite1.hide()
	attack_shape1.disabled = true
	can_use_potion = true


func make_effect():
	var node = _ulti_use_effect.instance()
	node.modulate = Color.red
	node.global_position = Vector2(global_position.x + (sign(_body.scale.x) * 15), global_position.y - 35)
	_level.add_child(node)


func _process(delta):
	ulti_percentage = 0
	if not MP.auth(self):
		return
	if Input.is_action_just_pressed("attack1"):
		attack()


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0 or not can_move or _is_drinking:
		return
	.use_gadget()
	is_active_gadget = true
	$gadget_active.emitting = true
	yield(get_tree().create_timer(3, false), "timeout")
	is_active_gadget = false
	$gadget_active.emitting = false
