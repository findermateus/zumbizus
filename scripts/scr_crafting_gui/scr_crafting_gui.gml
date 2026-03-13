function drawRequirement(_icon,	_itemTitle, _size, _x, _y, _currentValue, _expectedValue, _alpha = 1) {
	var _boxSprite = spr_item_collected_indicator;
	var _border = 12;
	var _color = _currentValue >= _expectedValue ? #2E7D32 : #660707;
	var _textDisplay = string(_currentValue) + "/" + string(_expectedValue) + " " + _itemTitle;
	var _boxWidth = _size + _border * 2 + string_width(_textDisplay);
	draw_sprite_stretched_ext(_boxSprite, 1, _x, _y, _boxWidth, _size, _color, _alpha);
	var _iconX = _x + _size / 2;
	var _iconY = _y + _size / 2;
	var _iconSize = _size - _border * 2;
	var _scale = getScale(_iconSize, sprite_get_height(_icon));
	drawSpriteShadow(_iconX, _iconY, _icon, 1, 0, _scale, _scale, 4, 4, _alpha);
	draw_sprite_ext(_icon, 0, _iconX, _iconY, _scale, _scale, 0, c_white, _alpha);
	draw_text_scribble(_x + _iconSize + _border * 2, _y + _size /2, "[fa_middle]" + _textDisplay);
}

function drawEarningItem(_title, _icon, _x, _y, _size, _value, _alpha = 1) {
	var auxAlpha = draw_get_alpha();	
	draw_set_alpha(_alpha);
	var _boxSprite = spr_item_collected_indicator;
	var _border = 12;
	var _color = #2E7D32;
	var _textDisplay = "+" + string(_value) + " " + _title;
	var _boxWidth = _size + _border * 2 + string_width(_textDisplay);
	draw_sprite_stretched_ext(_boxSprite, 1, _x, _y, _boxWidth, _size, _color, _alpha);
	var _iconX = _x + _size / 2;
	var _iconY = _y + _size / 2;
	var _iconSize = _size - _border * 2;
	var _scale = getScale(_iconSize, sprite_get_height(_icon));
	drawSpriteShadow(_iconX, _iconY, _icon, 1, 0, _scale, _scale, 4, 4, _alpha);
	draw_sprite_ext(_icon, 0, _iconX, _iconY, _scale, _scale, 0, c_white, _alpha);
	draw_text_scribble(_x + _iconSize + _border * 2, _y + _size /2, "[fa_middle]" + _textDisplay);
	draw_set_alpha(auxAlpha)
}