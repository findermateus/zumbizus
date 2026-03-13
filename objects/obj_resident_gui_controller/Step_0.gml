if (global.pause) exit;

guiMouseX = device_mouse_x_to_gui(0);
guiMouseY = device_mouse_y_to_gui(0);

if (keyboard_check_pressed(ord("N"))){
	loadResidentList();
}
currentState();
verifyMenuInput();


handleOffsetCount();