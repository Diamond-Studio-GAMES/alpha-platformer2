extends Area2D
class_name NPC, "res://textures/mobs/npcs/hairs/kare.png"


signal told
signal told_with_id(id)
signal ended_talk

const COLOR_TABLE = {
	"r" : Color.red,
	"b" : Color.blue,
	"y" : Color.yellow,
	"w" : Color.white,
	"g" : Color.green,
	"c" : Color.cyan,
	"dr" : Color.darkred,
	"dg" : Color.darkgreen,
	"db" : Color.darkblue,
	"bl" : Color.black,
	"v" : Color.violet,
	"m" : Color.magenta,
	"dv" : Color.darkviolet,
	"dm" : Color.darkmagenta,
	"gr" : Color.gray,
	"dgr" : Color.darkgray
}

export (Array, String) var dialog_data = []
export (Array, String) var hate_tier_1_dialog_data = []
export (Array, String) var hate_tier_2_dialog_data = []
export (Array, String) var hate_tier_3_dialog_data = []
export (Array, String) var hate_tier_4_dialog_data = []
var dialog = []
var dialog_colors = []
var dialog_times = []

var current_id = 0
var player: Player


func _ready():
	$button.rect_scale.x *= sign(scale.x)
	match G.getv("hate_tier", 0):
		1:
			if not hate_tier_1_dialog_data.empty():
				dialog_data = hate_tier_1_dialog_data
		2:
			if not hate_tier_2_dialog_data.empty():
				dialog_data = hate_tier_2_dialog_data
			elif not hate_tier_1_dialog_data.empty():
				dialog_data = hate_tier_1_dialog_data
		3:
			if not hate_tier_3_dialog_data.empty():
				dialog_data = hate_tier_3_dialog_data
			elif not hate_tier_2_dialog_data.empty():
				dialog_data = hate_tier_2_dialog_data
			elif not hate_tier_1_dialog_data.empty():
				dialog_data = hate_tier_1_dialog_data
		4:
			if not hate_tier_4_dialog_data.empty():
				dialog_data = hate_tier_4_dialog_data
			elif not hate_tier_3_dialog_data.empty():
				dialog_data = hate_tier_3_dialog_data
			elif not hate_tier_2_dialog_data.empty():
				dialog_data = hate_tier_2_dialog_data
			elif not hate_tier_1_dialog_data.empty():
				dialog_data = hate_tier_1_dialog_data
	for i in dialog_data:
		var splits = i.split("|")
		if G.getv("gender", "male") == "male":
			splits[2].replace("%", "")
		else:
			splits[2].replace("%", "а")
		dialog.append(splits[2])
		dialog_colors.append(COLOR_TABLE[splits[0]])
		dialog_times.append(float(splits[1]))


func _on_npc_body_entered(body):
	if body is Player and MP.auth(body):
		$button.show()
		player = body


func _on_npc_body_exited(body):
	if body is Player and MP.auth(body):
		$button.hide()
		player = null


func _on_button_pressed():
	emit_signal("told", current_id)
	player.make_dialog(tr(dialog[current_id]), dialog_times[current_id], dialog_colors[current_id])
	play_anim()
	current_id += 1
	if current_id == dialog.size():
		current_id = 0
		$button.hide()
		emit_signal("ended_talk")


func play_anim():
	$MultiplayerSynchronizer.sync_call(self, "play_anim")
	$talk_effect/anim.play("talk")
	$talk_effect/anim.seek(0, true)
