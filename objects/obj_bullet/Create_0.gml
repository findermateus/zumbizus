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
	if (alphaValue <= 0) instance_destroy(id);
}
function drawTrack(){
	if(!shouldDrawTrack) return;
	var _color = c_white;
	draw_set_alpha(alphaValue);
	draw_line_width_color(bulletTrackX1, bulletTrackY1, x + lengthdir_x(actualDistance, bulletDirection), y + lengthdir_y(actualDistance, bulletDirection), thickness, _color, _color);
	draw_set_alpha(1);
}

currentState = hitShit;
