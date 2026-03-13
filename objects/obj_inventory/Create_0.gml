#macro GRID_WIDTH 92
#macro GRID_MB 10
#macro INVENTORY_TITLE_SPACE 75
activeHoldingItem = global.blankInventorySpace;
activeHoverItem = global.blankInventorySpace;
activeSelectedItem = global.blankInventorySpace;
personalizedInventory = false;
hoverIndicatorUIData = {
	x: display_get_gui_width()/2,
	y: display_get_gui_height()/2,
	destinyX: display_get_gui_width()/2,
	destinyY: display_get_gui_height()/2,
	failEffect: 0,
	destinyAlpha: 0,
	alpha: 0,
	hoverInventory: global.inventory
}
mouseIsOnInventory = false;
mouseIsOnPrimaryInventory = false;
mouseIsOnSecundaryInventory = false;
mouseIsOnInventoryGrid = false;
mouseIsOnToolBar = false;
mouseIsOnEquipments = false;
mouseIsOnQuickUseBar = false;
holdingItemPositions = { x: 0, y: 0}
defaultToolBarAlpha = .80;
descriptionItemAlpha = 0;
toolbarIndex = global.blankInventorySpace;
hoverToolbarIndex = global.blankInventorySpace;
toolBarAlpha = [];
toolBarGridScale = 1.7;
holdingItemFromToolBar = false;
holdingItemFromEquipments = false;
secundaryInventory = false;
primaryInventory = global.inventory
indicatorToWhereItemShouldBePut = global.blankInventorySpace;
global.activeInventoryAction = global.inventory;
for(var _i = 0; _i < global.toolBarSize; _i ++){
	toolBarAlpha[_i] = defaultToolBarAlpha;
}
gui_height = display_get_gui_height();
gui_width = display_get_gui_width();
xMouseToGui = device_mouse_x_to_gui(0);
yMouseToGui = device_mouse_y_to_gui(0);
holdingItem = {
	j: global.blankInventorySpace,
	i: global.blankInventorySpace,
	scale: 1,
	x: 0,
	y: 0
};
hoverItem = {
	j: global.blankInventorySpace,
	i: global.blankInventorySpace
};
selectedItem = {
	j: global.blankInventorySpace,
	i: global.blankInventorySpace,
	xPosition: 0,
	yPosition: 0
};
animationCurveInventoryShow = animcurve_get_channel(ac_inventory,"inventory_show");
curveAnimationIndex = 0;
mouseIsOnOtherMenu = false;

function hide(){
	instance_destroy(obj_menu_option);
	var _animationSpeed = (delta_time/1000000);
	curveAnimationIndex -= _animationSpeed * 1.1;
	animationCurveInventoryShow = animcurve_get_channel(ac_inventory, "inventory_hide");
	if(curveAnimationIndex < .1){
		curveAnimationIndex = 0;
		global.activeInventory = false;
		currentState = nothing;
	}
}

function handleIndicator(){
	indicatorToWhereItemShouldBePut = global.blankInventorySpace;
	var _item = global.blankInventorySpace;
	
	if (activeHoldingItem == global.blankInventorySpace && activeHoverItem != global.blankInventorySpace){
		_item = activeHoverItem;
	}
	
	if (activeHoldingItem != global.blankInventorySpace){
		_item = activeHoldingItem;
	}
	
	if (_item == global.blankInventorySpace) return;
	
	if (_item.type == itemType.equipment){
		switch (_item.equipType) {
			case equipmentType.armor: indicatorToWhereItemShouldBePut = "armor"; break; 
			case equipmentType.bag: indicatorToWhereItemShouldBePut = "bag"; break; 
			case equipmentType.head: indicatorToWhereItemShouldBePut = "head"; break;
		}
		return;
	}
	if (_item.type == itemType.weapons){
		indicatorToWhereItemShouldBePut = "toolBar";
		return;
	}
}

function drawInventory(){
	if(!global.activeInventory) return;
	personalizedInventory = false;
	mouseIsOnInventory = false;
	mouseIsOnInventoryGrid = false;
	mouseIsOnEquipments = false;
	activeHoverItem = global.blankInventorySpace;
	hoverToolbarIndex = global.blankInventorySpace;
	mouseIsOnOtherMenu = false;
	var _animationSpeed = (delta_time/1000000);
	
	if(currentState != hide && curveAnimationIndex <= 1){
		curveAnimationIndex += _animationSpeed * 1.1;
	}
	
	if (secundaryInventory != false){
		drawInventoryWithContainer();
		return;
	}
	drawDefaultInventory(display_get_gui_width() * .5, gui_height * .2, global.inventory);
}

function drawDefaultInventory(_x, _y, _inventory){
	var _inventoryBox = drawInventoryBox(_x, _y, undefined, undefined, _inventory);
	drawPlayerStatsInventory(_inventoryBox);
	mouseIsOnInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	mouseIsOnPrimaryInventory = _inventory;
	mouseIsOnSecundaryInventory = false;
	drawInventoryGrid(_inventory, _inventoryBox);
	drawPlayerInfo(_inventoryBox);
	drawHoverIndicator();
	handleIndicator();
}

function drawPersonalizedInventory(_x, _y, _inventory, _mouseIsOnOtherMenu = false) {
	personalizedInventory = true;
	mouseIsOnOtherMenu = _mouseIsOnOtherMenu;
	var _inventoryBox = drawInventoryBox(_x, _y, undefined, undefined, _inventory, false, false);
	mouseIsOnInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	mouseIsOnPrimaryInventory = _inventory;
	mouseIsOnSecundaryInventory = false;
	mouseIsOnInventoryGrid = false;
	drawInventoryGrid(_inventory, _inventoryBox);
	drawHoverIndicator();
	handleIndicator();
}

function drawInventoryWithContainer(){
	static _toolBarUiValues = getToolBarUiValues();
	if (currentState == hide) {
		_toolBarUiValues.y = lerp(_toolBarUiValues.y, gui_height + 100, .3);
	} else {
		_toolBarUiValues.y = gui_height * .85;
	}
	var _displayWidth = display_get_gui_width();
	var _displayHeight = display_get_gui_height();
	var _inventoryWidth = _displayWidth/2 * .5;
	var _inventoryHeight = _displayHeight/2;
	var _marginBetweenBoxes = 15;
	var _primaryInventoryXPositon = _displayWidth/2  - _inventoryWidth - _marginBetweenBoxes;
	var _inventoryBox = drawInventoryBox(_primaryInventoryXPositon, undefined, _inventoryWidth, _inventoryHeight, global.inventory, true);
	mouseIsOnPrimaryInventory= checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	drawInventoryGrid(primaryInventory, _inventoryBox);
	var _secundaryInventoryXPositon = _inventoryBox.xPosition + _inventoryBox.boxWidth + _marginBetweenBoxes;
	_inventoryBox = drawInventoryBox(_secundaryInventoryXPositon, undefined, _inventoryWidth, _inventoryHeight, secundaryInventory);
	mouseIsOnSecundaryInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	drawInventoryGrid(secundaryInventory, _inventoryBox);
	var _toolBar = drawToolBar(_toolBarUiValues, true);
	var _width = _toolBar.x2Position - _toolBar.x1Position;
	var _x1 = _toolBar.x2Position + 15;
	drawHoverIndicator();
	mouseIsOnInventory = (mouseIsOnPrimaryInventory || mouseIsOnSecundaryInventory);
	handleIndicator();
}

function drawInventoryBox(_xPosition = undefined, _yPosition = undefined, _boxWidth = undefined, _boxHeight = undefined, _inventory = undefined, _adjustPositionWithWidth = false, _evaluateTransition = true){
	if (_inventory == undefined) return;
	var _inventoryCols = ds_grid_width(_inventory);
	var _inventoryRows = ds_grid_height(_inventory);
	var _displayWidth = display_get_gui_width();
	var _displayHeight = display_get_gui_height();
	
	var _maxWidth = _displayWidth * .4;
	var _maxHeight = _displayHeight * .4;
	var _inventoryBox = {
		sprite: spr_inventory_box,
		boxWidth: 0,
		boxHeight: 0,
		xPosition: 0,
		yPosition: 0,
		margin: 12,
	};
	var _gridTotalSize = 92 + 10;
	var _gridPerRow = 5;
	var _totalRows = ceil((_inventoryRows * _inventoryCols) / _gridPerRow);
	
	_boxWidth = _gridTotalSize * _gridPerRow + _inventoryBox.margin * 2;
	_inventoryBox.xPosition = _xPosition;
	_inventoryBox.yPosition = _yPosition;
	_inventoryBox.boxWidth = _boxWidth;
	_inventoryBox.boxHeight = INVENTORY_TITLE_SPACE + _gridTotalSize * _totalRows + _inventoryBox.margin * 2;	
	_inventoryBox.xPosition = _xPosition == undefined ? (_displayWidth/2) - (_inventoryBox.boxWidth/2) : _xPosition;
	_inventoryBox.yPosition = _yPosition == undefined ? (_displayHeight/2) - (_inventoryBox.boxHeight/2) : _yPosition;
	
	
	if (_inventoryCols > 3 && _adjustPositionWithWidth){
		var _sizeToIncrease = (_gridTotalSize) * (_inventoryCols - 3);
		_inventoryBox.xPosition -= _sizeToIncrease;
	}
	
	while(_inventoryBox.xPosition + _inventoryBox.boxWidth > display_get_gui_width()){
		_inventoryBox.xPosition -= _gridTotalSize;
	}
	
	var _curveLength = gui_width/2;
	if (_evaluateTransition) {
		var _positionTransition = animcurve_channel_evaluate(animationCurveInventoryShow, curveAnimationIndex) * _curveLength;
		_inventoryBox.yPosition -= _positionTransition;
	}
	
	draw_sprite_stretched(
		_inventoryBox.sprite,
		0,
		_inventoryBox.xPosition,
		_inventoryBox.yPosition,
		_inventoryBox.boxWidth,
		_inventoryBox.boxHeight
	);
	
	return _inventoryBox;
}
	
function checkMousePositionWithInventory(_x1, _x2, _y1, _y2){
	return ((xMouseToGui >= _x1 && xMouseToGui <= _x2) && (yMouseToGui >= _y1 && yMouseToGui <= _y2));
}
mouseHoveredTheGrid = false
function drawInventoryGrid(_inventory, _inventoryBox){	
	var _inventoryCols = ds_grid_width(_inventory);
	var _inventoryRows = ds_grid_height(_inventory);
	var _grid = {
		sprite: spr_inventory_grid,
		gridWidth: 0,
		gridHeight: 0,
		marginBetween: 0,
	}
	_grid.marginBetween = GRID_MB;
	_grid.gridWidth = GRID_WIDTH;
	var _totalGridSize = _grid.gridWidth + 10;
	var _inventoryHorizontalSpace = _totalGridSize * ds_grid_width(_inventory);
	var _xPosition = _inventoryBox.xPosition + 20;
	_grid.gridHeight = _grid.gridWidth;
	
	var _inititalYPosition = _inventoryBox.yPosition;
	var _yPosition = _inititalYPosition + INVENTORY_TITLE_SPACE;
	var _initialXPosition = _xPosition;
	static _hoverXPosition = 0, _hoverYPosition = 0;
	static hoverUIEffects = getInventoryHoverUiEffects(_inventory);
	if (array_length(hoverUIEffects) != _inventoryRows || array_length(hoverUIEffects[0]) != _inventoryCols) {
		hoverUIEffects = getInventoryHoverUiEffects(_inventory);
	}
	drawInventoryName(_inititalYPosition, _yPosition, _xPosition, _inventory);
	var _count = 0;
	for(var _i = 0; _i < _inventoryRows; _i++){
		for(var _j = 0; _j < _inventoryCols; _j++){
			var _x = _xPosition;// + (_j * _grid.gridWidth + (_grid.marginBetween * _j));
			var _y = _yPosition;// + (_i * _grid.gridHeight + (_grid.marginBetween * _i));
			_xPosition += _grid.gridWidth + _grid.marginBetween;
			_count ++;
			if (_count == 5) {
				_count = 0; _yPosition += _grid.gridHeight + _grid.marginBetween;
				_xPosition = _initialXPosition;
			}
			//_yPosition += _grid.gridHeight + _grid.marginBetween;
			var _hoverUiValue = hoverUIEffects[_i][_j];
			var _selectedGrid = mouseIsOnRectangle(_x, _y, _x + _grid.gridWidth, _y + _grid.gridHeight);
			setInventoryUiValue(_selectedGrid, _hoverUiValue, _x, _y, 10, verifyConditionToApplyHoverEffect);
			_y = _hoverUiValue.y;
			var _gridColor = c_white;
			var _item = _inventory[# _j, _i];
			var _alpha = .8;
			if(_selectedGrid){
				_alpha = 1;
				gridOnClick(_inventory, _item, _j, _i, _x + _grid.gridWidth, _y);
				if(currentState != drawOptionsMenu){
					mouseHoveredTheGrid = true;
					mouseIsOnInventoryGrid = true;
					activeHoverItem = _item;
					hoverIndicatorUIData.destinyX = _x;
					hoverIndicatorUIData.destinyY = _y;
					hoverIndicatorUIData.hoverInventory = _inventory;
					gridOnHover(_item, _j, _i);
					if(mouse_check_button(mb_left)){
						gridOnHold(_item, _j, _i, _grid, _inventory);
					}
				}
			}
			draw_sprite_stretched_ext(
				_grid.sprite,
				0,
				_x,
				_y,
				_grid.gridWidth,
				_grid.gridHeight,
				_gridColor,
				_alpha
			);

			if (_item != global.blankInventorySpace && itemHasDurability(_item)){
				var _gridXScale = _grid.gridWidth / sprite_get_width(_grid.sprite);
				var _gridYScale = _grid.gridHeight / sprite_get_height(_grid.sprite);
				var _xMargin = 2 * _gridXScale;
				var _yMargin = 2 * _gridYScale;
				drawItemDurability(_item, _x + _xMargin, _y + _yMargin, _grid.gridHeight - _yMargin * 2, _grid.gridWidth - _xMargin * 2);
			}
			drawItem(_item, _x + _grid.gridWidth/2,  _y + _grid.gridHeight/2, _grid, 25);
			
			draw_sprite_stretched_ext(
				_grid.sprite,
				1,
				_x,
				_y,
				_grid.gridWidth,
				_grid.gridHeight,
				_gridColor,
				_alpha
			);
			
			if(_item != global.blankInventorySpace && _item.stackable && _item.quantity > 1 ){
				drawQuantity(_item, _grid, _x, _y);
			}
			if (_inventory != primaryInventory) continue;
		}
	}
}

function verifyConditionToApplyHoverEffect() {
	if (!global.activeInventory || currentState == hide) return false;
	return curveAnimationIndex >= 1;
}

function setInventoryUiValue(_isHover, _value, _x, _y, _force, _verifyConditionToApplyHoverEffect) {
	if (_value.x == 0 || !_verifyConditionToApplyHoverEffect()) {
		_value.x = _x;
		_value.y = _y;
		_value.destinyY = _y;
		_value.destinyX = _x;
		return;
	}
	_value.destinyY = _isHover ? _y - _force : _y;
	_value.destinyX = _x;
	_value.y = lerp(_value.y, _value.destinyY, .1);
	_value.x = lerp(_value.x, _value.destinyX, .1);
}

function getInventoryHoverUiEffects(_inventory) {
    var _width = ds_grid_width(_inventory);
    var _height = ds_grid_height(_inventory);
    var _values = [];

    for (var _y = 0; _y < _height; _y++) {
        var _row = [];
        for (var _x = 0; _x < _width; _x++) {
            var value = ds_grid_get(_inventory, _x, _y);
            _row[_x] = {
                x: 0,
                y: 0,
                destinyX: 0,
                destinyY: 0
            };
        }
        _values[_y] = _row;
    }

    return _values;
}


function drawHoverIndicator(){
	var _size = (mouseIsOnToolBar && activeHoldingItem != global.blankInventorySpace && activeHoldingItem.type == itemType.weapons) ? global.toolBarGridSize : GRID_WIDTH
	hoverIndicatorUIData.destinyAlpha = mouseIsOnInventoryGrid || mouseIsOnToolBar || mouseIsOnEquipments;	
	var _lerpEffect = .15;
	hoverIndicatorUIData .x = lerp(hoverIndicatorUIData .x, hoverIndicatorUIData.destinyX, _lerpEffect);
	hoverIndicatorUIData .y = lerp(hoverIndicatorUIData .y, hoverIndicatorUIData.destinyY, _lerpEffect);
	hoverIndicatorUIData.alpha = lerp(hoverIndicatorUIData.alpha, hoverIndicatorUIData.destinyAlpha, _lerpEffect);
	var sprite = spr_hover_indicator;
	var _scale = getScale(_size, sprite_get_width(sprite));
	draw_sprite_stretched_ext(sprite, 0, hoverIndicatorUIData .x, hoverIndicatorUIData .y, _size, _size, c_white, hoverIndicatorUIData.alpha);
}

function drawInventoryName(_inititalYPosition, _yPosition, _xPosition, _inventory){
	var _centralizedYPosition = getMiddlePoint(_inititalYPosition, _yPosition);
	var _title = "Armazém";
	if (_inventory == global.inventory) _title = "Inventário"; 
	draw_text_scribble(_xPosition, _centralizedYPosition, "[fa_middle]" +  _title);
}

function drawItem(_item, _x, _y, _grid, _minusScale){
	if(_item == global.blankInventorySpace) return;
	var _itemWidth = sprite_get_width(_item.sprite);
	var _itemHeight = sprite_get_height(_item.sprite);
	var _scale = getItemScale(_grid.gridHeight - _minusScale, _itemHeight);
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getItemScale(_grid.gridWidth - _minusScale, _itemWidth);
	}
	drawSpriteShadow(_x, _y, _item.sprite, 0, 0, _scale + .1, _scale + .1, 0);
	draw_sprite_ext(_item.sprite, 0, _x, _y, _scale, _scale, 0, c_white, 1);	
}

function drawQuantity(_item, _grid, _x, _y){
	var _text = string(_item.quantity) + "x";
	var _gridSize = _grid.gridHeight;
	var _tWidth = string_width(_text);
	var _theight = string_height(_text);
	var _xPosition = _x + _gridSize - _tWidth;
	var _yPosition = _y + _gridSize - _theight;
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	drawTextShadow(_xPosition, _yPosition, _text, draw_get_alpha());
	draw_text(_xPosition, _yPosition, _text);
}

function getItemScale(_gridHeight, _itemHeight){
	return (_gridHeight) / _itemHeight
}

function gridOnHover(_item, _j, _i){
	if(hoverItem.j != _j || hoverItem.i != _i){
		hoverItem.j = _j
		hoverItem.i = _i
		if(currentState != holdItem && !audio_is_playing(snd_hover)) playHoverSound();
		return;
	}
	if(activeHoldingItem != global.blankInventorySpace) return;
}

function gridOnHold(_item, _j, _i, _grid, _inventory){
	if(activeHoldingItem == global.blankInventorySpace && _item != global.blankInventorySpace && currentState != drawOptionsMenu){
		global.activeInventoryAction = _inventory;
		activeHoldingItem = _item;
		holdingItem.j = _j;
		holdingItem.i = _i;
		holdingItem.scale = getItemScale(_grid.gridHeight -20, sprite_get_height(_item.sprite));
		global.currentItemPlayingTheAction = holdingItem;
		audio_play_sound(activeHoldingItem.sound, 0, false);
		currentState = holdItem;
		holdingItemPositions.x = xMouseToGui;
		holdingItemPositions.y = yMouseToGui;
	}
	
}

function holdItem(){
	
	holdingItemPositions.x = lerp(holdingItemPositions.x, xMouseToGui, .2);
	holdingItemPositions.y = lerp(holdingItemPositions.y, yMouseToGui, .2
	);
	
	if(mouse_check_button_released(mb_left) && activeHoldingItem != global.blankInventorySpace){
		dropInventoryItem();
		currentState = nothing;
		return;
	}
	
	var _isHolding = mouse_check_button(mb_left);
	if(_isHolding && activeHoldingItem != global.blankInventorySpace){
		drawSpriteShadow(holdingItemPositions.x, holdingItemPositions.y, activeHoldingItem.sprite, 0, 0, holdingItem.scale, holdingItem.scale);
		draw_sprite_ext(activeHoldingItem.sprite, 0, holdingItemPositions.x, holdingItemPositions.y, holdingItem.scale, holdingItem.scale, 0, image_blend, 1);
		return;
	}
	holdingItem.i = global.blankInventorySpace;
	holdingItem.j = global.blankInventorySpace;
	activeHoldingItem = global.blankInventorySpace;
}

function gridOnClick(_inventory, _item, _j, _i, _xPosition, _yPosition){
	if(mouse_check_button_released(mb_right)){
		if (_item == global.blankInventorySpace) {
			return;
		}
		selectingItemWhileOtherItemIsSelected(_j, _i);
		preparingToDrawOptionMenu(_inventory, _item, _j, _i, _xPosition, _yPosition);
	}
}

function selectingItemWhileOtherItemIsSelected(_j, _i){
	if(_j != selectedItem.j || _i != selectedItem.i){
		cleanMenuOptions();
	}
}
function preparingToDrawOptionMenu(_inventory, _item, _j, _i, _xPosition, _yPosition){
	if(_item != global.blankInventorySpace){	
		global.activeInventoryAction = _inventory
		activeSelectedItem = _item;
		selectedItem.j = _j;
		selectedItem.i = _i;
		selectedItem.xPosition = _xPosition;
		selectedItem.yPosition = _yPosition;
		global.currentItemPlayingTheAction = selectedItem;
		currentState = drawOptionsMenu;
	}
}

function drawOptionsMenu(){
	executeDrawOptions();
	if((mouse_check_button_pressed(mb_left) || mouse_check_button_pressed(mb_right)) && global.currentOptionMenu == noone){
		cleanMenuOptions();
		currentState = nothing;
	}
}

function executeDrawOptions(){
	if(instance_exists(obj_menu_option)) return;
	global.currentOptionMenu = noone;
	var _itemOptions = getItemInteractOptions(activeSelectedItem.type, activeSelectedItem.itemId);
	if (array_length(_itemOptions) == 0) return;
	var _options = [];
	var _largestText = 0;
	var _optionMenuSound = snd_option_menu;
	audio_play_sound(_optionMenuSound, 0, false);
	for(var _i = 0; _i < array_length(_itemOptions); _i++){
		var _currentOption = _itemOptions[_i];
		var _item = instance_create_layer(0, 0, "Alert", obj_menu_option);
		_item.item = activeSelectedItem;
		if(_i == 0) _largestText = string_width(_currentOption.label);
		_largestText = string_width(_currentOption.label) > _largestText ? string_width(_currentOption.label) : _largestText;
		
		_item.option.text = _currentOption.label;
		_item.option.key = _currentOption.actionKey;
		_item.option.itemId = activeSelectedItem.itemId;
		_item.option.itemType = activeSelectedItem.type;
		
		array_push(_options, _item);
		array_push(global.currentMenuOptions, _item);
	}
	var _x1 = selectedItem.xPosition;
	var _y1 = selectedItem.yPosition;
	var _fontHeight = string_height("TXT");
	var _margin = 12;
	for(var _i = 0; _i < array_length(_options); _i++){
		var _optionWidth = sprite_get_width(spr_menu_option);
		var _optionHeight = sprite_get_height(spr_menu_option);
		var _boxHeight = _fontHeight + _margin * 2;
		var _boxWidth = _largestText + _margin * 2;
		
		var _optionXScale =  getScale(_boxWidth, _optionWidth);
		var _optionYScale =  getScale(_boxHeight, _optionHeight);
		var _item = _options[_i].option;
		_item.x1 = _x1;
		_item.xScale = _optionXScale;
		_item.y1 = _y1;
		_item.yScale = _optionYScale;
		var _spaceBetweenItems = 3;
		_y1 += (_optionHeight * _optionYScale) + _spaceBetweenItems;
	}
}

#region actions

function dropInventoryItem(){
	if (holdingItemFromToolBar){
		handleToolBarDropping();
		return;
	}
	if (holdingItemFromEquipments){
		handleEquipmentDropping();
		return;
	}
	if (mouseIsOnInventoryGrid){
		switchPositionInInventory();	
		return;
	}
	if (mouseIsOnOtherMenu || mouseIsOnInventory || mouseIsOnToolBar || mouseIsOnEquipments || mouseIsOnQuickUseBar) return;
	global.currentItemPlayingTheAction = holdingItem;
	var _item = global.activeInventoryAction[# holdingItem.j, holdingItem.i];
	audio_play_sound(snd_equip_item, 0, false);
	dropItem();	
}

function addItemToToolBar(_index = undefined, _inventory = global.inventory, _item = holdingItem){
	if (holdingItemFromToolBar) return;
	var _auxiliarItem = _inventory[# _item.j, _item.i];
	if (_auxiliarItem.type != itemType.weapons) return;
	_index = _index == undefined ? getCleanIndexFromToolBar() : _index;
	if (_index != global.blankInventorySpace){
		_inventory[# _item.j, _item.i] = global.equipedItems[| _index];
		global.equipedItems[| _index] = _auxiliarItem;
		return;
	}
	_inventory[# _item.j, _item.i] = global.equipedItems[| 0];
	global.equipedItems[| 0] = _auxiliarItem;
}

function switchPositionInInventory(){
	var _holdingItem = global.activeInventoryAction[# holdingItem.j, holdingItem.i];
	var _auxiliarInventory = mouseIsOnPrimaryInventory ? primaryInventory : secundaryInventory;
	var _hoverItem = _auxiliarInventory[# hoverItem.j, hoverItem.i];
	whatInventoryIsTheItemBeingDropped(_holdingItem, _hoverItem);
}

function whatInventoryIsTheItemBeingDropped(_holdingItem, _hoverItem){
	if (global.activeInventoryAction == primaryInventory && mouseIsOnPrimaryInventory){
		if (holdingItem.j == hoverItem.j && holdingItem.i == hoverItem.i) return;
		handleSingleInventoryItemSwitching(_holdingItem, _hoverItem);
		return;
	}
	if (global.activeInventoryAction == secundaryInventory && mouseIsOnSecundaryInventory){
		if (holdingItem.j == hoverItem.j && holdingItem.i == hoverItem.i) return;
		handleSingleInventoryItemSwitching(_holdingItem, _hoverItem);
		return;
	}
	handleInventoryItemSwitching(_holdingItem, _hoverItem);
}

function handleSingleInventoryItemSwitching(_holdingItem, _hoverItem) {
    var _stackResult = checkIfItemsAreStackable(_holdingItem, _hoverItem);
    if (_stackResult != global.blankInventorySpace) {
		_holdingItem = global.blankInventorySpace;
		if(variable_struct_exists(_stackResult, "firstItem")) _holdingItem = _stackResult.firstItem;
        _hoverItem = _stackResult.lastItem;
		global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _holdingItem;
		global.activeInventoryAction[# hoverItem.j, hoverItem.i] = _hoverItem;
		return;
    } 
    global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _hoverItem;
    global.activeInventoryAction[# hoverItem.j, hoverItem.i] = _holdingItem;
}

function handleInventoryItemSwitching(_holdingItem, _hoverItem){
	var _stackResult = checkIfItemsAreStackable(_holdingItem, _hoverItem);
	if (_stackResult != global.blankInventorySpace){
		_holdingItem = global.blankInventorySpace;
		if(variable_struct_exists(_stackResult, "firstItem")) _holdingItem = _stackResult.firstItem;
        _hoverItem = _stackResult.lastItem;
		global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _holdingItem;
		var _auxiliarInventory = global.activeInventoryAction == primaryInventory ? secundaryInventory : primaryInventory;
		_auxiliarInventory[# hoverItem.j, hoverItem.i] = _hoverItem;
		return;
	}
	global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _hoverItem;
	var _auxiliarInventory = global.activeInventoryAction == primaryInventory ? secundaryInventory : primaryInventory;
	_auxiliarInventory[# hoverItem.j, hoverItem.i] = _holdingItem;
}

function checkIfItemsAreStackable(_droppingItem, _receivingItem){
	if (_droppingItem == global.blankInventorySpace || _receivingItem == global.blankInventorySpace) return global.blankInventorySpace;
	var _items = isItemStackable(_droppingItem, _receivingItem);
	return _items;
}

#endregion

#region checks
	function deleteDependenciesIfNotInventory(){
		if(global.activeInventory || personalizedInventory) return;
		cleanMenuOptions();
		currentState = nothing;
	}
#endregion

function nothing(){
	activeHoldingItem = global.blankInventorySpace;
	holdingItem.j = global.blankInventorySpace;
	holdingItem.i = global.blankInventorySpace;
	return false;
}
	
#region tool_bar

currentState = nothing;