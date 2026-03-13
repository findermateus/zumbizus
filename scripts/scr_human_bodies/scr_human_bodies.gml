enum drawStates {
	iddle,
	walking
}

enum genders {
	male,
	female,
	others
}

global.genders = {
	male: genders.male,
	female: genders.female,
	others: genders.others
}

global.genderList = [];

global.genderList[global.genders.male] = {
	title: "Masculino",
	id: global.genders.male
};

global.genderList[global.genders.female] = {
	title: "Feminino",
	id: global.genders.female
};

function getBodySprite(_gender, _drawState) {
	if (_gender == genders.female) {
		return _drawState == drawStates.iddle ? spr_human_female_iddle : spr_human_female_walking;
	}
	return _drawState == drawStates.iddle ? spr_human_male_iddle : spr_human_male_walking;
}

function drawBackPartOfHair(_hair, _helmet, _x, _y, _direction, _scale, _angle, _alpha) {
	if (array_length(global.hairOptions) <= _hair.hairId) return;
	var _hairOption = global.hairOptions[_hair.hairId];
	if (!is_struct(_helmet) && !_hairOption.drawBackWithoutHat) return;
	drawHair(_x, _y, _hair.hairId, _hair.color, _direction, _scale, _angle, _alpha, true);
}

function drawPersonBody(_x, _y, _gender, _imageIndex, _scale, _angle, _alpha, _skinColor, _hair, _armor = -1, _helmet = -1, _bag = -1, _direction = 1, _drawState = drawStates.iddle) {
	
	if (_bag != -1) {
		drawBackPack(_x, _y, _bag, _direction, _scale, _angle, _alpha, 0);
	}
	
	if (_hair.hairId != hairIds.bald) {
		drawBackPartOfHair(_hair, _helmet, _x, _y, _direction, _scale, _angle, _alpha);
	}
	
	var _sprite = getBodySprite(_gender, _drawState);
	
	draw_sprite_ext(_sprite, _imageIndex, _x, _y, _scale * _direction, _scale, _angle, _skinColor, _alpha);
	
	if (_armor != -1) {
		drawArmor(_x, _y, _armor, _direction, _scale, _angle, _alpha, _drawState, _imageIndex, _gender);
	}
	if (_helmet == -1 && _hair.hairId != hairIds.bald) {
		drawHair(_x, _y, _hair.hairId, _hair.color, _direction, _scale, _angle, _alpha);
	}
	if (_bag != -1) {
		drawBackPack(_x, _y, _bag, _direction, _scale, _angle, _alpha, 1);
	}
	if (_helmet != -1) {
		drawHelmet(_x, _y, _helmet, _direction, _scale, _angle, _alpha);
	}
}

function drawArmor(_x, _y, _itemId, _direction, _scale, _angle, _alpha, _drawState, _imageIndex, _gender) {
	if (array_length(global.clothesDisplay.armor) <= _itemId) return;
	var _clothing = global.clothesDisplay.armor[_itemId];
	var _sprite = _drawState == drawStates.iddle ? _clothing.getSprite(_gender) : _clothing.getWalkingSprite(_gender);
	var _color = _clothing.color;
	draw_sprite_ext(_sprite, _imageIndex, _x, _y, _scale * _direction, _scale, _angle, _color, _alpha);
}

function drawHair(_x, _y, _hairId, _color, _direction, _scale, _angle, _alpha, _behind = false) {
	if (array_length(global.hairOptions) <= _hairId) return;
	var _hairOption = global.hairOptions[_hairId];
	var _sprite = _hairOption.sprite;
	if (_behind && sprite_get_number(_sprite) == 1) return;
	var _index = _behind ? 1 : 0;
	draw_sprite_ext(_sprite, _index, _x, _y, _scale * _direction, _scale, _angle, _color, _alpha);
}

function drawHelmet(_x, _y, _headId, _direction, _scale, _angle, _alpha) {
	if (array_length(global.clothesDisplay.head) <= _headId) return;
	var _head = global.clothesDisplay.head[_headId];
	var _sprite = _head.sprite, _color = _head.color;
	draw_sprite_ext(_sprite, 0, _x, _y, _scale * _direction, _scale, _angle, _color, _alpha);
}

function drawBackPack(_x, _y, _bagId, _direction, _scale, _angle, _alpha, _index = 0) {
	if (array_length(global.clothesDisplay.bag) <= _bagId) return;
	var _bag = global.clothesDisplay.bag[_bagId];
	var _sprite = _bag.sprite, _color = _bag.color;
	draw_sprite_ext(_sprite, _index, _x, _y, _scale * _direction, _scale, _angle, _color, _alpha);
}