var _config = cursorSprites[cursorType];
var _sprite = _config.sprite;
var _size = _config.size;

var _x = device_mouse_x_to_gui(0); 
var _y = device_mouse_y_to_gui(0);

var _base_scale = getScale(_size, sprite_get_height(_sprite));
var _final_scale = _base_scale + recoilScale;

draw_sprite_ext(
	_sprite,
	0,
	_x,
	_y,
	_final_scale,
	_final_scale,
	0,
	c_white,
	draw_get_alpha() * .8
);