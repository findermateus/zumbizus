#macro EQUIPED_ITEM_GRID_SIZE 90
#macro QUICK_USE_WIDTH 250
#macro QUICK_USE_HEIGHT 150
#macro QUICK_USE_SLOT_SIZE 60
#macro QUICK_USE_SELECTED_SLOT_SIZE 75

gui_height = display_get_gui_height();
gui_width = display_get_gui_width();
xMouseToGui = device_mouse_x_to_gui(0);
yMouseToGui = device_mouse_y_to_gui(0);
jiggleData = ds_map_create();
healthStatus = { value: 1, max: 1, jiggleTimer: 0 };
staminaStatus = { value: 1, max: 1, jiggleTimer: 0 };
jiggleDecrease = 0.1;
equipedItemsUI = [];
equipedItemsY = gui_height + EQUIPED_ITEM_GRID_SIZE;
equipedItemsX2 = 0;

quickUseItemsY = gui_height + QUICK_USE_HEIGHT;

function drawJiggleStatusBar(_id, _statusStruct, _x, _y, _width, _bThickness, _sprite, _defaultMaxValue) {
	if (_statusStruct.value < _statusStruct.max * .3) {
		_statusStruct.jiggleTimer = 5;
	}
	
	if (!ds_map_exists(jiggleData, _id)) {
		ds_map_add(jiggleData, _id, { y: _y, amplitude: 0 });
	}

	_statusStruct = _statusStruct > _defaultMaxValue ? _defaultMaxValue : _statusStruct;

	var _data = ds_map_find_value(jiggleData, _id);
	var _jiggleSpeed = 0.000015;
	
	var _angle = 0;
	
	if (_statusStruct.jiggleTimer > 0.1) {
		_data.amplitude = 4;
		_statusStruct.jiggleTimer -= jiggleDecrease;
	}

	if (_data.amplitude > 0.01) {
		var _jigglePhase = get_timer() * _jiggleSpeed;
		var _jiggleOffset = sin(_jigglePhase) * _data.amplitude;
		_data.y = _y + _jiggleOffset;
		_data.amplitude *= 0.9;
	} else {
		_data.y = _y;
		_data.amplitude = 0;
	}

	var _size = drawPlayerStatusBar(
		_statusStruct.value,
		_defaultMaxValue,
		_x,
		_data.y,
		_width,
		1,
		_bThickness,
		_sprite,
		_angle
	);
	
	if (global.debug) draw_text(_x, _y, string(round(_statusStruct.value)) + "/" + string(round(_defaultMaxValue)));
	
	return _size;
}

function drawHealth(_x, _y, _width, _bThickness) {
	return drawJiggleStatusBar("health", healthStatus, _x, _y, _width, _bThickness, spr_life_bar, max(global.player.defaultMaxHealth, global.player.maxHealth));
}

function drawStamina(_x, _y, _width, _bThickness) {
	return drawJiggleStatusBar("stamina", staminaStatus, _x, _y, _width, _bThickness, spr_energy_bar, max(global.player.defaultMaxStamina, global.player.maxStamina));
}

function drawPlayerStatsList(
	_color = c_green,
	_xPosition = 30,
	_yPosition = 110,
	_barWidth = 250,
	_borderThickness = 3
) {
	static _x = _xPosition;
	if (global.activeInventory || global.stopInteractions) {
		_x = lerp(_x, -_barWidth - 10, .1);
		if (_x < -_barWidth) return;
	} else {
		_x = lerp(_x, _xPosition, .1);
	}

	var _currentY = _yPosition;
	var _vMargin = 15;
	var _barHeight = drawStamina(_x, _currentY, _barWidth, _borderThickness);
	_currentY -= _barHeight;
	_currentY -= _vMargin;
	drawHealth(_x, _currentY, _barWidth, _borderThickness);
}

function setHealthGuiJiggle() {
	healthStatus.jiggleTimer = 5;
}

function setStaminaGuiJiggle() {
	staminaStatus.jiggleTimer = 5;
}

function equipedItemUi() {
	return {
		x: getMiddlePoint(0, display_get_gui_width()),
		y: display_get_gui_height() + EQUIPED_ITEM_GRID_SIZE,
		dx: 0,
		dy: 0,
		size: EQUIPED_ITEM_GRID_SIZE,
		dsize: EQUIPED_ITEM_GRID_SIZE
	}
}

//função responsável por desenhar a tool bar in game
function drawEquipedItems() {
	static _y = equipedItemsY;
	_y = lerp(_y, equipedItemsY, .1);
	
	if (global.activeInventory || global.activeMenu) { 
		equipedItemsY = gui_height + EQUIPED_ITEM_GRID_SIZE;
		return;
	}
	
	var _activeIndex = global.activeEquipedItemIndex;
	
	var _margin = 15;
	var _toolBarSize = ds_list_size(global.equipedItems);
	var _totalWidth = EQUIPED_ITEM_GRID_SIZE * _toolBarSize;
	_totalWidth += _margin * (_toolBarSize - 1);
	_totalWidth = round(_totalWidth);
	var _totalHeight = EQUIPED_ITEM_GRID_SIZE;
	var _padding = 35;
	var _initialX = gui_width / 2 - _totalWidth / 2;

	equipedItemsY = gui_height - _totalHeight - _padding;
	
	if (equipedItemsY > gui_height) return;
	
	var _sprite = spr_base_resident_grid;
	var _bgSprite = spr_equiped_items;
	//drawSpriteShadowStretched(
	//	round(_initialX - _padding/2),
	//	round(_y - _padding / 2),
	//	_bgSprite,
	//	0,
	//	0,
	//	round(_totalWidth + _padding),
	//	round(_totalHeight + _padding),
	//);
	
	draw_sprite_stretched_ext(
		_bgSprite,
		0,
		round(_initialX - _padding/2),
		round(_y - _padding / 2),
		round(_totalWidth + _padding),
		round(_totalHeight + _padding),
		c_white,
		1
	);
	
	equipedItemsX2 = round(_initialX - _padding/2) + _totalWidth + _padding;

	for (var i = 0; i < _toolBarSize; i++) {
		var _item = global.equipedItems[| i];
		var _ui = equipedItemsUI[i];
		var _active = _activeIndex == i;

		_ui.dsize = EQUIPED_ITEM_GRID_SIZE + (_active * 20);

		_ui.dx = _initialX + (i * (EQUIPED_ITEM_GRID_SIZE + _margin));
		_ui.dy = _y;

		var _lerpEffect = 0.1;

		_ui.x = lerp(_ui.x, _ui.dx, _lerpEffect);
		_ui.y = lerp(_ui.y, _ui.dy, _lerpEffect);
		_ui.size = lerp(_ui.size, _ui.dsize, _lerpEffect);

		var _offset = (EQUIPED_ITEM_GRID_SIZE - _ui.size) / 2;

		draw_sprite_stretched(
			_sprite,
			_active,
			_ui.x + _offset,
			_ui.y + _offset,
			_ui.size,
			_ui.size
		);

		if (_item == global.blankInventorySpace) {
			var _iconSprite = spr_pistol;
			var _scale = getScale(EQUIPED_ITEM_GRID_SIZE * .5, sprite_get_width(_iconSprite));
			drawSpriteWithGpuFog(
				c_white,
				_iconSprite,
				0,
				_ui.x + EQUIPED_ITEM_GRID_SIZE / 2,
				_ui.y + EQUIPED_ITEM_GRID_SIZE / 2,
				_scale,
				_scale, 
				0,
				.2
			);
			continue;
		} 

		var _scale = getItemScaleInGrid(_item, _ui.size);
		
		var _gridX = _ui.x + _offset;
		var _gridY = _ui.y + _offset;
		
		var _itemHasDurability = itemHasDurability(_item);
		
		if (_itemHasDurability) {
			var _minusSize = 14;
			var _size = _ui.size - _minusSize;
			
			drawItemDurability(_item, _gridX + _minusSize / 2, _gridY + _minusSize / 2, _size, _size);
		}
		
		var _ix = _gridX + (_ui.size / 2);
		var _iy = _gridY + (_ui.size / 2);

		drawSpriteShadow(_ix, _iy, _item.sprite, 0, 0, _scale, _scale);

		draw_sprite_ext(
			_item.sprite,
			0,
			_ix,
			_iy,
			_scale,
			_scale,
			0,
			c_white,
			draw_get_alpha()
		);
		
		var _tx = _ui.x + _offset + 10;
		var _ty = _ui.y;
		
		drawTextShadow(_tx, _ty, i + 1, .6);
		draw_text(
			_tx,
			_ty,
			i + 1
		);
	}
}

function getItemScaleInGrid(_item, _size) {
	var _itemWidth = sprite_get_width(_item.sprite);
	var _itemHeight = sprite_get_height(_item.sprite);
	var _scale = getScale(_size, _itemHeight);
	
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getScale(_size, _itemWidth);
	}
	
	return _scale;
}

function drawQuickUse() {
	static _y = equipedItemsY;
	_y = lerp(_y, equipedItemsY, .08);
	var _quickUseSize = ds_list_size(global.quickUse);
	var _sprite = spr_quick_use_bg;
	
	var _gridMargin = 20;
	var _margin = 60;
	var _totalWidth = QUICK_USE_SLOT_SIZE * _quickUseSize;
	_totalWidth += _gridMargin * (_quickUseSize - 1);
	_totalWidth = round(_totalWidth);
	var _padding = 35;
	
	var _height = QUICK_USE_SLOT_SIZE * 1.5;
	var _initialX = equipedItemsX2 + _margin;

	if (equipedItemsY > gui_height) return;
	
	var tx = round(_initialX - _padding / 2), ty = round(_y - _padding / 2), tw = round(_totalWidth + _padding), th = round(_height + _padding)
	
	drawSpriteShadowStretched(
		tx,
		ty,
		_sprite,
		0,
		0,
		tw,
		th,
	);
	
	draw_sprite_stretched_ext(
		_sprite,
		0,
		tx,
		ty,
		tw,
		th,
		c_white,
		1
	);

	var _textX = getMiddlePoint(tx, tx + tw);
	
	draw_set_font(fnt_default_small);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	drawTextShadow(_textX, ty + 15, "Uso Rápido [E]", draw_get_alpha());
	draw_text(_textX, ty + 15, "Uso Rápido [E]");
	draw_set_valign(fa_top);
	draw_set_halign(fa_left)
	draw_set_font(fnt_default);

    if (_quickUseSize <= 0) return;
	
    var _centerX = _initialX + _totalWidth * 0.5;
    var _centerY = _y + _height * 0.5;

    var _equippedIndex = global.activeQuickUseIndex;
    var _equippedItem = global.quickUse[| _equippedIndex];

    var _leftIndex = (_equippedIndex - 1 + _quickUseSize) mod _quickUseSize;
    var _rightIndex = (_equippedIndex + 1) mod _quickUseSize;

    var _leftItem = global.quickUse[| _leftIndex];
    var _rightItem = global.quickUse[| _rightIndex];
	
	var _gridY = _y + _height - QUICK_USE_SLOT_SIZE;
	var _gridX = _initialX + QUICK_USE_SLOT_SIZE;
	
	for (var i = 0; i < _quickUseSize; i++) {
		var _item = global.quickUse[| i];
		var _active = global.activeQuickUseIndex == i;
		var _x = _initialX + (i * (QUICK_USE_SLOT_SIZE + _gridMargin));
		drawQuickUseGrid(_x, _gridY, _item, _active, QUICK_USE_SLOT_SIZE);
	}
}

function drawQuickUseGrid(_x, _y, _item, _active = false, _slotSize = QUICK_USE_SLOT_SIZE) {
	var _gridSprite = spr_quick_use_grid;
	_y -= _active * 5;
	draw_sprite_stretched(_gridSprite, _active, _x, _y, _slotSize, _slotSize);
	
	if (_item == global.blankInventorySpace) return;
	
	var _sprite = _item.sprite;
	var _scale = getScale(_slotSize * .8, sprite_get_width(_sprite));
	draw_sprite_ext(_sprite, 0, _x + _slotSize / 2, _y + _slotSize / 2, _scale, _scale, 0, c_white, draw_get_alpha());
	
	if (_item.quantity <= 1) return;
	
	draw_set_font(fnt_default_small);
	var _text = string(_item.quantity) + "x";
	var _textWidth = string_width(_text);
	var _textHeight = string_height(_text);
	var _tx = _x + _slotSize - _textWidth, _ty = _y + _slotSize - _textHeight;
	drawTextShadow(_tx, _ty, _text, draw_get_alpha());
	draw_text(_tx, _ty, _text);
	draw_set_font(fnt_default);
}
