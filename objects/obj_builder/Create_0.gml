#macro REQUIREMENTWIDTH 75
listOfElementsYPosition = display_get_gui_height();
listOfElementsDestinyYPosition = 0;
defaultListOfElementsDestinyYPosition = display_get_gui_height() - 100;
selectedFurniture = BLANK_INVENTORY_SPACE;
alreadyPlacedSelectedFurniture = noone;
furnitureDisplay = noone;
selectedFurnitureIndex = {
	category: BLANK_INVENTORY_SPACE,
	index: BLANK_INVENTORY_SPACE
};
buildIndicationBox = {
	width: 25,
	height: 25,
	y1Position: 0, 
	x1Position: 0, 
	x2Position: 0, 
	y2Position: 0 
};
mouseIsOnListOfFurniture = false;
activeSelectingFurniture = false;
arrowDirection = 1;
arrowScale = 1.5;
arrowDestinyScale = 1.5;
selectedCategory = furnitureCategories.decoration;
hoverFurniture = BLANK_INVENTORY_SPACE;
hoverCategory = -1;
constructorGridSize = 32;
hoverIndicatorUIData = {
	x: display_get_gui_width()/2,
	y: display_get_gui_height()/2,
	destinyX: display_get_gui_width()/2,
	destinyY: display_get_gui_height()/2,
	failEffect: 0,
	destinyAlpha: 0,
	alpha: 0
}
furnitureDisplay = instance_create_layer(mouse_x, mouse_y, "Alert", obj_furniture_display);
furnitureDisplayInfo = {
	angle: 0,
	xPosition: 0,
	yPosition: 0,
}
hoverFurnitureForUI = {
	x: 0,
	y: 0,
	desX: 0,
	desY: 0
}
requirementsCheck = false;
trashButtonUI = {
	scale: 0,
	hoverScale: 1,
	angle: 0,
	isHovering: false
};
hoveredPlacedFurniture = noone;
hoverPlacedUI = {
	x1: 0,
	y1: 0,
	x2: 0,
	y2: 0,
	padding: 0,
	pop: 0
};
placementEffects = [];

function hide(){
	return;
}

function nothing(){
	global.activeBuilding = false;
	verifyConditionsToAimFurniture()
}

function verifyConditionsToAimFurniture(){
	if(!keyboard_check_released(ord("T")) || global.blockMenus) return false;
	selectLateralMenuOption(menu.builder);
}

function setUpModal(){
	global.stopInteractions = true;
	global.playerStopInteractions = true;
	listOfElementsDestinyYPosition = defaultListOfElementsDestinyYPosition;
	playSwiiimmmSound();
	obj_camera.setDefaultValues();
	obj_camera.target = obj_player;
	guiCurrentState = displayFurniture;
	currentState = aimFurniture;
}

function verifyConditionsToStopAimFurniture(){
	if(keyboard_check_released(ord("T")) || global.blockMenus){
		deactivateLateralMenuOption(menu.builder);
		return true;
	}
	return false;
}

function closeBuilder(){
	deactivateLateralMenuOption(menu.builder);
}

function displayNothing(){
	return;
}

function drawGridLines(){
	var _gridSize = constructorGridSize;

	if (!global.activeBuilding) return;

	var _xStart = camera_get_view_x(view_camera[0]);
	var _yStart = camera_get_view_y(view_camera[0]);
	var _viewW  = camera_get_view_width(view_camera[0]);
	var _viewH  = camera_get_view_height(view_camera[0]);

	draw_set_color(c_white);
	draw_set_alpha(0.2);

	for (var _xPos = floor(_xStart / _gridSize) * _gridSize; _xPos < _xStart + _viewW; _xPos += _gridSize) {
	    draw_line(_xPos + 0.5, _yStart, _xPos + 0.5, _yStart + _viewH);
	}
	for (var _yPos = floor(_yStart / _gridSize) * _gridSize; _yPos < _yStart + _viewH; _yPos += _gridSize) {
	    draw_line(_xStart, _yPos + 0.5, _xStart + _viewW, _yPos + 0.5);
	}
	draw_set_alpha(1);
}

function displayFurniture(){
	if (currentState != aimFurniture && listOfElementsYPosition > display_get_gui_height()){
		guiCurrentState = displayNothing;
	}	
	listOfElementsYPosition = lerp(listOfElementsYPosition, listOfElementsDestinyYPosition, .1);
	var _box = getListOfFurnitureBox();
	mouseIsOnListOfFurniture = mouseIsOnToggleArea(_box)
	draw_sprite_ext(_box.sprite, 0, _box.xPosition, _box.yPosition, _box.xScale, _box.yScale, 0, c_white, 1);
	checkMouseOnClick();
	var _arrowXPosition = drawMenuTitle(_box);
	drawIndicationArrow(_box, _arrowXPosition);
	drawFurnitureMenu(_box);
	drawTrashButton();
}

function drawTrashButton() {
	var _isActive = alreadyPlacedSelectedFurniture != noone && instance_exists(alreadyPlacedSelectedFurniture);
	trashButtonUI.scale = lerp(trashButtonUI.scale, _isActive, .2);

	if (trashButtonUI.scale < .05) {
		trashButtonUI.isHovering = false;
		return;
	}

	var _size = 96;
	var _margin = 40;
	var _centerX = display_get_gui_width() - _margin - _size / 2;
	var _centerY = _margin + _size / 2;
	var _isHovering = _isActive && mouseIsOnRectangle(_centerX - _size / 2, _centerY - _size / 2, _centerX + _size / 2, _centerY + _size / 2);

	if (_isHovering && !trashButtonUI.isHovering) playHoverSound();
	trashButtonUI.isHovering = _isHovering;

	trashButtonUI.hoverScale = lerp(trashButtonUI.hoverScale, _isHovering ? 1.25 : 1, .2);
	trashButtonUI.angle = _isHovering ? sin(current_time / 60) * 8 : lerp(trashButtonUI.angle, 0, .2);

	var _drawSize = _size * trashButtonUI.scale * trashButtonUI.hoverScale;
	var _boxX = _centerX - _drawSize / 2;
	var _boxY = _centerY - _drawSize / 2;

	drawSpriteShadowStretched(_boxX, _boxY, spr_builder_furniture_box, _isHovering, 0, _drawSize, _drawSize);
	draw_sprite_stretched_ext(spr_builder_furniture_box, _isHovering, _boxX, _boxY, _drawSize, _drawSize, _isHovering ? #ff6b6b : c_white, 1);

	var _icon = spr_trash_icon;
	var _iconScale = getScale(_drawSize * .6, sprite_get_width(_icon));
	var _iconHalf = sprite_get_width(_icon) * _iconScale / 2;
	var _iconX = _centerX - lengthdir_x(_iconHalf, trashButtonUI.angle) - lengthdir_x(_iconHalf, trashButtonUI.angle - 90);
	var _iconY = _centerY - lengthdir_y(_iconHalf, trashButtonUI.angle) - lengthdir_y(_iconHalf, trashButtonUI.angle - 90);

	drawSpriteShadow(_iconX, _iconY, _icon, 0, trashButtonUI.angle, _iconScale, _iconScale, 3, 3);
	draw_sprite_ext(_icon, 0, _iconX, _iconY, _iconScale, _iconScale, trashButtonUI.angle, c_white, 1);

	if (_isHovering && mouse_check_button_released(mb_left)) {
		dismantleSelectedFurniture();
	}
}

function getFurnitureBuildRequirements(_instance) {
	if (_instance.object_index == obj_furniture_map_selector) return undefined;

	// baús guardam o tipo real da mobília no containerId
	var _furnitureId = _instance.object_index == obj_chest ? global.containerMapping[? _instance.containerId] : _instance.furnitureId;

	for (var i = 0; i < array_length(global.furniture); i++) {
		var _category = global.furniture[i];

		for (var j = 0; j < array_length(_category); j++) {
			if (_category[j].furnitureId == _furnitureId) return _category[j].requirements;
		}
	}

	return undefined;
}

function giveDismantledItem(_item, _instance) {
	if (addAbsoluteItemToGrid(global.inventory, _item)) {
		createIndicatorModal(_item, variable_struct_exists(_item, "quantity") ? _item.quantity : 1);
		return;
	}

	createItemByObjectId(_instance, _item, true);
}

function giveDismantleRequirements(_requirements, _instance) {
	for (var i = 0; i < array_length(_requirements); i++) {
		var _requirement = _requirements[i];
		var _itemData = global.items[_requirement.type][_requirement.itemId];
		var _limit = max(1, _itemData[$ "limit"] ?? _requirement.quantity);
		var _quantityLeft = _requirement.quantity;

		while (_quantityLeft > 0) {
			var _stackQuantity = min(_quantityLeft, _limit);
			var _item = constructItem(_requirement.type, _itemData);
			_item.quantity = _stackQuantity;
			giveDismantledItem(_item, _instance);
			_quantityLeft -= _stackQuantity;
		}
	}
}

function giveChestContent(_instance) {
	var _container = _instance.containerData;

	for (var i = 0; i < ds_grid_width(_container); i++) {
		for (var j = 0; j < ds_grid_height(_container); j++) {
			var _item = _container[# i, j];
			if (_item == BLANK_INVENTORY_SPACE || !is_struct(_item)) continue;

			giveDismantledItem(_item, _instance);
			_container[# i, j] = BLANK_INVENTORY_SPACE;
		}
	}
}

function dismantleSelectedFurniture() {
	var _instance = alreadyPlacedSelectedFurniture;
	var _requirements = getFurnitureBuildRequirements(_instance);

	if (_requirements == undefined) {
		playFailSound();
		createGUINotifyIndicator("Essa mobília não pode ser desmontada", device_mouse_x_to_gui(0), device_mouse_y_to_gui(0));
		return;
	}

	playClickSound();

	if (_instance.object_index == obj_chest) giveChestContent(_instance);
	giveDismantleRequirements(_requirements, _instance);

	unassignFurnitureWorkers(_instance.furnitureId, _instance.objectId);
	removeFurnitureData(_instance.furnitureId, _instance.objectId);

	createRoomNotifyIndicator("Mobília desmontada", _instance.x, _instance.y, c_orange);
	addPlacementBurst(_instance, c_orange, 20);
	screenShake(3);
	instance_destroy(_instance);

	furnitureDisplay.isDisplaying = false;
	requirementsCheck = false;
	trashButtonUI.isHovering = false;
	menuNotActiveSelectingFurnatureMenuButOnBuildMode();
}

function drawMenuTitle(_box){
	static _xPosition = _box.xPosition + _box.borderMargin * 2;
	static _scale = 1;
	var _title = "Construção";
	var _defaultXPosition = _box.xPosition + _box.borderMargin * 2;
	var _yPosition = _box.yPosition + _box.yMarginFromBottom/2;
	var _destinyScale = mouseIsOnListOfFurniture ? 1.1 : 1;
	var _destinyXPosition = mouseIsOnListOfFurniture ? _defaultXPosition + 50 : _defaultXPosition;
	var _lerpEffect = .3;
	_scale = lerp(_scale, _destinyScale, _lerpEffect);
	_xPosition = lerp(_xPosition, _destinyXPosition, _lerpEffect);
	
	draw_set_valign(fa_middle);
	draw_set_font(fnt_gui_title);
	
	drawTextShadow(_xPosition, _yPosition, _title, 1, 4, _scale);
	draw_text_transformed(_xPosition, _yPosition, _title, _scale, _scale, 0);
	var _stringWidth = string_width(_title) * _scale;
	draw_set_font(fnt_gui_default);
	draw_set_valign(fa_top);
	
	return _xPosition + _stringWidth;
}

function drawFurnitureMenu(_box){
	if (!activeSelectingFurniture) return;
	var _margin = 20;
	var _newBox = {
		xPosition: _box.xPosition + _box.borderMargin + _margin,
		x2Position: _box.x2Position - _box.borderMargin - _margin,
		yPosition: _box.yPosition + _box.yMarginFromBottom,
		y2Position: display_get_gui_height(),
		sprite: spr_builder_inside_box,
		hMargin: 12
	};
	var _xScale = getScale(_newBox.x2Position - _newBox.xPosition, sprite_get_width(_newBox.sprite));
	var _yScale = getScale(_newBox.y2Position - _newBox.yPosition, sprite_get_height(_newBox.sprite));
	//draw_sprite_ext(_newBox.sprite, 0, _newBox.xPosition, _newBox.yPosition, _xScale, _yScale, 0, c_white, 1);
	_newBox = drawFurnitureMenuItems(_newBox);
	drawFurnitureItems(_newBox);
	drawFurnitureRequirements();
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

function drawFurnitureRequirements() {
	static requirementUiValues = getRequirementsUiValues();
	if (array_length(global.furniture[selectedCategory]) <= hoverFurniture) return;
	if (hoverFurnitureControl == BLANK_INVENTORY_SPACE) return;
	var _furniture = global.furniture[selectedCategory][hoverFurniture];
	var _requirements = _furniture.requirements;
	var _requirementBoxHeight = 64;
	if (hoverFurnitureForUI.x == 0 && hoverFurnitureForUI.desX != 0) {
		hoverFurnitureForUI.x = hoverFurnitureForUI.desX;
		hoverFurnitureForUI.y = hoverFurnitureForUI.desY;
	}
	hoverFurnitureForUI.x = lerp(hoverFurnitureForUI.x, hoverFurnitureForUI.desX, .1);
	hoverFurnitureForUI.y = lerp(hoverFurnitureForUI.y, hoverFurnitureForUI.desY, .1);
	
	var _x = hoverFurnitureForUI.x + 15;
	var _y = hoverFurnitureForUI.y;
	var _furnitureName = _furniture.title;
	draw_set_font(fnt_gui_title);
	draw_set_valign(fa_bottom);
	drawTextShadow(_x, _y, _furnitureName, 1);
	draw_text(_x, _y, _furnitureName);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
	for (var i = 0; i < array_length(_requirements); i ++) {
		var _requirement = _requirements[i];
		var _item = global.items[_requirement.type][_requirement.itemId];
		var _currentQuantity = getItemQuantityInInventory(global.inventory, _requirement.itemId, _requirement.type);
		drawRequirement(_item.sprite, _item.name, _requirementBoxHeight, _x, _y, _currentQuantity, _requirement.quantity);	
		_y += _requirementBoxHeight;
	}
}

function drawFurnitureMenuItems(_box){
	static _menuItemPositions = [
		_box.yPosition,
		_box.yPosition,
		_box.yPosition,
		_box.yPosition,
		_box.yPosition
	];
	var _initialXPosition = _box.xPosition;
	var _initialYPosition = _box.yPosition;
	var _roomToWorkWith = _box.x2Position - _box.xPosition;
	var _categoryLength = array_length(global.furnitureCategories);
	var _hoverAny = false;
	for (var i = 0; i < _categoryLength; i++) {
		var _category = global.furnitureCategories[i];
		var _size = _roomToWorkWith div _categoryLength;
		var _destinyYPosition = (_category.type == selectedCategory) || (hoverCategory == _category.type) ? _initialYPosition - 10 : _initialYPosition;
		_menuItemPositions[i] = lerp(_menuItemPositions[i], _destinyYPosition, .2);
		var _y = canApplyHoverUiEffects() ? _menuItemPositions[i] : _box.yPosition;
		var _mouseIsOnButton = drawCategory(_size, _category, _initialXPosition, _y, _box.yPosition);
		if (_mouseIsOnButton) {
			_hoverAny = true;
		}
		_initialXPosition += _size;
	}
	if (!_hoverAny) {
		hoverCategory = -1;
	}
	draw_set_font(fnt_default);
	_box.yPosition += 100;
	return _box;
}

function canApplyHoverUiEffects(){
	return listOfElementsYPosition - listOfElementsDestinyYPosition < 10;
}

function drawFurnitureItems(_box){
	var _columns = 6;
	var _marginBetweenItems = 15;
	var _initialXPosition = _box.xPosition + _marginBetweenItems / 2;
	var _xPosition = _initialXPosition;
	var _yPosition = _box.yPosition;
	var _auxColumns = 1;
	var _boxHorizontalArea = (_box.x2Position - _box.xPosition) - (_marginBetweenItems * _columns);
	var _boxWidth = 0;
	var _tempYForIndicator = _yPosition;
	hoverFurnitureControl = BLANK_INVENTORY_SPACE;
	for (var i = 0; i < array_length(global.furniture[selectedCategory]); i++){
		var _furniture = global.furniture[selectedCategory][i];
		_boxWidth = drawFurnitureSelect(_furniture, _xPosition, _yPosition, _columns, _boxHorizontalArea, _marginBetweenItems, i);
		_xPosition += _boxWidth + _marginBetweenItems;
		if (_auxColumns >= _columns){
			_yPosition += _boxWidth + _marginBetweenItems;
			_auxColumns = 0;
			_xPosition = _initialXPosition;
		}
		_auxColumns++;
	}
	handleHoverIndicator(_initialXPosition, _tempYForIndicator, _boxWidth);
}

function handleHoverIndicator(_initialXPosition, _initialYPosition, _gridWidth){
	if (hoverFurnitureControl == BLANK_INVENTORY_SPACE) {
		hoverFurniture = 0;
		hoverIndicatorUIData.destinyAlpha = 0;
	} else {
		hoverFurniture = hoverFurnitureControl;
		hoverIndicatorUIData.destinyAlpha = 1;
	}
	if (hoverFurniture != BLANK_INVENTORY_SPACE){
		drawHoverIndicator(_gridWidth);
	}
}

function drawHoverIndicator(_size){
	var _lerpEffect = .2;
	hoverIndicatorUIData .x = lerp(hoverIndicatorUIData .x, hoverIndicatorUIData.destinyX, _lerpEffect);
	hoverIndicatorUIData .y = lerp(hoverIndicatorUIData .y, hoverIndicatorUIData.destinyY, _lerpEffect);
	hoverIndicatorUIData.alpha = lerp(hoverIndicatorUIData.alpha, hoverIndicatorUIData.destinyAlpha, _lerpEffect);
	if (hoverIndicatorUIData.failEffect != 0) {
		var _x = random_range(-hoverIndicatorUIData.failEffect, hoverIndicatorUIData.failEffect); 
		var _y = random_range(-hoverIndicatorUIData.failEffect, hoverIndicatorUIData.failEffect); 
		hoverIndicatorUIData.x += _x * 5;
		hoverIndicatorUIData.y += _y * 5;
		hoverIndicatorUIData.failEffect = lerp(hoverIndicatorUIData.failEffect, 0, .2);
	}
	var sprite = spr_hover_indicator;
	var _scale = getScale(_size, sprite_get_width(sprite));
	draw_sprite_stretched_ext(sprite, 0, hoverIndicatorUIData .x, hoverIndicatorUIData .y, _size, _size, c_white, hoverIndicatorUIData.alpha);
}

function checkPositionWithWithScreenBorder(_descriptionBox){
	var _displayWidth = display_get_width();
	var _hDifferenceBetween = _descriptionBox.x2Position - _displayWidth;
	if (_hDifferenceBetween){
		_descriptionBox.xPosition -= _hDifferenceBetween;
		_descriptionBox.x2Position -= _hDifferenceBetween;
	}
	var _displayHeight = display_get_height();
	var _vDifferenceBetween = _descriptionBox.y2Position - _displayHeight;
	if (_vDifferenceBetween) {
	    _descriptionBox.yPosition -= _vDifferenceBetween;
	    _descriptionBox.y2Position -= _vDifferenceBetween;
	}
	return _descriptionBox;
}

function drawDescriptionTitle(_box, _text){
	var _textHeight = string_height("TXT");
	var _textXPosition = getMiddlePoint(_box.xPosition, _box.x2Position);
	var _marginFromText = 15;
	var _textYPosition = _box.yPosition + _textHeight + _marginFromText/2;
	draw_text_scribble(_textXPosition, _textYPosition,"[fa_center][fa_bottom]" + _text);
	_box.yPosition += _textHeight + _marginFromText;
	return _box;
}

function drawFurnitureSelect(_furniture, _xPosition, _yPosition, _columns, _totalArea, _marginBetween, _i){
	var _stringWidth = string_width(_furniture.title);
	var _boxWidth = _totalArea div _columns;
	var _x2Position = _xPosition + _boxWidth;
	var _y2Position = _yPosition + _boxWidth;
	var _mouseIsOnFurniture = mouseIsOnRectangle(_xPosition, _yPosition, _x2Position + _marginBetween, _y2Position + _marginBetween);
	var _color = 0;
	if(_mouseIsOnFurniture){
		if (hoverFurniture != _i) {
			playHoverSound();
		}
		var _guiWidth = display_get_gui_width();
		var _actualXPosition = _xPosition + _boxWidth;
		hoverFurnitureForUI.desX = _actualXPosition > _guiWidth/2 ? _xPosition - _boxWidth * 2: _actualXPosition;
		hoverFurnitureForUI.desY = _yPosition;
		hoverFurnitureControl = _i;
		_color = 1;
		hoverIndicatorUIData.destinyX = _xPosition;
		hoverIndicatorUIData.destinyY = _yPosition;
		handleSelectionFurniture();
	}
	var _furnitureBox = drawFurnitureBox(_xPosition, _yPosition, _x2Position, _y2Position, _color);
	drawFurnitureItem(_furnitureBox, _furniture);
	return _boxWidth;
}

function drawFurnitureItem(_box, _furniture) {
    var _boxHeight = _box.y2Position - _box.yPosition;
    var _border = 25;
    var _marginPersonalized = _furniture.personalizedMargin;
    var _itemHeight = _boxHeight - _border - _marginPersonalized;

    var _sprite = _furniture.icon;
    var _spriteWidth = sprite_get_width(_sprite);
    var _spriteHeight = sprite_get_height(_sprite);
    var _spriteXOffset = sprite_get_xoffset(_sprite);
    var _spriteYOffset = sprite_get_yoffset(_sprite);

    var _itemScale = getScale(_itemHeight, _spriteHeight);

    var _centerX = _box.xPosition + (_boxHeight / 2);
    var _centerY = _box.yPosition + (_boxHeight / 2);

    var _xPosition = _centerX - (_spriteWidth / 2 - _spriteXOffset) * _itemScale;
    var _yPosition = _centerY - (_spriteHeight / 2 - _spriteYOffset) * _itemScale;

    draw_sprite_ext(_sprite, 0, _xPosition, _yPosition, _itemScale, _itemScale, 0, c_white, 1);
}


function drawFurnitureBox(_xPosition, _yPosition, _x2Position, _y2Position, _color){
	var _sprite = spr_builder_furniture_box;
	var _furnitureBox = {
		xPosition: _xPosition,
		yPosition: _yPosition,
		y2Position: _y2Position,
		x2Position: _x2Position
	};
	var _xSize = _x2Position - _xPosition;
	_xSize = _xSize % 2 == 0 ? _xSize : _xSize + 1;
	show_debug_message(_xSize);
	var _ySize = _y2Position - _yPosition;
	draw_sprite_stretched_ext(_sprite, _color, _xPosition, _yPosition, _xSize, _ySize, c_white, 1);
	return _furnitureBox;
}

function handleSelectionFurniture(){
	if (!mouse_check_button_released(mb_left)) return;
	var _furniture = global.furniture[selectedCategory][hoverFurniture];
	if (!checkRequirements(_furniture)) {
		playFailSound();
		hoverIndicatorUIData.failEffect = 5;
		return false;
	}
	playClickSound();
	menuNotActiveSelectingFurnatureMenuButOnBuildMode();
	selectedFurnitureIndex.category = selectedFurniture;
	selectedFurnitureIndex.index = hoverFurniture;
	selectedFurniture = _furniture;
	furnitureDisplayInfo.angle = 0;
	furnitureDisplay.setFurniture(_furniture.sprite);
	furnitureDisplay.isDisplaying = true;
	return _furniture;
}

function checkRequirements(_furniture){
	for(var i = 0; i < array_length(_furniture.requirements); i++){
		var _requirementQuantity = _furniture.requirements[i].quantity;
		var _requirementId = _furniture.requirements[i].itemId;
		var _item = global.items[itemType.trash][_requirementId];
		var _itemTotalQuantityOnInventory = countTotalItemsInInventoryById(global.inventory, _item.itemId, itemType.trash);
		if (_requirementQuantity > _itemTotalQuantityOnInventory){
			requirementsCheck = false;
			selectedFurniture = BLANK_INVENTORY_SPACE;
			furnitureDisplay.isDisplaying = false;
			return false;
		}
	}
	requirementsCheck = true;
	return true;
}

function cleanInventoryWhenBuild(_requirements){
	for(var i = 0; i < array_length(_requirements); i++){
		var _requirementQuantity = _requirements[i].quantity;
		var _requirementId = _requirements[i].itemId;
		var _item = global.items[itemType.trash][_requirementId];
		cleanItemInInventoryById(global.inventory, _item.itemId, itemType.trash, _requirementQuantity);
	}
}

function drawCategory(_size, _category, _xPosition, _yPosition, _yPositionForComparison){
	draw_set_font(fnt_gui_default);
	var _spriteButton = spr_builder_button;
	var _sprite = {
		image: _spriteButton,
		width: sprite_get_width(_spriteButton),
		height: sprite_get_width(_spriteButton),
		border: 12
	};
	var _text = {
		stringWidth: string_width(_category.displayTitle),
		padding: 5,
		xPosition: 0,
		yPosition: 0
	};
	
	var _buttonTotalWidth = _text.stringWidth + (_text.padding * 2) + (_sprite.border * 2);
	var _buttonXScale = getScale(_size, _sprite.width);
	var _buttonWidth = _sprite.width * _buttonXScale;
	var _buttonHeight = _sprite.height;
	var _color = c_white;
	var _mouseIsOnButton = mouseIsOnRectangle(_xPosition, _yPosition, _xPosition + _buttonWidth, _yPositionForComparison + _buttonHeight);
	var _alpha = .6;
	if (_category.type != selectedCategory){
		if (_mouseIsOnButton){
			if (hoverCategory != _category.type) {
				playHoverSound();
				hoverCategory = _category.type;
			}
			drawSpriteShadow(_xPosition, _yPosition, _spriteButton, 0, 0, _buttonXScale, 1, 0, 8);
			_alpha = 1;
			gpu_set_blendmode(bm_add);
			if (mouse_check_button_released(mb_left)){
				playClickSound();
				selectedCategory = _category.type;
			}
		}
	}else {
		drawSpriteShadow(_xPosition, _yPosition, _spriteButton, 0, 0, _buttonXScale, 1, 0, 8);
		_alpha = 1;
	}
	draw_sprite_ext(_spriteButton, 0, _xPosition, _yPosition, _buttonXScale, 1, 0, _color, _alpha);
	_text.xPosition = getMiddlePoint(_xPosition, _xPosition + (_buttonWidth));
	_text.yPosition = getMiddlePoint(_yPosition, _yPosition + (_sprite.height));
	draw_set_alpha(_alpha);
	draw_text_scribble(_text.xPosition, _text.yPosition, "[fa_center][fa_middle]" + _category.displayTitle);
	draw_set_alpha(1);
	gpu_set_blendmode(bm_normal);
	return _mouseIsOnButton
}

function checkMouseOnClick(){
	if(!mouseIsOnListOfFurniture || !mouse_check_button_released(mb_left)) return;
	global.stopInteractions = true;
	if (!activeSelectingFurniture){
		listOfElementsDestinyYPosition = 50;
		arrowDirection = -1;
		activeSelectingFurniture = true;
		furnitureDisplay.isDisplaying = false;
		selectedFurniture = BLANK_INVENTORY_SPACE;
		
		return;
	}
	menuNotActiveSelectingFurnatureMenuButOnBuildMode();
}

function menuNotActiveSelectingFurnatureMenuButOnBuildMode(){
	listOfElementsDestinyYPosition = defaultListOfElementsDestinyYPosition;
	arrowDirection = 1;
	activeSelectingFurniture = false;
	alreadyPlacedSelectedFurniture = noone;
	furnitureDisplay.ignoreId = noone;
}

function mouseIsOnToggleArea(_box){
	var _mouseX = device_mouse_x_to_gui(0);
	var _mouseY = device_mouse_y_to_gui(0);
	var _bottomLimit = _box.yPosition + _box.yMarginFromBottom;
	return (_mouseX >= _box.xPosition && _mouseX <= _box.x2Position) && (_mouseY >= _box.yPosition && _mouseY <= _bottomLimit);
}

function getListOfFurnitureBox(){
	var _horizontalMargin = 200;
	var _totalArea = display_get_gui_width() - _horizontalMargin;
	var _box = {
		totalArea: _totalArea,
		xPosition: _horizontalMargin/2,
		x2Position: _horizontalMargin/2 + _totalArea,
		yPosition: listOfElementsYPosition,
		spriteWidth: sprite_get_width(spr_inventory_box),
		spriteHeight: sprite_get_height(spr_inventory_box),
		sprite: spr_inventory_box,
		yMarginFromBottom: 100,
		borderMargin: 12,
		yScale: 1,
		xScale: 1
	};
	_box.xScale = getScale(_box.x2Position - _box.xPosition, _box.spriteWidth);
	_box.yScale = getScale(display_get_gui_height(), _box.spriteHeight);
	return _box;
}

function drawIndicationArrow(_box, _xPosition){
	var _sprite = spr_arrow_indicator;
	var _yPosition = _box.yPosition + _box.yMarginFromBottom/2;
	var _yScale = arrowScale * arrowDirection;
	_xPosition += sprite_get_width(_sprite) * arrowScale;
	if (mouseIsOnListOfFurniture){
		arrowDestinyScale = 2;
	} else {
		arrowDestinyScale = 1.5;
	}
	arrowScale = lerp(arrowScale, arrowDestinyScale, .3);
	drawSpriteShadow(_xPosition, _yPosition, _sprite, 0, 0, arrowScale, _yScale);
	draw_sprite_ext(_sprite, 0, _xPosition, _yPosition, arrowScale, _yScale, 0, c_white, 1);
}

function aimFurniture(){
	global.activeBuilding = true;
	if (verifyConditionsToStopAimFurniture()){
		return;
	}
	furnitureDisplay.isDimmed = trashButtonUI.isHovering;
	drawSelectedFurnitureOrigin();
	if (mouseIsOnListOfFurniture || activeSelectingFurniture || trashButtonUI.isHovering) {
		hoveredPlacedFurniture = noone;
		return;
	}
	if (selectedFurniture == BLANK_INVENTORY_SPACE){
		if (alreadyPlacedSelectedFurniture == noone){
			handleAlreadyPlacedFurnitures();
			return;
		}
	}
	hoveredPlacedFurniture = noone;
	var _canBuild = verifyConditionsToBuildItem();
	if (_canBuild && requirementsCheck){
		handleBuildable();
		return;
	}
	handleFailedPlacement();
	handleNonBuildable();
}

function handleFailedPlacement() {
	if (!mouse_check_button_released(mb_left)) return;
	if (!furnitureDisplay.isDisplaying || !furnitureDisplay.isColiding) return;

	playFailSound();
	furnitureDisplay.addShake(5);
}

function getPlacedFurnitureUnderMouse() {
	var _underMouse = collision_point(mouse_x, mouse_y, obj_furniture, false, true);
	if (_underMouse != noone) return _underMouse;

	var _nearest = instance_nearest(mouse_x, mouse_y, obj_furniture);
	if (_nearest == noone) return noone;

	var _centerX = getMiddlePoint(_nearest.bbox_left, _nearest.bbox_right);
	var _centerY = getMiddlePoint(_nearest.bbox_top, _nearest.bbox_bottom);
	return point_distance(mouse_x, mouse_y, _centerX, _centerY) <= 48 ? _nearest : noone;
}

function handleAlreadyPlacedFurnitures(){
	if (!instance_exists(obj_furniture)) return;
	handleAlreadyPlacedHoverFurniture(getPlacedFurnitureUnderMouse());
}

function updateHoverBrackets(_instance) {
	var _isNewHover = hoveredPlacedFurniture == noone;
	var _lerpEffect = _isNewHover ? 1 : .35;

	hoverPlacedUI.x1 = lerp(hoverPlacedUI.x1, _instance.bbox_left, _lerpEffect);
	hoverPlacedUI.y1 = lerp(hoverPlacedUI.y1, _instance.bbox_top, _lerpEffect);
	hoverPlacedUI.x2 = lerp(hoverPlacedUI.x2, _instance.bbox_right, _lerpEffect);
	hoverPlacedUI.y2 = lerp(hoverPlacedUI.y2, _instance.bbox_bottom, _lerpEffect);
}

function handleAlreadyPlacedHoverFurniture(_hoverFurniture){
	if (alreadyPlacedSelectedFurniture != noone) return;

	if (_hoverFurniture == noone) {
		hoveredPlacedFurniture = noone;
		return;
	}

	updateHoverBrackets(_hoverFurniture);

	if (_hoverFurniture != hoveredPlacedFurniture) {
		playHoverSound();
		_hoverFurniture.playPlaceBounce(.12);
		hoverPlacedUI.pop = 1;
		hoverPlacedUI.padding = 14;
		hoveredPlacedFurniture = _hoverFurniture;
	}

	var _pulse = .5 + sin(current_time / 180) * .5;
	hoverPlacedUI.pop = lerp(hoverPlacedUI.pop, 0, .12);
	hoverPlacedUI.padding = lerp(hoverPlacedUI.padding, 4 + _pulse * 2, .2);

	drawFurnitureFlash(_hoverFurniture, c_white, .12 + _pulse * .1 + hoverPlacedUI.pop * .4);

	var _padding = hoverPlacedUI.padding;
	drawCornerBrackets(hoverPlacedUI.x1 - _padding, hoverPlacedUI.y1 - _padding, hoverPlacedUI.x2 + _padding, hoverPlacedUI.y2 + _padding, c_white, .9, 8, 2);

	if (mouse_check_button_released(mb_left)){
		playClickSound();
		_hoverFurniture.playPlaceBounce(-.25);
		addPlacementBurst(_hoverFurniture, c_white, 4);
		hoveredPlacedFurniture = noone;
		furnitureDisplayInfo.angle = _hoverFurniture.image_angle;
		alreadyPlacedSelectedFurniture = _hoverFurniture;
		furnitureDisplay.setFurniture(_hoverFurniture.sprite_index);
		furnitureDisplay.isDisplaying = true;
		requirementsCheck = true;
		furnitureDisplay.ignoreId = _hoverFurniture.id;
	}
	return;
}

function drawFurnitureFlash(_instance, _color, _alpha) {
	var _base = getSpriteBottomCenter(_instance.sprite_index, _instance.xPosition, _instance.yPosition, _instance.image_xscale, _instance.image_yscale, _instance.image_angle);
	drawSpriteFromBottomCenterWithFog(
		_color,
		_instance.sprite_index,
		_instance.image_index,
		_base[0],
		_base[1],
		_instance.image_xscale * (1 + _instance.placeSquash),
		_instance.image_yscale * (1 - _instance.placeSquash),
		_instance.image_angle,
		_alpha
	);
}

function drawSelectedFurnitureOrigin() {
	var _instance = alreadyPlacedSelectedFurniture;
	if (_instance == noone || !instance_exists(_instance)) return;

	var _pulse = .5 + sin(current_time / 150) * .5;
	var _color = trashButtonUI.isHovering ? #ff6b6b : #ffd166;

	drawFurnitureFlash(_instance, _color, .2 + _pulse * .2);
	drawCornerBrackets(_instance.bbox_left - 4, _instance.bbox_top - 4, _instance.bbox_right + 4, _instance.bbox_bottom + 4, _color, .5 + _pulse * .4, 8, 2);

	if (!furnitureDisplay.isDisplaying || trashButtonUI.isHovering) return;

	var _fromX = getMiddlePoint(_instance.bbox_left, _instance.bbox_right);
	var _fromY = _instance.bbox_bottom;
	var _toX = getMiddlePoint(furnitureDisplay.bbox_left, furnitureDisplay.bbox_right);
	var _toY = furnitureDisplay.bbox_bottom;
	var _distance = point_distance(_fromX, _fromY, _toX, _toY);
	var _direction = point_direction(_fromX, _fromY, _toX, _toY);
	var _dashLength = 6;
	var _dashGap = 6;
	var _offset = (current_time / 40) mod (_dashLength + _dashGap);

	draw_set_color(_color);
	draw_set_alpha(.7);
	for (var _d = _offset - _dashLength; _d < _distance; _d += _dashLength + _dashGap) {
		var _start = max(0, _d);
		var _end = min(_distance, _d + _dashLength);
		if (_end <= _start) continue;
		draw_line_width(
			_fromX + lengthdir_x(_start, _direction), _fromY + lengthdir_y(_start, _direction),
			_fromX + lengthdir_x(_end, _direction), _fromY + lengthdir_y(_end, _direction),
			2
		);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function addPlacementBurst(_instance, _color = c_white, _dustCount = 12) {
	var _x = getMiddlePoint(_instance.bbox_left, _instance.bbox_right);
	var _y = _instance.bbox_bottom;
	var _width = _instance.bbox_right - _instance.bbox_left;

	array_push(placementEffects, {
		isRing: true,
		x: _x,
		y: _y,
		radius: _width * .3,
		maxRadius: _width * .7 + 16,
		alpha: .8,
		color: _color
	});

	repeat (_dustCount) {
		var _side = choose(-1, 1);
		var _speed = random_range(1, 2.5);
		array_push(placementEffects, {
			isRing: false,
			x: _x + random_range(-_width / 2, _width / 2),
			y: _y - random_range(0, 4),
			hsp: _side * _speed,
			vsp: -random_range(.5, 2),
			size: random_range(1.5, 3.5),
			alpha: 1,
			color: merge_color(#c8b89a, _color, .3)
		});
	}
}

function drawPlacementEffects() {
	for (var i = array_length(placementEffects) - 1; i >= 0; i--) {
		var _effect = placementEffects[i];

		if (_effect.isRing) {
			_effect.radius = lerp(_effect.radius, _effect.maxRadius, .15);
			_effect.alpha -= .05;
			draw_set_alpha(max(0, _effect.alpha));
			draw_set_color(_effect.color);
			draw_ellipse(_effect.x - _effect.radius, _effect.y - _effect.radius * .4, _effect.x + _effect.radius, _effect.y + _effect.radius * .4, true);
			draw_ellipse(_effect.x - _effect.radius + 1, _effect.y - _effect.radius * .4 + 1, _effect.x + _effect.radius - 1, _effect.y + _effect.radius * .4 - 1, true);
		} else {
			_effect.x += _effect.hsp;
			_effect.y += _effect.vsp;
			_effect.vsp += .12;
			_effect.hsp *= .92;
			_effect.alpha -= .035;
			draw_set_alpha(max(0, _effect.alpha));
			draw_set_color(_effect.color);
			draw_rectangle(_effect.x, _effect.y, _effect.x + _effect.size, _effect.y + _effect.size, false);
		}

		if (_effect.alpha <= 0) array_delete(placementEffects, i, 1);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function handleBuildable(){
	if(!mouse_check_button_released(mb_left)) return;

	if (alreadyPlacedSelectedFurniture != noone){
		alreadyPlacedSelectedFurniture.x = furnitureDisplayInfo.xPosition;
		alreadyPlacedSelectedFurniture.y = furnitureDisplayInfo.yPosition;
		alreadyPlacedSelectedFurniture.resetPosition();
		alreadyPlacedSelectedFurniture.image_angle = furnitureDisplayInfo.angle;
		alreadyPlacedSelectedFurniture.playPlaceBounce(.35);
		addPlacementBurst(alreadyPlacedSelectedFurniture);
		playTickSound();
		screenShake(2);
		furnitureDisplay.isDisplaying = false;
		furnitureDisplay.ignoreId = noone;
		requirementsCheck = false;
		menuNotActiveSelectingFurnatureMenuButOnBuildMode();
		return;
	}
	
	createRoomNotifyIndicator("Mobília construída", furnitureDisplayInfo.xPosition, furnitureDisplayInfo.yPosition, c_lime);
	
	var _furnitureId = selectedFurniture.furnitureId;
	
	var _furnitureConversor = global.furnitureObjectConversor[? selectedFurniture.furnitureId];
	var _object = _furnitureConversor.object;
	
	var _furniture = instance_create_layer(furnitureDisplayInfo.xPosition, furnitureDisplayInfo.yPosition, "Instances", _object, {
		image_angle: furnitureDisplayInfo.angle,
		sprite_index: selectedFurniture.sprite
	});
	
	_furniture.setFurniture(selectedFurniture, _furnitureConversor.info);
	
	setFurnitureBaseId(_furniture);
	
	_furniture.loadSavedData(false);

	_furniture.playPlaceBounce(.45);
	addPlacementBurst(_furniture, c_lime, 16);
	playTickSound();
	screenShake(3);

	cleanInventoryWhenBuild(selectedFurniture.requirements);
	checkRequirements(selectedFurniture);
	
	obj_quest_manager.notifyEvent(QuestEvent.FurnitureCrafted, { furnitureId: _furnitureId });
}

function handleNonBuildable(){
	if (!requirementsCheck && !alreadyPlacedSelectedFurniture){
		furnitureDisplay.isDisplaying = false;
		selectedFurniture = BLANK_INVENTORY_SPACE
		selectedFurnitureIndex = {
			category: BLANK_INVENTORY_SPACE,
			index: BLANK_INVENTORY_SPACE
		};
	}
}

function hideMenu(){
	playSwiiimmmSound();
	global.stopInteractions = false;
	global.playerStopInteractions = false;
	selectedFurniture = BLANK_INVENTORY_SPACE;
	furnitureDisplay.isDisplaying = false;
	arrowDirection = 1;
	activeSelectingFurniture = false;
	listOfElementsDestinyYPosition = display_get_gui_height() + 1;
	furnitureDisplay.ignoreId = noone;
	currentState = nothing;
}

function verifyConditionsToBuildItem(){
	furnitureDisplayInfo.xPosition = furnitureDisplay.x;
	furnitureDisplayInfo.yPosition = furnitureDisplay.y;
	furnitureDisplay.image_angle = furnitureDisplayInfo.angle;
	return !furnitureDisplay.isColiding;
}

currentState = nothing;
guiCurrentState = displayNothing;