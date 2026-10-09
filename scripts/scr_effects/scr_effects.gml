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

function rotateSpriteVector(_dx, _dy, _angle) {
	var _cos = dcos(_angle);
	var _sin = dsin(_angle);
	return [_dx * _cos + _dy * _sin, -_dx * _sin + _dy * _cos];
}

function getSpriteBottomCenter(_sprite, _x, _y, _xScale = 1, _yScale = 1, _angle = 0) {
	var _offset = rotateSpriteVector(
		(sprite_get_width(_sprite) / 2 - sprite_get_xoffset(_sprite)) * _xScale,
		(sprite_get_height(_sprite) - sprite_get_yoffset(_sprite)) * _yScale,
		_angle
	);
	return [_x + _offset[0], _y + _offset[1]];
}

function drawSpriteFromBottomCenter(_sprite, _frame, _baseX, _baseY, _xScale, _yScale, _angle, _color, _alpha) {
	var _offset = rotateSpriteVector(
		(sprite_get_width(_sprite) / 2 - sprite_get_xoffset(_sprite)) * _xScale,
		(sprite_get_height(_sprite) - sprite_get_yoffset(_sprite)) * _yScale,
		_angle
	);
	draw_sprite_ext(_sprite, _frame, _baseX - _offset[0], _baseY - _offset[1], _xScale, _yScale, _angle, _color, _alpha);
}

function drawSpriteFromBottomCenterWithFog(_fogColor, _sprite, _frame, _baseX, _baseY, _xScale, _yScale, _angle, _alpha) {
	gpu_set_fog(true, _fogColor, 0, 0);
	drawSpriteFromBottomCenter(_sprite, _frame, _baseX, _baseY, _xScale, _yScale, _angle, c_white, _alpha);
	gpu_set_fog(false, _fogColor, 0, 0);
}

function drawCornerBrackets(_x1, _y1, _x2, _y2, _color, _alpha, _length = 8, _width = 2) {
	var _oldAlpha = draw_get_alpha();
	var _oldColor = draw_get_color();
	draw_set_alpha(_alpha);
	draw_set_color(_color);

	var _lengthX = min(_length, (_x2 - _x1) / 2);
	var _lengthY = min(_length, (_y2 - _y1) / 2);

	draw_line_width(_x1, _y1, _x1 + _lengthX, _y1, _width);
	draw_line_width(_x1, _y1, _x1, _y1 + _lengthY, _width);
	draw_line_width(_x2, _y1, _x2 - _lengthX, _y1, _width);
	draw_line_width(_x2, _y1, _x2, _y1 + _lengthY, _width);
	draw_line_width(_x1, _y2, _x1 + _lengthX, _y2, _width);
	draw_line_width(_x1, _y2, _x1, _y2 - _lengthY, _width);
	draw_line_width(_x2, _y2, _x2 - _lengthX, _y2, _width);
	draw_line_width(_x2, _y2, _x2, _y2 - _lengthY, _width);

	draw_set_alpha(_oldAlpha);
	draw_set_color(_oldColor);
}

function drawSpriteFitCentered(_sprite, _cx, _cy, _maxSize, _scaleMultiplier = 1, _angle = 0, _color = c_white, _alpha = 1) {
	var _width = sprite_get_width(_sprite);
	var _height = sprite_get_height(_sprite);
	var _scale = getScale(_maxSize, max(_width, _height)) * _scaleMultiplier;
	var _offset = rotateSpriteVector(
		(_width / 2 - sprite_get_xoffset(_sprite)) * _scale,
		(_height / 2 - sprite_get_yoffset(_sprite)) * _scale,
		_angle
	);
	draw_sprite_ext(_sprite, 0, _cx - _offset[0], _cy - _offset[1], _scale, _scale, _angle, _color, _alpha);
}

function addDamageToGuiList(_x, _y, _value, _isKill = false){
	if (!instance_exists(obj_damage_controller)) return;
	with (obj_damage_controller) {
		var _damage = new Damage(_x, _y, _value, _isKill);
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

function drawCheckMark(_x, _y, _size, _color, _alpha, _progress = 1, _width = 3) {
	var _x1 = _x - _size;
	var _y1 = _y;
	var _x2 = _x - _size * .3;
	var _y2 = _y + _size * .7;
	var _x3 = _x + _size;
	var _y3 = _y - _size * .7;

	var _first = clamp(_progress / .4, 0, 1);
	var _second = clamp((_progress - .4) / .6, 0, 1);
	var _oldAlpha = draw_get_alpha();
	var _oldColor = draw_get_color();

	for (var i = 0; i < 2; i++) {
		var _offset = i == 0 ? 2 : 0;
		draw_set_color(i == 0 ? c_black : _color);
		draw_set_alpha(_alpha * (i == 0 ? .5 : 1));

		if (_first > 0) {
			draw_line_width(_x1 + _offset, _y1 + _offset, lerp(_x1, _x2, _first) + _offset, lerp(_y1, _y2, _first) + _offset, _width);
		}
		if (_second > 0) {
			draw_line_width(_x2 + _offset, _y2 + _offset, lerp(_x2, _x3, _second) + _offset, lerp(_y2, _y3, _second) + _offset, _width);
		}
	}

	draw_set_alpha(_oldAlpha);
	draw_set_color(_oldColor);
}
