extends Node2D


signal soul_returned

const SOUL_SPEED = 192
const IDLE_DISTANCE_SQUARED = 16
var player: Player
var is_controlling = false
var time = 10
var _timer = 0
var _immune_timer = 0
var _mouse_pressed = false
onready var _soul = $soul


func _ready():
	if not G.getv("soul_learned", false):
		$label/anim.play("tip")
		G.setv("soul_learned", true)
	$camera.set_as_toplevel(true)
	go_to_center()


func _physics_process(delta):
	if not is_controlling:
		return
	_timer += delta
	if _timer >= time:
		go_to_player()
		return
	_immune_timer -= delta
	player._health_timer = 0
	var mouse_position = get_global_mouse_position() if _mouse_pressed else _soul.global_position
	var direction = _soul.global_position.direction_to(mouse_position)
	if _soul.global_position.distance_squared_to(mouse_position) > IDLE_DISTANCE_SQUARED:
		_soul.move_and_slide(direction * SOUL_SPEED)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			_mouse_pressed = event.pressed


func hurt():
	if _immune_timer > 0:
		return
	$soul/anim.play("hurt")
	_immune_timer = 1.8
	var damage = player.max_health * 0.15
	if damage >= player.current_health:
		damage = player.current_health - 1
		if damage == 0:
			return
	player.hurt(damage, 0, false)


func go_to_center():
	player.can_control = false
	player.force_stop()
	_soul.global_position = player.global_position
	$soul/sprite.scale = Vector2.ONE * 0.5
	modulate = Color.transparent
	$camera.global_position = player.get_node("camera").global_position
	$camera.make_current()
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(_soul, "global_position", $soul_point.global_position, 0.5)
	tween.parallel().tween_property($camera, "global_position", $soul_point.global_position, 0.5)
	tween.parallel().tween_property($soul/sprite, "scale", Vector2.ONE, 0.5)
	tween.parallel().tween_property(self, "modulate", Color.white, 0.5)
	yield(tween, "finished")
	is_controlling = true
	$soul/shape.disabled = false


func go_to_player():
	is_controlling = false
	$soul/shape.disabled = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(_soul, "global_position", player.global_position, 0.5)
	tween.parallel().tween_property($soul/sprite, "scale", Vector2.ONE * 0.5, 0.5)
	tween.parallel().tween_property(self, "modulate", Color.transparent, 0.5)
	tween.parallel().tween_property($camera, "global_position", player.get_node("camera").global_position, 0.5)
	yield(tween, "finished")
	player.can_control = true
	player.get_node("camera").make_current()
	emit_signal("soul_returned")
	queue_free()
