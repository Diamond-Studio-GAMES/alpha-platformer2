extends Panel


var classes_to_unlock = []
var gadget_classes = []
var power_classes = []
var ulti_classes = []
var soul_power_classes = []
var amulet_types = []
const CLASSES = ["knight", "butcher", "spearman", "wizard", "archer"]
export (Dictionary) var offer_rec = {}
onready var buy_button = $buy
var day_of_offer = 0
var time_of_offer = 0
var timer = 0


func _ready():
	G.connect("loot_end", self, "update_offer", [], CONNECT_REFERENCE_COUNTED)
	day_of_offer = Time.get_date_dict_from_system()["day"]
	time_of_offer = Time.get_unix_time_from_system()
	update_offer()


func update_offer():
	if day_of_offer != Time.get_date_dict_from_system()["day"] and time_of_offer <= Time.get_unix_time_from_system():
		queue_free()
	power_classes = []
	gadget_classes = []
	soul_power_classes = []
	ulti_classes = []
	amulet_types = []
	classes_to_unlock = CLASSES.duplicate()
	var had_classes = G.getv("classes", [])
	var has_amulet = false
	for i in had_classes:
		if i in classes_to_unlock:
			classes_to_unlock.erase(i)
	for i in had_classes:
		if G.getv(i + "_level", 0) >= 10:
			has_amulet = true
		if G.getv(i + "_level", 0) < 20:
			power_classes.append(i)
		if G.getv(i + "_ulti_level", 0) < 5:
			ulti_classes.append(i)
		if G.getv(i + "_level", 0) >= 15 and not G.getv(i + "_gadget", false):
			gadget_classes.append(i)
		if G.getv(i + "_level", 0) == 20 and not G.getv(i + "_soul_power", false):
			soul_power_classes.append(i)
	if has_amulet:
		for i in range(6):
			if G.getv("total_amulet_frags_"+G.AMULET[i], 0) < G.AMULET_MAX[i]:
				amulet_types.append(G.AMULET[i])
	if offer_rec.has("class"):
		for i in offer_rec["class"]:
			if not i in classes_to_unlock:
				buy_button.disabled = true
				buy_button.text = tr("menu.have")
	if offer_rec.has("amulet_frags"):
		for i in offer_rec["amulet_frags"]:
			if not i in amulet_types:
				buy_button.disabled = true
				buy_button.text = tr("menu.have")
	if offer_rec.has("gadget"):
		for i in offer_rec["gadget"]:
			if not i in gadget_classes:
				buy_button.disabled = true
				buy_button.text = tr("menu.have")
	if offer_rec.has("soul_power"):
		for i in offer_rec["soul_power"]:
			if not i in soul_power_classes:
				buy_button.disabled = true
				buy_button.text = tr("menu.have")
	if offer_rec.has("potions1"):
		if offer_rec["potions1"] + G.getv("potions1", 0) > 5:
			buy_button.disabled = true
			buy_button.text = tr("menu.have")
	if offer_rec.has("potions2"):
		if offer_rec["potions2"] + G.getv("potions2", 0) > 5:
			buy_button.disabled = true
			buy_button.text = tr("menu.have")
	if offer_rec.has("potions3"):
		if offer_rec["potions3"] + G.getv("potions3", 0) > 5:
			buy_button.disabled = true
			buy_button.text = tr("menu.have")
	if offer_rec.has("tokens"):
		for i in offer_rec["tokens"]:
			if i in classes_to_unlock:
				continue
			if not i in power_classes:
				buy_button.disabled = true
				buy_button.text = tr("menu.have")
	if offer_rec.has("ulti_tokens"):
		for i in offer_rec["ulti_tokens"]:
			if i in classes_to_unlock:
				continue
			if not i in ulti_classes:
				buy_button.disabled = true
				buy_button.text = tr("menu.have")
	if offer_rec.has("wild_tokens"):
		if power_classes.empty():
			buy_button.disabled = true
			buy_button.text = tr("menu.have")
	if offer_rec.has("wild_ulti_tokens"):
		if ulti_classes.empty():
			buy_button.disabled = true
			buy_button.text = tr("menu.have")
