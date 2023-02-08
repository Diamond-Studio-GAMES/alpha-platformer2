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

export (float) var SPEED = 85
export (float) var speed_cooficent = 1
export (float) var JUMP_POWER = 255
const UP_DIRECTION = Vector2.UP
export (float) var KNOCKBACK_POWER = 150
var GRAVITY_SPEED = 750
export (float) var MAX_GRAVITY = 250
export (float) var MAX_UNDERWATER_GRAVITY = 30
export (float) var GRAVITY_SCALE = 1
var _move_direction = Vector2()
var _body
var _visual
var _anim
var _anim_tree
var _y
var _move = Vector2()
var _knockback = 0
var can_move = true
var can_turn = true
var _level
var _visual_scale = Vector2(1, 1)


# HEALTH
export (int) var max_health = 100
var current_health
export (int) var defense = 5
export (bool) var immune_to_water = false
var can_hurt = true
var _hp_count
var _health_bar
var _health_change_bar
var _head
var _head_sprite
var _head_hurt_sprite
var _tween
var _hurt_heal_text = load("res://prefabs/effects/hurt_heal_text.scn")
var _heal_particles
var _start_falling_y = 0
var _is_falling = false
var under_water = false
var waters = []
var breath_time = 10
var is_stunned = false
var stun_stars
var stun_time = 0
var ms : MultiplayerSynchronizer
var stun_effect = load("res://prefabs/effects/stun_effect.scn")
var fall_effect = load("res://prefabs/effects/fall_effect.scn")

signal died
signal hurt
signal stun_ended


func _ready():
	randomize()
	_anim = $anim
	_anim_tree = $anim_tree
	_visual = $visual
	_start_falling_y = global_position.y
	_tween = $tween
	_heal_particles = $heal
	current_health = max_health
	stun_stars = $stun_stars
	ms = $MultiplayerSynchronizer
	_level = $".."

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
		hurt(1, 0, false, true)
	elif distance_falling > 416:
		hurt(round(max_health * 0.7), 0, false)
	elif distance_falling > 320:
		hurt(round(max_health * 0.5), 0, false)
	elif distance_falling > 192:
		hurt(round(max_health * 0.3), 0, false)
	else:
		return
	var node = fall_effect.instance()
	var pos = Vector2(global_position.x, 0)
	pos.y = (round(global_position.y / 32) + 1 * GRAVITY_SCALE) * 32
	node.global_position = pos
	_level.add_child(node, true)


#HEALTH
func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4, can_ignored = true):
	ms.sync_call(self, "hurt", [damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, can_ignored])
	var past_health = current_health
	if defense_allowed:
		current_health = clamp(current_health - clamp(damage - defense, 0, 999), 0, max_health)
	else:
		current_health = clamp(current_health - damage, 0, max_health)
	if fatal:
		current_health = 0
		damage = max_health
	if current_health >= past_health:
		return
	can_hurt = false
	can_move = false
	if stuns:
		stun(stun_time)
	_head.texture = _head_hurt_sprite
	yield()
	if not current_health >= past_health:
		var node = _hurt_heal_text.instance()
		if defense_allowed:
			node.get_node("text").text = str(damage - defense)
		else:
			node.get_node("text").text = str(damage)
		_level.add_child(node)
		node.global_position = global_position
		node.position.x += randi() % 13 - 6
		node.position.y += randi() % 13 - 6
		node.global_scale = Vector2(0.5, 0.5)
	_health_bar.value = current_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	$hurt_sfx.play()
	_tween.interpolate_property(_health_change_bar, "value", past_health, current_health, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT, 0.4)
	_tween.start()
	if current_health > 0:
		emit_signal("hurt")
		_knockback = KNOCKBACK_POWER * knockback_multiplier
		if abs(knockback_multiplier) > 0 and can_turn:
			_body.scale = Vector2(sign(-knockback_multiplier), 1)
		_anim_tree["parameters/hurt_shot/active"] = true
	else:
		emit_signal("died")
		if abs(knockback_multiplier) > 0:
			_body.scale = Vector2(sign(-knockback_multiplier), 1)
		_visual.scale = _body.scale
		_visual_scale = _visual.scale
		_body.scale = Vector2(1, 1)
		_anim_tree["parameters/death_trans/current"] = AliveState.DEAD
		if has_node(@"fire_on_entity"):
			$fire_on_entity.queue_free()
	var time0 = clamp(custom_immobility_time, 0, 0.1) if current_health > 0 else 0
	var time1 = clamp(custom_immobility_time - 0.1, 0, 9999) if current_health > 0 else 0
	var difference = clamp(custom_invincibility_time - custom_immobility_time, 0, 9999) if current_health > 0 else 0
	if time0 > 0:
		yield(get_tree().create_timer(time0, false), "timeout")
	_knockback = 0
	if time1 > 0:
		yield(get_tree().create_timer(time1, false), "timeout")
	if current_health > 0:
		can_move = true
	if difference > 0:
		yield(get_tree().create_timer(difference, false), "timeout")
	if current_health > 0:
		_head.texture = _head_sprite
		can_hurt = true


func heal(amount):
	ms.sync_call(self, "heal", [amount])
	if current_health <= 0 and not name.begins_with("player"):
		return
	current_health = clamp(current_health + amount, 0, max_health)
	_health_bar.value = current_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_tween.stop_all()
	_tween.remove_all()
	_health_change_bar.value = current_health
	_heal_particles.restart()
	var node = _hurt_heal_text.instance()
	node.get_node("text").text = str(amount)
	node.get_node("text").modulate = Color.green
	node.global_position = global_position
	_level.add_child(node)
	$heal_sfx.play()


func _physics_process(delta):
	if is_stunned:
		can_move = false
		_head.texture = _head_hurt_sprite
		stun_time -= delta
		if stun_time <= 0:
			emit_signal("stun_ended")
	scale = Vector2(scale.x, abs(scale.y) * GRAVITY_SCALE)
	if can_move:
		if _move_direction.x != 0:
			if can_turn:
				_body.scale = Vector2(_move_direction.x, _body.scale.y)
			if _anim_tree["parameters/iw_trans/current"] != IWState.WALK:
				_anim_tree["parameters/iw_trans/current"] = IWState.WALK
		elif _anim_tree["parameters/iw_trans/current"] != IWState.IDLE:
			_anim_tree["parameters/iw_trans/current"] = IWState.IDLE
		if not under_water:
			_y = clamp(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, 
					-9999 if GRAVITY_SCALE > 0 else MAX_GRAVITY * GRAVITY_SCALE, 
					MAX_GRAVITY * GRAVITY_SCALE if GRAVITY_SCALE > 0 else 9999)
		else:
			_y = clamp(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, 
					-9999 if GRAVITY_SCALE > 0 else MAX_UNDERWATER_GRAVITY * GRAVITY_SCALE,
					MAX_UNDERWATER_GRAVITY * GRAVITY_SCALE if GRAVITY_SCALE > 0 else 9999)
		_move = Vector2(_move_direction.x * SPEED * speed_cooficent + _knockback, _y)
		_move.y = move_and_slide(_move, UP_DIRECTION * GRAVITY_SCALE, false, 4, 0.785398, true).y
	else:
		_anim_tree["parameters/iw_trans/current"] = IWState.IDLE
		if not under_water:
			_y = clamp(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, 
					-9999 if GRAVITY_SCALE > 0 else MAX_GRAVITY * GRAVITY_SCALE, 
					MAX_GRAVITY * GRAVITY_SCALE if GRAVITY_SCALE > 0 else 9999)
		else:
			_y = clamp(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, 
					-9999 if GRAVITY_SCALE > 0 else MAX_UNDERWATER_GRAVITY * GRAVITY_SCALE,
					MAX_UNDERWATER_GRAVITY * GRAVITY_SCALE if GRAVITY_SCALE > 0 else 9999)
		_move = Vector2(_knockback, _y)
		_move.y = move_and_slide(_move, UP_DIRECTION * GRAVITY_SCALE).y
	if GRAVITY_SCALE > 0:
		if _move.y >= 25 and not _is_falling:
			_start_falling_y = global_position.y
			_is_falling = true
		if _move.y <= 25 and _is_falling:
			calculate_fall_damage()
			_start_falling_y = global_position.y
			_is_falling = false
	else:
		if _move.y <= -25 and not _is_falling:
			_start_falling_y = global_position.y
			_is_falling = true
		if _move.y >= -25 and _is_falling:
			calculate_fall_damage()
			_start_falling_y = global_position.y
			_is_falling = false


func _process(delta):
	if current_health <= 0:
		can_move = false
	if under_water:
		_start_falling_y = global_position.y
	if waters.size() > 0:
		under_water = true
	else:
		under_water = false
	if under_water:
		breath_time -= delta
		if breath_time <= 0:
			if not immune_to_water:
				hurt(1, 0, false, true)
	else:
		breath_time = 10
	if current_health <= 0:
		_visual.scale = _visual_scale


func water_checked(area):
	if area.name.begins_with("water"):
		waters.append(area)


func water_unchecked(area):
	if area in waters:
		waters.erase(area)


func stun(time):
	$stun_sfx.play()
	var node = stun_effect.instance()
	node.global_position = global_position
	_level.add_child(node)
	if is_stunned:
		stun_time += time
		return
	is_stunned = true
	can_move = false
	stun_time = time
	stun_stars.show()
	yield(self, "stun_ended")
	is_stunned = false
	can_move = true
	if current_health > 0:
		_head.texture = _head_sprite
	stun_stars.hide()

