extends VisibilityEnabler2D
class_name Optimizer


onready var mob := get_parent() as Mob


func _ready():
	set_enabler(ENABLER_PAUSE_ANIMATED_SPRITES, false)
	set_enabler(ENABLER_FREEZE_BODIES, false)
	set_enabler(ENABLER_PAUSE_PARTICLES, false)
	if MP.is_active:
		if get_tree().is_network_server():
			set_enabler(ENABLER_PAUSE_ANIMATIONS, false)
			return
	connect("screen_entered", self, "_on_screen_entered")
	connect("screen_exited", self, "_on_screen_exited")
	call_deferred("setup_anim_tree")


func setup_anim_tree():
	mob._anim_tree.active = is_on_screen()


func _on_screen_entered():
	mob._anim_tree.active = true


func _on_screen_exited():
	mob._anim_tree.active = false
