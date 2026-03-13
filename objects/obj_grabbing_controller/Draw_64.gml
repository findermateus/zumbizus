var _guiW = display_get_gui_width();
var _guiH = display_get_gui_height();
var _centerX = _guiW / 2;
var _ratio = struggle_progress / struggle_target;

var _shakeX = random_range(-juice_shake, juice_shake);
var _shakeY = random_range(-juice_shake, juice_shake);
var _waveY = sin(text_wave) * 5;

var _barW = 200 * juice_scale;
var _barH = 30 * juice_scale;
var _barSprite = spr_bar;
var _barX = (_centerX - _barW / 2) + _shakeX;
var _barY = (roomToGuiY(obj_player.bbox_bottom + 15)) + _shakeY;

draw_sprite_stretched_ext(_barSprite, 0, _barX, _barY, _barW, _barH, c_black, 0.5);

var _barWidthProggress = _barW * clamp(_ratio, 0, 1);
var _color = merge_color(c_red, c_lime, _ratio);
draw_sprite_stretched_ext(_barSprite, 2, _barX, _barY, _barWidthProggress, _barH, _color, 1);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_gui_title);

var _t = "RESISTA!";
var _textScale = 1 + (juice_scale - 1) * 0.5;
var _mouseScale = _textScale * 2;

var _tW = string_width(_t) * _textScale;
var _sW = sprite_get_width(spr_mouse) * _mouseScale;
var _gap = 20 * _textScale; 
var _totalW = _tW + _gap + _sW;

var _tY = roomToGuiY(obj_player.bbox_top - 100) + _waveY + _shakeY;
var _textCol = (_ratio > 0.8) ? c_red : c_white;

var _drawStartX = _centerX - (_totalW / 2);
var _textPosX = _drawStartX + (_tW / 2) + _shakeX;
var _mousePosX = _drawStartX + _tW + _gap + (_sW / 2) + _shakeX;

drawTextShadow(_textPosX, _tY, _t, draw_get_alpha());
draw_text_transformed_color(_textPosX, _tY, _t, _textScale, _textScale, 0, _textCol, _textCol, c_white, c_white, 1);

var _mouseIdx = (current_time / 1000) * sprite_get_speed(spr_mouse);

drawSpriteShadow(_mousePosX, _tY, spr_mouse, _mouseIdx, 0, _mouseScale, _mouseScale, 4, 4, 1);
draw_sprite_ext(spr_mouse, _mouseIdx, _mousePosX, _tY, _mouseScale, _mouseScale, 0, c_white, draw_get_alpha());

draw_set_font(fnt_gui_default);
draw_set_color(c_white);