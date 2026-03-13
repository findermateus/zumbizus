function drawNpcHead(_npcXPosition, _y, _headSize, _size, _hair, _skinColor, _gender) {
    var _spriteSize = sprite_get_height(spr_human_male_iddle);
	var _scale = getScale(_headSize, _spriteSize);
	var _actualY = _y + _size/2 + _headSize / 2;
	drawPersonBody(_npcXPosition, _actualY, _gender, 0, _scale, 0, 1, _skinColor, _hair, -1, -1, -1, 1);
}


function drawEmptyNpcInsideBlock(_x, _y, _size, _alpha) {
	draw_sprite_stretched_ext(spr_builder_furniture_box, 0, _x, _y, _size, _size, c_white, _alpha);
	var _sprite = spr_person;
	var _personSize = _size * .5;
	var _personX = _x + _size / 2 - _personSize / 2;
	var _personY = _y + _size / 2 - _personSize / 2;
	drawSpriteShadowStretched(_personX, _personY, _sprite, 0, 0, _personSize, _personSize);
	draw_sprite_stretched_ext(
		_sprite,
		0,
		_personX,
		_personY,
		_personSize,
		_personSize,
		#ababab,
		1
	);
}

function drawNpcInsideBlock(_x, _y, _size, _hair, _skinColor, _gender, _alpha) {
	draw_sprite_stretched_ext(spr_builder_furniture_box, 0, _x, _y, _size, _size, c_white, _alpha);
		
	var _hSkinColor = getHexFromString(_skinColor);
	drawNpcHead(
		_x + _size /2,
		_y,
		_size * .5,
		_size,
		_hair,
		_hSkinColor,
		_gender
	);
}