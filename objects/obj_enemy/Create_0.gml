event_inherited();

gotWarned = false;
iwarned = false;
defeated = false;

pathHandler = instance_create_layer(x, y, layer, obj_path_handler, {
	father: id
});

function handlePositionWithPathHandler(_shouldReset = false){
	if (_shouldReset) {
		pathHandler.x = x;
		pathHandler.y = y;
		
		return;
	}
	
	var _speed = .1;
	
	if (point_distance(x, y, pathHandler.x, pathHandler.y) < attackDistance + 50) {
		_speed = .5
	}
	
	x = lerp(x, pathHandler.x, _speed);
	y = lerp(y, pathHandler.y, _speed);
}

function getKilled() {

}

function warnOtherEnemies() {
	if (gotWarned || iwarned) {
		return;
	}
	
	iwarned = true;
	
	var _radius = 250;
	var _instance = instance_create_layer(x, y, "Alert", obj_draw_circle_in_object, {
		father: id,
		radius: _radius
	});
	
	var _enemyList = ds_list_create();
	
	collision_circle_list(x, y, _radius, obj_enemy, false, true, _enemyList, false);
	
	for (var i = 0; i < ds_list_size(_enemyList); i ++) {
		_enemyList[| i].getWarned();
	}
	
	ds_list_destroy(_enemyList);
}

function getWarned() {

}

genericCollision = function(_positionX, _posititonY) {
	for(var i = 0; i < array_length(global.collidableObjects); i++){
		var _collidableObject = global.collidableObjects[i];
		var _col = instance_place(_positionX, _posititonY, _collidableObject);

		if (_col) return true;
	}

	return false;
}

#region
hitShakePower = 0;
hitShakeDecay = 0.4;
hitScaleX = 1;
hitScaleY = 1;
hitSquash = 0;
hitSquashVelocity = 0;
hitTilt = 0;
hitTiltVelocity = 0;
hitRecoilX = 0;
hitRecoilY = 0;
hitRedTint = 0;
hitStopFrames = 0;
hitImpact = {
	x: 0,
	y: 0,
	direction: 0,
	life: 0,
	maxLife: 10,
	size: 1
};

function applyHitShake(_direction = 0, _damage = 1, _isKill = false) {
	var _strength = clamp(.6 + _damage / 15, .6, 1.6) * (_isKill ? 1.5 : 1);
	var _side = lengthdir_x(1, _direction);

	hitShakePower = 4 * _strength;
	hitSquash = .35 * _strength;
	hitSquashVelocity = 0;

	hitTiltVelocity = -(_side >= 0 ? 1 : -1) * 6 * _strength;
	hitRecoilX = lengthdir_x(10 * _strength, _direction);
	hitRecoilY = lengthdir_y(6 * _strength, _direction);
	hitRedTint = 1;
	hitStopFrames = _isKill ? 8 : clamp(round(2 + _damage / 10), 2, 5);

	var _centerX = getMiddlePoint(bbox_left, bbox_right);
	var _centerY = getMiddlePoint(bbox_top, bbox_bottom);
	hitImpact.x = _centerX - lengthdir_x((bbox_right - bbox_left) * .35, _direction) - x;
	hitImpact.y = _centerY - lengthdir_y((bbox_bottom - bbox_top) * .25, _direction) - y;
	hitImpact.direction = _direction;
	hitImpact.life = hitImpact.maxLife;
	hitImpact.size = _strength;
}

function isInHitStop() {
	return hitStopFrames > 0;
}

function updateHitShake() {
	hitRedTint = max(0, hitRedTint - .04);
	if (hitImpact.life > 0) hitImpact.life--;

	if (hitStopFrames > 0) {
		hitStopFrames--;
		return;
	}

	hitSquashVelocity += -hitSquash * .3;
	hitSquashVelocity *= .7;
	hitSquash += hitSquashVelocity;

	hitTiltVelocity += -hitTilt * .25;
	hitTiltVelocity *= .7;
	hitTilt += hitTiltVelocity;

	hitRecoilX = lerp(hitRecoilX, 0, .2);
	hitRecoilY = lerp(hitRecoilY, 0, .2);
	hitShakePower = max(0, hitShakePower - hitShakeDecay);

	hitScaleX = 1 + hitSquash;
	hitScaleY = 1 - hitSquash;
}

function getHitShakeOffset() {
	return random_range(-hitShakePower, hitShakePower);
}

function getHitOffsetX() {
	return getHitShakeOffset() + hitRecoilX;
}

function getHitOffsetY() {
	return random_range(-hitShakePower, hitShakePower) * .4 + hitRecoilY;
}

function drawHitTint(_sprite, _index, _x, _y, _xScale, _yScale, _angle) {
	if (hitRedTint <= 0) return;

	gpu_set_fog(true, #ff2a2a, 0, 0);
	draw_sprite_ext(_sprite, _index, _x, _y, _xScale, _yScale, _angle, c_white, hitRedTint * .45 * image_alpha);
	gpu_set_fog(false, c_white, 0, 0);
}

function drawHitImpact() {
	if (hitImpact.life <= 0) return;

	var _progress = 1 - hitImpact.life / hitImpact.maxLife;
	var _alpha = 1 - _progress;
	var _size = hitImpact.size;
	var _x = x + hitImpact.x;
	var _y = y + hitImpact.y;
	var _sparkDirection = hitImpact.direction + 180;

	gpu_set_blendmode(bm_add);
	draw_set_alpha(_alpha);

	draw_set_color(#fff2c0);
	draw_circle(_x, _y, 9 * (1 - _progress) * _size, false);

	draw_set_color(c_white);
	var _radius = (6 + _progress * 22) * _size;
	draw_circle(_x, _y, _radius, true);
	draw_circle(_x, _y, _radius - 1, true);

	var _sparkCount = 7;
	for (var i = 0; i < _sparkCount; i++) {
		var _angle = _sparkDirection + (i - (_sparkCount - 1) / 2) * 24;
		var _inner = (4 + _progress * 14) * _size;
		var _outer = _inner + (16 * (1 - _progress) + 4) * _size;
		draw_line_width(
			_x + lengthdir_x(_inner, _angle), _y + lengthdir_y(_inner, _angle),
			_x + lengthdir_x(_outer, _angle), _y + lengthdir_y(_outer, _angle),
			1 + 2 * (1 - _progress)
		);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	gpu_set_blendmode(bm_normal);
}

function playHitFeedback(_damage, _direction, _force, _isKill) {
	applyHitShake(_direction, _damage, _isKill);
	addHitScreenShake(_isKill ? 6 : clamp(1 + _damage * .15, 1, 4));
	createBloodEffect(
		_isKill ? _force * 2 : _force,
		_direction,
		getMiddlePoint(bbox_left, bbox_right),
		getMiddlePoint(bbox_top, bbox_bottom),
		_isKill ? _damage + 30 : _damage,
		bbox_bottom
	);
	if (_isKill) createBloodPool(x, bbox_bottom, 6);
}
#endregion
