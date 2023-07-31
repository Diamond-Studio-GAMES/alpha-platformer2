extends Area2D


var player: Player


func _ready():
	connect("body_entered", self, "body_entered")


func body_entered(body):
	if body is Player:
		player = body
		body.can_revive = false


func _physics_process(delta):
	if is_instance_valid(player):
		if player.current_health > 0:
			player.hurt(1, 0, false, true)
