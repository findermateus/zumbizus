if (global.debug) {
	var _x = 5;
	var _y = display_get_gui_height() - string_height("TXT");
	draw_text(_x, _y, "Pause: " + string(global.pause));
	draw_text(_x, _y - string_height("TXT"), "StopTime: " + string(global.timeStopped));
}

if (isGamePaused) {
	drawPause();
}