function Hair(_name, _sprite, _id, _hairBackWithoutHat = true) constructor {
	hairId = _id
	name = _name;
	sprite = _sprite;
	drawBackWithoutHat = _hairBackWithoutHat;
}

enum HairOption {
	BALD,
	QUIFF,
	BUZZ_CUT,
	LONG_STRAIGHT,
	MOHAWK,
	AFRO
}

global.hairOptions[HairOption.QUIFF] = new Hair("Topete Gay", spr_hair_quiff, HairOption.QUIFF);
global.hairOptions[HairOption.BUZZ_CUT] = new Hair("Corte Militar", spr_hair_buzz_cut, HairOption.BUZZ_CUT);
global.hairOptions[HairOption.LONG_STRAIGHT] = new Hair("Longo Liso", spr_hair_long_straight, HairOption.LONG_STRAIGHT);
global.hairOptions[HairOption.MOHAWK] = new Hair("Moicano", spr_hair_mohawk, HairOption.MOHAWK);
global.hairOptions[HairOption.AFRO] = new Hair("Afro", spr_hair_afro, HairOption.AFRO, false);