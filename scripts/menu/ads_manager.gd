extends Node
class_name AdsManager


var ad_counter_win = 0
var ad_counter_go = 0
var is_waiting_ad = true
var admob: AdMobAPI

signal rewarded_video_finished(amount, currency)


func _ready():
	admob = AdMobAPI.new()
	admob.name = "admob"
	add_child(admob)


func ads_available():
	return admob.get_is_initialized()


func initialize(age):
	admob.initialize(true, age < 13, "PG" if age < 13 else "MA", false)
	admob.request_user_consent()
	admob.connect("user_earned_rewarded", self, "_on_rewarded_video_finished")
	admob.connect("rewarded_ad_failed_to_load", self, "_load_rewarded")
	admob.connect("rewarded_ad_clicked", self, "_load_rewarded")
	admob.connect("rewarded_ad_closed", self, "_load_rewarded")
	admob.connect("interstitial_clicked", self, "_load_interstitial")
	admob.connect("interstitial_failed_to_load", self, "_load_interstitial")
	admob.connect("interstitial_closed", self, "_load_interstitial")
	admob.load_interstitial("ca-app-pub-4032583867683331/5392039540")
	admob.load_rewarded("ca-app-pub-4032583867683331/3907621386")


func show_interstitial():
	print("Showing Interstitial...")
	if G.main_getv("no_ads", false):
		print("ABORTING: ADS REMOVED!")
		return
	if not admob.get_is_initialized():
		print("DUMMY: Shown Interstitial")
		return
	if admob.get_is_interstitial_loaded():
		admob.show_interstitial()
	else:
		if is_waiting_ad:
			return
		is_waiting_ad = true
		yield(admob, "interstitial_loaded")
		is_waiting_ad = false
		admob.show_interstitial()


func show_rewarded():
	print("Showing Rewarded...")
	if not admob.get_is_initialized():
		print("DUMMY: Shown Rewarded")
		return
	admob.show_rewarded()


func can_show_rewarded():
	return admob.get_is_initialized() and admob.get_is_rewarded_loaded()


func _load_interstitial(some = 0):
	if not admob.get_is_interstitial_loaded():
		admob.load_interstitial("ca-app-pub-4032583867683331/5392039540")


func _load_rewarded(some = 1):
	if not admob.get_is_rewarded_loaded():
		admob.load_rewarded("ca-app-pub-4032583867683331/3907621386")


func _on_rewarded_video_finished(a: float, c: String):
	print("REWARD GET: ", str(c), ", ", str(a))
	emit_signal("rewarded_video_finished", a, c)
	_load_rewarded()
