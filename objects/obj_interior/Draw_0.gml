if (alpha <= 0 || hasFadeOut) exit;

var _sprite = spr_fog;
var _pad = 30; 
var _width  = (bbox_right - bbox_left) + (_pad * 2);
var _height = (bbox_bottom - bbox_top) + (_pad * 2);

draw_sprite_stretched_ext(
    _sprite, 0, 
    bbox_left - _pad, 
    bbox_top - _pad, 
    _width, 
    _height, 
    c_black, 
    alpha
);