#macro BLOOD_SPLAT_LIMIT 150

function initBloodParticleTypes() {
	if (variable_global_exists("bloodMistParticleType")) return;

	part_type_color_mix(global.blood_particle_type, #4a0000, #b01010);

	global.bloodMistParticleType = part_type_create();
	part_type_shape(global.bloodMistParticleType, pt_shape_pixel);
	part_type_size(global.bloodMistParticleType, 1, 3, -0.08, 0);
	part_type_color_mix(global.bloodMistParticleType, #8a0000, #d42020);
	part_type_alpha2(global.bloodMistParticleType, .9, 0);
	part_type_life(global.bloodMistParticleType, 8, 18);

	global.bloodDropParticleType = part_type_create();
	part_type_shape(global.bloodDropParticleType, pt_shape_pixel);
	part_type_size(global.bloodDropParticleType, 5, 8, -0.04, 0);
	part_type_color_mix(global.bloodDropParticleType, #5a0000, #9a0000);
	part_type_alpha3(global.bloodDropParticleType, 1, 1, 0);
	part_type_life(global.bloodDropParticleType, 25, 45);
	part_type_gravity(global.bloodDropParticleType, 0.35, 270);
}

/// @param _force     força do golpe (velocidade das partículas)
/// @param _direction direção do golpe (o sangue espirra para esse lado)
/// @param _count     intensidade (normalmente o dano)
/// @param _groundY   y do chão para os respingos; padrão: um pouco abaixo de _y
function createBloodEffect(_force, _direction, _x, _y, _count, _groundY = undefined){
    if (!part_system_exists(global.blood_particle_system)) return;
	initBloodParticleTypes();

    var _minSpeed = clamp(1.5 + (_force * 0.5), 1.5, 6);
    var _maxSpeed = clamp(3.5 + (_force * 1.0), 3.5, 11);

	var _sprayCount = floor(clamp(6 + (_count * 1.5), 6, 70));
    part_type_speed(global.blood_particle_type, _minSpeed, _maxSpeed, -0.12, 0);
    part_type_direction(global.blood_particle_type, _direction - 25, _direction + 25, 0, 4);
    part_particles_create(global.blood_particle_system, _x, _y, global.blood_particle_type, _sprayCount);

	var _mistCount = floor(clamp(4 + _count * .6, 4, 30));
	part_type_speed(global.bloodMistParticleType, _maxSpeed * .8, _maxSpeed * 1.4, -0.25, 0);
	part_type_direction(global.bloodMistParticleType, _direction - 60, _direction + 60, 0, 0);
	part_particles_create(global.blood_particle_system, _x, _y, global.bloodMistParticleType, _mistCount);

	var _dropCount = floor(clamp(1 + _count / 6, 1, 10));
	part_type_speed(global.bloodDropParticleType, _minSpeed * .6, _maxSpeed * .7, -0.05, 0);
	part_type_direction(global.bloodDropParticleType, _direction - 35, _direction + 35, 0, 0);
	part_particles_create(global.blood_particle_system, _x, _y, global.bloodDropParticleType, _dropCount);

	createBloodSplats(_x, _groundY ?? _y + 24, _direction, _force, floor(clamp(_count / 8, 1, 5)));
}

function createBloodSplats(_x, _groundY, _direction, _force, _amount) {
	repeat (_amount) {
		if (instance_number(obj_blood_splat) >= BLOOD_SPLAT_LIMIT) return;

		var _distance = random_range(8, 24 + _force * 4);
		var _angle = _direction + random_range(-30, 30);
		var _splat = instance_create_layer(
			_x + lengthdir_x(_distance, _angle),
			_groundY + lengthdir_y(_distance, _angle) * .5 + random_range(-4, 4),
			"Instances",
			obj_blood_splat
		);
		_splat.image_xscale *= random_range(1.5, 3);
	}
}

function createBloodPool(_x, _groundY, _amount) {
	repeat (_amount) {
		if (instance_number(obj_blood_splat) >= BLOOD_SPLAT_LIMIT) return;

		var _splat = instance_create_layer(_x + random_range(-18, 18), _groundY + random_range(-6, 6), "Instances", obj_blood_splat);
		_splat.image_xscale *= random_range(2, 4);
	}
}

function addHitScreenShake(_force) {
	if (!instance_exists(obj_camera)) return;
	obj_camera.currentShakeEffect = max(obj_camera.currentShakeEffect, _force);
}

#region
function initHitJuice() {
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
}

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

function speakSimple(_textContent, _father) {
	audio_play_sound(snd_dialogue_pop_up, 0, false, .2);
	return instance_create_layer(0, 0, "Alert", obj_dialogue_simple_pop_up, {
		textContent: _textContent,
		father: _father
	});
}
