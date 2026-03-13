function openInventory(_sound = snd_open_inventory) {
	if (instance_exists(obj_base_controller) && global.currentBaseMenuOption != -1) {
		deactivateLateralMenuOption(global.currentBaseMenuOption);
	}
	obj_camera.target = obj_player;
	obj_camera.setInventoryZoom();
	audio_play_sound(_sound, 0, false);
	global.activeInventory = true;
	openMenu();
}

function openInventoryWithContainer(_target, _sound, _containerData){
	obj_camera.target = _target;
	obj_camera.currentState = obj_camera.followTarget;
	obj_camera.currentState();
	openInventory(_sound)
	obj_inventory.secundaryInventory = _containerData;
}

function closeInventory(){
	if (!global.activeInventory) return;
	closeMenu();
	obj_camera.setDefaultScale();
	obj_camera.target = obj_player;
	with (obj_inventory) {
		currentState = hide;
	}
}