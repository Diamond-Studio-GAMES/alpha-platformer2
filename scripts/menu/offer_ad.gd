extends Panel


var timer = 0


func _ready():
	yield(get_tree(), "idle_frame")
	AdManager.connect("rewarded_video_finished", self, "reward", [], CONNECT_ONESHOT | CONNECT_REFERENCE_COUNTED)
	$buy.disabled = true


func _process(delta):
	timer += delta
	if timer >= 2:
		$buy.disabled = not AdManager.canShowRewarded()


func see():
	AdManager.showRewarded()


func reward(amount, currency):
	get_tree().create_tween().tween_callback(G, "receive_ad_reward").set_delay(0.5)
	G.setv("collected_ad_bonus", true)
	queue_free()
