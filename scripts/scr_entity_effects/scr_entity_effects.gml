function createBloodEffect(_force, _direction, _x, _y, _count){ 
    if (!part_system_exists(global.blood_particle_system)) return;
	var _particle_count = floor(clamp(5 + (_count * 1.5), 5, 70));

    var _min_speed = clamp(1 + (_force * 0.5), 1, 5);
    var _max_speed = clamp(3 + (_force * 1.0), 3, 10);
    part_type_speed(global.blood_particle_type, _min_speed, _max_speed, -0.1, 0);

    var _spread = 20;
    var _dir_min = _direction - _spread;
    var _dir_max = _direction + _spread;
    part_type_direction(global.blood_particle_type, _dir_min, _dir_max, 0, 5);
    part_particles_create(global.blood_particle_system, _x, _y, global.blood_particle_type, _particle_count);
}

function speakSimple(_textContent, _father) {
	audio_play_sound(snd_dialogue_pop_up, 0, false, .2);
	return instance_create_layer(0, 0, "Alert", obj_dialogue_simple_pop_up, {
		textContent: _textContent,
		father: _father
	});
}