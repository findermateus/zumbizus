if (global.pause) exit;

if (global.debug){
	var _itemsToDebug = [
		"isDisplaying: " + string(isDisplaying),
	];
	for(var i = 0; i < array_length(_itemsToDebug); i ++){
		draw_text(display_mouse_get_x(), display_mouse_get_y() + (i*50), _itemsToDebug[i]);
	}

}