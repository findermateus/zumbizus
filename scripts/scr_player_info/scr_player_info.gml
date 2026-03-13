function drawPlayerInfo(_inventoryBox) {
	var _extraPlaceForStats = 32 * 3;
	var _playerInfoBox = {
		x: 0,
		y: _inventoryBox.yPosition,
		width: display_get_width() / 4,
		height: display_get_gui_height() * .7,
		sprite: spr_inventory_box,
		border: 12
	};
	var _marginFromInventory = 25;
	_playerInfoBox.x = _inventoryBox.xPosition - _playerInfoBox.width - _marginFromInventory;
    var _yScale = getScale(_playerInfoBox.height, sprite_get_height(_playerInfoBox.sprite));
	var _xScale = getScale(_playerInfoBox.width, sprite_get_width(_playerInfoBox.sprite));
	
	draw_sprite_ext(_playerInfoBox.sprite, 0, _playerInfoBox.x, _playerInfoBox.y, _xScale, _yScale, 0, c_white, 1);
    
	_playerInfoBox.x += _playerInfoBox.border;
	_playerInfoBox.width -= _playerInfoBox.border * 2;
	_playerInfoBox.y += _playerInfoBox.border;
	_playerInfoBox.height -= _playerInfoBox.border * 2;
	
	drawPlayerInsideInfoBox(_playerInfoBox);
	drawPlayerToolBar(_playerInfoBox);
	drawPlayerEquipments(_playerInfoBox);
}

function drawPlayerInsideInfoBox(_box) {
	var _verticalMiddlePoint = getMiddlePoint(_box.y, _box.y + _box.height);
	var _horizontalMiddlePoint = getMiddlePoint(_box.x, _box.x + _box.width);
	
	var _skinColor = global.player.skinColor;
	var _hair = global.player.hair;
	var _armor = global.equipments.armor;
	var _helmet = global.equipments.head;
	var _bag = global.equipments.bag;
	var _scale = 1.6;
	var _rawPlayerHeight = sprite_get_height(spr_human_male_iddle);
	var _rawPlayerWidht = sprite_get_width(spr_human_male_iddle);
	var _playerVerticalSize = _rawPlayerHeight * _scale;
	var _playerHorizontalSize = _rawPlayerWidht * _scale;

	var _padding = 30; 

	var _boxX = _horizontalMiddlePoint - (_playerHorizontalSize / 2) - _padding;
	var _boxY = _verticalMiddlePoint - _playerVerticalSize - _padding;
	var _boxWidth = _playerHorizontalSize + (_padding * 2);
	var _boxHeight = _playerVerticalSize + (_padding * 2);

	draw_sprite_stretched(
		spr_map_button,
		0,
		_boxX,
		_boxY,
		_boxWidth,
		_boxHeight
	);

	drawSpriteShadow(
		_horizontalMiddlePoint,
		_verticalMiddlePoint,
		spr_human_male_iddle,
		0,
		0,
		_scale,
		_scale
	);
	
	var _armorId = is_struct(_armor) ? _armor.itemId : -1;
	var _helmetId = is_struct(_helmet) ? _helmet.itemId : -1;
	var _bagId = is_struct(_bag) ? _bag.itemId : -1;
	
	drawPersonBody(
		_horizontalMiddlePoint,
		_verticalMiddlePoint,
		global.player.gender,
		0,
		_scale,
		0,
		1,
		_skinColor,
		_hair,
		_armorId,
		_helmetId,
		_bagId,
		1,
		drawStates.iddle
	);
}

function drawPlayerEquipments(_box){
	var _sprite = spr_inventory_grid;
	var _intendedSize = 100;
	var _scale = getScale(_intendedSize, sprite_get_width(_sprite));
	var _grid = {
		intendedSize: _intendedSize,
		sprite: _sprite,
		scale: _scale 
	};
	_box.y = drawPlayerHat(_box, _grid);
	drawPlayerArmor(_box, _grid);
}

function drawPlayerHat(_box, _grid){
	var _x = getMiddlePoint(_box.x, _box.x + _box.width);
	var _marginFromTop = 35;
	var _y = _box.y + _marginFromTop;
	_x -= (sprite_get_width(_grid.sprite) * _grid.scale)/2;
	drawEquipmentGrid(_x, _y, _grid, _box, 0, "head", global.equipments.head);
	return _y + sprite_get_height(_grid.sprite) * _grid.scale;
}

function drawPlayerArmor(_box, _grid){
	var _gridHeight = sprite_get_height(_grid.sprite) * _grid.scale;
	var _y = _box.y + _gridHeight;
	var _hMargin = 25;
	var _xPosition = _box.x + _hMargin;
	var _item = global.equipments.bag;
	drawEquipmentGrid(_xPosition, _y, _grid, _box, _hMargin, "bag", _item);
	_xPosition = _box.x + _box.width - _hMargin;
	_xPosition -= sprite_get_width(_grid.sprite) * _grid.scale;
	drawEquipmentGrid(_xPosition, _y, _grid, _box, _hMargin, "armor", global.equipments.armor);
}

function drawSpriteWithGpuFog(_color, _sprite, _sub, _x, _y, _xScale, _yScale, _angle, _alpha){
	gpu_set_fog(true, _color, 0, 0);
	draw_sprite_ext(_sprite, _sub, _x, _y, _xScale, _yScale, _angle, c_white, _alpha);
	gpu_set_fog(false, _color, 0, 0);
}

function drawSpriteWithGpuFogStretched(_color, _sprite, _sub, _x, _y, _xSize, _ySize, _angle, _alpha){
	gpu_set_fog(true, _color, 0, 0);
	draw_sprite_stretched_ext(_sprite, _sub, _x, _y, _xSize, _ySize, c_white, _alpha);
	gpu_set_fog(false, _color, 0, 0);
}

function drawEquipmentGrid(_xPosition, _y, _grid, _box, _hMargin, _indicatorType, _item){
	draw_sprite_ext(_grid.sprite, 2, _xPosition, _y, _grid.scale, _grid.scale, 0, c_white, 1);
	if (indicatorToWhereItemShouldBePut == _indicatorType) {
		var _timer = get_timer()/100000;
		var _alphaIndex = (sin(_timer * 0.5) + 1) * 0.2;
		drawSpriteWithGpuFog(c_white, _grid.sprite, 2, _xPosition, _y, _grid.scale, _grid.scale, 0, _alphaIndex);
	}
	if (_item != global.blankInventorySpace){
		drawItemInGrid(_item, _grid, _xPosition, _y);
	}
	var _gridSize = sprite_get_width(_grid.sprite) * _grid.scale;
	var _mouseIsOnGrid = mouseIsOnRectangle(_xPosition, _y, _xPosition + _gridSize, _y + _gridSize);
	if (_mouseIsOnGrid && indicatorToWhereItemShouldBePut == _indicatorType){
		hoverIndicatorUIData.destinyX = _xPosition;
		hoverIndicatorUIData.destinyY = _y;
		mouseIsOnEquipments = true;
		handleHoldingOverItem(_indicatorType);
	}
	if(global.activeInventory && (_mouseIsOnGrid && activeHoldingItem == global.blankInventorySpace)){
		holdItemFromEquipment(_item);
	}
}

function holdItemFromEquipment(_item){
	if(!mouse_check_button(mb_left)) return;
	cleanMenuOptions();
	if (_item == global.blankInventorySpace) return;
	holdingItemFromEquipments = true;
	activeHoldingItem = _item;
	holdingItem.scale = getItemScale(GRIDSIZE, sprite_get_height(_item.sprite));
	currentState = holdItem;
}

function handleHoldingOverItem(_indicatorType){
	if (!mouse_check_button_released(mb_left)) return;
	if (holdingItemFromEquipments) return;
	var _alreadyPlacedItem = variable_struct_get(global.equipments, _indicatorType)
	if (_alreadyPlacedItem != global.blankInventorySpace){
		var _inventoryItem = activeHoldingItem;
		global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _alreadyPlacedItem;
		equipEquipment(_indicatorType, _inventoryItem);
		return;
	}
	global.activeInventoryAction[# holdingItem.j, holdingItem.i] = global.blankInventorySpace;
	equipEquipment(_indicatorType, activeHoldingItem);
}

function equipEquipment(_type, _inventoryItem) {
	playEquipEquipmentSound();
	variable_struct_set(global.equipments, _type, _inventoryItem);
	handleEquipmentSwitch();
}

function playEquipEquipmentSound() {
	audio_play_sound(snd_equip_equipment, 0, false);
}

function storeEquipment(){
	var _inventorySpace = global.activeInventoryAction[# hoverItem.j, hoverItem.i];
	if (_inventorySpace != global.blankInventorySpace) return;
	global.activeInventoryAction[# hoverItem.j, hoverItem.i] = variable_struct_get(global.equipments, indicatorToWhereItemShouldBePut);
	variable_struct_set(global.equipments, indicatorToWhereItemShouldBePut, global.blankInventorySpace);
	handleEquipmentSwitch();
}

function handleEquipmentDropping(){
	holdingItemFromEquipments = false;
	if (mouseIsOnInventoryGrid){
		storeEquipment();
		return;
	}
	if (mouseIsOnEquipments || mouseIsOnInventory){
		return;
	}
	var _droppedItem = instance_create_layer(obj_player.x, obj_player.y, "Items", obj_item);
	_droppedItem.item = activeHoldingItem;
	variable_struct_set(global.equipments, indicatorToWhereItemShouldBePut, global.blankInventorySpace);
	handleEquipmentSwitch();
}

function drawItemInGrid(_item, _grid, _x, _y){
	var _height = sprite_get_height(_grid.sprite) * _grid.scale;
	var _itemWidth = sprite_get_width(_item.sprite);
	var _itemHeight = sprite_get_height(_item.sprite);
	var _scale = getItemScale(_height - 20, _itemHeight);
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getItemScale(_height - 20, _itemWidth);
	}
	_x += _height/2;
	_y += _height/2;
	draw_sprite_ext(_item.sprite, 0, _x, _y, _scale, _scale, 0, c_white, 1);
}

function drawPlayerToolBar(_playerInfoBox){
	var _marginBottom = 20;
	var _spriteSize = sprite_get_height(spr_inventory_grid);
	var _intendedSize = 100;
	var _scale = getScale(_intendedSize, GRIDSIZE);
	var _borderMargin = 60;
	var _x2 = _playerInfoBox.x + _playerInfoBox.width - _playerInfoBox.border - _borderMargin;
	_playerInfoBox.height -= _playerInfoBox.border + _marginBottom;
	_playerInfoBox.height -= _intendedSize;
	var _yPosition = _playerInfoBox.y + _playerInfoBox.height;
	var _toolBar = getToolBarBox(_playerInfoBox.x + _borderMargin, _x2, 0, _yPosition, undefined, _scale, false);
	drawToolBarItems(_toolBar);
	var _size = 85;
	drawQuickUseItemsInInventory(_playerInfoBox.x + _borderMargin, _x2, _yPosition - _size - 25, _size);
}

function drawQuickUseItemsInInventory(_x1, _x2, _y, _size) {
	static indicatorAlpha = 0;
	static hoverIndicator = {
		x: 0,
		y: 0,
		desX: 0,
		desY: 0,
		alpha: 0,
		isHovering: false
	};
	
	var _holdingItem = activeHoldingItem;
	var _hoverItem = activeHoverItem;
	var _actualItem = _holdingItem == global.blankInventorySpace ? _hoverItem : _holdingItem;
	 _actualItem = itemCanBeAddedToQuickBarUse(_actualItem) ? _actualItem : global.blankInventorySpace;
	
	var _sprite = spr_inventory_grid;
	var _spaceBetweenBoxes = 12;
	var _numItems = ds_list_size(global.quickUse);

	if (_numItems <= 0) {
		return;
	}
	
	var _totalItemsWidth = _numItems * _size;
	var _totalSpacingWidth = (_numItems - 1) * _spaceBetweenBoxes;
	var _totalGroupWidth = _totalItemsWidth + _totalSpacingWidth;
	var _areaCenterX = _x1 + (_x2 - _x1) / 2;
	var _startX = _areaCenterX - (_totalGroupWidth / 2);
	hoverIndicator.isHovering = false;
	for (var i = 0; i < _numItems; i++) {
		var _actualX = _startX + (i * (_size + _spaceBetweenBoxes));
		draw_sprite_stretched(_sprite, 0, _actualX, _y, _size, _size);
		
		if (_actualItem != global.blankInventorySpace) {
			drawSpriteWithGpuFogStretched(c_white, _sprite, 0, _actualX, _y, _size, _size, 0, indicatorAlpha * .6);
		}
		
		var _item = getItemFromQuickUse(i);
		var _itemX = getMiddlePoint(_actualX, _actualX + _size);
		var _itemY = getMiddlePoint(_y, _y + _size);
		
		if (_item != false) {
			drawQuickUseItem(_itemX, _itemY, _size * .8, _item.sprite);
		} else {
			drawQuickUsePlaceholder(_itemX, _itemY, _size);
		}
		
		draw_sprite_stretched(_sprite, 1, _actualX, _y, _size, _size);
		var _mouseIsHovering = mouseIsOnRectangle(_actualX, _y, _actualX + _size, _y + _size);
		if (_mouseIsHovering) {
			hoverIndicator.desX = _actualX;
			hoverIndicator.desY = _y;
			hoverIndicator.isHovering = true;
			if (itemCanBeAddedToQuickBarUse(activeHoldingItem) && mouse_check_button_released(mb_left)) {
				addToQuickUseWithIndex(i, activeHoldingItem, activeHoldingItem.quantity);
			}
			if (mouse_check_button_pressed(mb_left)) {
				if (_item != false) {
					addQuickUseItemToInventory(i);
				}
			}
			
		}
		if (_item != false && _item.quantity > 1) {
			drawQuickUseItemQuantity(_actualX, _y, _size, _item.quantity);
		}
	}	
	
	mouseIsOnQuickUseBar = hoverIndicator.isHovering;
	if (_actualItem != global.blankInventorySpace) {
		indicatorAlpha = getAlphaWithTimer(.2);
	}
	
	hoverIndicator.x = lerp(hoverIndicator.x, hoverIndicator.desX, .1);
	hoverIndicator.y = lerp(hoverIndicator.y, hoverIndicator.desY, .1);
	hoverIndicator.alpha = lerp(hoverIndicator.alpha, hoverIndicator.isHovering, .1);
	draw_sprite_stretched_ext(
		spr_hover_indicator,
		0,
		hoverIndicator.x,
		hoverIndicator.y,
		_size,
		_size,
		c_white,
		hoverIndicator.alpha
	);
}

function drawQuickUseItem(_x, _y, _size, _itemSprite) {
	var _scale = getScale(_size * .8, sprite_get_width(_itemSprite));
	draw_sprite_ext(_itemSprite, 0, _x, _y, _scale, _scale, 0, c_white, draw_get_alpha());
}

function drawQuickUseItemQuantity(_x, _y, _size, _quantity) {
	draw_set_valign(fa_bottom);
	draw_set_halign(fa_right)
	drawTextShadow(_x + _size, _y + _size, string(_quantity) + "x", 1);
	draw_text(_x + _size, _y + _size, string(_quantity) + "x");
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
}

function drawQuickUsePlaceholder(_x, _y, _size) {
	var _itemSprite = spr_attribute_supply;
	var _scale = getScale(_size * .5, sprite_get_width(_itemSprite));
	drawSpriteShadow(_x, _y, _itemSprite, 0, 0, _scale, _scale);
	drawSpriteWithGpuFog(c_gray, _itemSprite, 0, _x, _y, _scale, _scale, 0, .6);
}

function StatusBar(_value, _maxValue, _icon) constructor {
	value = _value;
	maxValue = _maxValue;
	icon = _icon;
}

function drawPlayerStatsInventory(_playerInfoBox){
	static statusBars = [
		new StatusBar(global.player.health, global.player.defaultMaxHealth, spr_life_bar),
		new StatusBar(global.player.stamina, global.player.defaultMaxStamina, spr_energy_bar),
		new StatusBar(global.player.currentHunger / 10, global.player.defaultTotalHunger / 10, spr_hunger_bar),
		new StatusBar(global.player.currentThirst / 10, global.player.defaultTotalThirst / 10, spr_thirst_bar)
	];
	
	var _playerValuesFactory = function (_currentValue, _maximumValue) {
		return {
			value: _currentValue,
			max: _maximumValue
		}
	}
	
	var _statusBarValues = [
		_playerValuesFactory(global.player.health, global.player.maxHealth),
		_playerValuesFactory(global.player.stamina, global.player.maxStamina),
		_playerValuesFactory(global.player.currentHunger / 10, global.player.defaultTotalHunger / 10),
		_playerValuesFactory(global.player.currentThirst / 10, global.player.defaultTotalThirst / 10)
	];
	
	for (var i = 0; i < array_length(statusBars); i ++) {
		statusBars[i].value = lerp(statusBars[i].value, _statusBarValues[i].value, .1);
		statusBars[i].maxValue = lerp(statusBars[i].maxValue, _statusBarValues[i].max, .1);
	}
	
	var _statsBox = getPlayerStatsBox(_playerInfoBox);
	draw_sprite_stretched(_statsBox.sprite, 0, _statsBox.x, _statsBox.y, _statsBox.width, _statsBox.height);
	_statsBox = fixBoxMargin(_statsBox, 12);
	_statsBox = drawStaminaInInventory(_statsBox, [statusBars[0], statusBars[1]]);
	drawStaminaInInventory(_statsBox,  [statusBars[2], statusBars[3]]);
}

function fixBoxMargin(_box, _margin){
	_box.x += _margin;
	_box.x2 -= _margin;
	_box.width -= _margin * 2;
	_box.y += _margin;
	_box.y2 -= _margin;
	_box.height -= _margin * 2;
	return _box;
}

function getPlayerStatsBox(_playerInfoBox){
	var _marginFromInventory = 10;
	var _box = {
		sprite: spr_inventory_box,
		x: _playerInfoBox.xPosition,
		x2: _playerInfoBox.xPosition + _playerInfoBox.boxWidth,
		width: _playerInfoBox.boxWidth,
		y: _playerInfoBox.yPosition + _playerInfoBox.boxHeight + _marginFromInventory,
		height: 180,
		y2: 0
	}
	_box.y2 = _box.y + _box.height
	return _box;
}

function drawStaminaInInventory(_box, _bars){
	var _staminaBarHeight = 15;
	var _margin = 10;
	var _yPosition = _box.y + _margin;
	var _xPosition = _box.x + 15;
	var _width = 0;
	for (var i = 0; i < array_length(_bars); i ++){
		var _bar = _bars[i];
		var _desiredHeight = 60, _scale = getScale(_desiredHeight, sprite_get_height(_bar.icon));
		//draw_sprite_ext(_bar.icon, 0, _xPosition, _yPosition, _scale, _scale, 0, c_white, 1);
		_width = sprite_get_width(_bar.icon) * _scale;
		drawPlayerStatusBar(round(_bar.value), round(_bar.maxValue), _xPosition, _yPosition, _width, _desiredHeight, 0, _bar.icon);
		var _marginBetween = 15;
		_yPosition += _desiredHeight + _marginBetween;
	}
	
	_box.x = _xPosition + _width + 10;
	return _box;
}

function drawStatusBar(_icon, _outline, _value, _color, _xPosition, _yPosition, _width, _alpha = .3) {
	var _spriteWidth = sprite_get_width(_icon);
	var _scale = getScale(_width, _spriteWidth);
	var _percent = round(_spriteWidth * _value/100);
	var _top = _spriteWidth - _percent;
	drawSpriteWithGpuFog(_color, _icon, 0, _xPosition, _yPosition, _scale, _scale, 0, _alpha);
	draw_sprite_part_ext(_icon, 0, 0, _top, _spriteWidth, _spriteWidth, _xPosition, _yPosition + _top * _scale, _scale, _scale, c_white, 1);
	draw_sprite_ext(_outline, 0, _xPosition, _yPosition, _scale, _scale, 0, c_white, 1);
	return _width;
}

function drawPlayerStatusBar(_value, _maxValue, _xPosition, _yPosition, _barWidth, _barHeight, _borderThickness, _sprite, _angle = 0) {
    var _staminaRatio = _value / _maxValue;
    var _scale = getScale(_barWidth, sprite_get_width(_sprite));
    var _barMarginLeft = 21;
    var _barMarginRight = 0;
    var _fillableWidth = sprite_get_width(_sprite) - _barMarginLeft - _barMarginRight;
	_barHeight = sprite_get_height(_sprite) * _scale;
    draw_sprite_ext(_sprite, 0, _xPosition, _yPosition, _scale, _scale, _angle, c_white, 1);
    
    draw_sprite_general(
        _sprite,
        1,
        _barMarginLeft,
        0,
        _fillableWidth * _staminaRatio,
        sprite_get_height(_sprite),
        _xPosition + (_barMarginLeft * _scale),
        _yPosition,
        _scale,
        _scale,
        _angle,
        c_white,
        c_white,
        c_white,
        c_white,
        1
    );

    draw_set_color(c_white);
	
	if (mouseIsOnRectangle(_xPosition, _yPosition, _xPosition + _barWidth, _yPosition + _barHeight)) {
		draw_set_font(fnt_default_small);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var tx = getMiddlePoint(_xPosition, _xPosition + _barWidth) + 15;
		var ty = getMiddlePoint(_yPosition, _yPosition + _barHeight);
		var _text = string(round(_value)) + "/" + string(round(_maxValue));
		drawTextShadow(tx, ty, _text, draw_get_alpha());
		draw_text(tx, ty, _text);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_font(fnt_default);
	}
	
    return sprite_get_height(_sprite) * _scale;
}