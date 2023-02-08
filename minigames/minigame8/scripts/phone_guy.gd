extends AudioStreamPlayer


export (NodePath) var button


func _ready():
	get_node(button).connect("pressed", self, "mute")
	connect("finished", self, "end")


func mute():
	stop()


func end():
	get_node(button).queue_free()
