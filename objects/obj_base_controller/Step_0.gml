if (global.pause) exit;

currentAlpha = lerp(currentAlpha, destinyAlpha, alphaConverter);

if (keyboard_check_released(ord("X"))) {
	loadBaseFurnituresData();
}