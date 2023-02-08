extends Button


export (String) var minigame_name = "l"
export (int) var id = 1
export (int) var cost = 1000
export (bool) var free = true
var coin = load("res://textures/items/coin.png")
var bought = false


func _ready():
	connect("pressed", self, "open_or_buy")
	$"../buy".get_cancel().text = "Отмена"
	if free:
		bought = true
	else:
		if G.getv("minigame" + str(id) + "_bought", false):
			bought = true


func _process(delta):
	if bought:
		text = minigame_name
		icon = null
	else:
		text = str(cost) + " (%s)" % minigame_name
		icon = coin


func open_or_buy():
	if bought:
		get_tree().change_scene("res://minigames/minigame" + str(id) + "/minigame.scn")
	else:
		$"../buy".get_ok().connect("pressed", self, "buy", [], CONNECT_REFERENCE_COUNTED)
		$"../buy".connect("popup_hide", self, "disconnect_signal", [], CONNECT_ONESHOT)
		$"../buy".dialog_text = "Ты действительно хочешь купить мини-игру \"" + minigame_name + "\" за " + str(cost) + " монет?\n У тебя " + str(G.getv("coins", 0)) + " монет."
		$"../buy".popup_centered()


func disconnect_signal():
	if $"../buy".get_ok().is_connected("pressed", self, "buy"):
		$"../buy".get_ok().disconnect("pressed", self, "buy")

func buy():
	if G.getv("coins") < cost:
		$"../no_resources".popup_centered()
		return
	G.setv("coins", G.getv("coins", 0) - cost)
	G.setv("minigame" + str(id) + "_bought", true)
	bought = true
