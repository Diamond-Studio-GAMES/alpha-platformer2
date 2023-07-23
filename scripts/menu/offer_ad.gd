extends Panel


var timer = 0


func _ready():
	yield(get_tree(), "idle_frame")
	G.ad.connect("rewarded_video_finished", self, "reward", [], CONNECT_ONESHOT | CONNECT_REFERENCE_COUNTED)
	$buy.disabled = true


func _process(delta):
	timer += delta
	if timer >= 2:
		$buy.disabled = not G.ad.can_show_rewarded()


func see():
	G.ad.show_rewarded()


func reward(amount, currency):
	get_tree().create_tween().tween_callback(G, "receive_ad_reward").set_delay(0.5)
	G.setv("collected_ad_bonus", true)
	queue_free()
