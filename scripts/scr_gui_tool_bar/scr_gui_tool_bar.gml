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
	mouseIsOnToolBar = (xMouseToGui >= _toolBar.x1Position && xMouseToGui <= _toolBar.x2Position) && (yMouseToGui >= _toolBar.y1Position && yMouseToGui <= _toolBar.y2Position)
	if (_draw) {
		var _boxX = _toolBar.x1Position - _padding / 2;
		var _boxY = _toolBar.y1Position - _padding / 2;
		var _boxWidth = _toolBar.x2Position - _toolBar.x1Position + _padding;
		var _boxHeight = _toolBar.y2Position - _toolBar.y1Position + _padding;
		drawSpriteShadowStretched(_boxX, _boxY, _toolBar.sprite, 0, 0, _boxWidth, _boxHeight, 0, 8);
		draw_sprite_stretched_ext(_toolBar.sprite, 0, _boxX, _boxY, _boxWidth, _boxHeight, c_white, .95 * draw_get_alpha());
	}
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
	var _spaceBetween = _totalItems > 1 ? (_barWidth - (_itemWidth * _totalItems)) / (_totalItems - 1) : 0;
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

function drawToolBarGrid(_x, _y, _width, _height, _index, _active = false){
	var _key = "tb:" + string(_index);
	var _item = global.equipedItems[| _index];
	var _mouseIsOnGrid = ((xMouseToGui >= _x && xMouseToGui <= _x + _width) && (yMouseToGui >= _y && yMouseToGui <= _y + _height));
	var _isHolding = activeHoldingItem != BLANK_INVENTORY_SPACE;
	var _isHoldingWeapon = _isHolding && activeHoldingItem.type == itemType.weapons;

	if (_mouseIsOnGrid){
		hoverToolbarIndex = _index;
		registerSlotHover(_key, _x, _y, _width, _item);
	}

	if (_mouseIsOnGrid && _isHoldingWeapon){
		if (mouse_check_button_released(mb_left)) popSlot(_key);
		holdingItemOverToolBar(_index);
	}

	if(_mouseIsOnGrid && !_isHolding) {
		holdTheToolBarItem(_index, _height);
	}

	drawInventorySlot(_key, _x, _y, _width, _item, {
		isHover: _mouseIsOnGrid,
		isTarget: indicatorToWhereItemShouldBePut == "toolBar" && !holdingItemFromToolBar,
		isGhost: holdingItemFromToolBar && toolbarIndex == _index,
		isDimmed: _mouseIsOnGrid && _isHolding && !_isHoldingWeapon,
		isActive: _active,
		placeholder: spr_pistol
	});
	drawToolBarIndex(_x, _y, _width, _height, _index, _active);
}

// usada também pelo HUD (obj_player_stats)
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

function drawToolBarIndex(_x, _y, _width, _height, _index, _active = false){
	var _alpha = draw_get_alpha();
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	drawTextShadow(_x + 8, _y + 4, string(_index + 1), _alpha);
	draw_set_color(_active ? #ffd166 : #c9c9c9);
	draw_text(_x + 8, _y + 4, string(_index + 1));

	if (_active) {
		draw_set_halign(fa_right);
		drawTextShadow(_x + _width - 8, _y + 4, "E", _alpha);
		draw_text(_x + _width - 8, _y + 4, "E");
		draw_set_halign(fa_left);
	}
	draw_set_color(c_white);
}

function holdingItemOverToolBar(_itemIndex){
	if (mouse_check_button_released(mb_left)){
		addItemToToolBar(_itemIndex, global.activeInventoryAction);
	}
}

function holdTheToolBarItem(_index, _height){
	if(!mouse_check_button(mb_left)) return;
	cleanMenuOptions();
	var _item = global.equipedItems[| _index];
	if (_item == BLANK_INVENTORY_SPACE) return;
	holdingItemFromToolBar = true;
	holdingItemPositions.x = xMouseToGui;
	holdingItemPositions.y = yMouseToGui;
	activeHoldingItem = _item;
	toolbarIndex = _index;
	holdingItem.scale = getItemScale(GRIDSIZE, sprite_get_height(_item.sprite));
	popSlot("tb:" + string(_index), -.15);
	onItemPickedUp();
	currentState = holdItem;
}

function handleToolBarDropping(){
	holdingItemFromToolBar = false;
	if(mouseIsOnInventoryGrid){
		var _auxiliarInventory = mouseIsOnPrimaryInventory ? primaryInventory : secundaryInventory;
		var _hoverItem = _auxiliarInventory[# hoverItem.j, hoverItem.i];
		if (_hoverItem == BLANK_INVENTORY_SPACE ){
			_auxiliarInventory[# hoverItem.j, hoverItem.i] = activeHoldingItem;
			global.equipedItems[| toolbarIndex] = BLANK_INVENTORY_SPACE;
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

	if (mouseIsOnToolBar && hoverToolbarIndex != BLANK_INVENTORY_SPACE){
		var _auxItem = global.equipedItems[| hoverToolbarIndex];
		global.equipedItems[| hoverToolbarIndex] = global.equipedItems[| toolbarIndex];
		global.equipedItems[| toolbarIndex] = _auxItem;

		return;
	}
	if (mouseIsOnPlayerInfo) return;

	audio_play_sound(snd_equip_item, 0, false);
	dropItemFromToolBar(global.equipedItems[|toolbarIndex], toolbarIndex);
}
