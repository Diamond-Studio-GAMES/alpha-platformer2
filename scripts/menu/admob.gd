class_name AdMobAPI
extends Node

signal initialization_complete(status, adapter_name)

signal consent_form_dismissed()
signal consent_status_changed(consent_status_message)
signal consent_form_load_failure(error_code, error_message)
signal consent_info_update_success(consent_status_message)
signal consent_info_update_failure(error_code, error_message)

signal banner_loaded()
signal banner_failed_to_load(error_code)
signal banner_opened()
signal banner_clicked()
signal banner_closed()
signal banner_recorded_impression()
signal banner_destroyed()

signal interstitial_failed_to_load(error_code)
signal interstitial_loaded()
signal interstitial_failed_to_show(error_code)
signal interstitial_opened()
signal interstitial_clicked()
signal interstitial_closed()
signal interstitial_recorded_impression()

signal rewarded_ad_failed_to_load(error_code)
signal rewarded_ad_loaded()
signal rewarded_ad_failed_to_show(error_code)
signal rewarded_ad_opened()
signal rewarded_ad_clicked()
signal rewarded_ad_closed()
signal rewarded_ad_recorded_impression()

signal rewarded_interstitial_ad_failed_to_load(error_code)
signal rewarded_interstitial_ad_loaded()
signal rewarded_interstitial_ad_failed_to_show(error_code)
signal rewarded_interstitial_ad_opened()
signal rewarded_interstitial_ad_clicked()
signal rewarded_interstitial_ad_closed()
signal rewarded_interstitial_ad_recorded_impression()

signal user_earned_rewarded(currency, amount)

var _plugin : Object

func _ready() -> void:
	if Engine.has_singleton("AdMob"):
		_plugin = Engine.get_singleton("AdMob")
	else:
		print("AdMob not found. Current platform: " + OS.get_name())

func get_is_initialized() -> bool:
	if _plugin:
		return _plugin.get_is_initialized()
	return false

func initialize(is_real := false, is_for_child_directed_treatment := false, max_ad_content_rating := "MA", is_test_europe_user_consent := false) -> void:
	if _plugin:
		_plugin.initialize(is_for_child_directed_treatment, max_ad_content_rating, is_real, is_test_europe_user_consent)
		_connect_signals()

func _connect_signals() -> void:
	_plugin.connect("initialization_complete", self, "_on_AdMob_initialization_complete")

	_plugin.connect("consent_form_dismissed", self, "_on_AdMob_consent_form_dismissed")
	_plugin.connect("consent_status_changed", self, "_on_AdMob_consent_status_changed")
	_plugin.connect("consent_form_load_failure", self, "_on_AdMob_consent_form_load_failure")
	_plugin.connect("consent_info_update_success", self, "_on_AdMob_consent_info_update_success")
	_plugin.connect("consent_info_update_failure", self, "_on_AdMob_consent_info_update_failure")

	_plugin.connect("banner_loaded", self, "_on_AdMob_banner_loaded")
	_plugin.connect("banner_failed_to_load", self, "_on_AdMob_banner_failed_to_load")
	_plugin.connect("banner_opened", self, "_on_AdMob_banner_opened")
	_plugin.connect("banner_clicked", self, "_on_AdMob_banner_clicked")
	_plugin.connect("banner_closed", self, "_on_AdMob_banner_closed")
	_plugin.connect("banner_recorded_impression", self, "_on_AdMob_banner_recorded_impression")
	_plugin.connect("banner_destroyed", self, "_on_AdMob_banner_destroyed")

	_plugin.connect("interstitial_failed_to_load", self, "_on_AdMob_interstitial_failed_to_load")
	_plugin.connect("interstitial_loaded", self, "_on_AdMob_interstitial_loaded")
	_plugin.connect("interstitial_failed_to_show", self, "_on_AdMob_interstitial_failed_to_show")
	_plugin.connect("interstitial_opened", self, "_on_AdMob_interstitial_opened")
	_plugin.connect("interstitial_clicked", self, "_on_AdMob_interstitial_clicked")
	_plugin.connect("interstitial_closed", self, "_on_AdMob_interstitial_closed")
	_plugin.connect("interstitial_recorded_impression", self, "_on_AdMob_interstitial_recorded_impression")

	_plugin.connect("rewarded_ad_failed_to_load", self, "_on_AdMob_rewarded_ad_failed_to_load")
	_plugin.connect("rewarded_ad_loaded", self, "_on_AdMob_rewarded_ad_loaded")
	_plugin.connect("rewarded_ad_failed_to_show", self, "_on_AdMob_rewarded_ad_failed_to_show")
	_plugin.connect("rewarded_ad_opened", self, "_on_AdMob_rewarded_ad_opened")
	_plugin.connect("rewarded_ad_clicked", self, "_on_AdMob_rewarded_ad_clicked")
	_plugin.connect("rewarded_ad_closed", self, "_on_AdMob_rewarded_ad_closed")
	_plugin.connect("rewarded_ad_recorded_impression", self, "_on_AdMob_rewarded_ad_recorded_impression")

	_plugin.connect("rewarded_interstitial_ad_failed_to_load", self, "_on_AdMob_rewarded_interstitial_ad_failed_to_load")
	_plugin.connect("rewarded_interstitial_ad_loaded", self, "_on_AdMob_rewarded_interstitial_ad_loaded")
	_plugin.connect("rewarded_interstitial_ad_failed_to_show", self, "_on_AdMob_rewarded_interstitial_ad_failed_to_show")
	_plugin.connect("rewarded_interstitial_ad_opened", self, "_on_AdMob_rewarded_interstitial_ad_opened")
	_plugin.connect("rewarded_interstitial_ad_clicked", self, "_on_AdMob_rewarded_interstitial_ad_clicked")
	_plugin.connect("rewarded_interstitial_ad_closed", self, "_on_AdMob_rewarded_interstitial_ad_closed")
	_plugin.connect("rewarded_interstitial_ad_recorded_impression", self, "_on_AdMob_rewarded_interstitial_ad_recorded_impression")

	_plugin.connect("user_earned_rewarded", self, "_on_AdMob_user_earned_rewarded")


func _on_AdMob_initialization_complete(status : int, adapter_name : String) -> void:
	emit_signal("initialization_complete", status, adapter_name)

func _on_AdMob_consent_form_dismissed() -> void:
	emit_signal("consent_form_dismissed")
func _on_AdMob_consent_status_changed(consent_status_message : String) -> void:
	emit_signal("consent_status_changed", consent_status_message)
func _on_AdMob_consent_form_load_failure(error_code : int, error_message: String) -> void:
	emit_signal("consent_form_load_failure", error_code, error_message)
func _on_AdMob_consent_info_update_success(consent_status_message : String) -> void:
	emit_signal("consent_info_update_success", consent_status_message)
func _on_AdMob_consent_info_update_failure(error_code : int, error_message : String) -> void:
	emit_signal("consent_info_update_failure", error_code, error_message)

func _on_AdMob_banner_loaded() -> void:
	emit_signal("banner_loaded")
func _on_AdMob_banner_failed_to_load(error_code : int) -> void:
	emit_signal("banner_failed_to_load", error_code)
func _on_AdMob_banner_opened() -> void:
	emit_signal("banner_loaded")
func _on_AdMob_banner_clicked() -> void:
	emit_signal("banner_clicked")
func _on_AdMob_banner_closed() -> void:
	emit_signal("banner_closed")
func _on_AdMob_banner_recorded_impression() -> void:
	emit_signal("banner_recorded_impression")
func _on_AdMob_banner_destroyed() -> void:
	emit_signal("banner_destroyed")

func _on_AdMob_interstitial_failed_to_load(error_code : int) -> void:
	emit_signal("interstitial_failed_to_load", error_code)
func _on_AdMob_interstitial_loaded() -> void:
	emit_signal("interstitial_loaded")
func _on_AdMob_interstitial_failed_to_show(error_code : int) -> void:
	emit_signal("interstitial_failed_to_show", error_code)
func _on_AdMob_interstitial_opened() -> void:
	emit_signal("interstitial_opened")
func _on_AdMob_interstitial_clicked() -> void:
	emit_signal("interstitial_clicked")
func _on_AdMob_interstitial_closed() -> void:
	emit_signal("interstitial_closed")
func _on_AdMob_interstitial_recorded_impression() -> void:
	emit_signal("interstitial_recorded_impression")

func _on_AdMob_rewarded_ad_failed_to_load(error_code : int) -> void:
	emit_signal("rewarded_ad_failed_to_load", error_code)
func _on_AdMob_rewarded_ad_loaded() -> void:
	emit_signal("rewarded_ad_loaded")
func _on_AdMob_rewarded_ad_failed_to_show(error_code : int) -> void:
	emit_signal("rewarded_ad_failed_to_show", error_code)
func _on_AdMob_rewarded_ad_opened() -> void:
	emit_signal("rewarded_ad_opened")
func _on_AdMob_rewarded_ad_clicked() -> void:
	emit_signal("rewarded_ad_clicked")
func _on_AdMob_rewarded_ad_closed() -> void:
	emit_signal("rewarded_ad_closed")
func _on_AdMob_rewarded_ad_recorded_impression() -> void:
	emit_signal("rewarded_ad_recorded_impression")

func _on_AdMob_rewarded_interstitial_ad_failed_to_load(error_code : int) -> void:
	emit_signal("rewarded_interstitial_ad_failed_to_load", error_code)
func _on_AdMob_rewarded_interstitial_ad_loaded() -> void:
	emit_signal("rewarded_interstitial_ad_loaded")
func _on_AdMob_rewarded_interstitial_ad_failed_to_show(error_code : int) -> void:
	emit_signal("rewarded_interstitial_ad_failed_to_show", error_code)
func _on_AdMob_rewarded_interstitial_ad_opened() -> void:
	emit_signal("rewarded_interstitial_ad_opened")
func _on_AdMob_rewarded_interstitial_ad_clicked() -> void:
	emit_signal("rewarded_interstitial_ad_clicked")
func _on_AdMob_rewarded_interstitial_ad_closed() -> void:
	emit_signal("rewarded_interstitial_ad_closed")
func _on_AdMob_rewarded_interstitial_ad_recorded_impression() -> void:
	emit_signal("rewarded_interstitial_ad_recorded_impression")

func _on_AdMob_user_earned_rewarded(currency : String, amount : int) -> void:
	emit_signal("user_earned_rewarded", currency, amount)

func load_banner(ad_unit_id: String, position := 1, size := "BANNER", show_instantly := true, respect_safe_area := true) -> void:
	if _plugin:
		_plugin.load_banner(ad_unit_id, position, size, show_instantly, respect_safe_area)

func load_interstitial(ad_unit_id: String) -> void:
	if _plugin:
		_plugin.load_interstitial(ad_unit_id)

func load_rewarded(ad_unit_id: String) -> void:
	if _plugin:
		_plugin.load_rewarded(ad_unit_id)

func load_rewarded_interstitial(ad_unit_id: String) -> void:
	if _plugin:
		_plugin.load_rewarded_interstitial(ad_unit_id)

func destroy_banner() -> void:
	if _plugin:
		_plugin.destroy_banner()

func show_banner() -> void:
	if _plugin:
		_plugin.show_banner()
		
func hide_banner() -> void:
	if _plugin:
		_plugin.hide_banner()

func show_interstitial() -> void:
	if _plugin:
		_plugin.show_interstitial()

func show_rewarded() -> void:
	if _plugin:
		_plugin.show_rewarded()

func show_rewarded_interstitial() -> void:
	if _plugin:
		_plugin.show_rewarded_interstitial()

func request_user_consent() -> void:
	if _plugin:
		_plugin.request_user_consent()

func reset_consent_state(will_request_user_consent := false) -> void:
	if _plugin:
		_plugin.reset_consent_state()

func get_banner_width() -> int:
	if _plugin:
		return _plugin.get_banner_width()
	return 0

func get_banner_width_in_pixels() -> int:
	if _plugin:
		return _plugin.get_banner_width_in_pixels()
	return 0
	
func get_banner_height() -> int:
	if _plugin:
		return _plugin.get_banner_height()
	return 0
	
func get_banner_height_in_pixels() -> int:
	if _plugin:
		return _plugin.get_banner_height_in_pixels()
	return 0
	
func get_is_banner_loaded() -> bool:
	if _plugin:
		return _plugin.get_is_banner_loaded()
	return false

func get_is_interstitial_loaded() -> bool:
	if _plugin:
		return _plugin.get_is_interstitial_loaded()
	return false

func get_is_rewarded_loaded() -> bool:
	if _plugin:
		return _plugin.get_is_rewarded_loaded()
	return false

func get_is_rewarded_interstitial_loaded() -> bool:
	if _plugin:
		return _plugin.get_is_rewarded_interstitial_loaded()
	return false
