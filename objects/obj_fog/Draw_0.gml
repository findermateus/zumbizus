var _minAlpha = 0.9;
var _maxAlpha = 1;
var _tempo = current_time * 0.001; 

var _onda1 = (1 + sin(_tempo * 1.5)) / 2;
var _onda2 = (1 + cos(_tempo * 0.8)) / 2;
var _oscilacao = (_onda1 + _onda2) / 2; 

var _finalAlpha = image_alpha * lerp(_minAlpha, _maxAlpha, _oscilacao);

var _sprite = spr_fog;
var _pad = 15; 
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