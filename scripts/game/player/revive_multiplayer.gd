extends Area2D


const REVIVE_TIME = 7.5
var bodies = []
var timer = 0
onready var player = $".."
onready var bar = $revive_bars/progress


func _ready():
	connect("body_entered", self, "add_body")
	connect("body_exited", self, "remove_body")
	bar.max_value = REVIVE_TIME


func add_body(node):
	if node is Player:
		bodies.append(node)


func remove_body(node):
	if node in bodies:
		bodies.erase(node)


func _physics_process(delta):
	if player.current_health > 0 or not MP.is_active:
		timer = 0
		visible = false
		return
	visible = true
	if not bodies.empty():
		timer += delta
	else:
		timer = 0
	bar.value = timer
	if timer >= REVIVE_TIME:
		for i in bodies:
			i.rpc("revived_player")
		timer = 0
		player.revive(int(player.max_health*0.25))
	
