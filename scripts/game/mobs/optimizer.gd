extends VisibilityEnabler2D
class_name Optimizer


onready var mob := get_parent() as Mob


func _init():
	pause_animated_sprites = false
	pause_particles = false
	freeze_bodies = false


func _ready():
	connect("screen_entered", self, "_on_screen_entered")
	connect("screen_exited", self, "_on_screen_exited")
	call_deferred("setup_anim_tree")


func setup_anim_tree():
	mob._anim_tree.active = is_on_screen()


func _on_screen_entered():
	mob._anim_tree.active = true


func _on_screen_exited():
	mob._anim_tree.active = false
