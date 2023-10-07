extends Attack


enum DamageMode {
	ON_MOVE = 0,
	ON_STILL = 1,
}


export (DamageMode) var damage_mode = DamageMode.ON_MOVE


func deal_damage(mob):
	match damage_mode:
		DamageMode.ON_MOVE:
			if mob._move.length_squared() < 25:
				return false
		DamageMode.ON_STILL:
			if mob._move.length_squared() > 25:
				return false
	return .deal_damage(mob)
