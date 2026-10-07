if (global.pause) exit;

guiCurrentState();

if (global.debug) {
	draw_text(20, 20, "Offset:" + string(residentDisplayOffset));
	draw_text(20, 40, "Count:" + string(array_length(residentList)));
}