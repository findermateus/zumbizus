if (global.pause) exit;
if (!instance_exists(obj_player)) exit;

animProgress = lerp(animProgress, 1, 0.15);
alpha = lerp(alpha, 1, 0.1);

var _oldAlpha = draw_get_alpha();
draw_set_alpha(alpha);
draw_set_font(fnt_gui_default);

var _canInteract = animProgress >= .9;

var _dspr = spr_bar;
var _hdspr = spr_bar_white;
var _pad = 12;

var _originX = roomToGuiX(getMiddlePoint(obj_player.bbox_left, obj_player.bbox_right));
var _originY = roomToGuiY((obj_player.bbox_top + obj_player.bbox_bottom) / 2);

var _lineOriginX = _originX;
var _lineOriginY = roomToGuiY(obj_player.bbox_top);

var _choiceCount = array_length(choices);
var _selectedIndex = -1;

for (var i = 0; i < _choiceCount; i++) {
	var _target = getChoiceTarget(i, _choiceCount);

	var _x = lerp(_originX, _target.x, animProgress);
	var _y = lerp(_originY, _target.y, animProgress);

	var _str = choices[i].label;
	var _w = string_width(_str);
	var _h = string_height(_str);

	var _boxX = _x - _pad;
	if (_target.halign == fa_right) _boxX = _x - _w - _pad;
	else if (_target.halign == fa_center) _boxX = _x - (_w / 2) - _pad;

	var _boxY = _y - _pad;
	var _boxW = _w + (_pad * 2);
	var _boxH = _h + (_pad * 2);

	var _hover = mouseIsOnRectangle(_boxX, _boxY, _boxX + _boxW, _boxY + _boxH);
	hoverOffsets[i] = lerp(hoverOffsets[i], _hover ? -8 : 0, 0.2);

	var _btnCenterX = _boxX + (_boxW / 2);
	var _btnCenterY = _boxY + hoverOffsets[i] + (_boxH / 2);

	draw_ui_connection(_lineOriginX, _lineOriginY, _btnCenterX, _btnCenterY, alpha);

	draw_interaction_button(
		_hover ? _hdspr : _dspr,
		_boxX, _boxY + hoverOffsets[i], _boxW, _boxH,
		_x, _y + hoverOffsets[i],
		_str, _target.halign, alpha
	);

	if (_canInteract && _hover && mouse_check_button_released(mb_left)) {
		_selectedIndex = i;
	}
}

draw_set_halign(fa_left);
draw_set_alpha(_oldAlpha);

if (_selectedIndex != -1) {
	selectChoice(_selectedIndex);
}
