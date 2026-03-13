function drawQuickUseOnGui(_x, _y, _verticalSize, _alpha = 1, _inventory = false) {
	var _box = spr_inventory_box;
	var _yscale = getScale(_verticalSize, sprite_get_width(_box));
	var _border = 12;
	var _width = _verticalSize * 2;
	
	draw_sprite_stretched_ext(_box, 0, _x, _y, _width, _verticalSize, c_white, _alpha);
	
	var _size = 80;
	var _gridY = _y + _verticalSize - _border - _size - 6;

	{	
		if (!_inventory) {
			var _textY = getMiddlePoint(_y + _border, _gridY);
			var _textX = getMiddlePoint(_x, _x + sprite_get_width(_box) * _yscale * 2);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(fnt_gui_long_text);
			var _label = "Uso rápido [E]";
			drawTextShadow(_textX, _textY, _label, _alpha * .6);
			draw_text(_textX, _textY, _label);
			draw_set_font(fnt_gui_default);
			draw_set_valign(fa_top);
			draw_set_halign(fa_left);
		}
	}
	
	var _initialX = _x + _border;
	var _endX = _x + _width - _border;
	if (_inventory) {
		_gridY = getMiddlePoint(_y, _y + _verticalSize) - _size / 2;
		drawQuickUseItemsInInventory(_initialX, _endX, _gridY, _size);
	} else {
		drawQuickUseItemsInGame(_initialX, _endX, _gridY, round(_size));
	}
}

function getQuickUseUiValues() {
	var _result = [];
	for (var i = 0; i < ds_list_size(global.quickUse); i++) {
		_result[i] = {
			y: 0,
			desY: 0
		}
	}
	return _result;
}

function drawQuickUseItemsInGame(_x1, _x2, _y, _size) {
	static uiValues = getQuickUseUiValues();
	var _sprite = spr_base_resident_grid;
	var _spaceBetweenBoxes = 12;
	var _numItems = ds_list_size(global.quickUse);

	if (_numItems <= 0) {
		return;
	}
	
	var _selectionShiftY = 8;
	var _totalItemsWidth = _numItems * _size;
	var _totalSpacingWidth = (_numItems - 1) * _spaceBetweenBoxes;
	var _totalGroupWidth = _totalItemsWidth + _totalSpacingWidth;
	var _areaCenterX = _x1 + (_x2 - _x1) / 2;
	var _startX = _areaCenterX - (_totalGroupWidth / 2);
	
	for (var i = 0; i < _numItems; i++) {
		var _uiValue = uiValues[i];
		var _is_selected = (global.activeQuickUseIndex == i);
		
		var _actualX = _startX + (i * (_size + _spaceBetweenBoxes));
		
		_uiValue.desY = _y - (_is_selected ? _selectionShiftY : 0);
		
		draw_sprite_stretched(_sprite, _is_selected, _actualX, _uiValue.y, _size, _size);
		var _item = getItemFromQuickUse(i);
		var _itemX = getMiddlePoint(_actualX, _actualX + _size);
		var _itemY = getMiddlePoint(_uiValue.y, _uiValue.y + _size);
		
		if (_item != false) {
			drawQuickUseItem(_itemX, _itemY, _size * .8, _item.sprite);
		} else {
			drawQuickUsePlaceholder(_itemX, _itemY, _size);
		}
		
		var _mouseIsHovering = mouseIsOnRectangle(_actualX, _uiValue.y, _actualX + _size, _uiValue.y + _size);
		
		if (_item != false && _item.quantity > 1) {
			drawQuickUseItemQuantity(_actualX, _uiValue.y, _size, _item.quantity);
		}
	}
	
	for (var i = 0; i < _numItems; i++) {
		uiValues[i].y = lerp(uiValues[i].y, uiValues[i].desY, .2);
	}
}