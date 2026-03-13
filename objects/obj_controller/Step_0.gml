loadInputs();
checkInventoryInput();

if(keyboard_check_released(vk_alt)) global.debug = !global.debug;

//if(keyboard_check_released(ord("P"))){
//	var _savePlayerData = true;
//	var _saveRoomData = room == RoomPlayerBase;
//	saveGame(_savePlayerData, _saveRoomData);
//}
//if(keyboard_check_released(ord("L"))){
//	loadGame();
//}

if (keyboard_check_pressed(ord("N"))){
	increaseHunger(100);
}
if (keyboard_check_pressed(ord("J"))){
	increaseThirst(70);
}

if (keyboard_check_pressed(ord("B"))){
	decreaseHealth(20);
}


if (keyboard_check_released(vk_space)){
	getNpcListFromDatabase();
}

//if (mouse_check_button_released(mb_left)) {
//	instance_create_layer(mouse_x, mouse_y, "Particles", obj_fire_weapon_light);
//}

if (global.debug && keyboard_check_released(ord("Z"))) {
	instance_create_layer(mouse_x, mouse_y, "Instances", obj_horde_enemy_entity)
}

if (keyboard_check_pressed(vk_escape)) {
	if (!isGamePaused) {
		pauseGame();
		return
	}
	unPauseGame();
}