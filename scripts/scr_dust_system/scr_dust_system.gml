global.dustParticleSystem = part_system_create();
global.particleDust = part_type_create();

#region dust particle system
{
	part_type_sprite(global.particleDust, spr_particle, 0, 0, 1);
	part_type_life(global.particleDust, 20, 40);
	part_type_speed(global.particleDust, .2, .4, -.004, 0);
	part_type_size(global.particleDust, 1, 1, .03, 0);
	part_type_alpha2(global.particleDust, .6, 0);
	part_type_scale(global.particleDust, .5, .5);
}

function createWalkingParticles(_x, _y, _velh, _velv, _quantity = 2){
	if (_quantity < 1) {
		_quantity = choose(0, 0, 1);
	}
	var _yPosition = _y + irandom_range(-5, 5);
	var _xPosition = _x + irandom_range(-15, 15);
	var _scale = random_range(.5, 1);
	var _direction = point_direction(_x, _y, _x + sign(_velh), _y + sign(_velv)) + 180;
	part_type_direction(global.particleDust, _direction, _direction, 0, 0);
	part_particles_create(global.dustParticleSystem, _xPosition, _yPosition, global.particleDust, _quantity);
}
