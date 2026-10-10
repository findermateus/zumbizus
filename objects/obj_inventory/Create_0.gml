#macro INVENTORY_SLOT_SIZE 92
#macro INVENTORY_SLOT_GAP 10
#macro INVENTORY_COLUMNS 5
#macro INVENTORY_PANEL_GAP 24
#macro INVENTORY_OPEN_SPEED 3.2
#macro INVENTORY_CLOSE_SPEED 3.6

activeHoldingItem = BLANK_INVENTORY_SPACE;
activeHoverItem = BLANK_INVENTORY_SPACE;
activeSelectedItem = BLANK_INVENTORY_SPACE;
personalizedInventory = false;
hoverIndicatorUIData = {
	x: display_get_gui_width()/2,
	y: display_get_gui_height()/2,
	size: INVENTORY_SLOT_SIZE,
	destinyX: display_get_gui_width()/2,
	destinyY: display_get_gui_height()/2,
	destinySize: INVENTORY_SLOT_SIZE,
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
mouseIsOnPlayerInfo = false;
mouseIsOnQuickUseBar = false;
mouseIsOnOtherMenu = false;
holdingItemPositions = { x: 0, y: 0}
descriptionItemAlpha = 0;
itemDetailsUIData = {
	itemId: undefined,
	itemType: undefined,
	x: 0,
	y: 0
};
toolbarIndex = BLANK_INVENTORY_SPACE;
hoverToolbarIndex = BLANK_INVENTORY_SPACE;
toolBarGridScale = 1.7;
holdingItemFromToolBar = false;
holdingItemFromEquipments = false;
secundaryInventory = false;
primaryInventory = global.inventory
indicatorToWhereItemShouldBePut = BLANK_INVENTORY_SPACE;
global.activeInventoryAction = global.inventory;
gui_height = display_get_gui_height();
gui_width = display_get_gui_width();
xMouseToGui = device_mouse_x_to_gui(0);
yMouseToGui = device_mouse_y_to_gui(0);
holdingItem = {
	j: BLANK_INVENTORY_SPACE,
	i: BLANK_INVENTORY_SPACE,
	scale: 1,
	x: 0,
	y: 0
};
hoverItem = {
	j: BLANK_INVENTORY_SPACE,
	i: BLANK_INVENTORY_SPACE
};
selectedItem = {
	j: BLANK_INVENTORY_SPACE,
	i: BLANK_INVENTORY_SPACE,
	xPosition: 0,
	yPosition: 0
};
curveAnimationIndex = 0;

slotAnim = {};
hoveringSlot = false;
lastHoveredSlotKey = "";
tooltipItem = BLANK_INVENTORY_SPACE;
heldItemScale = 1;
heldItemTilt = 0;

#region abrir / fechar

function hide(){
	instance_destroy(obj_menu_option);

	curveAnimationIndex -= (delta_time / 1000000) * INVENTORY_CLOSE_SPEED;

	if(curveAnimationIndex < .02){
		curveAnimationIndex = 0;
		global.activeInventory = false;
		global.activeInventoryAction = global.inventory;
		currentState = nothing;
	}
}

function easeOutBack(_t) {
	var _c1 = 1.70158;
	var _c3 = _c1 + 1;
	return 1 + _c3 * power(_t - 1, 3) + _c1 * power(_t - 1, 2);
}

function getPanelTransition(_delay) {
	var _progress = clamp((curveAnimationIndex - _delay) / (1 - _delay), 0, 1);
	return {
		alpha: clamp(_progress * 1.6, 0, 1),
		offset: (1 - easeOutBack(_progress)) * 220
	};
}

function drawInventoryBackdrop() {
	var _alpha = .35 * clamp(curveAnimationIndex, 0, 1);
	if (_alpha <= .01) return;

	draw_set_color(c_black);
	draw_set_alpha(_alpha);
	draw_rectangle(0, 0, gui_width, gui_height, false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

#endregion

#region desenho principal

function resetFrameFlags() {
	mouseIsOnInventory = false;
	mouseIsOnInventoryGrid = false;
	mouseIsOnEquipments = false;
	mouseIsOnPlayerInfo = false;
	mouseIsOnToolBar = false;
	mouseIsOnQuickUseBar = false;
	mouseIsOnOtherMenu = false;
	activeHoverItem = BLANK_INVENTORY_SPACE;
	hoverToolbarIndex = BLANK_INVENTORY_SPACE;
	hoveringSlot = false;
	tooltipItem = BLANK_INVENTORY_SPACE;
}

function finishFrame() {
	drawHoverIndicator();
	handleIndicator();
	handleItemDetails();
	if (!hoveringSlot) lastHoveredSlotKey = "";
}

function drawInventory(){
	if(!global.activeInventory) return;
	personalizedInventory = false;
	resetFrameFlags();
	primaryInventory = global.inventory;

	if(currentState != hide && curveAnimationIndex < 1){
		curveAnimationIndex = min(1, curveAnimationIndex + (delta_time / 1000000) * INVENTORY_OPEN_SPEED);
	}

	drawInventoryBackdrop();

	var _bottomY = secundaryInventory != false ? drawInventoryWithContainer() : drawDefaultInventory();

	finishFrame();
	drawInventoryLegend(secundaryInventory != false ? gui_height - 36 : _bottomY + 30);
}

function drawDefaultInventory(){
	var _inventoryWidth = getInventoryPanelWidth();
	var _inventoryHeight = getInventoryPanelHeight(global.inventory);
	var _characterHeight = getCharacterPanelHeight();
	var _totalWidth = CHARACTER_PANEL_WIDTH + INVENTORY_PANEL_GAP + _inventoryWidth;
	var _x = (gui_width - _totalWidth) / 2;
	var _y = max(32, (gui_height - max(_characterHeight, _inventoryHeight)) / 2 - 24);
	var _left = getPanelTransition(0);
	var _right = getPanelTransition(.12);

	draw_set_alpha(_left.alpha);
	drawPlayerInfo({
		x: _x - _left.offset,
		y: _y,
		width: CHARACTER_PANEL_WIDTH,
		height: _characterHeight
	});

	draw_set_alpha(_right.alpha);
	var _inventoryBox = drawInventoryPanel(_x + CHARACTER_PANEL_WIDTH + INVENTORY_PANEL_GAP + _right.offset, _y, global.inventory);
	mouseIsOnInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	mouseIsOnPrimaryInventory = true;
	mouseIsOnSecundaryInventory = false;
	drawInventoryGrid(global.inventory, _inventoryBox);

	var _effects = getPanelTransition(.2);
	var _effectsX = _x + CHARACTER_PANEL_WIDTH + INVENTORY_PANEL_GAP + _effects.offset;
	var _effectsY = _y + _inventoryHeight + INVENTORY_PANEL_GAP;
	draw_set_alpha(_effects.alpha);
	var _effectsHeight = drawActiveEffectsPanel(_effectsX, _effectsY, _inventoryWidth, gui_height - 70 - _effectsY);
	draw_set_alpha(1);

	if (checkMousePositionWithInventory(_effectsX, _effectsX + _inventoryWidth, _effectsY, _effectsY + _effectsHeight)) {
		mouseIsOnInventory = true;
	}

	return max(_y + _characterHeight, _effectsY + _effectsHeight);
}

function drawPersonalizedInventory(_x, _y, _inventory, _mouseIsOnOtherMenu = false) {
	resetFrameFlags();
	personalizedInventory = true;
	mouseIsOnOtherMenu = _mouseIsOnOtherMenu;
	var _inventoryBox = drawInventoryPanel(_x, _y, _inventory);
	mouseIsOnInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	mouseIsOnPrimaryInventory = true;
	mouseIsOnSecundaryInventory = false;
	drawInventoryGrid(_inventory, _inventoryBox);
	finishFrame();
}

function drawInventoryWithContainer(){
	static _toolBarUiValues = getToolBarUiValues();
	if (currentState == hide) {
		_toolBarUiValues.y = lerp(_toolBarUiValues.y, gui_height + 100, .3);
	} else {
		_toolBarUiValues.y = gui_height * .85;
	}

	var _panelWidth = getInventoryPanelWidth();
	var _primaryHeight = getInventoryPanelHeight(global.inventory);
	var _secondaryHeight = getInventoryPanelHeight(secundaryInventory);
	var _x = (gui_width - (_panelWidth * 2 + INVENTORY_PANEL_GAP)) / 2;
	var _y = max(32, gui_height * .42 - max(_primaryHeight, _secondaryHeight) / 2);
	var _left = getPanelTransition(0);
	var _right = getPanelTransition(.12);

	draw_set_alpha(_left.alpha);
	var _inventoryBox = drawInventoryPanel(_x - _left.offset, _y, global.inventory);
	mouseIsOnPrimaryInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	drawInventoryGrid(primaryInventory, _inventoryBox);

	draw_set_alpha(_right.alpha);
	_inventoryBox = drawInventoryPanel(_x + _panelWidth + INVENTORY_PANEL_GAP + _right.offset, _y, secundaryInventory);
	mouseIsOnSecundaryInventory = checkMousePositionWithInventory(_inventoryBox.xPosition, _inventoryBox.xPosition + _inventoryBox.boxWidth, _inventoryBox.yPosition, _inventoryBox.yPosition + _inventoryBox.boxHeight);
	drawInventoryGrid(secundaryInventory, _inventoryBox);

	draw_set_alpha(_left.alpha);
	drawToolBar(_toolBarUiValues, true);
	draw_set_alpha(1);

	mouseIsOnInventory = (mouseIsOnPrimaryInventory || mouseIsOnSecundaryInventory);

	return _y + max(_primaryHeight, _secondaryHeight);
}

function checkMousePositionWithInventory(_x1, _x2, _y1, _y2){
	return ((xMouseToGui >= _x1 && xMouseToGui <= _x2) && (yMouseToGui >= _y1 && yMouseToGui <= _y2));
}

#endregion

#region

function getInventoryRows(_inventory) {
	return ceil((ds_grid_width(_inventory) * ds_grid_height(_inventory)) / INVENTORY_COLUMNS);
}

function getInventoryPanelWidth() {
	return INVENTORY_COLUMNS * INVENTORY_SLOT_SIZE + (INVENTORY_COLUMNS - 1) * INVENTORY_SLOT_GAP + INVENTORY_PANEL_PADDING * 2;
}

function getInventoryPanelHeight(_inventory) {
	var _rows = getInventoryRows(_inventory);
	return INVENTORY_PANEL_PADDING * 2 + INVENTORY_PANEL_HEADER + _rows * INVENTORY_SLOT_SIZE + (_rows - 1) * INVENTORY_SLOT_GAP;
}

function countUsedSlots(_inventory) {
	var _used = 0;
	for (var _i = 0; _i < ds_grid_height(_inventory); _i++) {
		for (var _j = 0; _j < ds_grid_width(_inventory); _j++) {
			if (_inventory[# _j, _i] != BLANK_INVENTORY_SPACE) _used++;
		}
	}
	return _used;
}

function drawInventoryPanel(_x, _y, _inventory) {
	var _box = {
		xPosition: _x,
		yPosition: _y,
		boxWidth: getInventoryPanelWidth(),
		boxHeight: getInventoryPanelHeight(_inventory)
	};

	drawInventoryPanelBackground(_box.xPosition, _box.yPosition, _box.boxWidth, _box.boxHeight);

	var _title = _inventory == global.inventory ? "Inventário" : "Armazém";
	var _total = ds_grid_width(_inventory) * ds_grid_height(_inventory);
	var _used = countUsedSlots(_inventory);
	var _capacityColor = _used >= _total ? merge_color(#ff6b6b, c_white, (sin(current_time / 150) + 1) * .3) : #c9c9c9;

	drawPanelHeader(
		_box.xPosition + INVENTORY_PANEL_PADDING,
		_box.yPosition + INVENTORY_PANEL_PADDING,
		_box.boxWidth - INVENTORY_PANEL_PADDING * 2,
		_title,
		"",
		string(_used) + "/" + string(_total),
		_capacityColor
	);

	return _box;
}

function drawInventoryGrid(_inventory, _inventoryBox){
	var _inventoryCols = ds_grid_width(_inventory);
	var _inventoryRows = ds_grid_height(_inventory);
	var _startX = _inventoryBox.xPosition + INVENTORY_PANEL_PADDING;
	var _startY = _inventoryBox.yPosition + INVENTORY_PANEL_PADDING + INVENTORY_PANEL_HEADER;
	var _canInteract = currentState != drawOptionsMenu;
	var _count = 0;

	for(var _i = 0; _i < _inventoryRows; _i++){
		for(var _j = 0; _j < _inventoryCols; _j++){
			var _x = _startX + (_count mod INVENTORY_COLUMNS) * (INVENTORY_SLOT_SIZE + INVENTORY_SLOT_GAP);
			var _y = _startY + (_count div INVENTORY_COLUMNS) * (INVENTORY_SLOT_SIZE + INVENTORY_SLOT_GAP);
			_count++;

			var _key = "inv:" + string(_inventory) + ":" + string(_j) + ":" + string(_i);
			var _item = _inventory[# _j, _i];
			var _mouseIsOnSlot = mouseIsOnRectangle(_x, _y, _x + INVENTORY_SLOT_SIZE, _y + INVENTORY_SLOT_SIZE);

			if (_mouseIsOnSlot) {
				gridOnClick(_inventory, _item, _j, _i, _x + INVENTORY_SLOT_SIZE, _y);

				if (_canInteract) {
					mouseIsOnInventoryGrid = true;
					activeHoverItem = _item;
					hoverIndicatorUIData.hoverInventory = _inventory;
					registerSlotHover(_key, _x, _y, INVENTORY_SLOT_SIZE, _item);
					gridOnHover(_item, _j, _i);

					if (mouse_check_button_released(mb_left) && activeHoldingItem != BLANK_INVENTORY_SPACE) popSlot(_key);
					if (mouse_check_button_pressed(mb_left) && _item != BLANK_INVENTORY_SPACE && activeHoldingItem == BLANK_INVENTORY_SPACE) popSlot(_key, -.15);
					if (mouse_check_button(mb_left)) gridOnHold(_item, _j, _i, INVENTORY_SLOT_SIZE, _inventory);
				}
			}

			var _isGhost = activeHoldingItem != BLANK_INVENTORY_SPACE
				&& !holdingItemFromToolBar
				&& !holdingItemFromEquipments
				&& global.activeInventoryAction == _inventory
				&& holdingItem.j == _j
				&& holdingItem.i == _i;

			drawInventorySlot(_key, _x, _y, INVENTORY_SLOT_SIZE, _item, {
				isHover: _mouseIsOnSlot && _canInteract,
				isGhost: _isGhost
			});
		}
	}
}

function drawInventoryLegend(_y){
	var _alpha = clamp(curveAnimationIndex, 0, 1);
	if (_alpha <= .02) return;

	var _legend = "[fa_center][fa_middle][scale,1.5][spr_mouse_right][/scale] Interagir      [#9a9a9a]Arraste[/c] para mover      [#9a9a9a]Tab[/c] Fechar";
	draw_set_alpha(_alpha);
	drawTextShadowScribble(gui_width / 2, _y, _legend, _alpha);
	draw_text_scribble(gui_width / 2, _y, _legend);
	draw_set_alpha(1);
}

#endregion

#region hover, indicador e detalhes

function handleIndicator(){
	indicatorToWhereItemShouldBePut = BLANK_INVENTORY_SPACE;
	var _item = BLANK_INVENTORY_SPACE;

	if (activeHoldingItem == BLANK_INVENTORY_SPACE && activeHoverItem != BLANK_INVENTORY_SPACE){
		_item = activeHoverItem;
	}

	if (activeHoldingItem != BLANK_INVENTORY_SPACE){
		_item = activeHoldingItem;
	}

	if (_item == BLANK_INVENTORY_SPACE) return;

	if (_item.type == itemType.equipment){
		indicatorToWhereItemShouldBePut = getEquipmentSlotFromItem(_item);
		return;
	}
	if (_item.type == itemType.weapons){
		indicatorToWhereItemShouldBePut = "toolBar";
		return;
	}
}

function drawHoverIndicator(){
	var _ui = hoverIndicatorUIData;
	_ui.destinyAlpha = hoveringSlot;

	// aparece direto no slot em vez de deslizar de onde estava
	if (_ui.alpha < .05) {
		_ui.x = _ui.destinyX;
		_ui.y = _ui.destinyY;
		_ui.size = _ui.destinySize;
	}

	_ui.x = lerp(_ui.x, _ui.destinyX, .3);
	_ui.y = lerp(_ui.y, _ui.destinyY, .3);
	_ui.size = lerp(_ui.size, _ui.destinySize, .3);
	_ui.alpha = lerp(_ui.alpha, _ui.destinyAlpha, .2);

	if (_ui.alpha < .02) return;

	var _padding = 5 + sin(current_time / 180) * 2;
	var _color = activeHoldingItem != BLANK_INVENTORY_SPACE ? #ffd166 : c_white;
	drawCornerBrackets(_ui.x - _padding, _ui.y - _padding, _ui.x + _ui.size + _padding, _ui.y + _ui.size + _padding, _color, _ui.alpha, 12, 3);
}

function getItemDetailsWidth(_itemId, _itemType) {
	var _configuration = getItemConfiguration(_itemId, _itemType);
	draw_set_font(fnt_gui_title);
	var _nameWidth = string_width(_configuration.name) + 20;
	draw_set_font(fnt_gui_long_text);
	var _descriptionWidth = string_width_ext(_configuration.description, -1, 350) + 20;
	draw_set_font(fnt_gui_default);
	return max(_nameWidth, _descriptionWidth);
}

function handleItemDetails() {
	var _isShowing = currentState != hide
		&& currentState != drawOptionsMenu
		&& tooltipItem != BLANK_INVENTORY_SPACE
		&& activeHoldingItem == BLANK_INVENTORY_SPACE;

	if (_isShowing) {
		itemDetailsUIData.itemId = tooltipItem.itemId;
		itemDetailsUIData.itemType = tooltipItem.type;

		var _width = getItemDetailsWidth(tooltipItem.itemId, tooltipItem.type);
		var _slotX = hoverIndicatorUIData.destinyX;
		var _slotSize = hoverIndicatorUIData.destinySize;
		var _targetX = _slotX + _slotSize + 14;
		if (_targetX + _width > gui_width - 16) _targetX = _slotX - 14 - _width;
		var _targetY = clamp(hoverIndicatorUIData.destinyY, 16, gui_height - 220);

		if (descriptionItemAlpha < .05) {
			itemDetailsUIData.x = _targetX;
			itemDetailsUIData.y = _targetY;
		}
		itemDetailsUIData.x = lerp(itemDetailsUIData.x, _targetX, .3);
		itemDetailsUIData.y = lerp(itemDetailsUIData.y, _targetY, .3);
	}

	descriptionItemAlpha = lerp(descriptionItemAlpha, _isShowing, .2);

	if (descriptionItemAlpha < .01 || itemDetailsUIData.itemId == undefined) return;

	var _slide = (1 - descriptionItemAlpha) * 10;
	drawItemDetails(itemDetailsUIData.x + _slide, itemDetailsUIData.y, draw_get_alpha() * descriptionItemAlpha, itemDetailsUIData.itemId, itemDetailsUIData.itemType);
}

#endregion

#region pegar, arrastar e soltar

function getItemScale(_gridHeight, _itemHeight){
	return (_gridHeight) / _itemHeight
}

function onItemPickedUp() {
	heldItemScale = 1.35;
	heldItemTilt = 0;
	descriptionItemAlpha = 0;
}

function gridOnHover(_item, _j, _i){
	hoverItem.j = _j;
	hoverItem.i = _i;
}

function gridOnHold(_item, _j, _i, _slotSize, _inventory){
	if(activeHoldingItem == BLANK_INVENTORY_SPACE && _item != BLANK_INVENTORY_SPACE && currentState != drawOptionsMenu){
		global.activeInventoryAction = _inventory;
		activeHoldingItem = _item;
		holdingItem.j = _j;
		holdingItem.i = _i;
		holdingItem.scale = getItemScale(_slotSize - 20, sprite_get_height(_item.sprite));
		global.currentItemPlayingTheAction = holdingItem;
		audio_play_sound(activeHoldingItem.sound, 0, false);
		currentState = holdItem;
		holdingItemPositions.x = xMouseToGui;
		holdingItemPositions.y = yMouseToGui;
		onItemPickedUp();
	}
}

function isHoldingOutsideEveryPanel() {
	return !(mouseIsOnOtherMenu || mouseIsOnInventory || mouseIsOnToolBar || mouseIsOnEquipments || mouseIsOnPlayerInfo || mouseIsOnQuickUseBar);
}

function holdItem(){
	var _velocityX = xMouseToGui - holdingItemPositions.x;
	holdingItemPositions.x = lerp(holdingItemPositions.x, xMouseToGui, .35);
	holdingItemPositions.y = lerp(holdingItemPositions.y, yMouseToGui, .35);

	if(mouse_check_button_released(mb_left) && activeHoldingItem != BLANK_INVENTORY_SPACE){
		dropInventoryItem();

		if (currentState != hide) {
			currentState = nothing;
		}

		return;
	}

	if(mouse_check_button(mb_left) && activeHoldingItem != BLANK_INVENTORY_SPACE){
		heldItemScale = lerp(heldItemScale, 1, .25);
		heldItemTilt = lerp(heldItemTilt, clamp(-_velocityX * .8, -25, 25), .3);

		var _size = 80 * heldItemScale;
		var _x = holdingItemPositions.x;
		var _y = holdingItemPositions.y;
		drawSpriteFitCentered(activeHoldingItem.sprite, _x + 8, _y + 12, _size, 1, heldItemTilt, c_black, .3);
		drawSpriteFitCentered(activeHoldingItem.sprite, _x, _y, _size, 1, heldItemTilt, c_white, 1);

		if (isHoldingOutsideEveryPanel()) drawDropToFloorHint(_x, _y + 58);
		return;
	}
	holdingItem.i = BLANK_INVENTORY_SPACE;
	holdingItem.j = BLANK_INVENTORY_SPACE;
	activeHoldingItem = BLANK_INVENTORY_SPACE;
}

function drawDropToFloorHint(_x, _y) {
	var _text = "Soltar no chão";
	var _pulse = .7 + (sin(current_time / 140) + 1) * .15;
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	drawTextShadow(_x, _y, _text, _pulse);
	draw_set_alpha(_pulse);
	draw_set_color(#ff6b6b);
	draw_text(_x, _y, _text);
	draw_set_color(c_white);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

#endregion

#region menu de opções (clique direito)

function gridOnClick(_inventory, _item, _j, _i, _xPosition, _yPosition){
	if(!mouse_check_button_released(mb_right)){
		return;
	}

	if (_item == BLANK_INVENTORY_SPACE) {
		return;
	}

	if(_j != selectedItem.j || _i != selectedItem.i){
		cleanMenuOptions();
	}

	var _interactableOptions = getItemInteractOptions(_item.type, _item.itemId);

	if (array_length(_interactableOptions) == 0) {
		return;
	}

	global.activeInventoryAction = _inventory
	activeSelectedItem = _item;
	selectedItem.j = _j;
	selectedItem.i = _i;
	selectedItem.xPosition = _xPosition;
	selectedItem.yPosition = _yPosition;
	global.currentItemPlayingTheAction = selectedItem;
	currentState = drawOptionsMenu;
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
	audio_play_sound(snd_option_menu, 0, false);
	for(var _i = 0; _i < array_length(_itemOptions); _i++){
		var _currentOption = _itemOptions[_i];
		var _item = instance_create_layer(0, 0, "Alert", obj_menu_option);
		_item.item = activeSelectedItem;
		_largestText = max(_largestText, string_width(_currentOption.label));

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
	var _spaceBetweenItems = 3;
	for(var _i = 0; _i < array_length(_options); _i++){
		var _optionWidth = sprite_get_width(spr_menu_option);
		var _optionHeight = sprite_get_height(spr_menu_option);
		var _boxHeight = _fontHeight + _margin * 2;
		var _boxWidth = _largestText + _margin * 2;
		var _item = _options[_i].option;
		_item.x1 = _x1;
		_item.xScale = getScale(_boxWidth, _optionWidth);
		_item.y1 = _y1;
		_item.yScale = getScale(_boxHeight, _optionHeight);
		_y1 += (_optionHeight * _item.yScale) + _spaceBetweenItems;
	}
}

#endregion

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
	if (mouseIsOnOtherMenu || mouseIsOnInventory || mouseIsOnToolBar || mouseIsOnEquipments || mouseIsOnPlayerInfo || mouseIsOnQuickUseBar) return;
	global.currentItemPlayingTheAction = holdingItem;
	audio_play_sound(snd_equip_item, 0, false);
	dropItem();
}

function addItemToToolBar(_index = undefined, _inventory = global.inventory, _item = holdingItem){
	if (holdingItemFromToolBar) return;
	var _auxiliarItem = _inventory[# _item.j, _item.i];
	if (_auxiliarItem.type != itemType.weapons) return;

	_index = _index == undefined ? getCleanIndexFromToolBar() : _index;

	obj_quest_manager.notifyEvent(QuestEvent.ItemEquiped, {
		type: "weapon",
		itemId: _auxiliarItem.itemId,
		itemType: _auxiliarItem.type
	});

	if (_index != BLANK_INVENTORY_SPACE){
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
    if (_stackResult != BLANK_INVENTORY_SPACE) {
		_holdingItem = BLANK_INVENTORY_SPACE;
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
	var _from = global.activeInventoryAction;
	var _auxiliarInventory = (_from == primaryInventory) ? secundaryInventory : primaryInventory;
	var _to = _auxiliarInventory;

	var _stackResult = checkIfItemsAreStackable(_holdingItem, _hoverItem);

	if (_stackResult != BLANK_INVENTORY_SPACE){
		var _movedItem = _holdingItem;
		var _amount = _holdingItem.quantity;

		if (variable_struct_exists(_stackResult, "movedAmount")) {
			_amount = _stackResult.movedAmount;
		}

		_holdingItem = BLANK_INVENTORY_SPACE;

		if (variable_struct_exists(_stackResult, "firstItem")) {
			_holdingItem = _stackResult.firstItem;
		}

		_hoverItem = _stackResult.lastItem;

		global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _holdingItem;
		_auxiliarInventory[# hoverItem.j, hoverItem.i] = _hoverItem;

		if (_from == secundaryInventory && _to == primaryInventory) {
			if (_movedItem != BLANK_INVENTORY_SPACE) {
				obj_quest_manager.notifyEvent(QuestEvent.ItemCollected, {
					itemId: _movedItem.itemId,
					itemType: _movedItem.type,
					quantity: _amount
				});
			}
		}

		return;
	}

	global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _hoverItem;
	_auxiliarInventory[# hoverItem.j, hoverItem.i] = _holdingItem;

	if (_from == secundaryInventory && _to == primaryInventory) {
		if (_holdingItem != BLANK_INVENTORY_SPACE) {
			obj_quest_manager.notifyEvent(QuestEvent.ItemCollected, {
				itemId: _holdingItem.itemId,
				itemType: _holdingItem.type,
				quantity: _holdingItem.quantity
			});
		}
	}
}

function checkIfItemsAreStackable(_droppingItem, _receivingItem){
	if (_droppingItem == BLANK_INVENTORY_SPACE || _receivingItem == BLANK_INVENTORY_SPACE) return BLANK_INVENTORY_SPACE;

	var _firstItem = _droppingItem;
	var _lastItem = _receivingItem;

	if (_firstItem.itemId != _lastItem.itemId || _firstItem.type != _lastItem.type) return BLANK_INVENTORY_SPACE;

	if(!variable_struct_exists(_firstItem, "limit")) return BLANK_INVENTORY_SPACE;
	if(_lastItem.quantity >= _lastItem.limit) return BLANK_INVENTORY_SPACE;

	var _remainingSpace = _lastItem.limit - _lastItem.quantity;

    if (_firstItem.quantity > _remainingSpace ) {
        _lastItem.quantity += _remainingSpace ;
        _firstItem.quantity -= _remainingSpace ;
		return {
			firstItem: _firstItem,
			lastItem: _lastItem,
			movedAmount: _remainingSpace
		};
    }

	var _moved = _firstItem.quantity;
    _lastItem.quantity += _firstItem.quantity;

	return {
		lastItem: _lastItem,
		movedAmount: _moved
	};
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
	activeHoldingItem = BLANK_INVENTORY_SPACE;
	holdingItem.j = BLANK_INVENTORY_SPACE;
	holdingItem.i = BLANK_INVENTORY_SPACE;
	return false;
}

currentState = nothing;
