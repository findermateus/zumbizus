if (alpha <= 0 || hasFadeOut) exit;

var _minAlpha = 0.95;
var _maxAlpha = 1.00;
var _spd = current_time * 0.002;

var _oscilacao = (1 + sin(_spd)) / 2;

var _vivid = lerp(_minAlpha, _maxAlpha, _oscilacao);

var _finalAlpha = alpha * _vivid;

var _sprite = spr_interior_fog;
var _pad = 55;
var _width  = (bbox_right - bbox_left) + (_pad * 2);
var _height = (bbox_bottom - bbox_top) + (_pad * 2);

draw_sprite_stretched_ext(
    _sprite, 0, 
    bbox_left - _pad, 
    bbox_top - _pad, 
    _width, 
    _height, 
    c_black, 
    _finalAlpha
);