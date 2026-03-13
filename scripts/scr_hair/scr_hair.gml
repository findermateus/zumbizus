function Hair(_name, _sprite, _id, _hairBackWithoutHat = true) constructor {
	hairId = _id
	name = _name;
	sprite = _sprite;
	drawBackWithoutHat = _hairBackWithoutHat;
}

enum hairIds {
	bald,
	quiff,
	buzzCut,
	longStraight,
	mohawk,
	afro
}

global.hairOptions[hairIds.quiff] = new Hair("Topete Gay", spr_hair_quiff, hairIds.quiff);
global.hairOptions[hairIds.buzzCut] = new Hair("Corte Militar", spr_hair_buzz_cut, hairIds.buzzCut);
global.hairOptions[hairIds.longStraight] = new Hair("Longo Liso", spr_hair_long_straight, hairIds.longStraight);
global.hairOptions[hairIds.mohawk] = new Hair("Moicano", spr_hair_mohawk, hairIds.mohawk);
global.hairOptions[hairIds.afro] = new Hair("Afro", spr_hair_afro, hairIds.afro, false);