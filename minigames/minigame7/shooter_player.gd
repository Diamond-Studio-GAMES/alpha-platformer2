extends KinematicBody2D
class_name ShooterPlayer


var current_weapon = "gun"
var current_weapon_node = null
var weapons = []
var SPEED = 350
onready var joystick0 = $camera/gui/gui/joystick
onready var joystick1 = $camera/gui/gui/joystick2
onready var sprite = $sprite
onready var hp_bar = $camera/gui/gui/hp
onready var ammo_counter = $camera/gui/gui/ammo
onready var parent = $".."
onready var ip_text = $camera/gui/gui/ip
onready var ms = $MultiplayerSynchronizer
var timer = 0
var max_hp = 100
var hp = 100
var is_shooting = false
var aim_vector = Vector2.ZERO
var player_name = ""
var direction = Vector2.ZERO
var is_pc = false
var is_cool_aim = false
var effect = load("res://minigames/minigame7/death_effect.tscn")


func _ready():
	$label.text = player_name
	hp_bar.max_value = max_hp
	if not MP.has_multiplayer_authority(self):
		$camera/gui.hide()
	else:
		$camera.make_current()
	for i in $sprite/weapon.get_children():
		weapons.append(i.name)
	current_weapon = weapons[0]
	current_weapon_node = $sprite/weapon.get_node(current_weapon)
	current_weapon_node.is_active = true
	get_tree().connect("network_peer_connected", self, "sync_weapon")
	if get_tree().is_network_server():
		var ips = IP.get_local_addresses()
		var ip = ips[0]
		var ip_founded = false
		for i in ips:
			if i.begins_with("192.168."):
				ip = i
				ip_founded = true
				break
		if not ip_founded:
			ip += tr("lobby.strange_ip")
		ip_text.text = tr("lobby.your_ip") + ip
		$camera/gui/gui/start.show()
	is_cool_aim = bool(G.getv("shooter_aim_mode"))
	is_pc = OS.has_feature("pc")
	if is_pc:
		joystick0.hide()
		$camera/gui/gui/shoot.hide()


func _physics_process(delta):
	if MP.has_multiplayer_authority(self):
		if is_cool_aim:
			if joystick1._output != Vector2.ZERO and aim_vector == Vector2.ZERO:
				shoot(true)
			elif joystick1._output == Vector2.ZERO and aim_vector != Vector2.ZERO:
				shoot(false)
		aim_vector = joystick1._output
		if is_pc:
			direction.x = Input.get_axis("shooter_left", "shooter_right")
			direction.y = Input.get_axis("shooter_up", "shooter_down")
			direction = direction.normalized()
		else:
			direction = joystick0._output
		var dir = Vector2.ZERO
		if parent.started:
			dir = move_and_slide(SPEED * direction)
		if dir.x < 0:
			sprite.scale.x = -0.4
		elif dir.x > 0:
			sprite.scale.x = 0.4
		if aim_vector.x > 0:
			sprite.scale.x = 0.4
		elif aim_vector.x < 0:
			sprite.scale.x = -0.4
		hp_bar.value = hp
		ammo_counter.text = str(current_weapon_node.ammo) + "/" + str(current_weapon_node.all_ammo)
	else:
		if parent.started:
			move_and_slide(SPEED * direction)


func _process(delta):
	if is_pc and MP.has_multiplayer_authority(self):
		if Input.is_action_just_pressed("shooter_change_weapon"):
			change_weapon()
		if Input.is_action_just_pressed("shooter_shoot"):
			shoot(true)
		elif Input.is_action_just_released("shooter_shoot"):
			shoot(false)


func hurt(dmg, by, rmt = false):
	ms.sync_call(self, "hurt", [dmg, by, true])
	if hp <= 0:
		return
	hp = clamp(hp - dmg, 0, max_hp)
	if hp <= 0:
		if MP.has_multiplayer_authority(self) or rmt:
			var node = effect.instance()
			node.global_position = global_position
			node.scale.x = sprite.scale.x
			get_parent().add_child(node, true)
			hide()
			SPEED *= 2
			sprite.modulate = Color.black
			is_shooting = false
			$shape.set_deferred("disabled", true)
			if MP.has_multiplayer_authority(self):
				var h = load("res://minigames/minigame7/heal_dead_player.tscn").instance()
				h.global_position = global_position 
				h.name = "heal" + str(randi())
				parent.add_child(h, true)
				parent.rpc("player_died", get_tree().get_network_unique_id(), by)


func do_disconnect():
	queue_free()
	MP.close_network()
	$"../lobby".show()


func shoot(b):
	if hp <= 0:
		is_shooting = false
		return
	if not parent.started:
		is_shooting = false
		return
	is_shooting = b


func start_game():
	ip_text.text = ""
	get_parent().rpc("start_game")
	$camera/gui/gui/start.hide()


func change_weapon(change_idx = true):
	ms.sync_call(self, "change_weapon", [])
	current_weapon_node.hide()
	current_weapon_node.is_active = false
	var next_idx = weapons.find(current_weapon)
	if change_idx:
		next_idx += 1
		if next_idx >= len(weapons):
			next_idx = 0
	current_weapon = weapons[next_idx]
	current_weapon_node = $sprite/weapon.get_node(current_weapon)
	current_weapon_node.show()
	current_weapon_node.is_active = true


func sync_weapon(id):
	yield(get_tree().create_timer(0.5),"timeout")
	ms.sync_call(self, "change_weapon", [false])


func make_text(t):
	ip_text.text = t
