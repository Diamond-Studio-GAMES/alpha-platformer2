extends KinematicBody2D
class_name Dasher

enum Mode {
	CUBE = 0,
	SHIP = 1,
}


export (float) var SPEED = 170
export (float) var JUMP_POWER = 400
export (int) var GRAVITY_SCALE = 1
export (float) var GRAVITY_SPEED = 960
export (float) var MAX_GRAVITY = 240
export (float) var SHIP_UP_SPEED = 1600
export (float) var MAX_SHIP_UP_SPEED = 240
var mode = Mode.CUBE
var is_button_pressed = false
var _move = Vector2()
var _y = 0
var is_on_orb = false
var is_alive = true
onready var cube_visual = $cube
onready var ship_visual = $ship
onready var camera = $camera


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			is_button_pressed = event.pressed


func destroy():
	is_alive = false
	$"../music".stop()
	if mode == Mode.CUBE:
		cube_visual.hide()
		$destroy/cube.show()
		$destroy/cube/anim.play("destroy")
	else:
		ship_visual.hide()
		$destroy/ship.show()
		$destroy/ship/anim.play("destroy")
	yield(get_tree().create_timer(1), "timeout")
	get_tree().reload_current_scene()


func jump(power = 0):
	is_on_orb = false
	if power == 0:
		power = JUMP_POWER
	_move.y = -power * GRAVITY_SCALE


func _physics_process(delta):
	if not is_alive:
		return
	if cube_visual.visible and mode == Mode.SHIP:
		cube_visual.hide()
		ship_visual.show()
		$camera/ground1/shape.set_deferred("disabled", false)
		$camera/ground2/shape.set_deferred("disabled", false)
		camera.drag_margin_v_enabled = false
		yield(get_tree(), "idle_frame")
		camera.set_as_toplevel(true)
		camera.global_position.y = min(round(global_position.y / 32) * 32 + 16, -144)
	if ship_visual.visible and mode == Mode.CUBE:
		cube_visual.show()
		ship_visual.hide()
		$camera/ground1/shape.set_deferred("disabled", true)
		$camera/ground2/shape.set_deferred("disabled", true)
		camera.set_as_toplevel(false)
		camera.position = Vector2.ZERO
		camera.drag_margin_v_enabled = true
	scale.y = GRAVITY_SCALE
	if is_button_pressed:
		match mode:
			Mode.CUBE:
				if is_on_floor() or is_on_orb:
					jump()
			Mode.SHIP:
				if is_on_orb:
					jump()
				_move.y = max(_move.y - SHIP_UP_SPEED * delta, -MAX_SHIP_UP_SPEED) if GRAVITY_SCALE > 0 else min(_move.y + SHIP_UP_SPEED * delta, MAX_SHIP_UP_SPEED)
	if Mode.SHIP:
		camera.global_position.x = global_position.x
	_y = clamp(_move.y + GRAVITY_SPEED * delta * GRAVITY_SCALE, 
			-9999 if GRAVITY_SCALE > 0 else MAX_GRAVITY * GRAVITY_SCALE, 
			MAX_GRAVITY * GRAVITY_SCALE if GRAVITY_SCALE > 0 else 9999)
	_move = Vector2(SPEED, _y)
	_move = move_and_slide(_move, Vector2.UP * GRAVITY_SCALE, false, 4, 0.785398, true)
	if _move.x <= 5:
		destroy()
