extends Control

const SAVED_GAMES_NAME = "APA2"
const CLIENT_ID = "519698636400-10cq9k43mmnpp3ddiflcfqtkb32ukqjf.apps.googleusercontent.com"
var play_games

func _ready():
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games = Engine.get_singleton("GodotPlayGamesServices")
		play_games.initWithSavedGames(true, SAVED_GAMES_NAME, false, false, CLIENT_ID)
		
		play_games.connect("_on_sign_in_success", self, "_on_sign_in_success")
		play_games.connect("_on_game_load_success", self, "_on_game_load_success")
		play_games.connect("_on_create_new_snapshot", self, "_on_create_new_snapshot")
	else:
		hide()
		prints("Google Play Games is unavailable! Platform:", OS.get_name())


func open_saved_games():
	if not play_games.isSignedIn():
		play_games.signIn()
	else:
		play_games.showSavedGames(tr("sl.cloud"), true, true, 16)


func _on_sign_in_success(account_id):
	play_games.showSavedGames(tr("sl.cloud"), true, true, 16)


func _on_game_load_success(data):
	$"../../export".import_data(data, true)


func _on_create_new_snapshot(snapshot_name):
	var save_name = _create_save_name()
	play_games.saveSnapshot(snapshot_name, $"../../export".export_data(), save_name)


func _create_save_name():
	var amount = $"../../saves/scroll/saves".get_child_count()
	var text = ""
	if amount == 0:
		return tr("sl.cloud.no")
	text += $"../../saves/scroll/saves".get_child(0).get_node("name").text
	if amount > 1:
		text += tr("sl.cloud.more")
		text = text % amount
	return text
