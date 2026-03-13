global.blankInventorySpace = "";
global.toolBarGridSize = 0;
#macro GRIDSIZE 64


function handleToolBarUi(_ui, _y) {
	_ui.y = lerp(_ui.y, _y, .1);
}

function drawToolBar(_toolBarUiValues = {}, _inventory = false){
	var _horizontalMiddleOfScreen = gui_width/2;
	var _margin = global.toolBarSize;
	var _individualGridSize = GRIDSIZE * toolBarGridScale;
	global.toolBarGridSize = _individualGridSize;
	var _toolBarWidth = _individualGridSize * global.toolBarSize + _margin;
	var _toolBarBoxX1 = _horizontalMiddleOfScreen - (_toolBarWidth/2);
	var _toolBarBoxX2 = _horizontalMiddleOfScreen + (_toolBarWidth/2);
	handleToolBarUi(_toolBarUiValues, gui_height * .85);
	var _toolBar = getToolBarBox(_toolBarBoxX1, _toolBarBoxX2, _margin, _toolBarUiValues.y);
	drawToolBarItems(_toolBar);
	drawQuickUseOnGui(_toolBarBoxX2 + 50, _toolBarUiValues.y - 25, _individualGridSize + 50, .9, _inventory);
	return _toolBar;
}

function getToolBarBox(_x1, _x2, _margin = 0, _y1 = undefined, _y2 = undefined, _size = undefined, _draw = true){
	_y1 = _y1 ?? gui_height * .85;
	var _individualGridSize = _size == undefined ? GRIDSIZE * toolBarGridScale : GRIDSIZE * _size;
	_y2 = _y2 ?? _y1 + _individualGridSize;
	var _toolBar = {
		x1Position: _x1,
		x2Position: _x2,
		y1Position: _y1,
		y2Position: _y2,
		sprite: spr_inventory_box,
		margin: _margin,
		gridSize: _individualGridSize
	}	
	var _padding = 50;
	var _xScale = getScale(_toolBar.x2Position - _toolBar.x1Position + _padding, sprite_get_width(_toolBar.sprite));
	var _yScale = getScale(_toolBar.y2Position - _toolBar.y1Position + _padding, sprite_get_height(_toolBar.sprite));
	mouseIsOnToolBar = (xMouseToGui >= _toolBar.x1Position && xMouseToGui <= _toolBar.x2Position) && (yMouseToGui >= _toolBar.y1Position && yMouseToGui <= _toolBar.y2Position)
	if (_draw) draw_sprite_ext(_toolBar.sprite, 0, _toolBar.x1Position - _padding/2, _toolBar.y1Position - _padding /2, _xScale, _yScale, 0, c_white, .9);
	return _toolBar;
}

function drawToolBarItems(_toolBar = {
	x1Position: 0,
	x2Position: 0,
	y1Position: 0,
	y2Position: 0,
	margin: 0,
	sprite: spr_tool_bar_box
}) {
	var _barWidth = _toolBar.x2Position - _toolBar.x1Position;
	var _itemWidth = _toolBar.gridSize; 
	var _itemHeight = _toolBar.gridSize;
	var _totalItems = global.toolBarSize;
	var _spaceBetween = (_barWidth - (_itemWidth * _totalItems)) / (_totalItems - 1);
	for (var _i = 0; _i < _totalItems; _i++) {
		var _x = _toolBar.x1Position + _i * (_itemWidth + _spaceBetween);
		var _active = _i == global.activeEquipedItemIndex;
		drawToolBarGrid(_x, _toolBar.y1Position, _itemWidth, _itemHeight, _i, _active);
	}
}

function getToolBarUiValues(){
	return {
		y: display_get_gui_height() * .85,
	};
}

function verifyConditionToApplyToolBarHoverEffect() {
	return true;
}

function drawToolBarGrid(_x, _y, _width, _height, _index, _active = false){
	var _auxY = _y;
	var _temporaryAlpha = defaultToolBarAlpha;
	var _gridColor = c_white;
	var _mouseIsOnGrid = ((xMouseToGui >= _x && xMouseToGui <= _x + _width) && (yMouseToGui >= _y && yMouseToGui <= _y + _height));
	
	if (_mouseIsOnGrid){
		hoverToolbarIndex = _index;
		hoverIndicatorUIData.destinyX = _x;
		hoverIndicatorUIData.destinyY = _y;
	}
	
	if (_mouseIsOnGrid && activeHoldingItem != global.blankInventorySpace){
		if(activeHoldingItem.type == itemType.weapons){
			if(toolBarAlpha[_index] == defaultToolBarAlpha){
				playHoverSound();
			}
			_temporaryAlpha = 1;
			holdingItemOverToolBar(_index);
		}else{
			_temporaryAlpha = .5;
			if (_active) _temporaryAlpha = .8;
		}
	}
	
	if(_mouseIsOnGrid && activeHoldingItem == global.blankInventorySpace) {
		holdTheToolBarItem(_index, _height);
	}
	
	toolBarAlpha[_index] = _temporaryAlpha;
	drawGrid(_width, _height, _x, _y, _gridColor, _index);
	drawItemsInToolBar(_x + _width/2, _y + _height/2, _height, _index);
	drawToolBarIndexPrimary(_x + _width/2, _y + _height/2, _width, _height, _index, _active);
}

function drawItemDurability(_equipedItem, _x, _y, _height, _width) {
    var _durability = _equipedItem.durability;
    var _maxDurability = _equipedItem.maxDurability;

    var _barWidth = _width;
    var _barHeight = _height;
    var _barX = _x;
    var _barY = _y;
	drawProgressVerticalBlock(_barX, _barY, _durability, _maxDurability, _barHeight, _barWidth);
}

function drawProgressVerticalBlock(_x, _y, _current, _max, _barHeight, _barWidth) {
	var _fillHeight = (_current/ _max) * _barHeight;
    var _fillY = _y + (_barHeight - _fillHeight);
	draw_set_alpha(.2);
    draw_set_color(c_red);
    draw_rectangle(_x, _y, _x + _barWidth, _y + _barHeight, false);
	draw_set_alpha(.5);
    draw_set_color(c_green);
    draw_rectangle(_x, _fillY, _x + _barWidth, _y + _barHeight, false);
    draw_set_color(c_white);
	draw_set_alpha(1);	
}

function drawGrid(_width, _height, _x, _y, _gridColor, _index){
	var _gridXScale = _width / sprite_get_width(spr_inventory_grid);
	var _gridYScale = _height / sprite_get_height(spr_inventory_grid);
	
	draw_sprite_ext(spr_inventory_grid, 0, _x, _y, _gridXScale, _gridYScale, 0, _gridColor, toolBarAlpha[_index]);
	
	var _item = global.equipedItems[| _index];
	var _alphaTimer = .2;
	
	if (itemHasDurability(_item)){
		var _xMargin = 2 * _gridXScale;
		var _yMargin = 2 * _gridYScale;
		draw_sprite_ext(spr_inventory_grid, 0, _x, _y, _gridXScale, _gridYScale, 0, _gridColor, toolBarAlpha[_index]);
		drawItemDurability(_item, _x + _xMargin, _y + _yMargin, _height - _yMargin * 2, _width - _xMargin * 2);
		var _alpha = mouseIsOnToolBar ? toolBarAlpha[_index] : 1;
		draw_sprite_ext(spr_inventory_grid, 1, _x, _y, _gridXScale, _gridYScale, 0, _gridColor, _alpha);
		
		if (indicatorToWhereItemShouldBePut == "toolBar"){
			var _timer = get_timer()/100000;
			var _alphaIndex = (sin(_timer * 0.5) + 1) * _alphaTimer;
			drawSpriteWithGpuFog(c_white, spr_inventory_grid, 2, _x, _y, _gridXScale, _gridYScale, 0, _alphaIndex);
		}
		
		return;
	}
	
	draw_sprite_ext(spr_inventory_grid, 2, _x, _y, _gridXScale, _gridYScale, 0, _gridColor, toolBarAlpha[_index]);
	
	if (indicatorToWhereItemShouldBePut == "toolBar"){
		var _timer = get_timer()/100000;
		var _alphaIndex = (sin(_timer * 0.5) + 1) * _alphaTimer;
		drawSpriteWithGpuFog(c_white, spr_inventory_grid, 2, _x, _y, _gridXScale, _gridYScale, 0, _alphaIndex);
	}
}

function drawToolBarIndexPrimary(_x, _y, _gridWidth, _gridHeight, _index, _active = false){
	var _xPosition = _x - ((_gridWidth)/2) * .8;
	var _yPosition = _y - ((_gridHeight)/2) * .9;
	draw_text_scribble(_xPosition, _yPosition,"[fa_left][fa_top][alpha," + string(toolBarAlpha[_index]) + "]" + string(_index + 1));
	if (!_active) return;
	_xPosition = _x + ((_gridWidth)/2) * .8;
	_yPosition = _y + ((_gridHeight)/2) * .9
	draw_text_scribble(_xPosition, _yPosition, "[fa_right][fa_bottom][alpha," + string(toolBarAlpha[_index]) + "] E" );
}

function holdingItemOverToolBar(_itemIndex){
	if (mouse_check_button_released(mb_left)){
		addItemToToolBar(_itemIndex, global.activeInventoryAction);
	}
}

function drawItemsInToolBar(_x, _y, _height, _i){
	var _equipedItem = global.equipedItems[| _i];
	drawToolBarItem(_equipedItem, _x, _y, _height, toolBarAlpha[_i]);
}

function drawToolBarItem(_equipedItem, _x, _y, _height, _alpha){
	var _sprite = _equipedItem != global.blankInventorySpace ? _equipedItem.sprite : spr_pistol;
	var _fitInGrid = _equipedItem != global.blankInventorySpace ? _equipedItem.fitInGrid : fitInGridType.horizontaly;
	var _decreaseSize = _equipedItem != global.blankInventorySpace ? 20 : 50;
	var _itemWidth = sprite_get_width(_sprite);
	var _itemHeight = sprite_get_height(_sprite);
	var _scale = getItemScale(_height - _decreaseSize, _itemHeight);
	if (_fitInGrid == fitInGridType.horizontaly){
		_scale = getItemScale(_height - _decreaseSize, _itemWidth);
	}
	
	if (_equipedItem == global.blankInventorySpace) {
		drawSpriteWithGpuFog(c_white, _sprite, 0, _x, _y, _scale, _scale, 0, _alpha * .2);
		return;
	}
	
	drawSpriteShadow(_x, _y, _sprite, 0, 0, _scale, _scale, 4, 4, _alpha);
	
	draw_sprite_ext(_sprite, 0, _x, _y, _scale, _scale, 0, c_white, _alpha);
}



function holdTheToolBarItem(_index, _height){
	if(!mouse_check_button(mb_left)) return;
	cleanMenuOptions();
	var _item = global.equipedItems[| _index];
	if (_item == global.blankInventorySpace) return;
	holdingItemFromToolBar = true;
	holdingItemPositions.x = xMouseToGui;
	holdingItemPositions.y = yMouseToGui;
	activeHoldingItem = _item;
	toolbarIndex = _index;
	holdingItem.scale = getItemScale(GRIDSIZE, sprite_get_height(_item.sprite));
	currentState = holdItem;
}

function handleToolBarDropping(){
	holdingItemFromToolBar = false;
	if(mouseIsOnInventoryGrid){
		var _auxiliarInventory = mouseIsOnPrimaryInventory ? primaryInventory : secundaryInventory;
		var _hoverItem = _auxiliarInventory[# hoverItem.j, hoverItem.i];
		if (_hoverItem == global.blankInventorySpace ){
			_auxiliarInventory[# hoverItem.j, hoverItem.i] = activeHoldingItem;
			global.equipedItems[| toolbarIndex] = global.blankInventorySpace;
			return;
		}
		if(_hoverItem.type == itemType.weapons){
			_auxiliarInventory[# hoverItem.j, hoverItem.i] = activeHoldingItem;
			global.equipedItems[| toolbarIndex] = _hoverItem;
		}
		return;
	}
	if(mouseIsOnInventory){
		return;
	}
	if (mouseIsOnToolBar && hoverToolbarIndex != global.blankInventorySpace){
		var _auxItem = global.equipedItems[| hoverToolbarIndex];
		global.equipedItems[| hoverToolbarIndex] = global.equipedItems[| toolbarIndex];
		global.equipedItems[| toolbarIndex] = _auxItem;
		return;
	}
	audio_play_sound(snd_equip_item, 0, false);
	dropItemFromToolBar(global.equipedItems[|toolbarIndex], toolbarIndex);
}
