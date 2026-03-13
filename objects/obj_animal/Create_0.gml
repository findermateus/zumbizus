event_inherited();

animalId = noone;

spriteToDraw = spr_pixel;
spriteSpeed = 0;
xscaleToDraw = 1;
yscaleToDraw = 1;
alphaToDraw = 1;
angleToDraw = 0;
colorToDraw = c_white;
directionToDraw = 1;
loopAnimation = false;

imageSpeed = 0;

currentState = function () {};

changeSprite = function (_sprite, _xscale, _yscale) {
	spriteToDraw = _sprite;
	
	image_xscale = _xscale;
	image_yscale = _yscale;
	xscaleToDraw = _xscale;
	yscaleToDraw = _yscale;
	spriteSpeed = sprite_get_speed(_sprite) / 60;
	
	currentSpriteFrame = 0;
	
	finishedAnimation = false;
}

updateSpriteFrame = function () {
	var _spriteLength = sprite_get_number(spriteToDraw);
	currentSpriteFrame += spriteSpeed;
	
	if (loopAnimation) {
		currentSpriteFrame %= _spriteLength;
	} else if (currentSpriteFrame >= _spriteLength) {
		currentSpriteFrame = _spriteLength - 1;
	}
}

function checkPlaceToExist(){
	if (!place_meeting(x, y, obj_collision)) return;
	
	var _spriteWidth = sprite_get_width(sprite_index);
	var _spriteHeight = sprite_get_height(sprite_index);
	
	var _angles = [
		0,
		45,
		90,
		135,
		180,
		225,
		270,
		315
	];
	
	while(instance_place(x, y, obj_collision)){
		for(var i = 0; i < array_length(_angles); i++){
			var _xDirection = lengthdir_x(_spriteWidth, _angles[i]);
			var _yDirection = lengthdir_y(_spriteHeight, _angles[i]);
			var _x = x + _xDirection;
			var _y = y + _yDirection;
			if (!instance_place(_x, _y, obj_collision)){
				x = _x;
				y = _y;
				return;
			}
		}
		_spriteWidth++;
		_spriteHeight++;
	}
	
}