function drawResourceBar(_barSize, _barWidth, _x, _y, _color, _ratio, _quantity, _total, _alpha, _increasedSize, _backgroundAlpha = .6, _backgroundColor = c_black){
	var _border = _barSize * .2;
	var _resourceMaxWidth = _barWidth - _border * 2;
	var _resourceBarHeight = _barSize - _border * 2;
	var _resourceBarWidth = _resourceMaxWidth * _ratio;
	var _sprite = spr_resource_bar;
	var _xScale = getScale(_resourceBarWidth, sprite_get_width(_sprite));
	var _yScale = getScale(_resourceBarHeight, sprite_get_height(_sprite));
	var _barX = _x + _border;
	var _barY = _y + _border;
	var _currentAlpha = draw_get_alpha();
	var _bgX = _barX - _increasedSize;
	var _bgY = _barY - _increasedSize;
	var _bgWidth = _resourceMaxWidth + _increasedSize * 2;
	var _bgHeight = _resourceBarHeight + _increasedSize * 2;
	draw_sprite_stretched_ext(spr_resource_outline_bar, 0, _bgX, _bgY, _bgWidth, _bgHeight, _backgroundColor, _backgroundAlpha);
//	draw_rectangle(_bgX, _bgY, _bgX + _bgWidth, _bgY + _bgHeight, false);

	draw_set_alpha(_currentAlpha);
	draw_sprite_stretched_ext(
		_sprite, 0,
		_barX, _barY,
		_resourceBarWidth, _resourceBarHeight,
		_color,
		_alpha
	);
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	var _shadowColor = c_black;
	var _text = string(_quantity) + "/" + string(_total);
	draw_text_transformed_color(_x + _resourceMaxWidth + 3, _y + 3, _text, 0.8, 0.8, 0, _shadowColor, _shadowColor, _shadowColor, _shadowColor, _alpha);
	draw_text_transformed(_x + _resourceMaxWidth, _y, _text, .8, .8, 0);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}