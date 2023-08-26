extends Node


var classes_to_unlock = []
var gadget_classes = []
var power_classes = []
var ulti_classes = []
var soul_power_classes = []
var amulet_types = []
const CLASSES = ["knight", "butcher", "spearman", "wizard", "archer"]
var current_receive = null
var current_cost = null
var current_id = -1
var current_day = 0
var current_unix_time = 0
var offer_obj = load("res://prefabs/menu/offer.tscn")
onready var p0 = $scroll/offers/resources/potion0/count
onready var b0 = $scroll/offers/resources/potion0/buy
onready var p1 = $scroll/offers/resources/potion1/count
onready var b1 = $scroll/offers/resources/potion1/buy
onready var p2 = $scroll/offers/resources/potion2/count
onready var b2 = $scroll/offers/resources/potion2/buy
onready var na = $scroll/offers/resources/no_ads/buy
onready var http = $http_request
var gem = load("res://textures/items/gem.png")
var coin = load("res://textures/items/coin.png")
var diamond_box = load("res://textures/items/diamond_box.png")
var gold_box = load("res://textures/items/gold_box.png")
var box = load("res://textures/items/box.png")
var token = load("res://textures/items/token.png")
var ulti_token = load("res://textures/items/ulti_token.png")
var sp = load("res://textures/items/soul_power.png")
var gadget = load("res://textures/items/gadget.png")
var wild_token = load("res://textures/items/wild_token.png")
var wild_ulti_token = load("res://textures/items/wild_ulti_token.png")
var CLASS_ICONS = {
	"knight" : load("res://textures/classes/knight_helmet.png"),
	"butcher" : load("res://textures/classes/butcher_helmet.png"),
	"spearman" : load("res://textures/classes/spearman_helmet.png"),
	"wizard" : load("res://textures/classes/wizard_helmet.png"),
	"archer" : load("res://textures/classes/archer_helmet.png") 
}
var ULTI_ICONS = {
	"knight" : load("res://textures/gui/ulti_icon_0.tres"),
	"butcher" : load("res://textures/gui/ulti_icon_1.tres"),
	"spearman" : load("res://textures/gui/ulti_icon_2.tres"),
	"wizard" : load("res://textures/gui/ulti_icon_3.tres"),
	"archer" : load("res://textures/gui/ulti_icon_4.tres")
}
var POTIONS_ICONS = {
	"small" : load("res://textures/items/small_potion.png"),
	"normal" : load("res://textures/items/normal_potion.png"),
	"big" : load("res://textures/items/big_potion.png")
}
var AMULET_ICONS = {
	"power" : load("res://textures/items/amulet_power_frag.png"),
	"defense" : load("res://textures/items/amulet_defense_frag.png"),
	"health" : load("res://textures/items/amulet_health_frag.png"),
	"speed" : load("res://textures/items/amulet_speed_frag.png"),
	"reload" : load("res://textures/items/amulet_reload_frag.png"),
	"ulti" : load("res://textures/items/amulet_ulti_frag.png"),
}

# IAP PURCHASES
const GEMS_500_SKU = "gems500"
const GEMS_1250_SKU = "gems1250"
const GEMS_2500_SKU = "gems2500"
const NO_ADS_SKU = "no_ads"
var payment
onready var butt_gem0 = $scroll/offers/resources/gems0/buy
onready var butt_gem1 = $scroll/offers/resources/gems1/buy
onready var butt_gem2 = $scroll/offers/resources/gems2/buy
onready var butt_no_ads = $scroll/offers/resources/no_ads/buy


func init_iap():
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment = Engine.get_singleton("GodotGooglePlayBilling")
		payment.connect("connected", self, "_on_connected")
		payment.connect("disconnected", self, "_on_disconnected")
		payment.connect("connect_error", self, "_on_connect_error")
		payment.connect("purchases_updated", self, "_on_purchases_updated")
		payment.connect("purchase_error", self, "_on_purchase_error")
		payment.connect("product_details_query_completed", self, "_on_sku_details_query_completed")
		payment.connect("product_details_query_error", self, "_on_sku_details_query_error")
		payment.connect("purchase_acknowledged", self, "_on_purchase_acknowledged")
		payment.connect("purchase_acknowledgement_error", self, "_on_purchase_acknowledgement_error")
		payment.connect("purchase_consumed", self, "_on_purchase_consumed")
		payment.connect("purchase_consumption_error", self, "_on_purchase_consumption_error")
		payment.connect("query_purchases_response", self, "_on_query_purchases_response")
		payment.startConnection()
	else:
		print("Android IAP is unavailable! Platform: " + OS.get_name())


func _on_connected():
	print("PurchaseManager connected")
	payment.querySkuDetails([GEMS_500_SKU, GEMS_1250_SKU, GEMS_2500_SKU, NO_ADS_SKU], "inapp")
	payment.queryPurchases("inapp")


func _on_query_purchases_response(query_result):
	if query_result.status == OK:
		for purchase in query_result.purchases:
			print(purchase)
			if purchase.products[0] in [GEMS_500_SKU, GEMS_1250_SKU, GEMS_2500_SKU, NO_ADS_SKU] and purchase.purchase_state == 1:
				match purchase.products[0]:
					NO_ADS_SKU:
						removed_ads()
				if not purchase.is_acknowledged:
					payment.acknowledgePurchase(purchase.purchase_token)
				if purchase.products[0] in [GEMS_500_SKU, GEMS_1250_SKU, GEMS_2500_SKU]:
					payment.consumePurchase(purchase.purchase_token)
	else:
		printerr("queryPurchases failed, response code: ",
				query_result.response_code,
				" debug message: ", query_result.debug_message, ". Will retry in 5s...")
		yield(get_tree().create_timer(5), "timeout")
		payment.queryPurchases("inapp")


func _on_sku_details_query_completed(sku_details):
	toggle_buttons(true)
	for available_sku in sku_details:
		match available_sku.id:
			GEMS_500_SKU:
				butt_gem0.text = make_price(available_sku.one_time_purchase_details)
			GEMS_1250_SKU:
				butt_gem1.text = make_price(available_sku.one_time_purchase_details)
			GEMS_2500_SKU:
				butt_gem2.text = make_price(available_sku.one_time_purchase_details)
			NO_ADS_SKU:
				if G.main_getv("no_ads", false):
					continue
				butt_no_ads.text = make_price(available_sku.one_time_purchase_details)


func _on_purchases_updated(purchases):
	for purchase in purchases:
		if not purchase.is_acknowledged and purchase.purchase_state == 1:
			print("Purchase " + str(purchase.products[0]) + " has not been acknowledged. Acknowledging...")
			match purchase.products[0]:
				GEMS_500_SKU:
					get_gems(500)
				GEMS_1250_SKU:
					get_gems(1250)
				GEMS_2500_SKU:
					get_gems(2500)
				NO_ADS_SKU:
					removed_ads()
			if purchase.products[0] in [GEMS_500_SKU, GEMS_1250_SKU, GEMS_2500_SKU]:
				payment.consumePurchase(purchase.purchase_token)
			else:
				payment.acknowledgePurchase(purchase.purchase_token)


func _on_purchase_acknowledged(purchase_token):
	print("Purchase acknowledged: %s" % purchase_token)


func _on_purchase_consumed(purchase_token):
	print("Purchase consumed successfully: %s" % purchase_token)


func _on_purchase_error(code, message):
	printerr("Purchase error %d: %s" % [code, message])


func _on_purchase_acknowledgement_error(code, message, purchase_token):
	printerr("Purchase acknowledgement error %d: %s, purchase rokens: %s. Will retry in 0.5s..." % [code, message, purchase_token])
	yield(get_tree().create_timer(0.5), "timeout")
	payment.acknowledgePurchase(purchase_token)


func _on_purchase_consumption_error(code, message, purchase_token):
	printerr("Purchase consumption error %d: %s, purchase token: %s. Will retry in 0.5s..." % [code, message, purchase_token])
	yield(get_tree().create_timer(0.5), "timeout")
	payment.consumePurchase(purchase_token)


func _on_sku_details_query_error(code, message):
	printerr("SKU details query error %d: %s. Will retry in 5s..." % [code, message])
	yield(get_tree().create_timer(5), "timeout")
	payment.querySkuDetails([GEMS_500_SKU, GEMS_1250_SKU, GEMS_2500_SKU, NO_ADS_SKU], "inapp")


func _on_disconnected():
	toggle_buttons(false)
	printerr("GodotGooglePlayBilling disconnected. Will try to reconnect in 5s...")
	yield(get_tree().create_timer(5), "timeout")
	payment.startConnection()


func _on_connect_error():
	_on_disconnected()


func toggle_buttons(state):
	butt_gem0.disabled = not state
	butt_gem1.disabled = not state
	butt_gem2.disabled = not state
	butt_no_ads.disabled = not state
	if not state:
		butt_gem0.text = "-"
		butt_gem1.text = "-"
		butt_gem2.text = "-"
		if not G.main_getv("no_ads", false):
			butt_no_ads.text = "-"

func make_price(data):
	var norm = data.price_amount_micros / 1000000
	var micros_text = "%0.2f" % norm
	return micros_text + " " + data.price_currency_code

func buy_gems500():
	var response = payment.purchase(GEMS_500_SKU)
	if response.status != OK:
		print("Purchase error %s: %s" % [response.response_code, response.debug_message])

func buy_gems1250():
	var response = payment.purchase(GEMS_1250_SKU)
	if response.status != OK:
		print("Purchase error %s: %s" % [response.response_code, response.debug_message])

func buy_gems2500():
	var response = payment.purchase(GEMS_2500_SKU)
	if response.status != OK:
		print("Purchase error %s: %s" % [response.response_code, response.debug_message])

func buy_no_ads():
	var response = payment.purchase(NO_ADS_SKU)
	if response.status != OK:
		print("Purchase error %s: %s" % [response.response_code, response.debug_message])
# END OF IAP

func _process(delta):
	if current_day != Time.get_date_dict_from_system()["day"]:
		_ready()
	if G.getv("potions1", 0) < 1:
		p0.text = ""
		b0.disabled = false
	else:
		b0.disabled = false
		p0.text = "У тебя:" + str(G.getv("potions1", 0))
		if int(p0.text) >= 5:
			b0.disabled = true
	if G.getv("potions2", 0) < 1:
		p1.text = ""
		b1.disabled = false
	else:
		b1.disabled = false
		p1.text = "У тебя:" + str(G.getv("potions2", 0))
		if int(p1.text) >= 5:
			b1.disabled = true
	if G.getv("potions3", 0) < 1:
		p2.text = ""
		b2.disabled = false
	else:
		b2.disabled = false
		p2.text = "У тебя:" + str(G.getv("potions3", 0))
		if int(p2.text) >= 5:
			b2.disabled = true
	if G.main_getv("no_ads", false):
		na.disabled = true
		na.text = "Куплено"


func get_gems(count):
	yield(get_tree(), "idle_frame")
	get_tree().paused = true
	yield(get_tree().create_timer(0.5), "timeout")
	G.receive_loot({"gems" : count})


func removed_ads():
	if G.main_getv("no_ads", false):
		return
	G.main_setv("no_ads", true)
	G.save()
	yield(get_tree(), "idle_frame")
	get_tree().paused = true
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().paused = false
	get_tree().change_scene("res://scenes/menu/no_ads.tscn")


func buy(costs = "", receives = "", id = -1):
	var cost = JSON.parse(costs).result
	var receive = JSON.parse(receives).result
	for i in cost:
		if G.getv(i, 0) < cost[i]:
			$not_enough/anim.play("no")
			return
	current_receive = receive
	current_cost = cost
	current_id = id
	if cost.empty():
		confirm_buy()
		return
	var add = ""
	for i in receive:
		add += ", "
		match i:
			"coins":
				add += "монеты" + " (" + str(receive[i])
			"gems":
				add += "кристаллы" + " (" + str(receive[i])
			"amulet_frags":
				for j in receive[i]:
					add += "фрагменты амулета" + " (" + tr(G.AMULET_NAME[G.AMULET_ID[j]]) + \
							", " + str(receive[i][j])
			"gadget":
				for j in receive[i]:
					add += "душевный навык" + " (" + tr(G.CLASSES[j])
			"soul_power":
				for j in receive[i]:
					add += "душевная сила" + " (" + tr(G.CLASSES[j])
			"class":
				for j in receive[i]:
					add += "класс" + " (" + tr(G.CLASSES[j])
			"tokens":
				for j in receive[i]:
					add += "жетоны силы" + " (" + tr(G.CLASSES[j]) + "," + str(receive[i][j])
			"ulti_tokens":
				for j in receive[i]:
					add += "жетоны навыка" + " (" + tr(G.CLASSES[j]) + "," + str(receive[i][j])
			"wild_tokens":
				add += "жетоны силы на любой класс" + " (" + str(receive[i])
			"wild_ulti_tokens":
				add += "жетоны навыка на любой класс" + " (" + str(receive[i])
			"potions1":
				add += "маленькое зелье" + " (" + str(receive[i])
			"potions2":
				add += "среднее зелье" + " (" + str(receive[i])
			"potions3":
				add += "большое зелье" + " (" + str(receive[i])
			"box":
				add += "ящик" + " (" + str(receive[i])
			"gold_box":
				add += "золотой ящик" + " (" + str(receive[i])
			"diamond_box":
				add += "алмазный ящик" + " (" + str(receive[i])
		add += ")"
	add[0] = ""
	add += " за"
	for i in cost:
		if i == "coins":
			add += " монеты (" + str(cost[i]) + ")"
		if i == "gems":
			add += " кристаллы (" + str(cost[i]) + ")"
	$confirm.dialog_text = "Действительно хочешь купить" + add + "?"
	$confirm.get_cancel().text = "Отмена"
	$confirm.popup_centered()


func confirm_buy():
	var rec = current_receive
	var c = current_cost
	var id = current_id
	var loot_to_show = {}
	current_receive = null
	current_cost = null
	current_id = -1
	for i in c:
		G.setv(i, G.getv(i, 0) - c[i])
	if id != -1:
		get_node("scroll/offers/offer" + str(id)).queue_free()
	if id > 1000:
		G.addv("online_offers_used_id", [id], [])
	remove_offer(id)
	G.receive_loot(rec)


func info_box():
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
	var hero_chance = G.getv("hero_chance", 1.0) if not classes_to_unlock.empty() else 0
	var amul_chance = 16 if not amulet_types.empty() else 0
	var gadget_chance = 4 if not gadget_classes.empty() else 0
	var sp_chance = 2 if not soul_power_classes.empty() else 0
	var coins_chance = 100 - hero_chance - gadget_chance - sp_chance - amul_chance
	var coins_suffix = " и Жетоны" if not power_classes.empty() or not ulti_classes.empty() else ""
	$info_boxes.dialog_text = """В ящике могут содержатся классы, монеты, жетоны и многое другое.
	Открытие золотого ящика равно открытию 3 ящиков.
	Открытие алмазного ящика равно открытию 10 ящиков.
	
	Шансы при открытии одного обычного ящика:
	Монеты{cs}: {cc}%
	Класс: {hc}%
	Фрагмент амулета: {ac}%
	Душевный навык: {gc}%
	Душевная сила: {sc}%
	Кристаллы (как бонус): 10%
	
	Получить душевный навык можно только на класс, достигший 15-го уровня силы, а душевную силу на класс, достигший 20-го уровня силы. Получать фрагменты амулетов можно после того, как один из классов достигнет 10-го уровня силы. После каждого открытого обычного ящика, в котором не было класса, шанс на него повышается на 0.06%. А если в ящике оказался класс, шанс падает до 1.5%. Начальный шанс - 2%. Если жетоны какого-то типа все классы не могут получить, то они конвертируются в монеты. 3 монеты за каждый жетон силы, 12 монет за каждый жетон навыка."""\
			.format({"cs":coins_suffix, "cc":coins_chance, "hc":hero_chance, "ac":amul_chance, "gc":gadget_chance, "sc":sp_chance})
	$info_boxes.popup_centered()


func _ready():
	$info_boxes.get_ok().hide()
	fetch_online_offers()
	init_iap()
	$confirm.get_ok().text = "Купить"
	current_day = Time.get_date_dict_from_system()["day"]
	current_unix_time = Time.get_unix_time_from_system()
	show_offers()


func show_offers():
	if G.getv("offers_upd", {"day": 0})["day"] != Time.get_date_dict_from_system()["day"] and \
			G.getv("offers_upd_time", Time.get_unix_time_from_system()) <= Time.get_unix_time_from_system():
		generate_offers()
		return
	for i in G.getv("offers", []):
		show_offer(i["costs"], i["receives"], i["id"], i["name"])
	if not G.getv("collected_ad_bonus", false) and G.ad.ads_available():
		var node = load("res://prefabs/menu/offer_ad.tscn").instance()
		$scroll/offers.add_child(node)
		$scroll/offers.move_child(node, 0)


func show_offer(costs, receives, id = 0, name = "АКЦИЯ"):
	var off = offer_obj.instance()
	off.name = "offer" + str(id)
	off.offer_rec = receives
	off.get_node("title").text = name
	if not costs.empty():
		off.get_node("buy").icon = gem if costs.has("gems") else coin
		off.get_node("buy").text = str(costs[costs.keys()[0]])
	else:
		off.get_node("buy").text = "БЕСПЛАТНО"
		off.get_node("buy").icon = null
	var l = 0
	for i in receives:
		off.get_node("items/item" + str(l)).show()
		if i == "coins":
			off.get_node("items/item" + str(l) + "/name").text = "МОНЕТЫ"
			off.get_node("items/item" + str(l) + "/icon").texture = coin
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "gems":
			off.get_node("items/item" + str(l) + "/name").text = "КРИСТАЛЛЫ"
			off.get_node("items/item" + str(l) + "/icon").texture = gem
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "gadget":
			for j in receives[i]:
				off.get_node("items/item" + str(l)).show()
				off.get_node("items/item" + str(l) + "/name").text = "ДУШ. НАВЫК"
				off.get_node("items/item" + str(l) + "/icon").texture = gadget
				off.get_node("items/item" + str(l) + "/count").text = tr(G.CLASSES[j])
				l += 1
		if i == "soul_power":
			for j in receives[i]:
				off.get_node("items/item" + str(l)).show()
				off.get_node("items/item" + str(l) + "/name").text = "ДУШ. СИЛА"
				off.get_node("items/item" + str(l) + "/icon").texture = sp
				off.get_node("items/item" + str(l) + "/count").text = tr(G.CLASSES[j])
				l += 1
		if i == "class":
			for j in receives[i]:
				off.get_node("items/item" + str(l)).show()
				off.get_node("items/item" + str(l) + "/name").text = "КЛАСС"
				off.get_node("items/item" + str(l) + "/icon").texture = CLASS_ICONS[j]
				off.get_node("items/item" + str(l) + "/count").text = tr(G.CLASSES[j])
				l += 1
		if i == "tokens":
			for j in receives[i]:
				off.get_node("items/item" + str(l)).show()
				off.get_node("items/item" + str(l) + "/name").text = "ЖЕТОНЫ СИЛЫ"
				off.get_node("items/item" + str(l) + "/icon").texture = token
				off.get_node("items/item" + str(l) + "/icon").self_modulate = G.CLASS_COLORS[j]
				off.get_node("items/item" + str(l) + "/icon/sub").texture = CLASS_ICONS[j]
				off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i][j])
				l += 1
		if i == "ulti_tokens":
			for j in receives[i]:
				off.get_node("items/item" + str(l)).show()
				off.get_node("items/item" + str(l) + "/name").text = "ЖЕТОНЫ НАВЫКА"
				off.get_node("items/item" + str(l) + "/icon").texture = ulti_token
				off.get_node("items/item" + str(l) + "/icon").self_modulate = G.CLASS_COLORS[j]
				off.get_node("items/item" + str(l) + "/icon/sub").texture = ULTI_ICONS[j]
				off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i][j])
				l += 1
		if i == "amulet_frags":
			for j in receives[i]:
				off.get_node("items/item" + str(l)).show()
				off.get_node("items/item" + str(l) + "/name").text = "ФР. АМУЛЕТА"
				off.get_node("items/item" + str(l) + "/icon").texture = AMULET_ICONS[j]
				off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i][j])
				l += 1
		if i == "wild_tokens":
			off.get_node("items/item" + str(l) + "/name").text = "ЖЕТОНЫ СИЛЫ"
			off.get_node("items/item" + str(l) + "/icon").texture = wild_token
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "wild_ulti_tokens":
			off.get_node("items/item" + str(l) + "/name").text = "ЖЕТОНЫ НАВЫКА"
			off.get_node("items/item" + str(l) + "/icon").texture = wild_ulti_token
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "potions1":
			off.get_node("items/item" + str(l) + "/name").text = "МАЛЕНЬКОЕ ЗЕЛЬЕ"
			off.get_node("items/item" + str(l) + "/icon").texture = POTIONS_ICONS["small"]
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "potions2":
			off.get_node("items/item" + str(l) + "/name").text = "СРЕДНЕЕ ЗЕЛЬЕ"
			off.get_node("items/item" + str(l) + "/icon").texture = POTIONS_ICONS["normal"]
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "potions3":
			off.get_node("items/item" + str(l) + "/name").text = "БОЛЬШОЕ ЗЕЛЬЕ"
			off.get_node("items/item" + str(l) + "/icon").texture = POTIONS_ICONS["big"]
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "box":
			off.get_node("items/item" + str(l) + "/name").text = "ЯЩИК"
			off.get_node("items/item" + str(l) + "/icon").texture = box
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "gold_box":
			off.get_node("items/item" + str(l) + "/name").text = "ЗОЛОТОЙ ЯЩИК"
			off.get_node("items/item" + str(l) + "/icon").texture = gold_box
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
		if i == "diamond_box":
			off.get_node("items/item" + str(l) + "/name").text = "АЛМАЗНЫЙ ЯЩИК"
			off.get_node("items/item" + str(l) + "/icon").texture = diamond_box
			off.get_node("items/item" + str(l) + "/count").text = "x" + str(receives[i])
			l += 1
	off.get_node("buy").connect("pressed", self, "buy", [JSON.print(costs), JSON.print(receives), id])
	$scroll/offers.add_child(off)
	$scroll/offers.move_child(off, 0)


func remove_offer(id):
	var offs = G.getv("offers", [])
	for i in G.getv("offers", []):
		if i["id"] == id:
			offs.erase(i)


func generate_offers():
	G.setv("offers", [])
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
	var gen = RandomNumberGenerator.new()
	gen.randomize()
	randomize()
	var i = 0
	var limit = gen.randi_range(3, 6)
	while true:
		if i >= limit:
			break
		var offer = {}
		var list_of_types = [0, 1, 1, 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 10, 10, 10]
		list_of_types.shuffle()
		var type = list_of_types[4]
		if type == 0:
			#COINS
			var mul = [1, 2, 4, 1, 1, 2]
			mul.shuffle()
			var discount = [1.1, 1.1, 1.1, 1.2, 1.2, 1.3]
			discount.shuffle()
			var cc = 2250 * mul[1] * discount[3]
			var cost = 15 if mul[1] == 1 else 25 if mul[1] == 2 else 45
			offer = {"costs": {"gems" : cost}, "receives" : {"coins" : cc}, "id" : i, "name" : "АКЦИЯ"}
		if type == 1:
			#POTIONS
			var t = ["1", "1", "2", "2", "3"]
			t.shuffle()
			var discount = [0.9, 0.9, 0.8, 0.7]
			discount.shuffle()
			var c = gen.randi_range(1, clamp(5 - G.getv("potions" + t[2], 0), 1, 3))
			var cost_1 = 300 if t[2] == "1" else 650 if t[2] == "2" else 1000
			var cost = cost_1 * c * discount[1]
			if G.getv("potions" + t[2], 0) + c > 5:
				continue
			offer = {"costs": {"coins" : cost}, "receives" : {"potions" + t[2] : c}, "id" : i, "name" : "АКЦИЯ"}
		if type == 2:
			#BOX
			var cost = gen.randi_range(2, 3)
			var count = gen.randi_range(2, 10)
			offer = {"costs": {"gems" : cost * count}, "receives" : {"box" : count}, "id" : i, "name" : "АКЦИЯ"}
		if type == 3:
			#BOX GOLD
			var cost = 10 - gen.randi_range(2, 4)
			var count = gen.randi_range(1, 5)
			offer = {"costs": {"gems" : cost * count}, "receives" : {"gold_box" : count}, "id" : i, "name" : "АКЦИЯ"}
		if type == 4:
			#DIAMOND BOX
			var cost = 30 - gen.randi_range(1, 3) * 5
			var count = gen.randi_range(1, 3)
			offer = {"costs": {"gems" : cost * count}, "receives" : {"diamond_box" : count}, "id" : i, "name" : "АКЦИЯ"}
		if type == 5:
			#GADGET
			if not gadget_classes.empty():
				gadget_classes.shuffle()
				var to = gadget_classes[0]
				offer = {"costs": {"coins" : 500}, "receives" : {"gadget" : [to]}, "id" : i, "name" : "АКЦИЯ"}
			else:
				continue
		if type == 6:
			#SOUL POWER
			if not soul_power_classes.empty():
				soul_power_classes.shuffle()
				var to = soul_power_classes[0]
				offer = {"costs": {"coins" : 1000}, "receives" : {"soul_power" : [to]}, "id" : i, "name" : "АКЦИЯ"}
			else:
				continue
		if type == 7:
			#TOKENS
			if randi() % 2 == 1:
				#POWER
				if power_classes.empty():
					continue
				power_classes.shuffle()
				var to = power_classes[0]
				var count = 20 + gen.randi_range(0, 10) * 10
				offer = {"costs": {"coins" : count * 5}, "receives" : {"tokens" : {to: count }}, "id" : i, "name" : "АКЦИЯ"}
			else:
				#ULTI
				if ulti_classes.empty():
					continue
				ulti_classes.shuffle()
				var to = ulti_classes[0]
				var count = 10 + gen.randi_range(0, 15)
				offer = {"costs": {"coins" : count * 20}, "receives" : {"ulti_tokens" : {to: count }}, "id" : i, "name" : "АКЦИЯ"}
		if type == 8:
			#CLASS
			if classes_to_unlock.empty():
				continue
			classes_to_unlock.shuffle()
			var what = classes_to_unlock[0]
			var count_of_pt = 0
			var count_of_ut = 0
			var cost = 30
			if randi() % 3 == 1:
				count_of_pt = 80 + gen.randi_range(0, 1) * 40
				if count_of_pt == 80:
					cost += 5
				else:
					cost += 8
			if randi() % 3 == 2:
				count_of_ut = 20 + gen.randi_range(0, 1) * 10
				if count_of_ut == 20:
					cost += 5
				else:
					cost += 7
			if count_of_pt == 0 and count_of_ut == 0:
				offer = {"costs": {"gems" : cost}, "receives" : {"class" : [what]}, "id" : i, "name" : "КЛАСС"}
			elif count_of_pt == 0 and count_of_ut != 0:
				offer = {"costs": {"gems" : cost}, "receives" : {"class" : [what], "ulti_tokens" : {what: count_of_ut }}, "id" : i, "name" : "НАБОР КЛАССА"}
			elif count_of_pt != 0 and count_of_ut == 0:
				offer = {"costs": {"gems" : cost}, "receives" : {"class" : [what], "tokens" : {what: count_of_pt}}, "id" : i, "name" : "НАБОР КЛАССА"}
			else:
				offer = {"costs": {"gems" : cost}, "receives" : {"class" : [what], "tokens" : {what: count_of_pt}, "ulti_tokens" : {what: count_of_ut}}, "id" : i, "name" : "НАБОР КЛАССА"}
		if type == 9: #WILD TOKENS
			if randi() % 2 == 1:
				#POWER
				if power_classes.empty():
					continue
				var count = 20 + gen.randi_range(0, 10) * 10
				offer = {"costs": {"coins" : count * 7}, "receives" : {"wild_tokens" : count}, "id" : i, "name" : "АКЦИЯ"}
			else:
				#ULTI
				if ulti_classes.empty():
					continue
				var count = 10 + gen.randi_range(0, 15)
				offer = {"costs": {"coins" : count * 25}, "receives" : {"wild_ulti_tokens" : count}, "id" : i, "name" : "АКЦИЯ"}
		if type == 10:
			# AMULET FRAGS
			if amulet_types.empty():
				continue
			var count = randi() % 2 + 1
			amulet_types.shuffle()
			var am_type = amulet_types[0]
			offer = {"costs": {"coins" : count * 150}, "receives" : {"amulet_frags": {am_type:count}}, "id" : i, "name" : "АКЦИЯ"}
		var exists = false
		for y in G.getv("offers", []):
			if offer["receives"].hash() == y["receives"].hash():
				exists = true
		if exists:
			continue
		G.setv("offers", G.getv("offers", []) + [offer])
		G.save()
		i += 1
	var free_receives = [{"gold_box":1}, {"gems":gen.randi_range(1, 2)}, {"coins":10*gen.randi_range(15, 30)}]
	if not power_classes.empty():
		power_classes.shuffle()
		free_receives.append({"tokens":{power_classes[0]: gen.randi_range(10, 20)*2}})
	if not ulti_classes.empty():
		ulti_classes.shuffle()
		free_receives.append({"ulti_tokens":{ulti_classes[0]: gen.randi_range(5, 10)}})
	if not amulet_types.empty():
		amulet_types.shuffle()
		free_receives.append({"amulet_frags":{amulet_types[0]:1}})
	if G.getv("potions1", 0) < 5:
		free_receives.append({"potions1": 1})
	free_receives.shuffle()
	G.setv("offers", G.getv("offers", []) + [{"costs":{}, "receives":free_receives[0], "id" : 993, "name" : "ПОДАРОК!"}])
	G.save()
	G.setv("offers_upd", Time.get_date_dict_from_system())
	G.setv("offers_upd_time", Time.get_unix_time_from_system())
	G.setv("collected_ad_bonus", false)
	show_offers()


func promocodes():
	get_tree().change_scene("res://scenes/menu/promocodes.tscn")


func fetch_online_offers():
	http.download_file = OS.get_cache_dir().plus_file("online_cache.cfg")
	http.connect("request_completed", self, "request_online_response", [], CONNECT_ONESHOT)
	var err = http.request("http://f0695447.xsph.ru/apa2_online.cfg")
	if err:
		print("fetch failed:", err)


func request_online_response(result, code, header, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("fetch failed:", result, " ", code)
		return
	yield(get_tree(), "idle_frame")
	var cf = ConfigFile.new()
	var err = cf.load_encrypted_pass(OS.get_cache_dir().plus_file("online_cache.cfg"), "apa2_online")
	var dir = Directory.new()
	dir.open(OS.get_cache_dir())
	dir.remove("online_cache.cfg")
	if err:
		print("fetch failed:", err)
		return
	if not cf.has_section("offers"):
		print("fetch failed:", "no offers")
		return
	for i in cf.get_section_keys("offers"):
		if int(i) in G.getv("online_offers_used_id", []):
			continue
		var j = cf.get_value("offers", i, {})
		if j.has("ids"):
			if not G.getv("save_id", "none") in j["ids"]:
				continue
		show_offer(j["costs"], j["receives"], int(i), j["name"])


func _exit_tree():
	var dir = Directory.new()
	dir.remove("user://online_cache.cfg")
