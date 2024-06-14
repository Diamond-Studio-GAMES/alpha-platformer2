extends Attack


const GRAVITY_SPEED = 250
var velocity = Vector2.ZERO


func _physics_process(delta):
	velocity.y += GRAVITY_SPEED * delta
	global_position += velocity * delta
