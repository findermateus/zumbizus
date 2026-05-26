if (global.pause) exit;

if (levelUpPending && !isMenuOpen() && !instance_exists(obj_quest_popup)) {
    levelUpPending = false;
    handleLevelUp();
}

if (keyboard_check_pressed(ord("H"))) {
	xpAdd(irandom(12));
}

var _barDestiny = !isMenuOpen() ? defaultBarWidth : 0;
var _destinyTextAlpha = !isMenuOpen() ? 1 : 0;
barWidth = lerp(barWidth, _barDestiny, .1);
textAlpha = lerp(textAlpha, _destinyTextAlpha, .1);