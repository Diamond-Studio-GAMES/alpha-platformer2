extends Sprite


onready var player = $"../../.." as ShooterPlayer
onready var effect = $shot_effect/anim
export (int) var ammo = 1
export (int) var per_reload_ammo = 1
export (int) var all_ammo = 0
export (float) var shoot_delay = 0.5
export (float) var reload_time = 2
var is_active = false
var reload_timer = 0
var delay_timer = 0
var bullet = load("res://minigames/minigame7/weapons/ZAWARKA_effect.scn")


func _ready():
	randomize()


func _physics_process(delta):
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
	player.pause_mode = PAUSE_MODE_PROCESS
	if MP.has_multiplayer_authority(self):
		var node = bullet.instance()
		node.global_position = global_position
		player.get_parent().add_child(node, true)
	delay_timer = shoot_delay
	ammo -= 1
	if ammo <= 0:
		reload_timer = reload_time
		self_modulate = Color.gray
	yield(get_tree().create_timer(2), "timeout")
	player.pause_mode = PAUSE_MODE_INHERIT
