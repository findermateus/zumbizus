if (global.pause) exit;

if (keyboard_check_pressed(ord("H"))) {
	xpAdd(irandom(12));
}

var _barDestiny = !global.activeMenu ? defaultBarWidth : 0;
var _destinyTextAlpha = !global.activeMenu ? 1 : 0;
barWidth = lerp(barWidth, _barDestiny, .1);
textAlpha = lerp(textAlpha, _destinyTextAlpha, .1);