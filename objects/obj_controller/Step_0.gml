loadInputs();
checkInventoryInput();

if(keyboard_check_released(vk_alt)) global.debug = !global.debug;

if (keyboard_check_pressed(ord("N"))){
	increaseHunger(100);
}
if (keyboard_check_pressed(ord("J"))){
	increaseThirst(70);
}

if (keyboard_check_pressed(ord("B"))){
	decreaseHealth(20);
}

if (global.debug && keyboard_check_released(ord("Z"))) {
	instance_create_layer(mouse_x, mouse_y, "Instances", obj_horde_enemy_entity)
}

if (keyboard_check_pressed(ord("C"))) {
	global.player.money += 100;
}

if (keyboard_check_pressed(vk_escape)) {
	if (!isGamePaused) {
		pauseGame();
		return
	}
	unPauseGame();
}

if (keyboard_check_released(ord("P"))) {
	saveGame(true);
}