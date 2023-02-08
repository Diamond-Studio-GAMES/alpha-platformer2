extends Node2D


var collected_gems = 0
var collected_coins = 0
var cooldown = 0
var timer = 0
var minutes_passed = 0
var effect_coins = load("res://minigames/minigame3/coins_add_effect.scn")
var effect_gems = load("res://minigames/minigame3/gems_add_effect.scn")
onready var coins_count = $gui/base/coins
onready var gems_count = $gui/base/gems


func _ready():
	randomize()


func exit():
	get_tree().change_scene("res://scenes/menu/levels.scn")


func clicked():
	if cooldown > 0:
		return
	if randi() % 250 == 65:
		add_gems(1)
		$particles_gems.restart()
	else:
		add_coins(1)
		$particles.restart()
	cooldown = 2.5


func add_gems(gems):
	collected_gems += gems
	G.setv("gems", G.getv("gems", 10) + gems)
	var n = effect_gems.instance()
	n.text = "+" + str(gems)
	gems_count.add_child(n)


func add_coins(coins):
	collected_coins += coins
	G.setv("coins", G.getv("coins", 10) + coins)
	var n = effect_coins.instance()
	n.text = "+" + str(coins)
	coins_count.add_child(n)
	$particles.restart()


func _process(delta):
	coins_count.text = str(collected_coins)
	gems_count.text = str(collected_gems)
	cooldown -= delta
	timer += delta
	if timer >= 60:
		timer = 0
		add_coins(20)
		minutes_passed += 1
	if minutes_passed >= 60:
		minutes_passed = 0
		add_gems(6)
