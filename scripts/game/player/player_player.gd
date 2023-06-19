extends Player
class_name PlayerPlayer


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
	RECHARGE_SPEED = 0.65
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
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()


func attack():
	if is_hurt or is_stunned or _is_drinking or _is_ultiing or not can_control:
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
	_is_attacking = false


func _process(delta):
	ulti_percentage = 0
	if not MP.auth(self):
		return
	if Input.is_action_just_pressed("attack1"):
		attack()
