if (!instance_exists(obj_player)) exit;

var _guiW = display_get_gui_width();
var _guiH = display_get_gui_height();
var _ratio = clamp(displayedProgress / struggle_target, 0, 1);
var _trailRatio = clamp(trailProgress / struggle_target, 0, 1);
var _outro = escaped ? clamp(phaseTimer / 32, 0, 1) : 0;
var _uiAlpha = 1 - _outro;

if (!escaped) {
	var _beat = max(0, sin(current_time / 140)) * .12;
	with (obj_player) drawDamageVignette(_guiW, _guiH, .22 + _beat);
}

if (redFlash > 0 || whiteFlash > 0) {
	draw_set_alpha(redFlash * .45);
	draw_set_color(#b00010);
	draw_rectangle(0, 0, _guiW, _guiH, false);
	draw_set_alpha(whiteFlash);
	draw_set_color(c_white);
	draw_rectangle(0, 0, _guiW, _guiH, false);
	draw_set_alpha(1);
}

var _center = getRingCenter();
var _shakeX = random_range(-ringShake, ringShake);
var _shakeY = random_range(-ringShake, ringShake);
var _cx = _center[0] + _shakeX;
var _cy = _center[1] + _shakeY;

#region anel de luta
var _ringRadius = 74 * ringScale * (1 + ringPulse * .12 + _outro * .6);
var _ringThickness = 12 * ringScale;
var _progressColor = getProgressColor(_ratio);

if (_ringRadius > 1 && _uiAlpha > 0) {
	drawRadialProgress(_cx, _cy, _ringRadius - _ringThickness, _ringRadius, 1, c_black, .45 * _uiAlpha);
	drawRadialProgress(_cx, _cy, _ringRadius - _ringThickness, _ringRadius, _trailRatio, c_white, .35 * _uiAlpha);
	drawRadialProgress(_cx, _cy, _ringRadius - _ringThickness, _ringRadius, _ratio, _progressColor, _uiAlpha);

	if (ringPulse > 0) {
		gpu_set_blendmode(bm_add);
		drawRadialProgress(_cx, _cy, _ringRadius - _ringThickness - 4, _ringRadius + 4, _ratio, _progressColor, ringPulse * .5 * _uiAlpha);
		gpu_set_blendmode(bm_normal);
	}

	draw_set_alpha(.6 * _uiAlpha);
	draw_set_color(c_black);
	for (var i = 1; i < 4; i++) {
		var _angle = 90 - 90 * i;
		draw_line_width(
			_cx + lengthdir_x(_ringRadius - _ringThickness - 2, _angle), _cy + lengthdir_y(_ringRadius - _ringThickness - 2, _angle),
			_cx + lengthdir_x(_ringRadius + 2, _angle), _cy + lengthdir_y(_ringRadius + 2, _angle),
			3
		);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}
#endregion

#region título
draw_set_font(fnt_gui_title);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _titleShake = escaped ? 0 : 1 + _ratio * 3;
var _titleX = _cx + random_range(-_titleShake, _titleShake);
var _titleY = _cy - _ringRadius - 40 + sin(current_time / 120) * 3;
var _titleScale = titlePop * (escaped ? 1 + _outro * .5 : 1);
var _titleAlpha = escaped ? 1 - max(0, _outro - .4) / .6 : 1;
var _titleColor = escaped ? #5fd35f : merge_color(c_white, #ffd166, _ratio);

drawTextShadow(_titleX, _titleY, titleText, _titleAlpha, 4, _titleScale);
draw_set_alpha(_titleAlpha);
draw_text_transformed_color(_titleX, _titleY, titleText, _titleScale, _titleScale, 0, _titleColor, _titleColor, _titleColor, _titleColor, _titleAlpha);
draw_set_alpha(1);
#endregion

#region prompt
if (_uiAlpha > 0 && phase == "struggle") {
	var _promptPulse = 1 + sin(current_time / lerp(160, 70, _ratio)) * .06;
	var _promptY = _cy + _ringRadius + 50;

	draw_set_font(fnt_gui_default);
	var _keyText = "ESPAÇO";
	var _keyWidth = (string_width(_keyText) + 36) * _promptPulse;
	var _keyHeight = 46 * _promptPulse;
	var _orText = "ou";
	var _orWidth = string_width(_orText);
	var _mouseScale = 3 * _promptPulse;
	var _mouseWidth = sprite_get_width(spr_mouse) * _mouseScale;
	var _gap = 18;
	var _totalWidth = _keyWidth + _gap + _orWidth + _gap + _mouseWidth;
	var _startX = _cx - _totalWidth / 2;

	var _press = promptPress * 5;
	var _keyX = _startX;
	var _keyY = _promptY - _keyHeight / 2;
	draw_set_alpha(_uiAlpha);
	draw_set_color(#3a3a3a);
	draw_roundrect_ext(_keyX, _keyY + 6, _keyX + _keyWidth, _keyY + _keyHeight + 6, 10, 10, false);
	draw_set_color(merge_color(#e8e8e8, #fff6d6, _ratio));
	draw_roundrect_ext(_keyX, _keyY + _press, _keyX + _keyWidth, _keyY + _keyHeight + _press, 10, 10, false);
	draw_set_color(#2a2a2a);
	draw_text(_keyX + _keyWidth / 2, _keyY + _keyHeight / 2 + _press, _keyText);

	draw_set_color(c_white);
	var _orX = _keyX + _keyWidth + _gap + _orWidth / 2;
	drawTextShadow(_orX, _promptY, _orText, _uiAlpha);
	draw_text(_orX, _promptY, _orText);

	var _mouseX = _orX + _orWidth / 2 + _gap + _mouseWidth / 2;
	var _mouseFrame = (current_time / 1000) * sprite_get_speed(spr_mouse) * (1 + _ratio);
	drawSpriteShadow(_mouseX, _promptY + _press, spr_mouse, _mouseFrame, 0, _mouseScale, _mouseScale, 4, 4, _uiAlpha);
	draw_sprite_ext(spr_mouse, _mouseFrame, _mouseX, _promptY + _press, _mouseScale, _mouseScale, 0, c_white, _uiAlpha);
	draw_set_alpha(1);
}
#endregion

#region faíscas
gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(sparks); i++) {
	var _spark = sparks[i];
	var _size = 2 + _spark.life * 3;
	draw_set_alpha(_spark.life);
	draw_set_color(_spark.color);
	draw_rectangle(_spark.x - _size, _spark.y - _size, _spark.x + _size, _spark.y + _size, false);
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
#endregion

draw_set_font(fnt_gui_default);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
