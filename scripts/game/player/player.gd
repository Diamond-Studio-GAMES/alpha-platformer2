extends Entity
class_name Player


# MOVEMENT
export (float) var COYOTE_TIME = 0.09
var _coyote_timer = 0.09


# HEALTH
var _health_timer = 0
var have_soul_power = false
var amulet = -1
var potions_1 = 1
var potions_2 = 1
var potions_3 = 1
var _breath_time_warned = false
var custom_respawn_scene = ""
var can_see = true
var can_revive = true
var can_control = true
var _is_ultiing = false
var _is_drinking = false
var _is_attacking = false
var is_reviving = false
var _healed_times = 0
var _prev_move_x = 0
var _soul_sprite = load("res://textures/gui/soul.png")
var _soul_break_sprite = load("res://textures/gui/soul_break.png")
var _potion_1_sprite = load("res://textures/items/small_potion.png")
var _potion_2_sprite = load("res://textures/items/normal_potion.png")
var _potion_3_sprite = load("res://textures/items/big_potion.png")
onready var _soul = $camera/gui/base/hero_panel/head/soul
onready var _player_head = $camera/gui/base/hero_panel/head
onready var _buttons = $camera/gui/base/buttons
onready var _potion_1 = $camera/gui/base/hero_panel/potion1
onready var _potion_2 = $camera/gui/base/hero_panel/potion2
onready var _potion_3 = $camera/gui/base/hero_panel/potion3
onready var tint_anim = $camera/gui/base/tint/anim
onready var _breath_bar = $camera/gui/base/hero_panel/breath_indicator


#ATTACK
var attack_cooldown = 0
var RECHARGE_SPEED = 1.0
var can_attack = true
onready var _attack_bar = $camera/gui/base/hero_panel/strike_bar
onready var _attack_empty_anim = $camera/gui/base/hero_panel/strike_bar/anim


#ULTI
export (bool) var smooth_camera = true
export (float, 1, 5) var damping = 2.5
export (Vector2) var offset = Vector2(0.25, 0.25)
export (Color) var ulti_filled = Color.white
export (Color) var ulti_empty = Color.gray
var ulti_percentage = 0
var ulti_amulet = G.Amulet.POWER
var have_gadget = false
var gadget_count = 3
var gadget_cooldown = 0
var dialog_timer = 0
var class_nam = "player"
var power = 0
var ulti_power = 1
var face_left = false
var default_camera_zoom = Vector2(0.3, 0.3)
var _ulti_use_effect = load("res://prefabs/effects/super_use.tscn")
var _ulti
onready var _ulti_bar = $camera/gui/base/hero_panel/ulti_bar
onready var _ulti_anim = $ulti_charge_effect/anim
onready var _ulti_tween = $ulti_charge_effect/tween
onready var _ulti_button = $camera/gui/base/buttons/buttons_1/ulti
onready var gadget_bar = $camera/gui/base/buttons/buttons_0/gadget/progress
onready var gadget_counter = $camera/gui/base/buttons/buttons_0/gadget/count
onready var dialog_text = $camera/gui/base/dialog
onready var camera = $camera
onready var _camera_tween = $camera_tween

#HATE
var hate_level = -1
var refuse_chance = 0
var face_chance = 1
var face_duration = 0
var auto_chance = 0
var auto_timer = 0
var revive_chance = 0
var revive_amount = 0
var fatal_chance = 0
var hate_head = load("res://prefabs/effects/glitch_head.tscn")
var hate_head_node
const REFUSE_PHRASES = ["hate.refuse.0", "hate.refuse.1", "hate.refuse.2"]
const REVIVE_PHRASES = ["hate.revive.0", "hate.revive.1"]
const AUTO_ACTIONS = [
	"move_left",
	"move_right",
	"jump",
	"attack",
	"ulti",
	"use_gadget",
]


func _ready():
	add_to_group("player")
	$camera/gui/base/hero_panel/name.set_message_translation(false)
	$camera/gui/base/hero_panel/name.notification(NOTIFICATION_TRANSLATION_CHANGED)
	$camera/gui/base/hero_panel/name.text = G.getv("name", "")
	dialog_text.add_color_override("font_outline_modulate", Color.white)
	if G.getv("gender", "male") == "male":
		$visual/body/head/hair/hair_man.show()
		$visual/body/head/hair/hair_woman.hide()
		$camera/gui/base/hero_panel/head/hair_man.show()
		$camera/gui/base/hero_panel/head/hair_woman.hide()
		$hurt_sfx.stream = load("res://sounds/sfx/randomed/hurt.tres")
	else:
		$camera/gui/base/hero_panel/head/hair_woman.show()
		$camera/gui/base/hero_panel/head/hair_man.hide()
		$visual/body/head/hair/hair_woman.show()
		$visual/body/head/hair/hair_man.hide()
		$hurt_sfx.stream = load("res://sounds/sfx/randomed/female_hurt.tres")
	_body = $visual/body
	collision_layer = 0b10
	collision_mask = 0b11101
	_health_bar = $camera/gui/base/hero_panel/health
	_health_change_bar = $camera/gui/base/hero_panel/health/health_change
	_head = $visual/body/head
	_head_sprite = load("res://textures/mobs/player/head.tres")
	_head_hurt_sprite = load("res://textures/mobs/player/head_hurt.tres")
	
	
	_hp_count = $camera/gui/base/hero_panel/hp_count
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	potions_1 = G.getv("potions1", 0)
	potions_2 = G.getv("potions2", 0)
	potions_3 = G.getv("potions3", 0)
	if potions_1 <= 0:
		_potion_1.hide()
	if potions_2 <= 0:
		_potion_2.hide()
	if potions_3 <= 0:
		_potion_3.hide()
	_potion_1.get_node("count").text = str(potions_1)
	_potion_2.get_node("count").text = str(potions_2)
	_potion_3.get_node("count").text = str(potions_3)
	amulet = G.getv(class_nam + "_amulet", -1)
	dialog_text.grow_horizontal = Control.GROW_DIRECTION_BOTH
	smooth_camera = G.getv("smooth_camera", true)
	damping = G.getv("damping", 2.5)
	camera.set_as_toplevel(smooth_camera)
	camera.zoom = default_camera_zoom
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
	hate_level = G.getv("hate_level", -1)
	if class_nam == "death":
		hate_level = 0
	match hate_level:
		1:
			refuse_chance = 80
		2:
			refuse_chance = 66
			face_chance = 10
			face_duration = 1
		3:
			refuse_chance = 50
			face_chance = 6
			face_duration = 1.5
			auto_chance = 80
			revive_chance = 20
			revive_amount = 10
		4:
			refuse_chance = 33
			face_chance = 4
			face_duration = 2.5
			auto_chance = 33
			revive_chance = 5
			revive_amount = 25
			fatal_chance = 8
			var lvl_name = _level.name.split("_")
			if len(lvl_name) > 2:
				if lvl_name[2].is_valid_integer():
					if int(lvl_name[2]) == 10:
						fatal_chance = 1
	if MP.auth(self):
		if MP.is_active:
			$camera/gui/base/pause_menu/panel/restart.disabled = true
		camera.make_current()
		for i in 3:
			yield(get_tree(), "physics_frame")
		send_my_data()
	else:
		$bars.show()
		$camera/gui.visible = false


func send_my_data():
	ms.sync_call(self, "apply_data", [{
		"name" : G.getv("name", ""), 
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
	$bars/name.set_message_translation(false)
	$bars/name.notification(NOTIFICATION_TRANSLATION_CHANGED)
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


func hate_refuse():
	if not MP.auth(self):
		return false
	if hate_level < 1:
		return false
	if randi() % refuse_chance == 15:
		make_dialog(tr(REFUSE_PHRASES.pick_random()))
		return true
	return false


func hate_head_spawn(force = false, time = -1, custom_color = Color.white):
	if not MP.auth(self) and not force:
		return
	if hate_level < 2 and not force:
		return
	if _body.scale.x < 0 and not force:
		return
	if randi() % face_chance == 2 or force:
		ms.sync_call(self, "hate_head_spawn", [true, face_duration, G.SOUL_COLORS[G.getv("soul_type", 6)]])
		var n = hate_head.instance()
		if custom_color != Color.white:
			n.self_modulate = custom_color
		else:
			n.self_modulate = G.SOUL_COLORS[G.getv("soul_type", 6)]
		if time < 0:
			n.get_node("timer").wait_time = face_duration
		else:
			n.get_node("timer").wait_time = time
		_head.add_child(n)
		_head.move_child(n, 0)
		hate_head_node = n


func hate_head_clear():
	if not is_instance_valid(hate_head_node):
		return
	if _move_direction.x < 0 and can_turn:
		return
	if _body.scale.x < 0:
		return
	if is_instance_valid(hate_head_node):
		hate_head_node.queue_free()


func hate_auto(delta):
	if not MP.auth(self):
		return
	if hate_level < 3:
		return
	auto_timer += delta
	if auto_timer >= 1:
		auto_timer = 0
		if randi() % auto_chance == 19:
			var prev_hate_level = hate_level # Don't refuse hate actions
			hate_level = 0
			call(AUTO_ACTIONS.pick_random())
			hate_level = prev_hate_level


func hate_revive():
	if not MP.auth(self):
		return false
	if hate_level < 3:
		return false
	if randi() % revive_chance == 1:
		make_dialog(tr(REVIVE_PHRASES.pick_random()))
		heal(round(max_health * revive_amount / 100))
		return true
	return false


func hate_fatal():
	if hate_level < 4:
		return false
	return randi() % fatal_chance == 1

#MOVE
func move_left():
	if not can_control:
		return
	if hate_refuse():
		return
	ms.sync_call(self, "move_left")
	_prev_move_x = _move_direction.x
	_move_direction.x = -1
	hate_head_spawn()

func move_right():
	if not can_control:
		return
	if hate_refuse():
		return
	ms.sync_call(self, "move_right")
	_prev_move_x = _move_direction.x
	_move_direction.x = 1

func stop_left():
	if _move_direction.x < 0: 
		if _prev_move_x <= 0:
			stop()
		else:
			move_right()
	_prev_move_x = 0

func stop_right():
	if _move_direction.x > 0: 
		if _prev_move_x >= 0:
			stop()
		else:
			move_left()
	_prev_move_x = 0

func stop():
	if not can_control:
		return
	ms.sync_call(self, "stop")
	_move_direction.x = 0

func jump(power = 0):
	if not can_control:
		return false
	if hate_refuse():
		return false
	ms.sync_call(self, "jump", [power])
	if is_hurt or is_stunned:
		return false
	if power == 0:
		power = JUMP_POWER
	if is_on_floor() or under_water or _coyote_timer > 0:
		if MP.auth(self):
			G.addv("jumps", 1)
		_coyote_timer = -COYOTE_TIME
		_move.y = -power * GRAVITY_SCALE
		return true
	return false

func force_move_left():
	ms.sync_call(self, "force_move_left")
	_prev_move_x = _move_direction.x
	_move_direction.x = -1
	hate_head_spawn()

func force_move_right():
	ms.sync_call(self, "force_move_right")
	_prev_move_x = _move_direction.x
	_move_direction.x = 1

func force_stop():
	ms.sync_call(self, "force_stop")
	_move_direction.x = 0

func force_jump(power = 0):
	ms.sync_call(self, "force_jump", [power])
	if is_hurt or is_stunned:
		return false
	if power == 0:
		power = JUMP_POWER
	if is_on_floor() or under_water or _coyote_timer > 0:
		_coyote_timer = -COYOTE_TIME
		_move.y = -power * GRAVITY_SCALE
		return true
	return false

#HEALTH
func hurt(damage, knockback_multiplier = 1, defense_allowed = true, fatal = false, stuns = false, stun_time = 1, custom_invincibility_time = 0.5, custom_immobility_time = 0.4, damage_source = "env"):
	if immune_counter > 0:
		return false
	if fatal:
		return .hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, damage_source)
	var test_health = round(clamp(current_health - max(damage - defense * int(defense_allowed), 0), 0, max_health))
	if test_health >= current_health:
		return false
	if test_health <= 0:
		if hate_revive():
			return false
	return .hurt(damage, knockback_multiplier, defense_allowed, fatal, stuns, stun_time, custom_invincibility_time, custom_immobility_time, damage_source)


func _hurt_intermediate(damage_source, died):
	_health_timer = 0
	_player_head.texture = _head_hurt_sprite
	if MP.auth(self):
		G.addv("damaged", 1)
		if damage_source == "fall":
			G.addv("fall_damaged", 1)
			G.ach.complete(Achievements.FALL)
	if died:
		collision_layer = 0b0
		collision_mask = 0b1
		if MP.auth(self):
			if _is_drinking:
				G.ach.complete(Achievements.FUUUUCK)
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


func _post_hurt(ded):
	if ded:
		if G.getv("hardcore", false):
			G.main_setv("remove_save", G.getv("save_id"))
			G.save()
		yield(get_tree().create_timer(4, false), "timeout")
		if not MP.is_active:
			if not camera.is_screen_on:
				camera.show_revive_screen()


func end_game():
	camera.give_up()


func _hurt_end():
	._hurt_end()
	if not is_zero_approx(current_health) and not is_stunned and hurt_counter < 1:
		_player_head.texture = _head_sprite


func heal(amount):
	if current_health <= 0 and not is_reviving:
		return
	.heal(amount)


func use_potion(level):
	if _is_drinking or is_hurt or is_stunned or is_reviving or _is_ultiing or _is_attacking or not can_control:
		return
	if current_health >= max_health:
		make_dialog(tr("player.fullhp"), 1, Color.white)
		return
	if hate_refuse():
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
				G.addv("potions_used", 1)
				G.ach.check(Achievements.POTION_MAN)
			if potions_1 <= 0:
				_potion_1.hide()
			_potion_1.get_node("count").text = str(potions_1)
			$visual/body/arm_left/hand/item.texture = _potion_1_sprite
			_anim_tree["parameters/potion_seek/seek_position"] = 0
			_anim_tree["parameters/potion_shot/active"] = true
			yield(get_tree().create_timer(0.8, false), "timeout")
			if current_health <= 0:
				return
			immune_counter += 1
			$shield.show()
			for i in range(4):
				if MP.auth(self):
					heal(round(max_health * 0.05))
				if i < 3:
					yield(get_tree().create_timer(0.2, false), "timeout")
			$shield.hide()
			immune_counter -= 1
			_is_drinking = false
		2:
			if potions_2 <= 0:
				return
			_is_drinking = true
			potions_2 -= 1
			if MP.auth(self):
				G.setv("potions2", potions_2)
				G.addv("potions_used", 1)
				G.ach.check(Achievements.POTION_MAN)
			if potions_2 <= 0:
				_potion_2.hide()
			_potion_2.get_node("count").text = str(potions_2)
			$visual/body/arm_left/hand/item.texture = _potion_2_sprite
			_anim_tree["parameters/potion_seek/seek_position"] = 0
			_anim_tree["parameters/potion_shot/active"] = true
			yield(get_tree().create_timer(0.8, false), "timeout")
			if current_health <= 0:
				return
			$shield.show()
			immune_counter += 1
			for i in range(4):
				if MP.auth(self):
					heal(round(max_health * 0.1))
				if i < 3:
					yield(get_tree().create_timer(0.2, false), "timeout")
			$shield.hide()
			immune_counter -= 1
			_is_drinking = false
		3:
			if potions_3 <= 0:
				return
			_is_drinking = true
			potions_3 -= 1
			if MP.auth(self):
				G.setv("potions3", potions_3)
				G.addv("potions_used", 1)
				G.ach.check(Achievements.POTION_MAN)
			if potions_3 <= 0:
				_potion_3.hide()
			_potion_3.get_node("count").text = str(potions_3)
			$visual/body/arm_left/hand/item.texture = _potion_3_sprite
			_anim_tree["parameters/potion_seek/seek_position"] = 0
			_anim_tree["parameters/potion_shot/active"] = true
			yield(get_tree().create_timer(0.8, false), "timeout")
			if current_health <= 0:
				return
			$shield.show()
			immune_counter += 1
			for i in range(4):
				if MP.auth(self):
					heal(round(max_health * 0.15))
				if i < 3:
					yield(get_tree().create_timer(0.2, false), "timeout")
			$shield.hide()
			immune_counter -= 1
			_is_drinking = false


func ulti():
	if ulti_percentage < 100 or is_hurt or is_stunned or _is_attacking or _is_drinking or not can_control:
		return
	if hate_refuse():
		return
	ms.sync_call(self, "ulti")
	$skill_use_sfx.play()
	ulti_percentage = 0
	_health_timer = 0
	_is_ultiing = true
	immune_counter += 1
	_camera_tween.interpolate_property(camera, "zoom", default_camera_zoom, Vector2(0.6, 0.6), 0.3)
	_camera_tween.start()
	_ulti_tween.interpolate_property(_ulti_bar, "value", 100, 0, 0.5)
	_ulti_tween.start()
	_anim_tree["parameters/ulti_shot/active"] = true
	if MP.auth(self):
		G.addv("ulti_used", 1)
		G.ach.check(Achievements.SKILL)
		var node = _ulti.instance()
		node.has_amulet = is_amulet(ulti_amulet)
		node.level = ulti_power
		node.power = power
		node.global_position = global_position
		_level.add_child(node, true)
	$camera/gui/base/ulti_use/anim.play("ulti_use")
	yield(get_tree().create_timer(0.8, false), "timeout")
	_is_ultiing = false
	immune_counter -= 1
	yield(get_tree().create_timer(2, false), "timeout")
	_camera_tween.interpolate_property(camera, "zoom", Vector2(0.6, 0.6), default_camera_zoom, 0.3)
	_camera_tween.start()


func make_effect():
	var node = _ulti_use_effect.instance()
	node.modulate = ulti_filled
	node.global_position = Vector2(global_position.x + (sign(_body.scale.x) * 15), global_position.y - 35 * GRAVITY_SCALE)
	_level.add_child(node)


func _process(delta):
	attack_cooldown = max(attack_cooldown - delta, 0)
	if attack_cooldown <= 0 and not can_attack:
		can_attack = true
	_attack_bar.value = 100 - (attack_cooldown / RECHARGE_SPEED * 100)
	
	if under_water:
		_breath_bar.visible = true
		_breath_bar.value = breath_time
	else:
		_breath_bar.visible = false
	
	if breath_time <= 2 and not _breath_time_warned:
		tint_anim.stop(true)
		tint_anim.play("hurting")
		_breath_time_warned = true
	elif breath_time > 2 and _breath_time_warned:
		_breath_time_warned = false
	
	if current_health > 0 and not _is_ultiing:
		ulti_percentage = clamp(ulti_percentage + 2.5 * delta * (1.25 if is_amulet(G.Amulet.ULTI) else 1), 0, 100)
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
	dialog_timer = max(dialog_timer - delta, 0)
	if dialog_timer <= 0:
		dialog_text.text = ""
	if have_gadget:
		if gadget_count > 0:
			gadget_cooldown = clamp(gadget_cooldown - delta, 0, 10)
		gadget_bar.value = gadget_cooldown
	hate_auto(delta)


func _physics_process(delta):
	#MOVE
	if is_on_floor() and _coyote_timer < COYOTE_TIME:
		_coyote_timer += delta
	if MP.auth(self):
		if Input.is_action_just_pressed("left"):
			move_left()
		if Input.is_action_just_pressed("right"):
			move_right()
		if Input.is_action_just_pressed("jump"):
			jump()
		if Input.is_action_just_released("right"):
			stop_right()
		if Input.is_action_just_released("left"):
			stop_left()
	if _coyote_timer > 0 and not is_on_floor():
		_coyote_timer -= delta
	
	#HEALTH
	if MP.auth(self):
		if Input.is_action_just_pressed("potion1"):
			use_potion(1)
		if Input.is_action_just_pressed("potion2"):
			use_potion(2)
		if Input.is_action_just_pressed("potion3"):
			use_potion(3)
	if _move.length_squared() < 25 and _move_direction == Vector2.ZERO and attack_cooldown == 0:
		_health_timer += delta * 60
	else:
		_health_timer = 0
	if MP.auth(self):
		if _health_timer >= 300 and current_health < round(max_health * 0.75) and current_health > 0:
			idle_heal()
	if _health_timer < 237:
		_healed_times = 0
	
	if smooth_camera and MP.auth(self):
		face_left = true if _move_direction.x < 0 else false
		var target: Vector2
		if not face_left:
			target = Vector2(global_position.x + offset.x, global_position.y - offset.y)
		else:
			target = Vector2(global_position.x - offset.x, global_position.y - offset.y)
		camera.global_position = camera.global_position.linear_interpolate(target, damping * delta)
	hate_head_clear()


func idle_heal():
	ms.sync_call(self, "idle_heal")
	_heal_particles.restart()
	_health_timer = 237
	_healed_times += 1
	var percent = 0.03 + _healed_times * 0.0075
	current_health = clamp(round(current_health + max_health * percent), 0, round(max_health * 0.75))
	_update_bars()


func use_gadget():
	if not have_gadget:
		return false
	if gadget_cooldown > 0 or gadget_count <= 0 or current_health <= 0 or not can_control or is_stunned or _is_drinking or _is_ultiing:
		return false
	if hate_refuse():
		return false
	ms.sync_call(self, "use_gadget")
	if MP.auth(self):
		G.addv("gadget_used", 1)
	$gadget_sfx.play()
	gadget_cooldown = 10
	gadget_count -= 1
	gadget_counter.text = str(gadget_count)
	$gadget_use.restart()
	_health_timer = 0
	return true


func revive(hp_count = -1):
	ms.sync_call(self, "revive", [hp_count])
	if MP.is_active:
		$"/root/mg".kill_revive_player(int(name.trim_prefix("player")), true)
	collision_layer = 0b10
	collision_mask = 0b11101
	if MP.auth(self):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)
	$revive_sfx.play()
	is_hurt = false
	is_reviving = true
	_is_drinking = false
	immune_counter += 1
	can_control = false
	_health_timer = 0
	_head.texture = _head_sprite
	_player_head.texture = _head_sprite
	_visual.scale = Vector2(1, 1)
	_soul.texture = _soul_sprite
	breath_time = 10
	tint_anim.play("reviving")
	if MP.auth(self):
		G.addv("revives", 1)
		if hp_count < 0:
			heal(max_health)
		else:
			heal(hp_count)
	var node = load("res://prefabs/effects/revive.tscn").instance()
	node.global_position = global_position
	_level.add_child(node)
	_anim_tree["parameters/death_trans/current"] = AliveState.ALIVE
	_anim_tree["parameters/attack_shot/active"] = false
	_anim_tree["parameters/potion_shot/active"] = false
	_buttons.show()
	yield(get_tree().create_timer(0.4, false), "timeout")
	can_control = true
	$shield/anim.seek(0, true)
	$shield.show()
	_move.y = -JUMP_POWER * 1.7 * GRAVITY_SCALE
	is_hurt = false
	yield(get_tree().create_timer(4.6, false), "timeout")
	is_reviving = false
	immune_counter -= 1
	can_see = true
	$shield.hide()


remote func revived_player():
	if MP.auth(self):
		G.addv("mp_revives", 1)
		G.ach.check(Achievements.GOOD_PARTNER)


func make_dialog(text = "", time = 2, color = Color.white):
	if G.getv("lore_disabled", false):
		return
	if G.getv("gender", "male") == "male":
		text = text.replace("%", "")
	else:
		text = text.replace("%", "а")
	dialog_text.text = text
	dialog_text.add_color_override("font_color", color)
	dialog_text.get_font("font").outline_color = Color.black if color.get_luminance() > 0.5 else Color.white
	dialog_timer = time


func stun(time):
	if is_stunned:
		ms.sync_call(self, "stun", [time])
		stun_time += time
		return
	yield(.stun(time), "completed")
	if current_health > 0:
		_player_head.texture = _head_sprite


func get_boss_bar():
	return $camera/gui/base/hero_panel/boss_bar


func _exit_tree():
	if MP.auth(self):
		AudioServer.set_bus_mute(AudioServer.get_bus_index("music"), false)


func is_amulet(type):
	return amulet == type


func _update_water_state():
	if waters.size() > 0:
		under_water = true
	else:
		under_water = false
		if breath_time < 2 and MP.auth(self) and current_health > 0:
			G.ach.complete(Achievements.AIR)
		breath_time = 10
