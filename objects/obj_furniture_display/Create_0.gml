imageColor = c_lime;
displayColor = c_lime;
isColiding = false;
isDisplaying = false;
isDimmed = false;
ignoreId = noone;
display = {
	x: x,
	y: y,
	squash: 0,
	squashVelocity: 0,
	tilt: 0,
	shake: 0,
	alpha: 0
}

function setFurniture(_sprite){
	sprite_index = _sprite;
	setPosition();
	display.x = x;
	display.y = y;
	display.tilt = 0;
	display.alpha = 0;
	display.squash = -.35;
	display.squashVelocity = 0;
}

function addShake(_force) {
	display.shake = _force;
	display.squash = .2;
}

function setColor(){
	var _wallColision = place_meeting(x, y, obj_collision);
	var _furnitureColision = instance_place(x, y, obj_furniture);
	var _playerColision = place_meeting(x, y, obj_player);
	if (_furnitureColision == ignoreId) _furnitureColision = false;
	var _wasColiding = isColiding;
	isColiding = _wallColision || _furnitureColision || _playerColision;
	imageColor = isColiding ? c_red : c_lime;

	if (isDisplaying && isColiding && !_wasColiding) display.shake = 2;
}

function setPosition() {
	var _gridSize = 32;
	var _x = floor(mouse_x / _gridSize) * _gridSize;
	var _y = floor(mouse_y / _gridSize) * _gridSize;

	if (isDisplaying && (_x != x || _y != y)) display.squash = .12;

	x = _x;
	y = _y;
	var _lerpEffect = 0.25;
	var _velocityX = x - display.x;
	display.x = lerp(display.x, x, _lerpEffect);
	display.y = lerp(display.y, y, _lerpEffect);
	display.tilt = lerp(display.tilt, clamp(-_velocityX * .35, -12, 12), .2);
}

function updateDisplayEffects() {
	display.squashVelocity += -display.squash * .3;
	display.squashVelocity *= .72;
	display.squash += display.squashVelocity;
	display.shake = lerp(display.shake, 0, .15);
	displayColor = merge_color(displayColor, imageColor, .25);
}

function drawFootprint(_pulse, _alpha) {
	var _oldAlpha = draw_get_alpha();
	var _oldColor = draw_get_color();

	draw_set_color(displayColor);
	draw_set_alpha((.12 + _pulse * .08) * _alpha);
	draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false);
	draw_set_alpha(.5 * _alpha);
	draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

	drawCornerBrackets(bbox_left - 3, bbox_top - 3, bbox_right + 3, bbox_bottom + 3, displayColor, .9 * _alpha, 6, 2);

	draw_set_alpha(_oldAlpha);
	draw_set_color(_oldColor);
}

function drawFurniture(){
	if(!isDisplaying) {
		display.alpha = 0;
		return;
	}

	display.alpha = lerp(display.alpha, isDimmed ? .3 : 1, .15);

	var _alpha = display.alpha;
	var _pulse = .5 + sin(current_time / 180) * .5;
	var _float = 6 + sin(current_time / 250) * 2;
	var _shakeX = display.shake > .1 ? random_range(-display.shake, display.shake) : 0;

	drawFootprint(_pulse, _alpha);

	var _base = getSpriteBottomCenter(sprite_index, display.x, display.y, 1, 1, image_angle);
	var _baseX = _base[0] + _shakeX;
	var _baseY = _base[1] - _float;
	var _xScale = 1 + display.squash;
	var _yScale = 1 - display.squash;
	var _angle = image_angle + display.tilt;

	var _shadowWidth = sprite_get_width(sprite_index) * .45 * (1 - _float / 40);
	draw_set_color(c_black);
	draw_set_alpha(.25 * _alpha);
	draw_ellipse(_base[0] - _shadowWidth, _base[1] - 4, _base[0] + _shadowWidth, _base[1] + 4, false);
	draw_set_color(c_white);

	drawSpriteFromBottomCenter(sprite_index, 0, _baseX, _baseY, _xScale, _yScale, _angle, c_white, .75 * _alpha);
	drawSpriteFromBottomCenterWithFog(displayColor, sprite_index, 0, _baseX, _baseY, _xScale, _yScale, _angle, (.3 + _pulse * .2) * _alpha);

	draw_set_alpha(1);
}
