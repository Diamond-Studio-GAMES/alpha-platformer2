extends Throwable


export (float) var end_speed = 200
export (float) var time = 1
export (float) var delay = 0
export (float) var fade_time = 0


func _ready():
	SPEED = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.white, fade_time).from(Color(1, 1, 1, 0))
	tween.parallel().tween_property(self, "SPEED", end_speed, time).set_delay(delay)
