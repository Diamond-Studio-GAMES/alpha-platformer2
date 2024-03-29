class_name Achievements, "res://textures/achievements/complete.png"
extends CanvasLayer


const BOSS1 = "boss1"
const BOSS2 = "boss2"
const BOSS3 = "boss3"
const BOSS4 = "boss4"
const BOSS5 = "boss5"
const BOSS6 = "boss6"
const BOSS7 = "boss7"
const BOSS8 = "boss8"
const BOSS9 = "boss9"
const BOSS10 = "boss10"
const WHAT_IS_IT = "first_class"
const MASTER_OF_WEAPONS = "all_classes"
const IM_POWER = "class_maxed"
const LUCKY_AMULET = "first_amulet"
const HELP_FROM_INSIDE = "first_gadget"
const SOUL_MASTER = "first_sp"
const DARK_CREATION = "death"
const POTION_MAN = "10_potions"
const PROZAPASS = "max_potions"
const BURN_HER_FASTER = "burn_enemy"
const THIS_IS_SPARTA = "fall_enemy_death"
const BOMBER = "tnt_enemy_death"
const FUUUUCK = "death_with_potion"
const SOME_PEOPLES = "about"
const REZNYA = "reznya"
const CLEARED = "dyh"
const DIAMONDS = "ss_gem"
const LAST_STANDER = "ls"
const DASHER = "pd_level_done"
const LOOT = "garden_loot"
const VICTORY_ROYALE = "2d_shooter_win"
const ESCAPE = "fnas_done"
const UNTOUCHED = "no_damage"
const BETTER_TOGETHER = "mp_level"
const GOOD_PARTNER = "mp_revive_5"
const SCREW_IT = "mp_level_died"
const WHAT_A_WASTE = "level_died"
const ON_THE_EDGE = "almost_died"
const ORIGIN = "lore_seen"
const KILLER = "killer"
const YOU_MISSED = "dodge_shot"
const AIR = "almost_drown"
const FALL = "fall_damaged"
const SKILL = "skill_used"
const BEAR = "beartraped"
const PACIFIST = "no_kills"
const REJECTED = "reject"
const RETURN_TO_SENDER = "self_damage"
const HACKER = "boxes_opened"
const SOMETHING = "something"
const HERO = "complete"

signal effect_completed
var blocked_counter = 0
var achievement_get = load("res://prefabs/menu/achievement_complete.tscn")
var achievements = {
	HERO : {
		"icon" : load("res://textures/achievements/complete.png"),
		"name" : "achv.hero",
		"desc" : "achv.hero.desc"
	},
	# Boss achievemnts
	BOSS1 : {
		"icon" : load("res://textures/achievements/boss1.png"),
		"name" : "achv.boss1",
		"desc" : "achv.boss1.desc"
	},
	BOSS2 : {
		"icon" : load("res://textures/achievements/boss2.png"),
		"name" : "achv.boss2",
		"desc" : "achv.boss2.desc"
	},
	BOSS3 : {
		"icon" : load("res://textures/achievements/boss3.png"),
		"name" : "achv.boss3",
		"desc" : "achv.boss3.desc"
	},
	BOSS4 : {
		"icon" : load("res://textures/achievements/boss4.png"),
		"name" : "achv.boss4",
		"desc" : "achv.boss4.desc"
	},
	BOSS5 : {
		"icon" : load("res://textures/achievements/boss5.png"),
		"name" : "achv.boss5",
		"desc" : "achv.boss5.desc"
	},
	BOSS6 : {
		"icon" : load("res://textures/achievements/boss6.png"),
		"name" : "achv.boss6",
		"desc" : "achv.boss6.desc"
	},
	BOSS7 : {
		"icon" : load("res://textures/achievements/boss7.png"),
		"name" : "achv.boss7",
		"desc" : "achv.boss7.desc"
	},
	BOSS8 : {
		"icon" : load("res://textures/achievements/boss8.png"),
		"name" : "achv.boss8",
		"desc" : "achv.boss8.desc"
	},
	BOSS9 : {
		"icon" : load("res://textures/achievements/boss9.png"),
		"name" : "achv.boss9",
		"desc" : "achv.boss9.desc"
	},
	BOSS10 : {
		"icon" : load("res://textures/achievements/boss10.png"),
		"name" : "achv.boss10",
		"desc" : "achv.boss10.desc"
	},
	# Upgrade achievements
	WHAT_IS_IT : {
		"icon" : load("res://textures/achievements/first_class.png"),
		"name" : "achv.what_is_it",
		"desc" : "achv.what_is_it.desc"
	},
	MASTER_OF_WEAPONS : {
		"icon" : load("res://textures/achievements/all_classes.png"),
		"name" : "achv.master",
		"desc" : "achv.master.desc"
	},
	LUCKY_AMULET : {
		"icon" : load("res://textures/achievements/first_amulet.png"),
		"name" : "achv.lucky_amulet",
		"desc" : "achv.lucky_amulet.desc"
	},
	HELP_FROM_INSIDE : {
		"icon" : load("res://textures/achievements/first_gadget.png"),
		"name" : "achv.help_from_inside",
		"desc" : "achv.help_from_inside.desc"
	},
	SOUL_MASTER : {
		"icon" : load("res://textures/achievements/first_sp.png"),
		"name" : "achv.soul_master",
		"desc" : "achv.soul_master.desc"
	},
	IM_POWER : {
		"icon" : load("res://textures/achievements/class_maxed.png"),
		"name" : "achv.im_power",
		"desc" : "achv.im_power.desc"
	},
	HACKER : {
		"icon" : load("res://textures/achievements/boxes_opened.png"),
		"name" : "achv.hacker",
		"desc" : "achv.hacker.desc"
	},
	POTION_MAN : {
		"icon" : load("res://textures/achievements/10_potions.png"),
		"name" : "achv.potion_man",
		"desc" : "achv.potion_man.desc"
	},
	PROZAPASS : {
		"icon" : load("res://textures/achievements/max_potions.png"),
		"name" : "achv.prozapass",
		"desc" : "achv.prozapass.desc"
	},
	FUUUUCK : {
		"icon" : load("res://textures/achievements/death_with_potion.png"),
		"name" : "achv.fuck",
		"desc" : "achv.fuck.desc"
	},
	# Game achievemnts
	BURN_HER_FASTER : {
		"icon" : load("res://textures/achievements/burn_enemy.png"),
		"name" : "achv.burn_her_faster",
		"desc" : "achv.burn_her_faster.desc"
	},
	THIS_IS_SPARTA : {
		"icon" : load("res://textures/achievements/fall_enemy_death.png"),
		"name" : "achv.this_is_sparta",
		"desc" : "achv.this_is_sparta.desc"
	},
	BOMBER : {
		"icon" : load("res://textures/achievements/tnt_enemy_death.png"),
		"name" : "achv.bomber",
		"desc" : "achv.bomber.desc"
	},
	KILLER : {
		"icon" : load("res://textures/achievements/killer.png"),
		"name" : "achv.killer",
		"desc" : "achv.killer.desc"
	},
	AIR : {
		"icon" : load("res://textures/achievements/almost_drown.png"),
		"name" : "achv.air",
		"desc" : "achv.air.desc"
	},
	FALL : {
		"icon" : load("res://textures/achievements/fall_damaged.png"),
		"name" : "achv.fall",
		"desc" : "achv.fall.desc"
	},
	SKILL : {
		"icon" : load("res://textures/achievements/skill_used.png"),
		"name" : "achv.skill",
		"desc" : "achv.skill.desc"
	},
	BEAR : {
		"icon" : load("res://textures/achievements/beartraped.png"),
		"name" : "achv.bear",
		"desc" : "achv.bear.desc"
	},
	REJECTED : {
		"icon" : load("res://textures/achievements/reject.png"),
		"name" : "achv.rejected",
		"desc" : "achv.rejected.desc"
	},
	RETURN_TO_SENDER : {
		"icon" : load("res://textures/achievements/self_damage.png"),
		"name" : "achv.return_to_sender",
		"desc" : "achv.return_to_sender.desc"
	},
	YOU_MISSED : {
		"icon" : load("res://textures/achievements/dodge_shot.png"),
		"name" : "achv.you_missed",
		"desc" : "achv.you_missed.desc"
	},
	GOOD_PARTNER : {
		"icon" : load("res://textures/achievements/mp_revive_5.png"),
		"name" : "achv.good_partner",
		"desc" : "achv.good_partner.desc"
	},
	# End level achievements
	BETTER_TOGETHER : {
		"icon" : load("res://textures/achievements/mp_level.png"),
		"name" : "achv.better_together",
		"desc" : "achv.better_together.desc"
	},
	SCREW_IT : {
		"icon" : load("res://textures/achievements/mp_level_died.png"),
		"name" : "achv.screw_it",
		"desc" : "achv.screw_it.desc"
	},
	WHAT_A_WASTE : {
		"icon" : load("res://textures/achievements/level_died.png"),
		"name" : "achv.what_a_waste",
		"desc" : "achv.what_a_waste.desc"
	},
	ON_THE_EDGE : {
		"icon" : load("res://textures/achievements/almost_died.png"),
		"name" : "achv.on_the_edge",
		"desc" : "achv.on_the_edge.desc"
	},
	UNTOUCHED : {
		"icon" : load("res://textures/achievements/no_damage.png"),
		"name" : "achv.untouched",
		"desc" : "achv.untouched.desc"
	},
	PACIFIST : {
		"icon" : load("res://textures/achievements/no_kills.png"),
		"name" : "achv.pacifist",
		"desc" : "achv.pacifist.desc"
	},
	# Misc achievemnts
	SOME_PEOPLES : {
		"icon" : load("res://textures/achievements/about.png"),
		"name" : "achv.some_peoples",
		"desc" : "achv.some_peoples.desc"
	},
	DARK_CREATION : {
		"icon" : load("res://textures/achievements/death.png"),
		"name" : "achv.dark_creation",
		"desc" : "achv.dark_creation.desc"
	},
	ORIGIN : {
		"icon" : load("res://textures/achievements/lore_seen.png"),
		"name" : "achv.origin",
		"desc" : "achv.origin.desc"
	},
	# Minigame achievements
	REZNYA : {
		"icon" : load("res://textures/achievements/reznya.png"),
		"name" : "achv.reznya",
		"desc" : "achv.reznya.desc"
	},
	CLEARED : {
		"icon" : load("res://textures/achievements/dyh.png"),
		"name" : "achv.cleared",
		"desc" : "achv.cleared.desc"
	},
	DIAMONDS : {
		"icon" : load("res://textures/achievements/ss_gem.png"),
		"name" : "achv.diamonds",
		"desc" : "achv.diamonds.desc"
	},
	LAST_STANDER : {
		"icon" : load("res://textures/achievements/ls.png"),
		"name" : "achv.last_stander",
		"desc" : "achv.last_stander.desc"
	},
	DASHER : {
		"icon" : load("res://textures/achievements/pd_level_done.png"),
		"name" : "Dasher",
		"desc" : "achv.dasher.desc"
	},
	LOOT : {
		"icon" : load("res://textures/achievements/garden_loot.png"),
		"name" : "achv.loot",
		"desc" : "achv.loot.desc"
	},
	VICTORY_ROYALE : {
		"icon" : load("res://textures/achievements/2d_shooter_win.png"),
		"name" : "Victory Royale #1",
		"desc" : "achv.victory_royale.desc"
	},
	ESCAPE : {
		"icon" : load("res://textures/achievements/fnas_done.png"),
		"name" : "achv.escape",
		"desc" : "achv.escape.desc"
	},
}


func complete(id):
	if is_completed(id):
		return
	G.setv("achv_" + id + "_done", true)
	blocked_counter += 1
	for i in range(blocked_counter - 1):
		yield(self, "effect_completed")
	var effect = achievement_get.instance()
	effect.get_node("panel/name").text = tr(achievements[id]["name"]) + "!"
	effect.get_node("panel/desc").text = tr(achievements[id]["desc"])
	effect.get_node("panel/bg/icon").texture = achievements[id]["icon"]
	add_child(effect)
	yield(effect, "tree_exited")
	blocked_counter -= 1
	emit_signal("effect_completed")


func is_completed(id):
	return G.getv("achv_" + id + "_done", false)


func check(id):
	if is_completed(id):
		return
	match id:
		POTION_MAN:
			if G.getv("potions_used") >= 10:
				complete(id)
		PROZAPASS:
			if G.getv("potions1") + G.getv("potions2") + G.getv("potions3") == 6:
				complete(id)
		LOOT:
			if G.getv("garden_looted") >= 3:
				complete(id)
		GOOD_PARTNER:
			if G.getv("mp_revives") >= 5:
				complete(id)
		KILLER:
			if G.getv("kills") >= 250:
				complete(id)
		SKILL:
			if G.getv("ulti_used") >= 15:
				complete(id)
		BEAR:
			if G.getv("beartraped") >= 10:
				complete(id)
		HACKER:
			if G.getv("boxes_opened") >= 50:
				complete(id)
