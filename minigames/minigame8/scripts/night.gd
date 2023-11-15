extends Node2D
class_name Night


export (float) var energy_loss_per_sec = 0.06
export (float) var flashlight_loss_per_sec = 0.4
export (float) var door_loss_per_sec = 0.75
export (float) var cameras_loss_per_sec = 0.3
export (float) var music_box_loss_per_sec = 2
const WIND_UP_SPEED = 20
var current_camera = "f0w0"
var is_in_another_way = false
var is_door = false
var is_mask = false
var is_flashlight = false
var is_flashlight_broken = false
var is_flashlight_another_broken = false
var broken_flashlight_timer = 0
var broken_flashlight_another_timer = 0
var is_cameras = false
var energy = 100
var music_box_charge = 100
var music_box_change = 2
var energy_ran_out = false
var music_ended = false
var time = 0
var ambient_sounds_timer = 0
var ambient_sounds_next = 5
var is_test = false
var ambient_sounds = [load("res://minigames/minigame8/sounds/ambient/ambient0.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient1.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient2.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient3.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient4.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient5.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient6.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient7.ogg"), 
		load("res://minigames/minigame8/sounds/ambient/ambient8.ogg")]
onready var battery = $screen/base/main/battery/progress
onready var music_box = $screen/base/screen/gui/music_box/box
onready var music_box_butt = $screen/base/screen/gui/music_box
onready var music_box_sfx = $box
onready var mb_warn0 = $screen/base/screen/gui/mb_warn
onready var mb_warn1 = $screen/base/monitor_b/mb_warn
onready var time_sh = $screen/base/main/time
onready var mask_anim = $screen/base/mask/anim
onready var monitor_anim = $screen/base/screen/anim
onready var door_anim = $main/door/anim
onready var light0 = $main/light
onready var real_light0 = $main/light/light
onready var broken_light0 = $main/light/broken_light
onready var dark0 = $main/dark
onready var light1 = $another_way/light
onready var real_light1 = $another_way/light/light
onready var broken_light1 = $another_way/light/broken_light
onready var dark1 = $another_way/dark


func flashlight(another, enabled = true):
	if energy <= 0 and enabled:
		return
	if is_mask or is_cameras:
		return
	is_flashlight = enabled
	light0.visible = enabled
	dark0.visible = not enabled
	light1.visible = enabled
	dark1.visible = not enabled


func mask():
	if is_cameras or is_flashlight:
		return
	if mask_anim.is_playing():
		return
	is_mask = not is_mask
	if is_mask:
		mask_anim.play("on")
	else:
		mask_anim.play("off")


func door():
	if energy <= 0 and not is_door:
		return
	if is_cameras or is_mask:
		return
	if door_anim.is_playing():
		return
	is_door = not is_door
	if is_door:
		door_anim.play("close")
	else:
		door_anim.play("open")


func monitor():
	if energy <= 0 and not is_cameras:
		return
	if is_mask or is_flashlight:
		return
	if monitor_anim.is_playing():
		return
	is_cameras = not is_cameras
	if is_cameras:
		monitor_anim.play("on")
		yield(get_tree().create_timer(0.35), "timeout")
		change_camera(current_camera)
	else:
		monitor_anim.play("off")
		var id = "another_way" if is_in_another_way else "main"
		get_node(id + "/camera").make_current()


func another():
	if is_cameras or is_mask:
		return
	is_in_another_way = not is_in_another_way
	var id = "another_way" if is_in_another_way else "main"
	get_node(id + "/camera").make_current()


func wind_up(yes):
	if yes:
		music_box_change = -WIND_UP_SPEED
	else:
		music_box_change = music_box_loss_per_sec


func change_camera(id):
	get_node(id + "/camera").make_current()
	current_camera = id
	music_box_butt.visible = current_camera == "f2w1"


func get_room_pos(room = ""):
	var room_poses_root = get_node(room + "/poses")
	return room_poses_root.get_child(randi() % room_poses_root.get_child_count())


func jumpscare(visual, sound = ""):
	if $screen/jumpscare/anim.is_playing():
		return
	$screen/jumpscare.texture = visual
	$screen/jumpscare/anim.play("jumpscare")
	get_node(sound).play()
	yield(get_tree().create_timer(1), "timeout")
	get_tree().change_scene("res://minigames/minigame8/scenes/game_over.tscn")


func energy_ran_out():
	flashlight(true, false)
	if is_cameras:
		monitor()
	if is_door:
		door()
	var tween = get_tree().create_tween()
	tween.tween_property($screen/tint, "color", Color.black, 2.5)
	yield(tween, "finished")
	jumpscare(load("res://minigames/minigame8/textures/enemies/tehnolog_fake.png"), "jumpscare_male")


func music_ended():
	yield(get_tree().create_timer(5), "timeout")
	var texture = load("res://minigames/minigame8/textures/enemies/muzichka_fake.png")
	jumpscare(texture, "jumpscare_female")


func play_sound(id = ""):
	get_node(id).play()


func break_flashlight(another = false):
	if another:
		is_flashlight_another_broken = true
		broken_flashlight_another_timer = 1.5
		real_light1.hide()
		broken_light1.show()
	else:
		is_flashlight_broken = true
		broken_flashlight_timer = 1.5
		real_light0.hide()
		broken_light0.show()


func _process(delta):
	energy -= energy_loss_per_sec * delta + \
			flashlight_loss_per_sec * delta * int(is_flashlight) + \
			door_loss_per_sec * delta * int(is_door) + \
			cameras_loss_per_sec * delta * int(is_cameras)
	battery.value = energy
	music_box_charge -= music_box_change * delta
	music_box_charge = clamp(music_box_charge, 0, 100)
	music_box.value = music_box_charge
	mb_warn0.visible = music_box_charge < 20 and not music_ended
	mb_warn1.visible = music_box_charge < 20 and not music_ended
	if music_box_charge <= 0 and not music_ended:
		music_ended = true
		music_ended()
	time += delta
	var time_to_show = floor(time / 60)
	if time_to_show == 0:
		time_to_show = 12
	time_sh.text = str(time_to_show) + " AM"
	music_box_sfx.stream_paused = not (is_cameras and current_camera == "f2w1") or music_ended
	if energy <= 0 and not energy_ran_out:
		energy_ran_out = true
		energy_ran_out()
	if time >= 360:
		get_tree().change_scene("res://minigames/minigame8/scenes/win.tscn")
	ambient_sounds_timer += delta
	if ambient_sounds_timer >= ambient_sounds_next:
		ambient_sounds_timer = 0
		ambient_sounds_next = rand_range(5, 40)
		ambient_sounds.shuffle()
		$ambient.stream = ambient_sounds[6]
		$ambient.play()
	if is_flashlight_broken:
		broken_flashlight_timer -= delta
		if broken_flashlight_timer <= 0:
			is_flashlight_broken = false
			real_light0.show()
			broken_light0.hide()
	if is_flashlight_another_broken:
		broken_flashlight_another_timer -= delta
		if broken_flashlight_another_timer <= 0:
			is_flashlight_another_broken = false
			real_light1.show()
			broken_light1.hide()
	
	if Input.is_action_just_pressed("flashlight"):
		flashlight(true, true)
	if Input.is_action_just_released("flashlight"):
		flashlight(true, false)


func _ready():
	music_box_change = music_box_loss_per_sec
