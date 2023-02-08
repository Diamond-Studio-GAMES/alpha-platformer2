extends Node
class_name AdsManager


enum AdType {
	INTERSTITIAL = 1,
	BANNER = 2,
	NATIVE = 4,
	REWARDED_VIDEO = 8,
	NON_SKIPPABLE_VIDEO = 16,
}
enum ShowStyle {
	INTERSTITIAL = 1,
	BANNER_TOP = 2,
	BANNER_BOTTOM = 4,
	REWARDED_VIDEO = 8,
	NON_SKIPPABLE_VIDEO = 16,
}


var ad_counter = 0
var appodeal

signal rewarded_video_finished(amount, currency)


func _ready():
	if Engine.has_singleton("GodotAppodeal"):
		appodeal = Engine.get_singleton("GodotAppodeal")
	else:
		print("Appodeal not supported on current platform! Platform: ", OS.get_name())


func ads_available():
	return appodeal != null


func initialize(age):
	if appodeal == null:
		return
	var consent = age > 15
	var coppa = age < 13
	appodeal.setUserAge(age)
	appodeal.setChildDirectedTreatment(coppa)
	if coppa:
		appodeal.disableNetworks(["a4g", "applovin", "bidmachine", "facebook", "mraid", "my_target", "nast", "notsy", "ogury", "startapp", "vast", "yandex"])
	appodeal.initialize("07728a05559bd903f48c492785faf0600d70eaab155f1179", AdType.INTERSTITIAL | AdType.REWARDED_VIDEO, consent)
	appodeal.muteVideosIfCallsMuted(true)
	appodeal.setTestingEnabled(false)
	appodeal.connect("rewarded_video_finished", self, "rvf")


func showInterstitial():
	print("Showing Interstitial...")
	if G.file.get_value("main", "no_ads", false):
		print("ABORTING: ADS REMOVED!")
		return
	if appodeal == null:
		print("DUMMY: Shown Interstitial")
		return
	appodeal.showAdForPlacement(ShowStyle.INTERSTITIAL, "win_lose")


func showRewarded():
	print("Showing Rewarded...")
	if appodeal == null:
		print("DUMMY: Shown Rewarded")
		return
	appodeal.showAdForPlacement(ShowStyle.REWARDED_VIDEO, "gold_box")


func canShowRewarded():
	if appodeal == null:
		return false
	return appodeal.canShow(ShowStyle.REWARDED_VIDEO)


func rvf(a : float, c : String):
	print("REWARD GET: ", str(c), ", ", str(a))
	emit_signal("rewarded_video_finished", a, c)
