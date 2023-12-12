extends KinematicBody2D
class_name Entity


enum IWState {
	IDLE = 0,
	WALK = 1,
}
enum AliveState {
	ALIVE = 0,
	DEAD = 1,
}

const UP_DIRECTION = Vector2.UP
export (int) var SPEED = 85
export (float) var speed_cooficent = 1.0
export (int) var JUMP_POWER = 255
export (int) var KNOCKBACK_POWER = 150
export (int) var MAX_GRAVITY = 250
export (int) var MAX_UNDERWATER_GRAVITY = 30
export (float) var GRAVITY_SCALE = 1.0
var GRAVITY_SPEED = 750
var _move_direction = Vector2()
var _body
var _move = Vector2()
var _knockback = 0
var hurt_counter = 0
var immune_counter = 0
var is_hurt = false
var can_turn = true
var is_stunned = false
var under_water = false
var _is_falling = false
var _visual_scale = Vector2(1, 1)
onready var _visual = $visual
onready var _anim = $anim
onready var _anim_tree = $anim_tree
onready var _level = get_tree().current_scene


# HEALTH
export (int) var max_health = 100
export (int) var defense = 5
export (bool) var immune_to_water = false
var current_health = 100
var _hp_count
var _health_bar
var _health_change_bar
var _tween
var _head
var _head_sprite
var _head_hurt_sprite
var _start_falling_y = 0
var waters = []
var breath_time = 10
var stun_time = 0
var _hurt_heal_text = load("res://prefabs/effects/hurt_heal_text.tscn")
var stun_effect = load("res://prefabs/effects/stun_effect.tscn")
var fall_effect = load("res://prefabs/effects/fall_effect.tscn")
onready var stun_stars = $stun_stars
onready var _heal_particles = $heal
onready var ms: MultiplayerSynchronizer = $MultiplayerSynchronizer as MultiplayerSynchronizer

signal died
signal hurt
signal healed
signal stun_ended


func _ready():
	_start_falling_y = global_position.y
	current_health = max_health

#MOVE

func calculate_fall_damage():
	if not MP.auth(self):
		return
	var distance_falling = abs(_start_falling_y - global_position.y)
	if GRAVITY_SCALE > 0 and _start_falling_y > global_position.y:
		return
	elif GRAVITY_SCALE < 0 and _start_falling_y < global_position.y:
		return
	if distance_falling > 480:
		hurt(1, 0, false, true, false, 1, 0.5, 0.4, "fall")
	elif distance_falling > 416:
		hurt(round(max_health * 0.7), 0, false, false, false, 1, 1.5, 1.2, "fall")
	elif distance_falling > 320:
		hurt(round(max_health * 0.5), 0, false, false, false, 1, 1, 0.8, "fall")
	elif distance_falling > 192:
		hurt(round(max_health * 0.3), 0, false, false, false, 1, 0.5, 0.4, "fall")
	else:
		return
	var node = fall_effect.instance()
	var pos = Vector2(global_position.x, 0)
	pos.y = (round(global_position.y / 32) + 1 * GRAVITY_SCALE) * 32
	node.global_position = pos
	_level.add_child(node, true)


#HEALTH
func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4, damage_source = "env"):
	if immune_counter > 0:
		return false
	ms.sync_call(self, "hurt", [damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, damage_source])
	var past_health = current_health
	var real_defense = defense * int(defense_allowed)
	current_health = round(clamp(current_health - max(damage - real_defense, 0), 0, max_health))
	if fatal:
		current_health = 0
		damage = max_health + real_defense
	if current_health >= past_health:
		return false
	is_hurt = true
	hurt_counter += 1
	if stuns:
		stun(stun_time)
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
	_head.texture = _head_hurt_sprite
	_hurt_intermediate(damage_source, died)
	var node = _hurt_heal_text.instance()
	node.get_node("text").text = str(damage - real_defense)
	_level.add_child(node)
	node.global_position = global_position
	node.position += Vector2(randi() % 13 - 6, randi() % 13 - 6)
	node.global_scale = Vector2(0.5, 0.5)
	var prev_hcb_value = _health_change_bar.value
	_update_bars()
	_health_change_bar.value = prev_hcb_value
	$hurt_sfx.play()
	if is_instance_valid(_tween):
		if _tween.is_valid():
			_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_health_change_bar, "value", current_health, 0.6).set_delay(0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).from_current()
	var time0 = 0
	var time1 = 0
	var difference = 0
	if not died:
		time0 = min(custom_immobility_time, 0.1)
		time1 = max(custom_immobility_time - 0.1, 0)
		difference = max(custom_invincibility_time - custom_immobility_time, 0)
	_post_hurt(died)
	_hurt_knockback(time0, time1, difference)
	return true


func _hurt_intermediate(damage_source, died):
	pass


func _post_hurt(died):
	pass


func _hurt_knockback(time0, time1, difference):
	if time0 > 0:
		get_tree().create_timer(time0, false).connect("timeout", self, "_hurt_immobility", [time1, difference], CONNECT_ONESHOT)
	else:
		_hurt_immobility(time1, difference)

func _hurt_immobility(time1, difference):
	_knockback = 0
	if time1 > 0:
		get_tree().create_timer(time1, false).connect("timeout", self, "_hurt_invincibility", [difference], CONNECT_ONESHOT)
	else:
		_hurt_invincibility(difference)

func _hurt_invincibility(difference):
	if current_health > 0:
		is_hurt = false
	if difference > 0:
		get_tree().create_timer(difference, false).connect("timeout", self, "_hurt_end", [], CONNECT_ONESHOT)
	else:
		_hurt_end()

func _hurt_end():
	hurt_counter -= 1
	if not is_zero_approx(current_health) and not is_stunned and hurt_counter < 1:
		_head.texture = _head_sprite


func heal(amount):
	ms.sync_call(self, "heal", [amount])
	if current_health <= 0 and not is_in_group("player"):
		return
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("healed")
	if is_instance_valid(_tween):
		if _tween.is_valid():
			_tween.kill()
	_update_bars()
	_heal_particles.restart()
	var node = _hurt_heal_text.instance()
	node.get_node("text").text = str(amount)
	node.get_node("text").modulate = Color.green
	node.global_position = global_position
	node.position += Vector2(randi() % 13 - 6, randi() % 13 - 6)
	_level.add_child(node)
	$heal_sfx.play()


func _physics_process(delta):
	if is_stunned:
		stun_time -= delta
		if stun_time <= 0:
			emit_signal("stun_ended")
	scale.y = abs(scale.y) * GRAVITY_SCALE
	if not (is_stunned or is_hurt):
		if _move_direction.x != 0:
			if can_turn:
				_body.scale = Vector2(_move_direction.x, _body.scale.y)
			_anim_tree["parameters/iw_trans/current"] = IWState.WALK
		else:
			_anim_tree["parameters/iw_trans/current"] = IWState.IDLE
		_move.x = _move_direction.x * SPEED * speed_cooficent + _knockback
	else:
		_anim_tree["parameters/iw_trans/current"] = IWState.IDLE
		_move.x = _knockback
	if under_water:
		if GRAVITY_SCALE > 0:
			_move.y = min(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, MAX_UNDERWATER_GRAVITY * GRAVITY_SCALE)
		else:
			_move.y = max(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, MAX_UNDERWATER_GRAVITY * GRAVITY_SCALE)
	else:
		if GRAVITY_SCALE > 0:
			_move.y = min(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, MAX_GRAVITY * GRAVITY_SCALE)
		else:
			_move.y = max(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, MAX_GRAVITY * GRAVITY_SCALE)
	if is_on_floor():
		_move -= get_floor_velocity()
	_move = move_and_slide(_move, UP_DIRECTION * GRAVITY_SCALE)
	
	if _move.y * GRAVITY_SCALE >= 25 and not _is_falling:
		_start_falling_y = global_position.y
		_is_falling = true
	if _move.y * GRAVITY_SCALE <= 25 and _is_falling:
		calculate_fall_damage()
		_start_falling_y = global_position.y
		_is_falling = false


func _process(delta):
	if current_health <= 0:
		_visual.scale = _visual_scale
		is_hurt = true
		_head.texture = _head_hurt_sprite
	if under_water:
		_start_falling_y = global_position.y
		if current_health > 0:
			breath_time -= delta
			if breath_time <= 0:
				if not immune_to_water:
					hurt(1, 0, false, true)


func water_checked(area):
	if area.get_collision_layer_bit(5):
		waters.append(area)
		_update_water_state()


func water_unchecked(area):
	if area in waters:
		waters.erase(area)
		_update_water_state()


func stun(time):
	$stun_sfx.play()
	var node = stun_effect.instance()
	node.global_position = global_position
	_level.add_child(node)
	if is_stunned:
		stun_time += time
		return
	is_stunned = true
	stun_time = time
	stun_stars.show()
	yield(self, "stun_ended")
	is_stunned = false
	if current_health > 0 and hurt_counter < 1:
		_head.texture = _head_sprite
	stun_stars.hide()


func _update_bars():
	_health_bar.value = current_health
	_health_change_bar.value = current_health
	_hp_count.text = str(current_health) + "/" + str(max_health)


func _update_water_state():
	if waters.size() > 0:
		under_water = true
	else:
		under_water = false
		breath_time = 10
