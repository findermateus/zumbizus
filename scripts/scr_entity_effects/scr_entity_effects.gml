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

function speakSimple(_textContent, _father) {
	audio_play_sound(snd_dialogue_pop_up, 0, false, .2);
	return instance_create_layer(0, 0, "Alert", obj_dialogue_simple_pop_up, {
		textContent: _textContent,
		father: _father
	});
}
