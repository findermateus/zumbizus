if (global.pause) exit;

if (levelUpPending && !isMenuOpen() && !instance_exists(obj_quest_popup)) {
    levelUpPending = false;
    handleLevelUp();
}

if (keyboard_check_pressed(ord("H"))) {
	xpAdd(irandom(12));
}
