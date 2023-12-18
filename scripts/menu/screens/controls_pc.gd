extends WindowDialog


var _is_waiting_for_input = false
var _action_selected = ""
var _event_selected


func _ready():
	$key_picker.get_ok().text = tr("event.change.ok")
	$key_picker.get_cancel().text = tr("menu.cancel")
	$key_picker.get_label().align = Label.ALIGN_CENTER
	load_map_from_config()


func _input(event):
	if not _is_waiting_for_input:
		return
	if event is InputEventMouseButton:
		if event.pressed and event.button_index in [BUTTON_RIGHT, BUTTON_MIDDLE, BUTTON_XBUTTON1, BUTTON_XBUTTON2]:
			pick_event(event)
			get_tree().set_input_as_handled()
	if event is InputEventKey:
		event.physical_scancode = 0
		pick_event(event)
		get_tree().set_input_as_handled()


func load_map_from_config():
	InputMap.load_from_globals()
	for i in $list.get_children():
		if i.name in ["info", "reset"]:
			continue
		var action_name = i.name
		if not i.get_node("change").is_connected("pressed", self, "edit_action"):
			i.get_node("change").connect("pressed", self, "edit_action", [action_name])
		if G.hasv("event_" + action_name):
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, G.getv("event_" + action_name))
		i.get_node("button").text = _get_event_as_text(InputMap.get_action_list(action_name)[0])


func edit_action(action):
	$key_picker.dialog_text = tr("event.change.wait")
	$key_picker.window_title = tr("event.change.title") % tr("event." + action).rstrip(':')
	$key_picker.get_ok().hide()
	$key_picker.popup_centered()
	_is_waiting_for_input = true
	_action_selected = action


func pick_event(event: InputEvent):
	_is_waiting_for_input = false
	$key_picker.dialog_text = _get_event_as_text(event)
	$key_picker.get_ok().show()
	_event_selected = event


func set_event():
	$key_picker.hide()
	G.setv("event_" + _action_selected, _event_selected)
	load_map_from_config()


func reset():
	for i in $list.get_children():
		if i.name in ["info", "reset"]:
			continue
		if G.hasv("event_" + i.name):
			G.save_file.erase_section_key("save", "event_" + i.name)
	load_map_from_config()


func _get_event_as_text(event: InputEvent):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT:
				return tr("mouse.right")
			BUTTON_MIDDLE:
				return tr("mouse.middle")
			BUTTON_XBUTTON1:
				return tr("mouse.x1")
			BUTTON_XBUTTON2:
				return tr("mouse.x2")
	if event is InputEventKey:
		if event.physical_scancode != 0:
			return event.as_text().split(' ')[0]
	return event.as_text()
