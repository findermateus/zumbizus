if (fadeAlpha > 0) {
	var _guiW = display_get_gui_width();
	var _guiH = display_get_gui_height();

	draw_set_alpha(fadeAlpha);
	draw_set_color(c_black);
	draw_rectangle(0, 0, _guiW, _guiH, false);

	draw_set_alpha(1);
	draw_set_color(c_white);
}