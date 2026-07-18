event_inherited();

var _shakeX = random_range(-shake_power, shake_power);

draw_sprite_ext(
	sprite_index, 
	image_index, 
	x + _shakeX, 
	y, 
	image_xscale * scale_x, 
	image_yscale * scale_y, 
	fall_angle, 
	image_blend, 
	image_alpha
);

drawHitFlash(
	sprite_index,
	image_index,
	x + _shakeX,
	y,
	image_xscale * scale_x,
	image_yscale * scale_y,
	fall_angle, 
	c_white
);