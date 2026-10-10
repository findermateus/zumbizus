struggle_progress = 0;
struggle_target = 100;
struggle_decay = 0.5;
struggle_power = 15;

phase = "intro";
phaseTimer = 0;
escaped = false;
titleText = "AGARRADO!";

ringScale = 0;
ringScaleVelocity = .45;
ringPulse = 0;
ringShake = 0;
displayedProgress = 0;
trailProgress = 0;
promptPress = 0;
titlePop = 1.6;
redFlash = .55;
whiteFlash = 0;
sparks = [];

blockPlayerMenus();
screenShake(8);

damage_interval = game_get_speed(gamespeed_fps) * 0.5;
alarm[0] = damage_interval;

function getRingCenter() {
	return [roomToGuiX(obj_player.x), roomToGuiY(obj_player.y - 40)];
}

function getProgressColor(_ratio) {
	return _ratio < .5 ? merge_color(#e5383b, #ffd166, _ratio * 2) : merge_color(#ffd166, #5fd35f, (_ratio - .5) * 2);
}

function addRingSparks(_count, _angleCenter, _spread, _color) {
	var _center = getRingCenter();
	var _radius = 74 * ringScale;
	repeat (_count) {
		var _angle = _angleCenter + random_range(-_spread, _spread);
		var _speed = random_range(3, 8);
		array_push(sparks, {
			x: _center[0] + lengthdir_x(_radius, _angle),
			y: _center[1] + lengthdir_y(_radius, _angle),
			hsp: lengthdir_x(_speed, _angle),
			vsp: lengthdir_y(_speed, _angle),
			life: 1,
			color: _color
		});
	}
}

function struggle() {
	struggle_progress += struggle_power;

	var _ratio = clamp(struggle_progress / struggle_target, 0, 1);
	ringPulse = 1;
	promptPress = 1;
	titlePop = 1.25;
	screenShake(struggle_power / 2);

	with (obj_player) {
		x += random_range(-2, 2);
		addBodySquash(-.15);
	}
	enemy.hitSquash = .2;
	enemy.hitShakePower = 3;

	addRingSparks(5, 90 - 360 * _ratio, 25, getProgressColor(_ratio));
}

function escape() {
	escaped = true;
	phaseTimer = 0;
	titleText = "ESCAPOU!";
	titlePop = 1.8;
	whiteFlash = .6;
	alarm[0] = -1;

	var _dir = point_direction(obj_player.x, obj_player.y, enemy.x, enemy.y);
	enemy.x += lengthdir_x(20, _dir);
	enemy.y += lengthdir_y(20, _dir);
	with (enemy) applyHitShake(_dir, 10);

	addHitScreenShake(12);
	addRingSparks(28, 0, 180, #5fd35f);
	obj_camera.setDefaultValues();
}
