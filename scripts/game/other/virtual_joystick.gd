class_name VirtualJoystick

extends Control

# https://github.com/MarcoFazioRandom/Virtual-Joystick-Godot
export(Color) var pressed_color := Color.gray


export(float, 0, 200, 1) var deadzone_size : float = 10

export(float, 0, 500, 1) var clampzone_size : float = 75

enum JoystickMode {FIXED, DYNAMIC}

export(JoystickMode) var joystick_mode := JoystickMode.FIXED

enum VisibilityMode {ALWAYS , TOUCHSCREEN_ONLY }

export(VisibilityMode) var visibility_mode := VisibilityMode.ALWAYS

export(bool) var pc_control = true

export var use_input_actions := true

export var action_left := "ui_left"
export var action_right := "ui_right"
export var action_up := "ui_up"
export var action_down := "ui_down"



var _pressed := false setget , is_pressed


signal released(output)
signal pressed


func is_pressed() -> bool:
	return _pressed


var _output := Vector2.ZERO


var _touch_index : int = -1

onready var _base := $base
onready var _tip := $base/tip

onready var _base_radius = _base.rect_size * _base.get_global_transform_with_canvas().get_scale() / 2

onready var _base_default_position : Vector2 = _base.rect_position
onready var _tip_default_position : Vector2 = _tip.rect_position

onready var _default_color : Color = _tip.modulate



func _ready() -> void:
	pause_mode = PAUSE_MODE_PROCESS
	if not OS.has_touchscreen_ui_hint() and visibility_mode == VisibilityMode.TOUCHSCREEN_ONLY:
		hide()
	if OS.has_feature("pc") and pc_control:
		modulate = Color(1, 1, 1, 0)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_joystick_area(event.position) and _touch_index == -1:
				if joystick_mode == JoystickMode.DYNAMIC or (joystick_mode == JoystickMode.FIXED and _is_point_inside_base(event.position)):
					if joystick_mode == JoystickMode.DYNAMIC:
						_move_base(event.position)
					emit_signal("pressed")
					_touch_index = event.index
					_tip.modulate = pressed_color
					_update_joystick(event.position)
		elif event.index == _touch_index:
			_reset()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)

func _move_base(new_position: Vector2) -> void:
	_base.rect_global_position = new_position - _base.rect_pivot_offset * get_global_transform_with_canvas().get_scale()

func _move_tip(new_position: Vector2) -> void:
	_tip.rect_global_position = new_position - _tip.rect_pivot_offset * _base.get_global_transform_with_canvas().get_scale()

func _is_point_inside_joystick_area(point: Vector2) -> bool:
	if OS.has_feature("pc") and pc_control:
		var x: bool = point.x >= rect_global_position.x - 1000 and point.x <= rect_global_position.x + 1000
		var y: bool = point.y >= rect_global_position.y - 270 and point.y <= rect_global_position.y + 270
		return x and y
	else:
		var x: bool = point.x >= rect_global_position.x and point.x <= rect_global_position.x + (rect_size.x * get_global_transform_with_canvas().get_scale().x)
		var y: bool = point.y >= rect_global_position.y and point.y <= rect_global_position.y + (rect_size.y * get_global_transform_with_canvas().get_scale().y)
		return x and y

func _is_point_inside_base(point: Vector2) -> bool:
	var center : Vector2 = _base.rect_global_position + _base_radius
	var vector : Vector2 = point - center
	if vector.length_squared() <= _base_radius.x * _base_radius.x:
		return true
	else:
		return false

func _update_joystick(touch_position: Vector2) -> void:
	var center : Vector2 = _base.rect_global_position + _base_radius
	var vector : Vector2 = touch_position - center
	vector = vector.limit_length(clampzone_size)
	
	_move_tip(center + vector)
	
	if vector.length_squared() > deadzone_size * deadzone_size:
		_pressed = true
		_output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
	else:
		_pressed = true
		_output = Vector2.ZERO
	
	if use_input_actions:
		_update_input_actions()

func _update_input_actions():
	if _output.x < 0:
		Input.action_press(action_left, -_output.x)
	elif Input.is_action_pressed(action_left):
		Input.action_release(action_left)
	if _output.x > 0:
		Input.action_press(action_right, _output.x)
	elif Input.is_action_pressed(action_right):
		Input.action_release(action_right)
	if _output.y < 0:
		Input.action_press(action_up, -_output.y)
	elif Input.is_action_pressed(action_up):
		Input.action_release(action_up)
	if _output.y > 0:
		Input.action_press(action_down, _output.y)
	elif Input.is_action_pressed(action_down):
		Input.action_release(action_down)

func _reset():
	emit_signal("released", _output)
	_pressed = false
	_output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	_base.rect_position = _base_default_position
	_tip.rect_position = _tip_default_position
	if use_input_actions:
		if Input.is_action_pressed(action_left) or Input.is_action_just_pressed(action_left):
			Input.action_release(action_left)
		if Input.is_action_pressed(action_right) or Input.is_action_just_pressed(action_right):
			Input.action_release(action_right)
		if Input.is_action_pressed(action_down) or Input.is_action_just_pressed(action_down):
			Input.action_release(action_down)
		if Input.is_action_pressed(action_up) or Input.is_action_just_pressed(action_up):
			Input.action_release(action_up)
