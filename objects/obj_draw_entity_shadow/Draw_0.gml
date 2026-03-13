gpu_set_fog(true, c_black, 0, 1);
//var _shadowX = (display_get_gui_width() / 2) - roomToGuiX(getMouseXGui());
//var _shadowY = (display_get_gui_height() / 2) - roomToGuiY(getMouseYGui());

var cX = camera_get_view_x(view_camera[0]);
var cY = camera_get_view_y(view_camera[0]);

setSurface();

draw_clear_alpha(c_black, 0);
with (obj_entity) {
	other.drawShadow(spriteToDrawShadow, currentSpriteFrame, x, y, shadowDirection, image_alpha, image_xscale);
}
surface_reset_target();
	
draw_set_alpha(.3);
draw_surface(shadowSurface, cX, cY);
draw_set_alpha(1);
	
gpu_set_fog(false, c_white, 0, 1);