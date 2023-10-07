extends Mob
class_name Mushroom


onready var attack_shape = $attack/shape
var bodies = []


func _ready():
	attack_damage = round(stats_multiplier * attack_damage)
	attack_shape.disabled = true
	current_health = max_health
	_health_bar.max_value = max_health
	_health_change_bar.max_value = max_health
	_update_bars()
	$attack.damage = attack_damage
	$check.connect("body_entered", self, "append_body")
	$check.connect("body_exited", self, "remove_body")


func append_body(body):
	if body.name.begins_with("player"):
		bodies.append(body)


func remove_body(body):
	bodies.erase(body)


func _physics_process(delta):
	if bodies.empty() or is_stunned or current_health <= 0 or is_hurt:
		attack_shape.set_deferred("disabled", true)
		return
	_anim_tree["parameters/attack_shot/active"] = true
	attack_shape.set_deferred("disabled", false)
