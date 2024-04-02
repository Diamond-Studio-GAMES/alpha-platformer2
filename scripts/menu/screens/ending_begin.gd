extends Node

var anim: AnimationPlayer
var current_class = ""

func _ready():
	current_class = G.getv("selected_class", "player")
	var scene = load("res://prefabs/classes/%s.tscn" % current_class)
	var node = scene.instance()
	var visual = node.get_node("visual")
	anim = node.get_node("anim")
	node.remove_child(visual)
	node.remove_child(anim)
	$"../player_class".add_child(visual)
	$"../player_class".add_child(anim)
	visual.owner = $"../player_class"
	anim.owner = $"../player_class"
	anim.play("idle")
	node.queue_free()
	$"../player_class".set_script(load("res://scripts/menu/other/hair.gd"))
	if current_class == "player":
		$"../gleb/body/arm_right/hand/class".hide()
	else:
		$"../gleb/body/arm_right/hand/class".modulate = G.CLASS_COLORS_LIGHT[current_class]
	


func play_anim(an):
	anim.play(an)


func special_text(num):
	if current_class == "player":
		get_parent().make_dialog("begin.%d.no" % num, 4, Color.red)
	else:
		get_parent().make_dialog("begin.%d" % num, 4, Color.magenta)
