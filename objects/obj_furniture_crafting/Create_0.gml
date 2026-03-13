event_inherited();

#macro REQUIREMENT_MODAL_BORDER 12
buttonTimer = 0;

guiWidth = display_get_gui_width();
guiHeight = display_get_gui_height();

xMouse = display_mouse_get_x();
yMouse = display_mouse_get_y();

actionDescription = "Criar";
currentCraftingOption = craftingOptions.create;
isUsing = false;

destinyYposition = -1500;
destinyXposition = -1500;
boxXPosition = destinyXposition;
boxYPosition = destinyYposition;
modalXSize = 0;
modalYSize = 0;

requirementModalAlpha = 0;
currentHoverItem = global.blankInventorySpace;

itemsThatCanBeRepaired = [];
itemsThatCanBeCrafted = [];
itemsThatCanBeDismantled = [];

currentHoverItemRequirements = {
	item: global.blankInventorySpace,
	requirement: []
}

dismantleProgress = 0;
dismantleProgressTarget = 0;

hoverIndicator = {
	x: 0,
	y: 0,
	destinyX: 0,
	destinyY: 0,
	alpha: 0,
	destinyAlpha: 0,
	size: 32,
	destinySize: 32,
	failEffect: 0
}

// No create do objeto responsável pelo crafting
hoverCrafting = -1;
hoverCraftingControl = -1;
hoverCraftingForUI = { x: 0, y: 0, desX: 0, desY: 0, gridSize: 0 };


mouseIsOnItem = false;
lastHoveredItem = global.blankInventorySpace;
furnitureIluminator = noone;
furnitureCategory = furnitureCategories.creation;
furnitureId = furnitureIds.meeleCraftingStation;
activationMethod = function () {
	playClickSound();
	audio_play_sound(snd_open_crafting_station, 0, false);
	activateFurniture();
}

loadFurnitureByDefaultId();

setShadow(sprite_index, image_index, 1);

function loadDisplayData(){
	guiWidth = display_get_gui_width();
	guiHeight = display_get_gui_height();
	xMouse = display_mouse_get_x();
	yMouse = display_mouse_get_y();
}

function loadSavedData(_data = false) {
	var _savedData = getFurnitureData(furnitureId, objectId);
	
	if (is_undefined(_savedData) || _savedData == false) {
		var _setupData = new MeeleWeaponCraftingStation(objectId);
		setFurnitureData(furnitureId, objectId, _setupData);
	}
}

function activateFurniture() {
	openMenu();
	obj_camera.setTargetWithZoom(id);
	isUsing = true;
	setVariablesOpenFurniture();
	reloadItems();
}

function reloadItems() {
	itemsThatCanBeCrafted = getAvailableCraftingItemsByCategoryAndLevel(craftingCategories.weapons, global.player.skills.crafting);
	itemsThatCanBeRepaired = getItemsThatCanBeRepaired(global.inventory);
	itemsThatCanBeDismantled = getItemsThatCanBeDismantled(global.inventory, itemType.weapons);
	hoverCrafting = -1;
}

function hide(){
	if (!global.activeInventory) {
		obj_camera.setDefaultScale();
		obj_camera.target = obj_player;
	}
	
	destinyXposition = - modalXSize - 10;
	isUsing = false;
	setVariablesCloseFurniture();
	closeMenu();
	itemsThatCanBeDismantled = [];
	itemsThatCanBeRepaired = [];
	itemsThatCanBeCrafted = [];
	hoverCrafting = -1;
	currentState = innactive;
}

function drawCraftingModal(){
	if (!isUsing && abs(boxXPosition - destinyXposition) <= 2) {
	    boxXPosition = destinyXposition;
		return;
	}

	var _modal = getModal(display_get_gui_width() * .9);
	currentHoverItem = global.blankInventorySpace;
	mouseIsOnItem = false;
	
	if (checkConditionsToClose() && isUsing){
		audio_play_sound(snd_close_crafting_station, 0, false);
		hide();
	}
	
	if (isUsing){
		var _modalYPosition = (guiHeight - _modal.height) / 2;
		var _modalXPosition = guiWidth / 2 - _modal.width / 2; 
		destinyXposition = _modalXPosition;
		destinyYposition = _modalYPosition;
		boxYPosition = _modalYPosition;
	}
	
	boxXPosition = lerp(boxXPosition, destinyXposition, .1);
	boxYPosition = lerp(boxYPosition, destinyYposition, .1);
	
	_modal.x = boxXPosition;
	_modal.y = boxYPosition;
	_modal.x2 = _modal.x + _modal.width;
	_modal.y2 = _modal.y + _modal.height
	_modal.initialY = _modal.y;
	
	if (!isUsing && boxXPosition + _modal.width < 0 ) return;
	
	draw_sprite_stretched_ext(_modal.sprite, 0, boxXPosition, boxYPosition, _modal.width, _modal.height, c_white, 1);
	
	var _yPosition = _modal.y + 32;
	
	var _buttonSize = 64;
	
	drawCloseButton(_modal, _buttonSize);
	
	drawSelectCategories(_yPosition, _modal);
	
	var _margin = 64;
	drawCraftingItems(_yPosition + _margin, _modal);
	if (!mouseIsOnItem) {
		requirementModalAlpha = lerp(requirementModalAlpha, 0, .2);
		lastHoveredItem = global.blankInventorySpace;
	}
	drawHoverUiIndicator();
}

function drawHoverUiIndicator() {
	var _sprite = spr_hover_indicator;
	hoverIndicator.x = lerp(hoverIndicator.x, hoverIndicator.destinyX, .1);
	hoverIndicator.y = lerp(hoverIndicator.y, hoverIndicator.destinyY, .1);
	hoverIndicator.alpha = lerp(hoverIndicator.alpha, hoverIndicator.destinyAlpha, .1);
	hoverIndicator.size = lerp(hoverIndicator.size, hoverIndicator.destinySize, .1);
	if (hoverIndicator.failEffect != 0) {
		var _x = random_range(-hoverIndicator.failEffect, hoverIndicator.failEffect); 
		var _y = random_range(-hoverIndicator.failEffect, hoverIndicator.failEffect); 
		hoverIndicator.x += _x * 5;
		hoverIndicator.y += _y * 5;
		hoverIndicator.failEffect = lerp(hoverIndicator.failEffect, 0, .2);
	}
	draw_set_alpha(hoverIndicator.alpha);
	draw_sprite_stretched(_sprite, 0, hoverIndicator.x, hoverIndicator.y, hoverIndicator.size, hoverIndicator.size);
	draw_set_alpha(1);
}

function drawItemTitle(_x, _y){
	var _title = "Estação de criação";
	draw_text_scribble(_x, _y, "[fa_left]" + _title);
}

function drawCloseButton(_modal, _buttonSize){
	var _sprite = spr_icon_close_button;
	var _scale = getScale(_buttonSize, sprite_get_width(_sprite));
	var _x = _modal.x2 - _modal.border - _buttonSize;
	var _y = _modal.y + _modal.border;
	var _subming = mouseIsOnRectangle(_x, _y, _x + sprite_get_width(_sprite) * _scale, _y + sprite_get_height(_sprite) * _scale);
	draw_sprite_ext(_sprite, _subming, _x, _y, _scale, _scale, 0, c_white, 1);
	var _marginFromButton = 20;
	handleCloseButton(_subming);
}

function handleCloseButton(_mouseHover){
	if (!_mouseHover) return;
	if (!mouse_check_button_released(mb_left)) return;
	playClickSound();
	audio_play_sound(snd_close_crafting_station, 0, false);
	hide();
}

function drawSelectCategories(_y, _modal) {
    var _sprite = spr_menu_option;
    var _spriteHeight = sprite_get_height(_sprite);
    var _spriteWidth = sprite_get_width(_sprite);

    var _button = {
        sprite: _sprite,
        spriteWidth: _spriteWidth,
        spriteHeight: _spriteHeight,
        yScale: 1,
        xScale: 1
    };

    var _totalCategories = array_length(global.craftingOptions);
    static _categoryUiValues = getCategoriesUiValues();
	var _hMargin = _modal.border * 6;
    var _availableWidth = _modal.width - _hMargin;
    var _buttonWidth = (_availableWidth/_totalCategories) * .9;
    var _freeSpace = _availableWidth - (_buttonWidth * _totalCategories);
    var _spacing = _freeSpace / (_totalCategories + 1);

    var _x = _modal.x + _hMargin/2 + _spacing;
    var _totalHeight = 0;

    for (var i = 0; i < _totalCategories; i++) {
        var _uiValue = _categoryUiValues[i];
        var _text = global.craftingOptions[i].title;
        var _type = global.craftingOptions[i].id;
        var _icon = global.craftingOptions[i].icon;

        var _buttonHeight = drawButton(_x, _y, _buttonWidth, _button, _text, _type, _icon, _uiValue);
        _totalHeight = max(_totalHeight, _buttonHeight);

        _x += _buttonWidth + _spacing;
    }

    handleUiValues(_categoryUiValues);

    var _marginFromTop = 50;
}


function handleUiValues(_uiValues) {
	for (var i = 0; i < array_length(_uiValues); i ++) {
		var _uiValue = _uiValues[i];
		_uiValue.y = lerp(_uiValue.y, _uiValue.desY, .1);
	}
}

function getCategoriesUiValues() {
	return array_map(global.craftingOptions, function () {
		return {
			y: 0,
			desY: 0
		}
	});
}

function drawButton(_x, _y, _size, _button, _text, _type, _icon, _uiValue){
	if (_uiValue.y == 0) {
		_uiValue.desY = _y;
		_uiValue.y = _y;
	}
	var _yPos = _uiValue.y;
	_uiValue.desY = _y;
	var _buttonBorder = 12;
	var _textHeight = string_height(_text);
	var _buttonHeight = _textHeight + (_buttonBorder * 2);
	var _mouseIsOnButton = mouseIsOnRectangle(_x, _yPos, _x + _size, _yPos + _buttonHeight);
	var _xScale = getScale(_size, _button.spriteWidth);
	var _yScale = getScale(_buttonHeight, _button.spriteHeight);
	drawSpriteShadow(_x, _yPos, _button.sprite, 0, 0, _xScale, _yScale, 0, 8);
	draw_sprite_stretched_ext(_button.sprite, 0, _x, _yPos, _size, _buttonHeight, c_white, 1);
	if (currentCraftingOption == _type){
		_uiValue.desY = _y - 10;
	}
	if (_mouseIsOnButton && currentCraftingOption != _type) {
		_uiValue.desY = _y - 10;
		var _alphaTimer = .1;
		var _alphaIndex = (sin(buttonTimer * 0.1) + 1) * _alphaTimer;
		buttonTimer += .1;
		drawSpriteWithGpuFog(
			c_white,
			_button.sprite,
			0,
			_x,
			_yPos,
			_xScale,
			_yScale,
			0,
			_alphaIndex
		);
		handleClickOnCraftingOptionButton(_type);
	}
	if (!_mouseIsOnButton && currentCraftingOption != _type) {
		buttonTimer = 0;
	}
	var _textYMiddlePoint = getMiddlePoint(_yPos, _yPos + _buttonHeight);
	var _textXMiddlePoint = getMiddlePoint(_x, _x + _size);
	var _desiredHeight = string_height(_text);
	var _textWidth = string_width(_text);
	var _iconX = _textXMiddlePoint - _textWidth / 2 - _desiredHeight - 7;
	draw_sprite_stretched(_icon, 0, _iconX, _textYMiddlePoint - _desiredHeight / 2, _desiredHeight, _desiredHeight);
	draw_text_scribble(_textXMiddlePoint, _textYMiddlePoint, "[fa_center][fa_middle]" + _text);
	return _buttonHeight;
}

function handleClickOnCraftingOptionButton(_type){
	if (!mouse_check_button_pressed(mb_left)) return;
	playClickSound();
	reloadItems();
	currentCraftingOption = _type;
}

function drawCraftingItems(_y, _modal){
	if (currentCraftingOption == craftingOptions.repair){
		drawRepairPanel(_y, _modal);
		return;
	}
	if (currentCraftingOption == craftingOptions.create) {
		drawCraftingPanel(_y, _modal);
		return;
	}
	
	drawDismantlePanel(_y, _modal);
}

function drawDismantlePanel(_y, _modal) {
	var _totalItems = array_length(itemsThatCanBeDismantled);
    var _itemsPerRow = 10;
    var _marginBetweenItems = 15;

    var _availableWidth = _modal.width - (_marginBetweenItems * (_itemsPerRow + 1)) - 80;
    var _gridSize = _availableWidth / _itemsPerRow;

   	var _startX = (_modal.x + 60) + _marginBetweenItems;
	var _startY = (_y + 20) + _marginBetweenItems;

    var _isHovering = false;

    for (var i = 0; i < _totalItems; i++) {
		var _itemThatCanBeDismantled = itemsThatCanBeDismantled[i];
        var _item = _itemThatCanBeDismantled.item;

        var _col = i mod _itemsPerRow;
        var _row = i div _itemsPerRow;

        var _x = _startX + _col * (_gridSize + _marginBetweenItems);
        var _yItem = _startY + _row * (_gridSize + _marginBetweenItems);
		var _isHoveringItem = mouseIsOnRectangle(_x, _yItem, _x + _gridSize, _yItem + _gridSize);
		drawDismantleOption(_x, _yItem, _gridSize, _item, _isHoveringItem, i);
		_isHovering = _isHoveringItem ? _isHoveringItem : _isHovering;
	}
	
	if (!_isHovering) hoverIndicator.destinyAlpha = 0;
	
	if (_isHovering && mouse_check_button(mb_left)) {
		if (!audio_is_playing(snd_tools_jiggle)) audio_play_sound(snd_tools_jiggle, 0, false)
		var _structToDismantle = itemsThatCanBeDismantled[hoverCrafting];
		var _j = variable_struct_exists(_structToDismantle, "j") ? _structToDismantle.j : -1;
		var _i = variable_struct_exists(_structToDismantle, "i") ? _structToDismantle.i : -1;
		var _toolBar = variable_struct_exists(_structToDismantle, "toolBar") ? _structToDismantle.toolBar : -1;
		dismantleProgress += .7;
		if (dismantleProgress >= 100) {
			dismantleItem(_j, _i, _toolBar);
			reloadItems();
			return;
		}
	} else {
		dismantleProgress = 0;
		audio_stop_sound(snd_tools_jiggle);
	}
	
	if (hoverCrafting != -1) {
		var _item = itemsThatCanBeDismantled[hoverCrafting].item;
		var _dismantableReturn = getDismantableContent(_item.itemId, _item.type)
		drawDismantleReturn(_dismantableReturn);
	}
}

function drawDismantleOption(_x, _y, _size, _item, _isHovering, _i) {
	var _gridSprite = spr_base_resident_grid;
	drawSpriteShadow(_x, _y, _gridSprite, 2, 0, getScale(_size, sprite_get_width(_gridSprite)), getScale(_size, sprite_get_height(_gridSprite)), 8, 8);
	draw_sprite_stretched_ext(_gridSprite, _isHovering, _x, _y, _size, _size, c_white, 1);
	
	var _itemX = _x + _size/2;
	var _itemY = _y + _size/2;
	var _scale = 1;
	var _border = 16;
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getScale(_size - _border * 2, sprite_get_width(_item.sprite))
	} else {
		_scale = getScale(_size - _border * 2, sprite_get_height(_item.sprite))
	}
	
	drawSpriteShadow(_itemX, _itemY, _item.sprite, 0, 0, _scale, _scale);
	draw_sprite_ext(_item.sprite, 0, _itemX, _itemY, _scale, _scale, 0, c_white, 1);
	
	if (!_isHovering) return;
	if (hoverCrafting != _i) {
		dismantleProgress = 0;
		playHoverSound();
	}
	
	var _progress = dismantleProgress;
	var _progressHeight = _size * (_progress / 100);
	
	var _fillRectY1 = _y + _size - _progressHeight;
	
	var _fillColor = c_white;
	var _alpha = 0.4;
	
	draw_set_alpha(_alpha);
	draw_set_color(_fillColor);
	
	draw_rectangle(
		_x, 
		_fillRectY1, 
		_x + _size, 
		_y + _size, 
		false
	);
	
	draw_set_alpha(1);
	draw_set_color(c_white);
	
	var _actualXPosition = _x + _size;

	hoverCraftingForUI.desX = _x + _size + 15;
	hoverCraftingForUI.desY = _itemY - _size / 2;
	hoverCraftingForUI.gridSize = _size;
	
	hoverCraftingControl = _i;
	hoverCrafting = _i;
	
	defineHoverIndicator(_x, _y, _size);
}

function drawRepairPanel(_y, _modal) {
    var _totalItems = array_length(itemsThatCanBeRepaired);
    var _itemsPerRow = 10;
    var _marginBetweenItems = 15;

    var _availableWidth = _modal.width - (_marginBetweenItems * (_itemsPerRow + 1)) - 120;
    var _gridSize = _availableWidth / _itemsPerRow;

   	var _startX = (_modal.x + 60) + _marginBetweenItems;
	var _startY = (_y + 20) + _marginBetweenItems;

    var _isHovering = false;

    for (var i = 0; i < _totalItems; i++) {
        var _item = itemsThatCanBeRepaired[i];

        var _col = i mod _itemsPerRow;
        var _row = i div _itemsPerRow;

        var _x = _startX + _col * (_gridSize + _marginBetweenItems);
        var _yItem = _startY + _row * (_gridSize + _marginBetweenItems);

        var _hoverIndividualItem = drawRepairItem(_x, _yItem, _gridSize, _item, i);
        if (_hoverIndividualItem) _isHovering = true;
    }

    if (!_isHovering) {
		hoverIndicator.destinyAlpha = 0;
	}
	
	if (hoverCrafting == -1) return;
	var _struct = itemsThatCanBeRepaired[hoverCrafting]
	var _selectedItem = _struct.item;
	var _requirements = getItemRepairRequirements(_selectedItem.itemId);
	drawRepairRequirements(_requirements.requirements, _selectedItem.name);
	if (mouse_check_button_released(mb_left)) {
		repairItem(_struct, _requirements);
	}
}

function repairItem(_selectedItem, _requirements) {
	if (!verifyIfHasAllItems(_requirements)){
		playFailSound();
		hoverIndicator.failEffect = 5;
		return;
	}
	
	var _repair = function (_struct) {
		if (variable_struct_exists(_struct, "toolBar")) {
			repairItemFromToolBar(_struct.toolBar);
			return;
		}
		repairItemFromInventory(_struct.j, _struct.i, global.inventory);
	}	
	
	_repair(_selectedItem);
	
	array_foreach(_requirements.requirements, function (_req) {
		cleanItemInInventoryById(global.inventory, _req.itemId, _req.type, _req.quantity);
	});
	
	audio_play_sound(snd_builded_item, 0, false);
	reloadItems();
}

function drawRepairRequirements(_requirements, _title) {
	static requirementUiValues = getRequirementsUiValues();
	var _requirementBoxHeight = 64;
	if (hoverCraftingForUI.x == 0 && hoverCraftingForUI.desX != 0) {
		hoverCraftingForUI.x = hoverCraftingForUI.desX;
		hoverCraftingForUI.y = hoverCraftingForUI.desY;
	}
	
	var _guiWidth = display_get_gui_width();
	
	var _shouldAdapt = hoverCraftingForUI.desX - hoverCraftingForUI.gridSize > _guiWidth / 2;
	
	var _largestString = 0
	for (var i = 0; i < array_length(_requirements); i ++) {
		var _return = _requirements[i];
		var _item = global.items[_return.type][_return.itemId];
		var _string = _item.name;
		_largestString = string_width(_string) > _largestString ? string_width(_string) : _largestString;
	}
	
	if (_shouldAdapt) {
		hoverCraftingForUI.desX -= _largestString + hoverCraftingForUI.gridSize + hoverCraftingForUI.gridSize + 40 ;
	}
	
	hoverCraftingForUI.x = lerp(hoverCraftingForUI.x, hoverCraftingForUI.desX, .1);
	hoverCraftingForUI.y = lerp(hoverCraftingForUI.y, hoverCraftingForUI.desY, .1);
	
	var _alpha = draw_get_alpha();
	
	draw_set_alpha(hoverIndicator.alpha)
	
	var _x = hoverCraftingForUI.x;
	var _y = hoverCraftingForUI.y;
	
	draw_set_font(fnt_gui_title);
	draw_set_valign(fa_bottom);
	
	drawTextShadow(_x, _y, _title, hoverIndicator.alpha);
	
	draw_text(_x, _y, _title);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
	
	for (var i = 0; i < array_length(_requirements); i ++) {
		var _requirement = _requirements[i];
		var _item = global.items[_requirement.type][_requirement.itemId];
		var _currentQuantity = getItemQuantityInInventory(global.inventory, _requirement.itemId, _requirement.type);
		drawRequirement(_item.sprite, _item.name, _requirementBoxHeight, _x, _y, _currentQuantity, _requirement.quantity, hoverIndicator.alpha);	
		_y += _requirementBoxHeight;
	}
	
	draw_set_alpha(_alpha);
}

function drawRepairItem(_x, _y, _size, _data, _i){
	var _gridSprite = spr_base_resident_grid;
	var _scale = 1;
	var _item = _data.item;
	var _border = 16;
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getScale(_size - _border * 2, sprite_get_width(_item.sprite))
	} else {
		_scale = getScale(_size - _border * 2, sprite_get_height(_item.sprite))
	}
	var _itemX = _x + _size/2;
	var _itemY = _y + _size/2;
	var _mouseIsOnGrid = mouseIsOnRectangle(_x, _y, _x + _size, _y + _size);
	
	draw_sprite_stretched_ext(_gridSprite, _mouseIsOnGrid, _x, _y, _size, _size, c_white, 1);
	var _spriteSize = sprite_get_height(_gridSprite);
	var _gridScale = getScale(_size, _spriteSize );
	drawItemDurability(_item, _x + _border, _y + _border, _size - _border * 2, _size - _border* 2);
	drawSpriteShadow(_itemX, _itemY, _item.sprite, 0, 0, _scale, _scale);
	draw_sprite_ext(_item.sprite, 0, _itemX, _itemY, _scale, _scale, 0, c_white, 1);
	
	if (!_mouseIsOnGrid) {
		return false;
	}
	
	if (hoverCrafting != _i) {
		playHoverSound();
	}
	
	hoverCraftingForUI.desX = _x + _size + 15;
	hoverCraftingForUI.desY = _itemY - _size / 2;
	hoverCraftingForUI.gridSize = _size;
	
	hoverCraftingControl = _i;
	hoverCrafting = _i;
	
	defineHoverIndicator(_x, _y, _size);
	
	return true;
}

function handleClickOnRepairItem(_item, _data){
	if (!mouse_check_button_released(mb_left)) return;
	playClickSound();
	_item.durability = _item.maxDurability;
}

function getContainerValues(_y, _modal, _totalItems, _itemsPerRow, _differenceBetween, _marginBetweenGrids){
	var _lateralBorder = 80;
	var _totalModalSpace = _modal.width - (_lateralBorder * 2);
	var _totalSpaceToWorkWith = _totalModalSpace - _differenceBetween - _totalItems * _marginBetweenGrids;
	var _initialXPosition = _modal.x + _lateralBorder;
	var _xPosition = _initialXPosition;
	var _individualGridSize = _totalSpaceToWorkWith / _itemsPerRow;
	return {
		yPosition: _y,
		xPosition: _xPosition,
		individualGridSize: _individualGridSize,
		initialXPosition: _initialXPosition
	};
}

function drawCraftingPanel(_y, _modal){
	var _marginBetweenItems = 15;
	var _itemsPerRow = 10;
	var _totalItems = array_length(itemsThatCanBeCrafted);

	var _availableWidth = _modal.width - (_marginBetweenItems * (_itemsPerRow + 1)) - 120;

	var _gridSize = _availableWidth / _itemsPerRow;

	var _startX = (_modal.x + 60) + _marginBetweenItems;
	var _startY = (_y + 20) + _marginBetweenItems;

	for (var i = 0; i < _totalItems; i++) {
		var _item = itemsThatCanBeCrafted[i];
		var _buildedItem = constructItem(_item.type, global.items[_item.type][_item.id]);

		var _col = i mod _itemsPerRow;
		var _row = i div _itemsPerRow;

		var _x = _startX + _col * (_gridSize + _marginBetweenItems);
		var _itemY = _startY + _row * (_gridSize + _marginBetweenItems);

		drawCraftingItem(_x, _itemY, _gridSize, _buildedItem, _item, _modal, i);
	}
	
	if (hoverCrafting != -1) {
		var _item = itemsThatCanBeCrafted[hoverCrafting];
		var _buildedItem = global.items[_item.type][_item.id];
		drawCraftingRequirements(_item.requirements, _buildedItem.name);
	}
	
	if (!mouseIsOnItem) hoverIndicator.destinyAlpha = 0
}

function drawCraftingRequirements(_requirements, _title) {
	static requirementUiValues = getRequirementsUiValues();
	var _requirementBoxHeight = 64;
	
	if (hoverCraftingForUI.x == 0 && hoverCraftingForUI.desX != 0) {
		hoverCraftingForUI.x = hoverCraftingForUI.desX;
		hoverCraftingForUI.y = hoverCraftingForUI.desY;
	}
	
	var _guiWidth = display_get_gui_width();
	
	var _shouldAdapt = hoverCraftingForUI.desX - hoverCraftingForUI.gridSize > _guiWidth / 2;
	
	var _largestString = 0
	for (var i = 0; i < array_length(_requirements); i ++) {
		var _return = _requirements[i];
		var _item = global.items[_return.type][_return.itemId];
		var _string = _item.name;
		_largestString = string_width(_string) > _largestString ? string_width(_string) : _largestString;
	}
	
	if (_shouldAdapt) {
		hoverCraftingForUI.desX -= _largestString + hoverCraftingForUI.gridSize + hoverCraftingForUI.gridSize;
	} else {
		hoverCraftingForUI.desX += 15;
	}
	
	hoverCraftingForUI.x = lerp(hoverCraftingForUI.x, hoverCraftingForUI.desX, .1);
	hoverCraftingForUI.y = lerp(hoverCraftingForUI.y, hoverCraftingForUI.desY, .1);
	
	var _alpha = draw_get_alpha();
	draw_set_alpha(hoverIndicator.alpha)
	var _x = hoverCraftingForUI.x;
	var _y = hoverCraftingForUI.y;
	draw_set_font(fnt_gui_title);
	draw_set_valign(fa_bottom);
	drawTextShadow(_x, _y, _title, hoverIndicator.alpha);
	draw_text(_x, _y, _title);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
	for (var i = 0; i < array_length(_requirements); i ++) {
		var _requirement = _requirements[i];
		var _item = global.items[_requirement.type][_requirement.itemId];
		var _currentQuantity = getItemQuantityInInventory(global.inventory, _requirement.itemId, _requirement.type);
		drawRequirement(_item.sprite, _item.name, _requirementBoxHeight, _x, _y, _currentQuantity, _requirement.quantity, hoverIndicator.alpha);	
		_y += _requirementBoxHeight;
	}
	draw_set_alpha(_alpha);
}

function drawDismantleReturn(_items) {
	static requirementUiValues = getRequirementsUiValues();
	var _requirementBoxHeight = 64;
	if (hoverCraftingForUI.x == 0 && hoverCraftingForUI.desX != 0) {
		hoverCraftingForUI.x = hoverCraftingForUI.desX;
		hoverCraftingForUI.y = hoverCraftingForUI.desY;
	}
	
	var _guiWidth = display_get_gui_width();
	
	var _shouldAdapt = hoverCraftingForUI.desX - hoverCraftingForUI.gridSize > _guiWidth / 2;
	
	var _largestString = 0
	for (var i = 0; i < array_length(_items); i ++) {
		var _return = _items[i];
		var _item = global.items[_return.type][_return.id];
		var _string = _item.name;
		_largestString = string_width(_string) > _largestString ? string_width(_string) : _largestString;
	}
	
	if (_shouldAdapt) {
		hoverCraftingForUI.desX -= _largestString + hoverCraftingForUI.gridSize + hoverCraftingForUI.gridSize;
	}
	
	hoverCraftingForUI.x = lerp(hoverCraftingForUI.x, hoverCraftingForUI.desX, .1);
	hoverCraftingForUI.y = lerp(hoverCraftingForUI.y, hoverCraftingForUI.desY, .1);
	
	var _x = hoverCraftingForUI.x;
	var _y = hoverCraftingForUI.y;
	
	for (var i = 0; i < array_length(_items); i ++) {
		var _return = _items[i];
		var _quantity = _return.quantity;
		var _item = global.items[_return.type][_return.id];
		
		drawEarningItem(_item.name, _item.sprite, _x, _y + (_requirementBoxHeight * i), _requirementBoxHeight, _quantity, hoverIndicator.alpha)
	}
}

function getRequirementsUiValues() {
	return {
		x: 0, 
		y: 0,
		destinyX: 0,
		destinyY: 0,
		alpha: 0,
		destinyAlpha: 0
	}
}

function drawPagination(_modal, _y, _actionUp = function () {}, _actionDown = function () {}) {
	var _buttonSprite = spr_base_resident_grid;
	var _buttonWidth = 40;
	var _spriteIndex = 0;
	var _buttonHeight = _modal.heightWithoutBorder / 2 - 40;
	var _x = _modal.x2 - _buttonWidth - _modal.border;
	
	draw_sprite_stretched(_buttonSprite, _spriteIndex, _x, _y, _buttonWidth, _buttonHeight)
	draw_sprite_ext(spr_builder_arrow_indicator, 0, _x + _buttonWidth/2, _y + _buttonHeight/2, 1, 1, 0, c_white, 1);
	
	var _y2 = _y + _buttonHeight + 10;
	
	draw_sprite_stretched(_buttonSprite, _spriteIndex, _x, _y2, _buttonWidth, _buttonHeight)
	draw_sprite_ext(spr_builder_arrow_indicator, 0, _x + _buttonWidth/2, _y2 + _buttonHeight/2, 1, -1, 0, c_white, 1);
	
}

function drawCraftingItem(_x, _y, _size, _item, _requirementItem, _modal, _i){
	var _gridSprite = spr_base_resident_grid;
	var _scale = 1;
	
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getScale(_size - 15, sprite_get_width(_item.sprite))
	} else {
		_scale = getScale(_size - 15, sprite_get_height(_item.sprite))
	}
	
	var _itemX = _x + _size/2;
	var _itemY = _y + _size/2;
	
	var _mouseIsOnGrid = mouseIsOnRectangle(_x, _y, _x + _size, _y + _size);
	
	if (!_mouseIsOnGrid) {
		drawCraftItemMouseNotHover(_gridSprite, _scale, _x, _y, _size, _itemX, _itemY, _item);
		return;
	}
	
	defineHoverIndicator(_x, _y, _size);
	
    if (lastHoveredItem != _item.itemId) {
        playHoverSound();
		lastHoveredItem = _item.itemId;
    }
	
	if (currentHoverItem != _item.itemId) {
		currentHoverItem = _item.itemId;
		currentHoverItemRequirements.requirement = _requirementItem;
		currentHoverItemRequirements.item = _item;
	}
	
	mouseIsOnItem = true;
	requirementModalAlpha = lerp(requirementModalAlpha, 1, .2);
	drawCraftItemMouseHover(_gridSprite, _scale, _x, _y, _size, _itemX, _itemY, _item);
	
	if (hoverCrafting != _i) {
		playHoverSound();
	}
	
	var _actualXPosition = _x + _size;

	hoverCraftingForUI.desX = _actualXPosition;
	hoverCraftingForUI.desY = _y;

	hoverCraftingControl = _i;
	hoverCrafting = _i;
	
	if (mouse_check_button_released(mb_left)) {
		handleClickOnItem(_item, _requirementItem);
	}
}

function defineHoverIndicator(_x, _y, _size) {
	hoverIndicator.destinyX = _x;
	hoverIndicator.destinyY = _y;
	hoverIndicator.destinyAlpha = 1;
	hoverIndicator.destinySize = _size;
}

function handleClickOnItem(_item, _requirementItem){
	if (!verifyIfHasAllItems(_requirementItem)){
		playFailSound();
		hoverIndicator.failEffect = 5;
		return;
	}
	
	var _requirementList = _requirementItem.requirements;
	
	var _gridIndex = findCleanIndexFromInventory(global.inventory, "");
	if(_gridIndex[0] == -1){
		var _modalX = xMouse;
		var _modalY = yMouse;
		createNotifyIndicator("Inventário cheio!", _modalX, _modalY);
		return;
	}
	
	for(var i = 0; i < array_length(_requirementList); i++){
		var _requirement = _requirementList[i];
		var _requirementType = _requirement.type;
		var _requirementQuantity = _requirement.quantity;
		var _requirementId = _requirement.itemId;
		cleanItemInInventoryById(global.inventory, _requirementId, _requirementType, _requirementQuantity);
		//createIndicatorForDroppedItems(
		//	constructItem(_requirementType, global.items[_requirementType][_requirementId]),
		//	_requirementQuantity
		//);
	}
	
	if (addItemToGrid(global.inventory, _item)){
		createIndicatorModal(_item, variable_struct_exists(_item, "quantity") ? _item.quantity : 1);
		audio_play_sound(snd_builded_item, 0, false);
		audio_play_sound(snd_equip_item, 0, false);
	} 
}


function drawCraftItemMouseHover(_gridSprite, _scale, _x, _y, _size, _itemX, _itemY, _item) {
	var _spriteSize = sprite_get_height(_gridSprite);
	var _gridScale = getScale(_size, _spriteSize);
	draw_sprite_stretched_ext(_gridSprite, 1, _x, _y, _size, _size, c_white, 1);
	drawSpriteShadow(_itemX, _itemY, _item.sprite, 0, 0, _scale, _scale);
	draw_sprite_ext(_item.sprite, 0, _itemX, _itemY, _scale, _scale, 0, c_white, 1);
}

function drawCraftItemMouseNotHover(_gridSprite, _scale, _x, _y, _size, _itemX, _itemY, _item){
	drawSpriteShadow(_x, _y, _gridSprite, 2, 0, getScale(_size, sprite_get_width(_gridSprite)), getScale(_size, sprite_get_height(_gridSprite)), 8, 8);
	draw_sprite_stretched_ext(_gridSprite, 2, _x, _y, _size, _size, c_white, 1);
	drawSpriteShadow(_itemX, _itemY, _item.sprite, 0, 0, _scale, _scale);
	draw_sprite_ext(_item.sprite, 0, _itemX, _itemY, _scale, _scale, 0, c_white, 1);
}

function getModal(_width = 1000, _height = guiHeight * 0.9) {
    var _sprite = spr_inventory_box;
    var _xScale = getScale(_width, sprite_get_width(_sprite));
    var _yScale = getScale(_height, sprite_get_height(_sprite));
    
	var _border = 20;
    
	var _widthWithoutBorder = _width - _border * 2;
    var _heightWithoutBorder = _height - _border * 2;
    var _xScaleWithoutBorder = getScale(_widthWithoutBorder, sprite_get_width(_sprite));
    var _yScaleWithoutBorder = getScale(_heightWithoutBorder, sprite_get_height(_sprite));
	
	modalXSize = _width;
	modalYSize = _height;
    
	return {
        width: _width,
        height: _height,
        sprite: _sprite,
        xScale: _xScale,
        yScale: _yScale,
        widthWithoutBorder: _widthWithoutBorder,
        heightWithoutBorder: _heightWithoutBorder,
        xScaleWithoutBorder: _xScaleWithoutBorder,
        yScaleWithoutBorder: _yScaleWithoutBorder,
		x: 0,
		y: 0,
		x2: 0,
		y2: 0,
		border: _border
    };
}

defineWorkersPositions = function () {
	workerPositions = [
		getWorkerPosition(bbox_left + 64, bbox_bottom + 20)
	];
}

defineWorkersPositions();