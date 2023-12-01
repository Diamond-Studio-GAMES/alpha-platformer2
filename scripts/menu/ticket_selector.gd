extends HBoxContainer


signal started
export (int, 1, 10, 1) var max_tickets = 5
export (int, 0, 5, 1) var min_tickets = 5
export (String) var buy_text = "menu.play"
var selected_tickets = 1


func _ready():
	selected_tickets = min_tickets
	if selected_tickets == min_tickets:
		$down.disabled = true
	if selected_tickets == max_tickets:
		$up.disabled = true
	if max_tickets == min_tickets:
		$up.hide()
		$down.hide()
	if G.getv("tickets") < min_tickets:
		$play.disabled = true
	$play.text = str(selected_tickets) + " " + tr(buy_text)


func _on_down_pressed():
	selected_tickets -= 1
	if selected_tickets == min_tickets:
		$down.disabled = true
	if selected_tickets > G.getv("tickets"):
		$play.disabled = true
	else:
		$play.disabled = false
	$up.disabled = false
	$play.text = str(selected_tickets) + " " + tr(buy_text)


func _on_up_pressed():
	selected_tickets += 1
	if selected_tickets == max_tickets:
		$up.disabled = true
	if selected_tickets > G.getv("tickets"):
		$play.disabled = true
	else:
		$play.disabled = false
	$down.disabled = false
	$play.text = str(selected_tickets) + " " + tr(buy_text)


func _on_play_pressed():
	G.current_tickets = selected_tickets
	G.addv("tickets", -selected_tickets)
	emit_signal("started")
