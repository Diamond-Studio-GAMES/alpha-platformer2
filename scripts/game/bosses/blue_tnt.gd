extends KinematicBody2D


const GRAVITY_SPEED = 500
var explosion_radius = 4
var _is_exploded = false
var velocity = Vector2()
var bounced_times = 0
onready var sprite = $sprite


func _physics_process(delta):
	if _is_exploded:
		return
	sprite.rotation += PI / 2 * delta
	velocity.y += GRAVITY_SPEED * delta
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.normal)
		bounced_times += 1
		if bounced_times >= 2:
			explode()


func explode():
	if _is_exploded:
		return
	$MultiplayerSynchronizer.sync_call(self, "explode")
	_is_exploded = true
	$explosion/shape.set_deferred("disabled", false)
	$explosion/particles.restart()
	$explosion/sfx.play()
	$sprite.hide()
	$shape.set_deferred("disabled", true)
	$timer.start()
	velocity = Vector2.ZERO
	yield(get_tree().create_timer(0.3, false), "timeout")
	$explosion/shape.set_deferred("disabled", true)
