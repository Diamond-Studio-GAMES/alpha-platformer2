extends Panel


signal emotion_selected(x, y)
export (NodePath) var emotion_button


func _ready():
	var button = get_node(emotion_button)
	if not MP.is_active:
		button.hide()
	button.connect("released", self, "_on_emotions_released")
	call_deferred("_pose_button", button)
	


func _process(delta):
	if Input.is_action_just_pressed("emotions") and MP.is_active:
		_on_emotions_released()


func _pose_button(button):
	var pos = button.global_position
	button.set_as_toplevel(true)
	button.global_position = pos


func _on_emotions_released():
	visible = not visible
	if visible:
		$grid/emotion0.grab_focus()
		$grid/emotion0.call_deferred("grab_focus")


func _on_emotion_pressed(idx):
	hide()
	emit_signal("emotion_selected", idx % 5 * 16, idx / 5 * 16)
