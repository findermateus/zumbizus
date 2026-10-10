bulletDirection = 0;
velh = 0;
velv = 0;
bulletVel = 60;
damage = 0;
errorValue = 0;
maximumDistance = 0;
actualDistance = 0;
alphaValue = 1;
shouldDrawTrack = false;
thickness = 1;
bulletTrackX1 = x;
bulletTrackY1 = y;

function defineValues(_direction, _errorValue, _damage, _maxDistance, _thickness){
	bulletDirection = _direction //+ random_range(-_errorValue, _errorValue);
	damage = _damage;
	maximumDistance = _maxDistance;
	thickness = _thickness;
	screenShake(_damage);
}

function hitShit(){
	var _xPosition = x;
	var _yPosition = y;
	actualDistance = maximumDistance;
	for(var _i = 0; _i < maximumDistance; _i ++){
		_xPosition += lengthdir_x(1, bulletDirection);
		_yPosition += lengthdir_y(1, bulletDirection);
		if (instance_place(_xPosition, _yPosition, obj_collision)){
			actualDistance = point_distance(x, y, _xPosition, _yPosition);
			break;
		}
		var _enemyCol = instance_place(_xPosition, _yPosition, obj_hittable);
		if (_enemyCol){
			if (variable_instance_exists(_enemyCol, "defeated")) {
				if (_enemyCol.defeated) {
					continue;
				}
			}
			
			actualDistance = point_distance(x, y, _enemyCol.x, _enemyCol.y);
			_enemyCol.getHit(damage, bulletDirection, damage, weaponTypes.shoot);
			break;
		}
	}
	currentState = showBulletTrack;
}

function showBulletTrack(){
	shouldDrawTrack = true;
	alphaValue = lerp(alphaValue, 0, .1);
	if (alphaValue <= .02) instance_destroy(id);
}

function drawTrack(){
	if(!shouldDrawTrack) return;

	var _x2 = x + lengthdir_x(actualDistance, bulletDirection);
	var _y2 = y + lengthdir_y(actualDistance, bulletDirection);

	gpu_set_blendmode(bm_add);
	draw_set_alpha(1);
	var _glow = merge_color(c_black, #ffb347, alphaValue * .6);
	var _core = merge_color(c_black, c_white, alphaValue);
	draw_line_width_color(bulletTrackX1, bulletTrackY1, _x2, _y2, thickness + 4, c_black, _glow);
	draw_line_width_color(bulletTrackX1, bulletTrackY1, _x2, _y2, thickness, c_black, _core);

	if (actualDistance < maximumDistance - 1) {
		var _progress = 1 - alphaValue;
		draw_set_alpha(alphaValue);
		draw_set_color(#ffe6a0);
		draw_circle(_x2, _y2, 3 + _progress * 14, true);
		draw_circle(_x2, _y2, 2 + _progress * 13, true);
		draw_circle(_x2, _y2, 3 * alphaValue, false);
	}

	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

currentState = hitShit;
