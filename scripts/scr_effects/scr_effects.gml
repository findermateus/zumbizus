function drawSpriteShadow(_x, _y, _sprite, _imageIndex, _angle, _xScale, _yScale, shadow_offset_x = 4, shadow_offset_y = 4, _alpha = draw_get_alpha()) {
    var shadow_color = c_black;
    var shadow_alpha = 0.5 * _alpha;

    drawSpriteWithGpuFog(
		shadow_color,
		_sprite,
		_imageIndex,
		_x + shadow_offset_x,
		_y + shadow_offset_y,
		_xScale,
		_yScale,
		_angle, 
		shadow_alpha
	);
}

function drawSpriteShadowStretched(_x, _y, _sprite, _imageIndex, _angle, _xSize, _ySize, shadow_offset_x = 4, shadow_offset_y = 4) {
	var shadow_color = c_black;
    var shadow_alpha = 0.5 * draw_get_alpha();

    drawSpriteWithGpuFogStretched(
		shadow_color,
		_sprite,
		_imageIndex,
		_x + shadow_offset_x,
		_y + shadow_offset_y,
		_xSize,
		_ySize,
		_angle, 
		shadow_alpha
	);
}

function addDamageToGuiList(_x, _y, _value){
	if (!instance_exists(obj_damage_controller)) return;
	with (obj_damage_controller) {
		var _damage = new Damage(_x, _y, _value);
		array_push(damageList, _damage);
	}
}

function PathTrail(_color, _pathTimer = 0) constructor {
	path = path_add();
	pathDelay = 8;
	pathTimer = _pathTimer;
	hasPath = false;

	trailLength = 1000;
	particleScale = .6;
	startOffset = 16;
	spawnDelay = .5;
	spawnTimer = 0;

	system = part_system_create();
	part_system_depth(system, -15000);
	particle = part_type_create();

	part_type_sprite(particle, spr_particle, 0, 0, 1);
	part_type_life(particle, 60, 90);
	part_type_speed(particle, .5, .9, -.004, 0);
	part_type_size(particle, .9, 2, .006, 0);
	part_type_scale(particle, particleScale, particleScale);
	part_type_alpha3(particle, 0, 1, 0);
	part_type_color2(particle, _color, _color);
	part_type_blend(particle, true);
	part_type_orientation(particle, 0, 360, .5, 0, false);

	static update = function(_target) {
		if (pathTimer <= 0) {
			pathTimer = pathDelay;

			var _target_x = getMiddlePoint(_target.bbox_left, _target.bbox_right);
			var _target_y = getMiddlePoint(_target.bbox_top, _target.bbox_bottom);

			hasPath = mp_grid_path(global.motionPlanningGrid, path, obj_player.x, obj_player.y, _target_x, _target_y, true);
		} else {
			pathTimer--;
		}

		if (!hasPath || !path_exists(path)) {
			return;
		}

		if (global.debug) {
			draw_set_color(c_green);
			draw_path(path, path_get_x(path, 0), path_get_y(path, 0), true);
			draw_set_color(c_white);
		}

		if (global.timeStopped) {
			return;
		}

		if (spawnTimer > 0) {
			spawnTimer--;
			return;
		}

		spawnTimer = spawnDelay;
		emit();
	}

	static emit = function() {
		var _path_length = path_get_length(path);
		if (_path_length <= startOffset) {
			return;
		}

		var _trail_end = min(_path_length, startOffset + trailLength);
		var _distance = random_range(startOffset, _trail_end);
		var _position = _distance / _path_length;
		var _ahead_position = min(1, (_distance + 8) / _path_length);

		var _x = path_get_x(path, _position);
		var _y = path_get_y(path, _position);
		var _direction = point_direction(_x, _y, path_get_x(path, _ahead_position), path_get_y(path, _ahead_position));

		part_type_direction(particle, _direction - 12, _direction + 12, 0, 1.5);
		part_particles_create(system, _x + random_range(-4, 4), _y + random_range(-4, 4), particle, 2);
	}

	static destroy = function() {
		if (path_exists(path)) {
			path_delete(path);
		}

		part_type_destroy(particle);
		part_system_destroy(system);
	}
}
