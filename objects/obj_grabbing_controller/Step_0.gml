if (!instance_exists(enemy)) {
    instance_destroy();
    exit;
}

phaseTimer++;

if (escaped) {
	if (phaseTimer > 32) instance_destroy();
} else {
	obj_camera.setTargetWithZoom(obj_player);

	obj_player.x = lerp(obj_player.x, enemy.x, 0.1);
	obj_player.y = lerp(obj_player.y, enemy.y, 0.1);

	if (phase == "intro" && phaseTimer > 20) {
		phase = "struggle";
		titleText = "SE SOLTE!";
		titlePop = 1.3;
	}

	if (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) {
		struggle();
	}

	struggle_progress = max(0, struggle_progress - struggle_decay);

	if (struggle_progress >= struggle_target) {
		escape();
	}
}

ringScaleVelocity += (1 - ringScale) * .25;
ringScaleVelocity *= .7;
ringScale += ringScaleVelocity;
ringPulse = max(0, ringPulse - .08);
ringShake = lerp(ringShake, 0, .15);
promptPress = max(0, promptPress - .15);
titlePop = lerp(titlePop, 1, .15);
redFlash = max(0, redFlash - .04);
whiteFlash = max(0, whiteFlash - .04);

displayedProgress = lerp(displayedProgress, struggle_progress, .35);
trailProgress = displayedProgress > trailProgress ? displayedProgress : lerp(trailProgress, displayedProgress, .05);

for (var i = array_length(sparks) - 1; i >= 0; i--) {
	var _spark = sparks[i];
	_spark.x += _spark.hsp;
	_spark.y += _spark.vsp;
	_spark.hsp *= .9;
	_spark.vsp *= .9;
	_spark.life -= .04;
	if (_spark.life <= 0) array_delete(sparks, i, 1);
}
