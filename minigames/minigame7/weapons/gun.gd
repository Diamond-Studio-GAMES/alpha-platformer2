extends Node2D


onready var player = $"../../.." as ShooterPlayer
onready var aim_line = $shoot_point/line
onready var effect = $shoot_point/shot_effect/anim
export (int) var damage = 30
export (int) var ammo = 7
export (int) var per_reload_ammo = 7
export (int) var all_ammo = 35
export (float) var shoot_delay = 0.5
export (float) var reload_time = 2
export (float) var bullet_lifetime = 1.5
export (float) var bullet_speed = 100
export (float) var max_unaccuracity = 5
var is_active = false
var reload_timer = 0
var delay_timer = 0
var bullet = load("res://minigames/minigame7/weapons/bullet.tscn")


func _ready():
	randomize()


func _physics_process(delta):
	if player.aim_vector != Vector2.ZERO:
		if MP.has_multiplayer_authority(self):
			aim_line.visible = true
		rotation_degrees = rad2deg(Vector2(abs(player.aim_vector.x), player.aim_vector.y).angle())
	else:
		if MP.has_multiplayer_authority(self):
			aim_line.visible = false
	if player.is_shooting:
		if ammo > 0 and reload_timer <= 0 and is_active and delay_timer <= 0:
			shoot()
	if reload_timer > 0:
		reload_timer -= delta
		if reload_timer <= 0:
			if all_ammo > 0:
				all_ammo -= per_reload_ammo
				ammo = per_reload_ammo
				self_modulate = Color.white
	if delay_timer > 0:
		delay_timer -= delta


func shoot():
	player.ms.sync_call(self, "shoot")
	effect.play("shot")
	effect.seek(0, true)
	if MP.has_multiplayer_authority(self):
		var node = bullet.instance()
		node.global_position = $shoot_point.global_position
		var rot = Vector2.RIGHT.rotated(rotation)
		if player.get_node("sprite").scale.x < 0:
			rot.x = -rot.x
		node.rotation = rot.angle() + deg2rad(randi() % int(max_unaccuracity * 2) - max_unaccuracity)
		node.speed = bullet_speed
		node.damage = damage
		node.bullet_lifetime = bullet_lifetime
		node.name = "bullet" + str(randi())
		node.by_who = player.player_name
		player.get_parent().add_child(node, true)
	delay_timer = shoot_delay
	ammo -= 1
	if ammo <= 0:
		reload_timer = reload_time
		self_modulate = Color.gray
	
