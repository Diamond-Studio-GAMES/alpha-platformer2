class_name Achievements
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
const MY_LEG = "fall_damage"
const SKILL_UPGRADING = "skill_used_10"

signal effect_completed
var blocked_counter = 0
var achievement_get = load("res://prefabs/menu/achievement_complete.scn")
var achievements = {
	BOSS1 : {
		"icon" : load("res://textures/achievements/boss1.png"),
		"name" : "Это мои овцы",
		"desc" : "Победите Пастуха."
	},
	BOSS2 : {
		"icon" : load("res://textures/achievements/boss2.png"),
		"name" : "Экологический борец",
		"desc" : "Победите Лесоруба."
	},
	BOSS3 : {
		"icon" : load("res://textures/achievements/boss3.png"),
		"name" : "Белый маг",
		"desc" : "Победите Чёрного мага."
	},
	BOSS4 : {
		"icon" : load("res://textures/achievements/boss4.png"),
		"name" : "Фехтовальщик",
		"desc" : "Победите Великого рыцаря."
	},
	BOSS5 : {
		"icon" : load("res://textures/achievements/boss5.png"),
		"name" : "Без талона",
		"desc" : "Победите Хирурга."
	},
	BOSS6 : {
		"icon" : load("res://textures/achievements/boss6.png"),
		"name" : "Пожарник",
		"desc" : "Победите Огненного стража."
	},
	WHAT_IS_IT : {
		"icon" : load("res://textures/achievements/first_class.png"),
		"name" : "Это что?",
		"desc" : "Откройте первый класс."
	},
	MASTER_OF_WEAPONS : {
		"icon" : load("res://textures/achievements/all_classes.png"),
		"name" : "Мастер всех оружий",
		"desc" : "Откройте все классы."
	},
	IM_POWER : {
		"icon" : load("res://textures/achievements/class_maxed.png"),
		"name" : "Сама сила",
		"desc" : "Прокачайте класс на максимум."
	},
	LUCKY_AMULET : {
		"icon" : load("res://textures/achievements/first_amulet.png"),
		"name" : "На удачу",
		"desc" : "Откройте первый амулет."
	},
	HELP_FROM_INSIDE : {
		"icon" : load("res://textures/achievements/first_gadget.png"),
		"name" : "Помощь изнутри",
		"desc" : "Откройте первый душевный навык."
	},
	SOUL_MASTER : {
		"icon" : load("res://textures/achievements/first_sp.png"),
		"name" : "Мастер души",
		"desc" : "Откройте первую душевную силу."
	},
	DARK_CREATION : {
		"icon" : load("res://textures/achievements/death.png"),
		"name" : "Воплощение тьмы",
		"desc" : "Встретьте саму Смерть."
	},
	POTION_MAN : {
		"icon" : load("res://textures/achievements/10_potions.png"),
		"name" : "Зельеман",
		"desc" : "Используйте зелья 10 раз."
	},
	PROZAPASS : {
		"icon" : load("res://textures/achievements/max_potions.png"),
		"name" : "Прозапас",
		"desc" : "Получите по 5 зелий каждого вида."
	},
	BURN_HER_FASTER : {
		"icon" : load("res://textures/achievements/burn_enemy.png"),
		"name" : "Кремируйте её быстрее!",
		"desc" : "Сожгите врага."
	},
	THIS_IS_SPARTA : {
		"icon" : load("res://textures/achievements/fall_enemy_death.png"),
		"name" : "Это... Спарта",
		"desc" : "Заставьте монстра умереть от падения."
	},
	FUUUUCK : {
		"icon" : load("res://textures/achievements/death_with_potion.png"),
		"name" : "ДА ТЫ ЧТО..",
		"desc" : "Умрите во время использования зелья..."
	},
	SOME_PEOPLES : {
		"icon" : load("res://textures/achievements/about.png"),
		"name" : "Какие-то человеки..",
		"desc" : "Посмотрите создателей игры."
	},
	REZNYA : {
		"icon" : load("res://textures/achievements/reznya.png"),
		"name" : "Резня",
		"desc" : 'Пройдите мини-игру "Резня".'
	},
	CLEARED : {
		"icon" : load("res://textures/achievements/dyh.png"),
		"name" : "Очищение",
		"desc" : 'Пройдите мини-игру "Изб. от ненависти".'
	},
	DIAMONDS : {
		"icon" : load("res://textures/achievements/ss_gem.png"),
		"name" : "АЛМАЗЫ!!",
		"desc" : 'Подберите кристалл в "Симуляторе камня".'
	},
	LAST_STANDER : {
		"icon" : load("res://textures/achievements/ls.png"),
		"name" : "Последний оплот",
		"desc" : 'Пройдите мини-игру "Последние волны".'
	},
	DASHER : {
		"icon" : load("res://textures/achievements/pd_level_done.png"),
		"name" : "Dasher",
		"desc" : 'Пройдите уровень в мини-игре "Platformer Dash".'
	},
	LOOT : {
		"icon" : load("res://textures/achievements/garden_loot.png"),
		"name" : "Урожай",
		"desc" : 'Соберите награду с 3 растений в "Саду".'
	},
	VICTORY_ROYALE : {
		"icon" : load("res://textures/achievements/2d_shooter_win.png"),
		"name" : "Victory Royale #1",
		"desc" : 'Выиграйте 1 игру в "2Д-шутере".'
	},
	ESCAPE : {
		"icon" : load("res://textures/achievements/fnas_done.png"),
		"name" : "Побег",
		"desc" : 'Пройдите мини-игру "FNaS"...'
	},
	UNTOUCHED : {
		"icon" : load("res://textures/achievements/no_damage.png"),
		"name" : "Неприкасаемый",
		"desc" : "Пройдите уровень, не получив урон."
	},
	BETTER_TOGETHER : {
		"icon" : load("res://textures/achievements/mp_level.png"),
		"name" : "Вместе сильнее",
		"desc" : "Пройдите любой уровень в мультиплеере."
	},
	GOOD_PARTNER : {
		"icon" : load("res://textures/achievements/mp_revive_5.png"),
		"name" : "Надёжный товарищ",
		"desc" : "Воскресите напарника 5 раз."
	},
	SCREW_IT : {
		"icon" : load("res://textures/achievements/mp_level_died.png"),
		"name" : "Беззаботность",
		"desc" : "Дайте товарищу завершить уровень, пока вы лежите на земле."
	},
	WHAT_A_WASTE : {
		"icon" : load("res://textures/achievements/level_died.png"),
		"name" : "Какая жалость!",
		"desc" : "Пройдите уровень с 0 здоровья."
	},
	ON_THE_EDGE : {
		"icon" : load("res://textures/achievements/almost_died.png"),
		"name" : "На грани",
		"desc" : "Завершите уровень с меньше, чем 10% здоровья."
	},
	ORIGIN : {
		"icon" : load("res://textures/achievements/lore_seen.png"),
		"name" : "Начало",
		"desc" : "Вспомните своё прошлое."
	},
	KILLER : {
		"icon" : load("res://textures/achievements/killer.png"),
		"name" : "Убийца",
		"desc" : "Сделайте 250 убийств."
	},
	YOU_MISSED : {
		"icon" : load("res://textures/achievements/dodge_shot.png"),
		"name" : "Ха! Не попал",
		"desc" : "Уклонитесь от атаки."
	},
}


func complete(id):
	if is_completed(id):
		return
	G.setv("achv_" + id + "_done", true)
	blocked_counter += 1
	for i in range(blocked_counter-1):
		yield(self, "effect_completed")
	var effect = achievement_get.instance()
	effect.get_node("panel/name").text = achievements[id]["name"] + "!"
	effect.get_node("panel/desc").text = achievements[id]["desc"]
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
			if G.getv("potions1") + G.getv("potions2") + G.getv("potions3") == 15:
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
		
