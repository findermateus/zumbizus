if (global.pause) {
	exit;
}

deleteDependenciesIfNotInventory();
xMouseToGui = device_mouse_x_to_gui(0);
yMouseToGui = device_mouse_y_to_gui(0);
if(!global.activeInventory){
	secundaryInventory = false;
	curveAnimationIndex = 0;
}
adjustClosestDepth();