draw();

if (global.debug) {
	var _textToShow = [
		"CoolDown: " + string(wanderCooldown),
		"WanderX: " + string(wanderTargetX),
		"WanderY: " + string(wanderTargetY),
		"WanderTimer: " + string(wanderTimer),
	]
	
	var _initialY = y;
	
	for (var i = 0; i < array_length(_textToShow); i++) {
		draw_text(x, y + i * 30, _textToShow[i]);
	}
}