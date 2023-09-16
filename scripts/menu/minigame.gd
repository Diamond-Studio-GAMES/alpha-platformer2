extends Button


export (String) var minigame_name = "l"
export (int) var id = 1
export (int) var cost = 1000
export (bool) var free = true
var coin = load("res://textures/items/coin.png")
var bought = false


func _ready():
	connect("pressed", self, "open_or_buy")
	$"../buy".get_cancel().text = tr("menu.cancel")
	$"../buy".get_ok().text = tr("shop.buy")
	if free:
		bought = true
	else:
		if G.getv("minigame" + str(id) + "_bought", false):
			bought = true


func _process(delta):
	if bought:
		text = tr(minigame_name)
		icon = null
	else:
		text = str(cost) + " (%s)" % tr(minigame_name)
		icon = coin


func open_or_buy():
	if bought:
		get_tree().change_scene("res://minigames/minigame" + str(id) + "/minigame.tscn")
	else:
		$"../buy".get_ok().connect("pressed", self, "buy", [], CONNECT_REFERENCE_COUNTED)
		$"../buy".connect("popup_hide", self, "disconnect_signal", [], CONNECT_ONESHOT)
		$"../buy".dialog_text = tr("minigame.buy.text") % [tr(minigame_name), cost, G.getv("coins", 0)]
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
