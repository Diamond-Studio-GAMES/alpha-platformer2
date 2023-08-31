extends Control


var STORY = [
	tr("story.0"),
	tr("story.1"),
	tr("story.2"),
	tr("story.3"),
	tr("story.4"),
	tr("story.5"),
]
var textures = [
	null,
	load("res://textures/story/0.png"),
	load("res://textures/story/1.png"),
	load("res://textures/story/2.png"),
	load("res://textures/story/3.png"),
	null
]
onready var tw = $tween
onready var s_tex = $story_tex
onready var text = $text


func skip():
	G.current_level = "1_1"
	G.change_to_scene("res://scenes/levels/level_" + G.current_level + ".tscn")


func _ready():
	s_tex.texture = null
	s_tex.self_modulate = Color.black
	text.text = ""
	for i in range(STORY.size()):
		s_tex.texture = textures[i]
		text.text = ""
		tw.interpolate_property($story_tex, "self_modulate", Color.black, Color.white, 0.5)
		tw.start()
		yield(tw, "tween_completed")
		for j in STORY[i]:
			text.text += j
			yield(get_tree().create_timer(0.05, false), "timeout")
			if j == "." or j == ",":
				yield(get_tree().create_timer(0.45, false), "timeout")
		yield(get_tree().create_timer(0.5, false), "timeout")
		tw.interpolate_property(s_tex, "self_modulate", Color.white, Color.black, 0.5)
		tw.start()
		yield(tw, "tween_completed")
	$skip.hide()
	text.text = ""
	yield(get_tree().create_timer(1, false), "timeout")
	$name_of_game/anim.play("name")
	yield($name_of_game/anim, "animation_finished")
	skip()
