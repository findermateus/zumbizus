if (global.debug){
	draw_text(display_get_gui_width() * .7,50, "weaponAction yscale: " + string(weaponAction.yScale));
	draw_text(display_get_gui_width() * .7,100, "weapon yScale: " + string(weapon.yScale));
	draw_text(display_get_gui_width() * .7,150, "weapon angle switch: " + string(weapon.angleSwitching));
}