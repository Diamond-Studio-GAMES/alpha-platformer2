extends VisibilityEnabler2D


func _ready():
	connect("screen_exited", self, "destroy")


func destroy():
	$"..".queue_free()
