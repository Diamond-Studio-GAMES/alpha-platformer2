extends Entity
class_name Player


# HEALTH
var _soul
var _player_head
var _soul_sprite
var _soul_break_sprite
var _health_timer = 0
var have_soul_power = false
var amulet = -1
var _buttons
var _potion_1
var _potion_2
var _potion_3
var potions_1 = 1
var potions_2 = 1
var potions_3 = 1
var can_use_potion = true
var _is_drinking = false
var breath_bar
var breath_time_warned = false
var is_reviving = false
var tint_anim
var custom_respawn_scene = ""
var can_see = true
var can_revive = true
var _healed_times = 0


#ATTACK
var attack_cooldown = 0
var RECHARGE_SPEED = 1.0
var can_attack = true
var _attack_bar


#ULTI
var _ulti_tween
var _ulti_anim
var ulti_percentage = 0
var _ulti_bar
var _ulti_button
export (Color) var ulti_filled = Color.white
export (Color) var ulti_empty = Color.gray
var _is_ultiing = false
var have_gadget = false
var gadget_count = 3
var gadget_cooldown = 0
var gadget_bar
var gadget_counter
var dialog_text
var dialog_timer = 0
var class_nam = "player"
var power = 0
var ulti_power = 1

#CAMERA
export (bool) var smooth_camera = true
export (float, 1, 5) var damping = 2.5
export (Vector2) var offset = Vector2(0.25, 0.25)
var face_left = false
onready var camera = $camera
var default_camera_zoom = Vector2(0.3, 0.3)


func _ready():
	add_to_group("player")
	$camera/gui/base/hero_panel/name.text = G.getv("name", "")
	if G.getv("gender", "male") == "male":
		$visual/body/head/hair/hair_man.show()
		$visual/body/head/hair/hair_woman.hide()
		$camera/gui/base/hero_panel/head/hair_man.show()
		$camera/gui/base/hero_panel/head/hair_woman.hide()
	else:
		$camera/gui/base/hero_panel/head/hair_woman.show()
		$camera/gui/base/hero_panel/head/hair_man.hide()
		$visual/body/head/hair/hair_woman.show()
		$visual/body/head/hair/hair_man.hide()
		$hurt_sfx.stream = load("res://sounds/sfx/female_hurt.wav")
	$camera/gui/base/hero_panel/head/soul.self_modulate = G.SOUL_COLORS[G.getv("soul_type", 6)]
	#MOVE
	_body = $visual/body
	collision_layer = 0b10
	collision_mask = 0b11101
	
	#HEALTH
	_health_bar = $camera/gui/base/hero_panel/health
	_health_change_bar = $camera/gui/base/hero_panel/health/health_change
	_soul = $camera/gui/base/hero_panel/head/soul
	_head = $camera/gui/base/hero_panel/head
	_head_sprite = load("res://textures/mobs/player/head.res")
	_head_hurt_sprite = load("res://textures/mobs/player/head_hurt.res")
	_soul_sprite = load("res://textures/gui/soul.png")
	_soul_break_sprite = load("res://textures/gui/soul_break.png")
	_hp_count = $camera/gui/base/hero_panel/hp_count
	_player_head = $visual/body/head
	_heal_particles = $heal
	_buttons = $camera/gui/base/buttons
	tint_anim = $camera/gui/base/tint/anim
	
	
	
	current_health = max_health
	_hp_count.text = str(current_health) + "/" + str(max_health)
	_health_bar.max_value = max_health
	_health_bar.value = current_health
	_health_change_bar.max_value = max_health
	_health_change_bar.value = current_health
	potions_1 = G.getv("potions1", 0)
	potions_2 = G.getv("potions2", 0)
	potions_3 = G.getv("potions3", 0)
	_potion_1 = $camera/gui/base/hero_panel/potion1
	_potion_2 = $camera/gui/base/hero_panel/potion2
	_potion_3 = $camera/gui/base/hero_panel/potion3
	if potions_1 <= 0:
		_potion_1.hide()
	if potions_2 <= 0:
		_potion_2.hide()
	if potions_3 <= 0:
		_potion_3.hide()
	_potion_1.get_node("count").text = str(potions_1)
	_potion_2.get_node("count").text = str(potions_2)
	_potion_3.get_node("count").text = str(potions_3)
	breath_bar = $camera/gui/base/hero_panel/breath_indicator
	
	_attack_bar = $camera/gui/base/hero_panel/strike_bar
	_ulti_bar = $camera/gui/base/hero_panel/ulti_bar
	_ulti_anim = $ulti_charge_effect/anim
	_ulti_tween = $ulti_charge_effect/tween
	_ulti_button = $camera/gui/base/buttons/buttons_1/ulti
	gadget_bar = $camera/gui/base/buttons/buttons_0/gadget/progress
	gadget_counter = $camera/gui/base/buttons/buttons_0/gadget/count
	dialog_text = $camera/gui/base/dialog
	amulet = G.getv(class_nam + "_amulet", -1)
	dialog_text.grow_horizontal = Control.GROW_DIRECTION_BOTH
	smooth_camera = G.getv("smooth_camera", true)
	damping = G.getv("damping", 2.5)
	camera.set_as_toplevel(smooth_camera)
	if smooth_camera:
		camera.global_position = global_position
	
	#CONTROL
	for i in $camera/gui/base/buttons/buttons_0.get_children():
		if i.name != "joystick" and i.name != "gadget":
			i.position = G.getv(i.name + "_position", i.position)
			if OS.has_feature("pc"):
				i.hide()
		else:
			i.rect_position = G.getv(i.name + "_position", i.rect_position)
			if i.name == "gadget" and OS.has_feature("pc"):
				i.get_node("button").hide()
	for i in $camera/gui/base/buttons/buttons_1.get_children():
		if i.name != "joystick" and i.name != "gadget":
			i.position = G.getv(i.name + "_position", i.position)
			if OS.has_feature("pc"):
				i.hide()
		else:
			i.rect_position = G.getv(i.name + "_position", i.rect_position)
			if i.name == "gadget" and OS.has_feature("pc"):
				i.get_node("button").hide()
	
	if MP.auth(self):
		camera.make_current()
		for i in 3:
			yield(get_tree(), "physics_frame")
		send_my_data()
	else:
		$bars.show()
		$camera/gui.visible = false


func send_my_data():
	ms.sync_call(self, "apply_data", [
			{"name" : G.getv("name", ""), 
			"gender" : G.getv("gender", "male"), 
			"power" : power, 
			"ulti_power" : ulti_power, 
			"potions_1" : potions_1,
			"potions_2" : potions_2,
			"potions_3" : potions_3,
			"have_gadget" : have_gadget,
			"have_soul_power" : have_soul_power,
			"amulet" : amulet,
			}])


func apply_data(data):
	$bars/name.text = data["name"]
	if data["gender"] == "male":
		$visual/body/head/hair/hair_man.show()
		$visual/body/head/hair/hair_woman.hide()
		$hurt_sfx.stream = load("res://sounds/sfx/hurt.wav")
	else:
		$visual/body/head/hair/hair_man.hide()
		$visual/body/head/hair/hair_woman.show()
		$hurt_sfx.stream = load("res://sounds/sfx/female_hurt.wav")
	power = data["power"]
	ulti_power = data["ulti_power"]
	potions_1 = data["potions_1"]
	potions_2 = data["potions_2"]
	potions_3 = data["potions_3"]
	have_gadget = data["have_gadget"]
	have_soul_power = data["have_soul_power"]
	amulet = data["amulet"]
	_health_bar = $bars/progress
	_health_change_bar = $bars/progress/under
	_hp_count = $bars/hp

#MOVE
func move_left():
	ms.sync_call(self, "move_left")
	_move_direction = Vector2(-1, _move_direction.y)

func move_right():
	ms.sync_call(self, "move_right")
	_move_direction = Vector2(1, _move_direction.y)

func stop():
	ms.sync_call(self, "stop")
	_move_direction = Vector2(0, _move_direction.y)

func jump(power = 0):
	ms.sync_call(self, "jump")
	if not can_move:
		return false
	if power == 0:
		power = JUMP_POWER
	if is_on_floor() or under_water:
		_move.y = -power * GRAVITY_SCALE
		return true
	return false


#HEALTH
func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4, can_ignored = true):
	if is_reviving:
		return
	var state = .hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, can_ignored)
	if state == null:
		return
	if not state.is_valid():
		return
	_health_timer = 0
	_player_head.texture = _head_hurt_sprite
	if current_health <= 0:
		collision_layer = 0b0
		collision_mask = 0b1
		if MP.auth(self):
			AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), true)
			$game_over_sfx.play()
		tint_anim.stop(true)
		tint_anim.play("dying")
		_buttons.hide()
		_soul.texture = _soul_break_sprite
		can_see = false
		if MP.is_active:
			$"/root/mg".kill_revive_player(int(name.trim_prefix("player")))
	else:
		tint_anim.stop(true)
		tint_anim.play("hurting")
	state.connect("completed", self, "post_hurt")
	var state_next = state.resume()


func post_hurt():
	if current_health <= 0:
		yield(get_tree().create_timer(4, false), "timeout")
		if not MP.is_active:
			if not $camera.is_screen_on and current_health <= 0:
				$camera.show_revive_screen()
	else:
		_player_head.texture = _head_sprite
		can_hurt = true


func end_game():
	$camera.give_up()


func heal(amount):
	if current_health <= 0 and not is_reviving:
		return
	.heal(amount)


func use_potion(level):
	if _is_drinking or not can_move or is_reviving:
		return
	if not can_use_potion:
		return
	ms.sync_call(self, "use_potion", [level])
	match level:
		1:
			if potions_1 <= 0:
				return
			_is_drinking = true
			potions_1 -= 1
			if MP.auth(self):
				G.setv("potions1", potions_1)
			if potions_1 <= 0:
				_potion_1.hide()
			_potion_1.get_node("count").text = str(potions_1)
			_anim_tree["parameters/potion_seek/seek_position"] = 0
			_anim_tree["parameters/potion_shot/active"] = true
			yield(get_tree().create_timer(0.8, false), "timeout")
			if MP.auth(self):
				heal(round(max_health * 0.2))
			yield(get_tree().create_timer(0.6, false), "timeout")
			_is_drinking = false
		2:
			if potions_2 <= 0:
				return
			_is_drinking = true
			potions_2 -= 1
			if MP.auth(self):
				G.setv("potions2", potions_2)
			if potions_2 <= 0:
				_potion_2.hide()
			_potion_2.get_node("count").text = str(potions_2)
			_anim_tree["parameters/potion_seek/seek_position"] = 0
			_anim_tree["parameters/potion_shot/active"] = true
			yield(get_tree().create_timer(0.8, false), "timeout")
			if MP.auth(self):
				heal(round(max_health * 0.4))
			yield(get_tree().create_timer(0.6, false), "timeout")
			_is_drinking = false
		3:
			if potions_3 <= 0:
				return
			_is_drinking = true
			potions_3 -= 1
			if MP.auth(self):
				G.setv("potions3", potions_3)
			if potions_3 <= 0:
				_potion_3.hide()
			_potion_3.get_node("count").text = str(potions_3)
			_anim_tree["parameters/potion_seek/seek_position"] = 0
			_anim_tree["parameters/potion_shot/active"] = true
			yield(get_tree().create_timer(0.8, false), "timeout")
			if MP.auth(self):
				heal(round(max_health * 0.6))
			yield(get_tree().create_timer(0.6, false), "timeout")
			_is_drinking = false


func _process(delta):
	attack_cooldown = clamp(attack_cooldown - delta, 0, 10)
	if attack_cooldown == 0 and not can_attack:
		can_attack = true
	_attack_bar.value = 100 - (attack_cooldown / RECHARGE_SPEED * 100)
	
	if under_water:
		breath_bar.visible = true
		breath_bar.value = breath_time
	else:
		breath_bar.visible = false
	
	if breath_time <= 2 and not breath_time_warned:
		tint_anim.stop(true)
		tint_anim.play("hurting")
	if breath_time <= 2 and not breath_time_warned:
		breath_time_warned = true
	elif breath_time > 2 and breath_time_warned:
		breath_time_warned = false
	
	if current_health > 0 and not _is_ultiing:
		ulti_percentage = clamp(ulti_percentage + 2.5 * delta * (1.25 if is_amulet(G.Amulet.ULTI) else 1), 0, 100)
#		ulti_percentage = clamp(ulti_percentage + 10 * delta, 0, 100)
	if not _is_ultiing:
		_ulti_bar.value = ulti_percentage
	if ulti_percentage >= 100:
		if not OS.has_feature("pc"):
			_ulti_button.visible = true
		_ulti_bar.tint_progress = ulti_filled
		if _ulti_anim.current_animation == "nope":
			_ulti_anim.play("ulti_now_charged")
	else:
		_ulti_bar.tint_progress = ulti_empty
		_ulti_anim.play("nope")
		_ulti_button.visible = false
	dialog_timer = clamp(dialog_timer - delta, 0, 999)
	if dialog_timer <= 0:
		dialog_text.text = ""
	if not have_gadget:
		return
	if gadget_count > 0:
		gadget_cooldown = clamp(gadget_cooldown - delta, 0, 10)
	gadget_bar.value = gadget_cooldown


func _physics_process(delta):
	if is_stunned:
		_player_head.texture = _head_hurt_sprite
	#MOVE
	if MP.auth(self):
		if Input.is_action_just_pressed("left"):
			move_left()
		if Input.is_action_just_pressed("right"):
			move_right()
		if Input.is_action_just_pressed("jump"):
			jump()
		if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
			stop()
	
	#HEALTH
		if Input.is_action_just_pressed("potion1"):
			use_potion(1)
		if Input.is_action_just_pressed("potion2"):
			use_potion(2)
		if Input.is_action_just_pressed("potion3"):
			use_potion(3)
	if _move.length_squared() < 5*5 and attack_cooldown == 0:
		_health_timer += delta * 60
	else:
		_health_timer = 0
	if MP.auth(self):
		if _health_timer >= 300 and current_health < round(max_health * 0.75) and current_health > 0:
			idle_heal()
	if _health_timer < 240:
		_healed_times = 0
	
	if smooth_camera and MP.auth(self):
		face_left = true if _move_direction.x < 0 else false
		var target = Vector2()
		if not face_left:
			target = Vector2(global_position.x + offset.x, global_position.y - offset.y)
		else:
			target = Vector2(global_position.x - offset.x, global_position.y - offset.y)
		camera.global_position = camera.global_position.linear_interpolate(target, damping * delta)


func idle_heal():
	ms.sync_call(self, "idle_heal")
	_heal_particles.restart()
	_health_timer = 240
	_healed_times += 1
	var percent = 0.03 + _healed_times * 0.0075
	current_health = clamp(round(current_health + max_health * percent), 0, round(max_health * 0.75))
	_health_change_bar.value = current_health
	_health_bar.value = current_health
	_hp_count.text = str(current_health) + "/" + str(max_health)


func use_gadget():
	if gadget_cooldown > 0 or gadget_count <= 0:
		return
	ms.sync_call(self, "use_gadget")
	$gadget_sfx.play()
	gadget_cooldown = 10
	gadget_count -= 1
	gadget_counter.text = str(gadget_count)
	$gadget_use.restart()
	_health_timer = 0


func revive(hp_count = -1):
	ms.sync_call(self, "revive")
	if MP.is_active:
		$"/root/mg".kill_revive_player(int(name.trim_prefix("player")), true)
	collision_layer = 0b10
	collision_mask = 0b11101
	if MP.auth(self):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
	$revive_sfx.play()
	can_hurt = true
	can_move = false
	is_reviving = true
	_health_timer = 0
	_head.texture = _head_sprite
	_player_head.texture = _head_sprite
	_visual.scale = Vector2(1, 1)
	_soul.texture = _soul_sprite
	breath_time = 10
	tint_anim.play("reviving")
	if MP.auth(self):
		if hp_count < 0:
			heal(max_health)
		else:
			heal(hp_count)
	var node = load("res://prefabs/effects/revive.scn").instance()
	node.global_position = global_position
	_level.add_child(node)
	_anim_tree["parameters/death_trans/current"] = AliveState.ALIVE
	_buttons.show()
	yield(get_tree().create_timer(0.4, false), "timeout")
	$shield.rotation_degrees = 0 
	$shield.show()
	_move.y = -JUMP_POWER * 1.7 * GRAVITY_SCALE
	can_move = true
	yield(get_tree().create_timer(4.6, false), "timeout")
	is_reviving = false
	$shield.hide()
	can_see = true


func make_dialog(text = "", time = 2, color = Color.white):
	dialog_text.text = text
	dialog_text.self_modulate = color
	dialog_timer = time


func stun(time):
	if is_stunned:
		ms.sync_call(self, "stun")
		stun_time += time
		return
	yield(.stun(time), "completed")
	if current_health > 0:
		_player_head.texture = _head_sprite


func get_boss_bar():
	return $camera/gui/base/hero_panel/boss_bar


func _exit_tree():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)


func is_amulet(type):
	if amulet == type:
		return true
	return false

static func sis_amulet(type, class_na):
	if G.getv(class_na + "_amulet", -1) == type:
		return true
	return false
