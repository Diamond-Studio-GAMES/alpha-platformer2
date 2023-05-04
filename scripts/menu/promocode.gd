extends CryptoKey
class_name Promocode, "res://textures/gui/promocodes.png"


export (String) var id = ""
export (Dictionary) var reward = {}
export (String, MULTILINE) var comment = ""
export (String) var custom_method = ""
export (String) var custom_method_pass = ""
export (bool) var multiple_uses = false


func evrey(it):
	yield(it.get_node("/root/G"), "loot_end")
	it.get_node("/root/G").receive_loot({"gems":-11})


func otis(it):
	yield(it.get_node("/root/G"), "loot_end")
	it.get_node("/root/G").receive_loot({"gems":60})


func fem(it):
	it.get_node("/root/G").setv("gems", -4)
	it.get_node("/root/G").save()
	yield(it.get_tree().create_timer(0.5, false), "timeout")
	it.get_tree().quit()


func hardcore(it):
	randomize()
	if it.get_node("/root/G").getv("classes", []).empty():
		it.get_node("/root/G").receive_loot({"class":[it.get_node("/root/G").CLASSES_ID[randi()%5]]})
	else:
		it.get_node("/root/G").receive_loot({"coins":1000})


func hardcore_pass(it):
	return it.get_node("/root/G").getv("hardcore")


func diavolo(it):
	it.get_node("diavolo").show()


func spos_pass(it):
	return it.is_promocode_used("смерть")


func smer(it):
	yield(it.get_tree().create_timer(0.5), "timeout")
	it.get_node("/root/G").save()
	it.get_tree().quit()


func pro(it):
	yield(it.get_node("/root/G"), "loot_end")
	it.get_node("/root/G").receive_loot({"gems":0, "coins":101})


func smer_pass(it):
	return it.is_promocode_used("способности")


func pi(it):
	yield(it.get_node("/root/G"), "loot_end")
	it.get_node("/root/G").receive_loot({"gems":0.86})
	it.get_node("/root/G").save()


func zero(it):
	it.get_node("/root/G").setv("gems", 0)
	it.get_node("/root/G").setv("coins", 0)
