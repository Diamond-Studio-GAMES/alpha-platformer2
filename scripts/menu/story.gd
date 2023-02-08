extends Control


func _enter_tree():
	pass
const STORY = [
	"После событий Alpha Platformer Adventure...",
	"Когда дракону уже нужно было начинать сражение, он понимал, что шанс поражения велик. Он передал все свои знания и часть своей силы трём людям.",
	"После убийства дракона и уничтожения метеорита, последователи стали собирать осколки небесного камня, надеясь его восстановить.",
	"Надеялись они не зря, и вскоре метеорит был воссоздан...",
	"И запущен...",
	"Опять его надо уничтожать."
]
var textures = [
	null,
	load("res://textures/story/0.png"),
	load("res://textures/story/1.png"),
	load("res://textures/story/2.png"),
	load("res://textures/story/3.png"),
	null
]


func skip():
	G.current_level = "1_1"
	G.change_to_scene("res://scenes/levels/level_" + G.current_level + ".scn")


func _ready():
	$story_tex.texture = null
	$story_tex.self_modulate = Color.black
	$text.text = ""
	for i in range(STORY.size()):
		$story_tex.texture = textures[i]
		$text.text = ""
		$tween.interpolate_property($story_tex, "self_modulate", Color.black, Color.white, 0.5)
		$tween.start()
		yield($tween, "tween_completed")
		for j in STORY[i]:
			$text.text += j
			yield(get_tree().create_timer(0.05, false), "timeout")
			if j == "." or j == ",":
				yield(get_tree().create_timer(0.45, false), "timeout")
		yield(get_tree().create_timer(0.5, false), "timeout")
		$tween.interpolate_property($story_tex, "self_modulate", Color.white, Color.black, 0.5)
		$tween.start()
		yield($tween, "tween_completed")
	$skip.hide()
	$text.text = ""
	yield(get_tree().create_timer(1, false), "timeout")
	$name_of_game/anim.play("name")
	yield($name_of_game/anim, "animation_finished")
	G.current_level = "1_1"
	G.change_to_scene("res://scenes/levels/level_" + G.current_level + ".scn")
