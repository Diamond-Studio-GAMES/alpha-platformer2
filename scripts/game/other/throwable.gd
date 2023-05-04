extends Node2D
class_name Throwable


enum DestroyedReason {
	WALL = 0,
	REJECT = 1,
	HIT = 2,
	END_OF_RANGE = 3,
}
enum EntityType {
	ENEMY = 0,
	PLAYER = 1
}


export (float) var SPEED = 150
export (float) var destroy_time = 3
var timer = 0
export (Vector2) var angle = Vector2.ZERO
var is_destroying = false
export (bool) var is_player_projectile = true
export (bool) var is_enemy_projectile = false
export (bool) var destroyable_by_attacks = true
export (bool) var collides = true
export (String, FILE, "*.scn") var effect_wall = ""
export (String, FILE, "*.scn") var effect_hit = ""
export (String, FILE, "*.scn") var effect_end_of_range = ""
export (String, FILE, "*.scn") var effect_reject = ""
var destroy_effect_simple_path = "res://prefabs/effects/destroy_effect.scn"
export (Color) var simple_effect_color = Color.white
export (Vector2) var simple_effect_scale = Vector2.ONE
export (Vector2) var simple_effect_offset = Vector2.ZERO
export (String, FILE, "*.wav, *.ogg") var simple_effect_destroy_sound_hit = ""
export (String, FILE, "*.wav, *.ogg") var simple_effect_destroy_sound_wall = ""


func _ready():
	var _attack = $attack
	_attack.connect("hit_wall", self, "destroy_it", [DestroyedReason.WALL])
	_attack.emit_hit_attack_signal = true
	_attack.connect("hit_enemy", self, "destroy_it", [DestroyedReason.HIT, EntityType.ENEMY])
	_attack.connect("hit_player", self, "destroy_it", [DestroyedReason.HIT, EntityType.PLAYER])
	if destroyable_by_attacks:
		_attack.connect("hit_attack_with_object", self, "destroy_it_attack")
	if angle == Vector2.ZERO:
		angle = Vector2.RIGHT.rotated(deg2rad(rotation_degrees))


func destroy_it_attack(attack):
	if is_player_projectile and attack.is_player_attack:
		return
	if is_enemy_projectile and attack.is_enemy_attack:
		return
	destroy_it(DestroyedReason.REJECT)


func destroy_it(destroy_reason, entity_hit = EntityType.ENEMY):
	if not collides and destroy_reason != DestroyedReason.END_OF_RANGE:
		return
	if destroy_reason == DestroyedReason.HIT:
		if is_enemy_projectile and entity_hit == EntityType.ENEMY:
			return
		if is_player_projectile and entity_hit == EntityType.PLAYER:
			return
	if is_destroying:
		return
	is_destroying = true
	var node
	if G.getv("effects", Globals.EffectsType.STANDARD) == Globals.EffectsType.STANDARD:
		match destroy_reason:
			DestroyedReason.WALL:
				if not effect_wall.empty():
					node = load(effect_wall).instance()
			DestroyedReason.REJECT:
				if not effect_reject.empty():
					node = load(effect_reject).instance()
			DestroyedReason.HIT:
				if not effect_hit.empty():
					node = load(effect_hit).instance()
			DestroyedReason.END_OF_RANGE:
				if not effect_end_of_range.empty():
					node = load(effect_end_of_range).instance()
		if node != null:
			node.global_position = global_position
			node.rotation = rotation
			get_parent().add_child(node)
	elif G.getv("effects", Globals.EffectsType.STANDARD) == Globals.EffectsType.SIMPLE:
		node = load(destroy_effect_simple_path).instance()
		node.global_position = global_position + simple_effect_offset.rotated(rotation)
		node.modulate = simple_effect_color
		node.scale = simple_effect_scale
		get_parent().add_child(node)
	if G.getv("effects", Globals.EffectsType.STANDARD) != Globals.EffectsType.STANDARD:
		var simple_sound
		match destroy_reason:
			DestroyedReason.WALL, DestroyedReason.REJECT:
				if not simple_effect_destroy_sound_wall.empty():
					simple_sound = load(simple_effect_destroy_sound_wall)
			DestroyedReason.HIT:
				if not simple_effect_destroy_sound_hit.empty():
					simple_sound = load(simple_effect_destroy_sound_hit)
		if simple_sound != null:
			var n = AudioStreamPlayer2D.new()
			n.global_position = global_position
			n.max_distance = 800
			n.bus = "sfx"
			n.stream = simple_sound
			get_parent().add_child(n)
			n.play()
			get_tree().create_tween().set_pause_mode(SceneTreeTween.TWEEN_PAUSE_STOP).tween_callback(n, "queue_free").set_delay(1.5)
	queue_free()


func _physics_process(delta):
	global_position += angle * SPEED * delta
	timer += delta
	if timer >= destroy_time:
		destroy_it(DestroyedReason.END_OF_RANGE)
