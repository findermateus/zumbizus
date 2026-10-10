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
drawerVelocity = 0;
drawerPeek = 0;
arrowFlip = 1;
menuHintAlpha = 0;
categoryIndicator = {
	x: 0,
	width: 0
};
categoryTabAnim = [];
cardAnim = [];
lastHoveredCard = -1;
hoverFurnitureControl = BLANK_INVENTORY_SPACE;
hoveredCardRect = {
	x: 0,
	y: 0,
	size: 0
};
furnitureDetailsUI = {
	alpha: 0,
	slide: 0,
	furnitureIndex: -1,
	category: -1
};

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
	drawerVelocity = 0;
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
	updateDrawerSpring();
	drawMenuBackdrop();
	var _box = getListOfFurnitureBox();
	mouseIsOnListOfFurniture = mouseIsOnToggleArea(_box);
	drawerPeek = lerp(drawerPeek, mouseIsOnListOfFurniture && !activeSelectingFurniture ? 8 : 0, .2);
	_box.yPosition -= drawerPeek;
	draw_sprite_ext(_box.sprite, 0, _box.xPosition, _box.yPosition, _box.xScale, _box.yScale, 0, c_white, 1);
	checkMouseOnClick();
	var _arrowXPosition = drawMenuTitle(_box);
	var _hintXPosition = drawIndicationArrow(_box, _arrowXPosition);
	drawMenuHint(_box, _hintXPosition);
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

function updateDrawerSpring() {
	drawerVelocity += (listOfElementsDestinyYPosition - listOfElementsYPosition) * .1;
	drawerVelocity *= .7;
	listOfElementsYPosition += drawerVelocity;
}

function getDrawerOpenness() {
	var _openY = 50;
	return clamp((defaultListOfElementsDestinyYPosition - listOfElementsYPosition) / (defaultListOfElementsDestinyYPosition - _openY), 0, 1);
}

function drawMenuBackdrop() {
	var _alpha = getDrawerOpenness() * .45;
	if (_alpha <= .01) return;

	draw_set_color(c_black);
	draw_set_alpha(_alpha);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function resetCardAnimations() {
	cardAnim = [];
}

function resetMenuAnimations() {
	categoryTabAnim = [];
	resetCardAnimations();
	furnitureDetailsUI.alpha = 0;
}

function getCardAnim(_index) {
	while (array_length(cardAnim) <= _index) {
		array_push(cardAnim, {
			scale: 0,
			velocity: 0,
			lift: 0,
			hover: 0,
			shake: 0,
			delay: array_length(cardAnim) * 3
		});
	}
	return cardAnim[_index];
}

function getCategoryTitle(_type) {
	for (var i = 0; i < array_length(global.furnitureCategories); i++) {
		if (global.furnitureCategories[i].type == _type) return global.furnitureCategories[i].displayTitle;
	}
	return "";
}

function canAffordFurniture(_furniture) {
	for (var i = 0; i < array_length(_furniture.requirements); i++) {
		var _requirement = _furniture.requirements[i];
		if (countTotalItemsInInventoryById(global.inventory, _requirement.itemId, _requirement.type) < _requirement.quantity) return false;
	}
	return true;
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

function drawMenuHint(_box, _xPosition) {
	menuHintAlpha = lerp(menuHintAlpha, mouseIsOnListOfFurniture, .15);
	if (menuHintAlpha < .02) return;

	var _text = activeSelectingFurniture ? "Clique para fechar" : "Clique para ver as mobílias";
	var _x = _xPosition + 16 + (1 - menuHintAlpha) * 12;
	var _y = _box.yPosition + _box.yMarginFromBottom / 2;

	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	drawTextShadow(_x, _y, _text, menuHintAlpha);
	draw_set_alpha(menuHintAlpha * .85);
	draw_text(_x, _y, _text);
	draw_set_alpha(1);
	draw_set_valign(fa_top);
}

function drawFurnitureMenu(_box){
	if (!activeSelectingFurniture) {
		furnitureDetailsUI.alpha = 0;
		return;
	}
	var _margin = 20;
	var _area = {
		xPosition: _box.xPosition + _box.borderMargin + _margin,
		x2Position: _box.x2Position - _box.borderMargin - _margin,
		yPosition: _box.yPosition + _box.yMarginFromBottom
	};
	var _cardsYPosition = drawCategoryTabs(_area);
	drawFurnitureCards(_area, _cardsYPosition);
	drawFurnitureDetails();
}

function canApplyHoverUiEffects(){
	return abs(listOfElementsYPosition - listOfElementsDestinyYPosition) < 10;
}

function selectCategory(_type) {
	playClickSound();
	selectedCategory = _type;
	hoverFurniture = 0;
	lastHoveredCard = -1;
	furnitureDetailsUI.alpha = 0;
	resetCardAnimations();
}

function drawCategoryTabs(_area) {
	var _categories = global.furnitureCategories;
	var _count = array_length(_categories);
	var _tabHeight = 64;
	var _gap = 16;
	var _iconSize = 36;
	var _padding = 22;

	draw_set_font(fnt_gui_default);

	var _widths = [];
	var _totalWidth = _gap * (_count - 1);
	for (var i = 0; i < _count; i++) {
		var _itemCount = array_length(global.furniture[_categories[i].type]);
		_widths[i] = _padding * 2 + _iconSize + 10 + string_width(_categories[i].displayTitle) + 10 + string_width(string(_itemCount));
		_totalWidth += _widths[i];
	}

	while (array_length(categoryTabAnim) < _count) {
		array_push(categoryTabAnim, { alpha: 0, yOffset: -20, scale: 1, lift: 0 });
	}

	var _x = getMiddlePoint(_area.xPosition, _area.x2Position) - _totalWidth / 2;
	var _y = _area.yPosition;
	var _canHover = canApplyHoverUiEffects();
	var _openness = getDrawerOpenness();
	var _hoverAny = false;
	var _indicatorX = categoryIndicator.x;
	var _indicatorWidth = categoryIndicator.width;
	var _minAlpha = 1;

	for (var i = 0; i < _count; i++) {
		var _category = _categories[i];
		var _anim = categoryTabAnim[i];
		var _width = _widths[i];
		var _itemCount = array_length(global.furniture[_category.type]);
		var _isSelected = _category.type == selectedCategory;

		var _canStart = i == 0 ? _openness > .6 : categoryTabAnim[i - 1].alpha > .4;
		if (_canStart) {
			_anim.alpha = lerp(_anim.alpha, 1, .2);
			_anim.yOffset = lerp(_anim.yOffset, 0, .2);
		}
		_minAlpha = min(_minAlpha, _anim.alpha);

		var _isHover = _canHover && mouseIsOnRectangle(_x, _y - 6, _x + _width, _y + _tabHeight);
		if (_isHover) {
			_hoverAny = true;
			if (hoverCategory != _category.type) {
				playHoverSound();
				hoverCategory = _category.type;
			}
			if (mouse_check_button_released(mb_left) && !_isSelected) {
				selectCategory(_category.type);
				_isSelected = true;
			}
		}

		_anim.lift = lerp(_anim.lift, _isHover ? 6 : 0, .25);
		_anim.scale = lerp(_anim.scale, _isSelected ? 1.08 : (_isHover ? 1.05 : 1), .2);

		var _scale = _anim.scale;
		var _drawWidth = _width * _scale;
		var _drawHeight = _tabHeight * _scale;
		var _drawX = _x + (_width - _drawWidth) / 2;
		var _drawY = _y + (_tabHeight - _drawHeight) / 2 - _anim.lift + _anim.yOffset;
		var _centerY = _drawY + _drawHeight / 2;
		var _isLit = _isSelected || _isHover;

		draw_set_alpha(_anim.alpha);
		drawSpriteShadowStretched(_drawX, _drawY, spr_builder_furniture_box, _isLit, 0, _drawWidth, _drawHeight, 0, 4 + _anim.lift * .5);
		draw_sprite_stretched_ext(spr_builder_furniture_box, _isLit, _drawX, _drawY, _drawWidth, _drawHeight, _isSelected ? c_white : #c8c8c8, _anim.alpha);

		var _icon = _itemCount > 0 ? global.furniture[_category.type][0].icon : spr_builder_icon;
		var _contentX = _drawX + _padding * _scale;
		var _iconAngle = _isHover ? sin(current_time / 90) * 6 : 0;
		drawSpriteFitCentered(_icon, _contentX + _iconSize * _scale / 2, _centerY, _iconSize * _scale, 1, _iconAngle, c_white, _anim.alpha);

		var _textX = _contentX + (_iconSize + 10) * _scale;
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		drawTextShadow(_textX, _centerY, _category.displayTitle, _anim.alpha, 3, _scale);
		draw_set_color(_isSelected ? c_white : #d0d0d0);
		draw_text_transformed(_textX, _centerY, _category.displayTitle, _scale, _scale, 0);

		var _countText = string(_itemCount);
		var _countX = _textX + (string_width(_category.displayTitle) + 10) * _scale;
		drawTextShadow(_countX, _centerY, _countText, _anim.alpha, 3, _scale);
		draw_set_color(#a0a0a0);
		draw_text_transformed(_countX, _centerY, _countText, _scale, _scale, 0);
		draw_set_color(c_white);

		if (_isSelected) {
			_indicatorX = _x;
			_indicatorWidth = _width;
		}

		_x += _width + _gap;
	}

	if (!_hoverAny) hoverCategory = -1;

	if (categoryIndicator.width == 0) {
		categoryIndicator.x = _indicatorX;
		categoryIndicator.width = _indicatorWidth;
	}
	categoryIndicator.x = lerp(categoryIndicator.x, _indicatorX, .25);
	categoryIndicator.width = lerp(categoryIndicator.width, _indicatorWidth, .25);

	var _indicatorY = _y + _tabHeight + 12;
	draw_set_color(#ffd166);
	draw_set_alpha(.3 * _minAlpha);
	draw_rectangle(categoryIndicator.x + 8, _indicatorY - 2, categoryIndicator.x + categoryIndicator.width - 8, _indicatorY + 6, false);
	draw_set_alpha(_minAlpha);
	draw_rectangle(categoryIndicator.x + 12, _indicatorY, categoryIndicator.x + categoryIndicator.width - 12, _indicatorY + 3, false);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	return _y + _tabHeight + 44;
}

function drawFurnitureCards(_area, _yPosition) {
	var _furnitures = global.furniture[selectedCategory];
	var _count = array_length(_furnitures);
	hoverFurnitureControl = BLANK_INVENTORY_SPACE;

	if (_count == 0) {
		drawEmptyCategoryMessage(_area, _yPosition);
		handleHoverIndicator(0);
		return;
	}

	var _cardSize = 200;
	var _gapX = 28;
	var _gapY = 28;
	var _areaWidth = _area.x2Position - _area.xPosition;
	var _columns = clamp(floor((_areaWidth + _gapX) / (_cardSize + _gapX)), 1, _count);
	var _gridWidth = _columns * _cardSize + (_columns - 1) * _gapX;
	var _startX = getMiddlePoint(_area.xPosition, _area.x2Position) - _gridWidth / 2;

	for (var i = 0; i < _count; i++) {
		var _column = i mod _columns;
		var _row = i div _columns;
		drawFurnitureCard(_furnitures[i], i, _startX + _column * (_cardSize + _gapX), _yPosition + _row * (_cardSize + _gapY), _cardSize);
	}

	handleHoverIndicator(_cardSize);
}

function drawEmptyCategoryMessage(_area, _yPosition) {
	var _text = "Nenhuma mobília nesta categoria ainda";
	var _alpha = .55 + sin(current_time / 300) * .2;
	var _x = getMiddlePoint(_area.xPosition, _area.x2Position);
	var _y = _yPosition + 80;

	draw_set_font(fnt_gui_title);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	drawTextShadow(_x, _y, _text, _alpha);
	draw_set_alpha(_alpha);
	draw_text(_x, _y, _text);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
}

function drawFurnitureCard(_furniture, _index, _x, _y, _size) {
	var _anim = getCardAnim(_index);

	if (_anim.delay > 0) {
		_anim.delay--;
		return;
	}
	_anim.velocity += (1 - _anim.scale) * .22;
	_anim.velocity *= .68;
	_anim.scale += _anim.velocity;

	var _canAfford = canAffordFurniture(_furniture);
	var _isHover = canApplyHoverUiEffects() && mouseIsOnRectangle(_x, _y - 8, _x + _size, _y + _size);

	if (_isHover) {
		if (lastHoveredCard != _index) playHoverSound();
		hoverFurnitureControl = _index;
		hoveredCardRect.x = _x;
		hoveredCardRect.y = _y - _anim.lift;
		hoveredCardRect.size = _size;
		hoverIndicatorUIData.destinyX = _x;
		hoverIndicatorUIData.destinyY = _y - _anim.lift;
		handleSelectionFurniture(_index);
	}

	_anim.lift = lerp(_anim.lift, _isHover ? 8 : 0, .25);
	_anim.hover = lerp(_anim.hover, _isHover, .2);
	_anim.shake = lerp(_anim.shake, 0, .2);

	var _shakeX = _anim.shake > .2 ? random_range(-_anim.shake, _anim.shake) : 0;
	var _drawSize = _size * _anim.scale * (1 + _anim.hover * .04);
	var _centerX = _x + _size / 2 + _shakeX;
	var _centerY = _y + _size / 2 - _anim.lift;
	var _boxX = _centerX - _drawSize / 2;
	var _boxY = _centerY - _drawSize / 2;
	var _alpha = clamp(_anim.scale, 0, 1);

	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_boxX, _boxY, spr_builder_furniture_box, _isHover, 0, _drawSize, _drawSize, 0, 4 + _anim.lift);
	draw_sprite_stretched_ext(spr_builder_furniture_box, _isHover, _boxX, _boxY, _drawSize, _drawSize, _canAfford ? c_white : #9a9a9a, _alpha);

	var _iconAngle = _anim.hover * sin(current_time / 120) * 5;
	drawSpriteFitCentered(
		_furniture.icon,
		_centerX,
		_centerY,
		_drawSize * .75,
		1 + _anim.hover * .1,
		_iconAngle,
		_canAfford ? c_white : c_gray,
		_alpha * (_canAfford ? 1 : .55)
	);

	if (_anim.hover > .05) {
		var _padding = 6 + (1 - _anim.hover) * 10 + sin(current_time / 180) * 2;
		drawCornerBrackets(_boxX - _padding, _boxY - _padding, _boxX + _drawSize + _padding, _boxY + _drawSize + _padding, _canAfford ? c_white : #ff6b6b, _anim.hover * .9 * _alpha, 10, 2);
	}

	draw_set_alpha(1);
}

function handleHoverIndicator(_size){
	if (hoverFurnitureControl == BLANK_INVENTORY_SPACE) {
		hoverFurniture = 0;
		lastHoveredCard = -1;
		hoverIndicatorUIData.destinyAlpha = 0;
	} else {
		hoverFurniture = hoverFurnitureControl;
		lastHoveredCard = hoverFurnitureControl;
		hoverIndicatorUIData.destinyAlpha = 1;
	}
	if (_size > 0){
		drawHoverIndicator(_size);
	}
}

function drawHoverIndicator(_size){
	var _lerpEffect = .2;
	hoverIndicatorUIData.x = lerp(hoverIndicatorUIData.x, hoverIndicatorUIData.destinyX, _lerpEffect);
	hoverIndicatorUIData.y = lerp(hoverIndicatorUIData.y, hoverIndicatorUIData.destinyY, _lerpEffect);
	hoverIndicatorUIData.alpha = lerp(hoverIndicatorUIData.alpha, hoverIndicatorUIData.destinyAlpha, _lerpEffect);
	if (hoverIndicatorUIData.failEffect != 0) {
		var _x = random_range(-hoverIndicatorUIData.failEffect, hoverIndicatorUIData.failEffect);
		var _y = random_range(-hoverIndicatorUIData.failEffect, hoverIndicatorUIData.failEffect);
		hoverIndicatorUIData.x += _x * 5;
		hoverIndicatorUIData.y += _y * 5;
		hoverIndicatorUIData.failEffect = lerp(hoverIndicatorUIData.failEffect, 0, .2);
	}
	draw_sprite_stretched_ext(spr_hover_indicator, 0, hoverIndicatorUIData.x, hoverIndicatorUIData.y, _size, _size, c_white, hoverIndicatorUIData.alpha);
}

function drawFurnitureDetails() {
	var _ui = furnitureDetailsUI;
	var _furnitures = global.furniture[selectedCategory];
	var _isHovering = hoverFurnitureControl != BLANK_INVENTORY_SPACE;

	if (_isHovering && (_ui.furnitureIndex != hoverFurnitureControl || _ui.category != selectedCategory)) {
		_ui.furnitureIndex = hoverFurnitureControl;
		_ui.category = selectedCategory;
		_ui.slide = 14;
		_ui.alpha = min(_ui.alpha, .4);
	}

	_ui.alpha = lerp(_ui.alpha, _isHovering, .2);
	_ui.slide = lerp(_ui.slide, 0, .2);

	if (_ui.alpha < .02) return;
	if (_ui.category != selectedCategory || _ui.furnitureIndex < 0 || _ui.furnitureIndex >= array_length(_furnitures)) return;

	var _furniture = _furnitures[_ui.furnitureIndex];
	var _canAfford = canAffordFurniture(_furniture);
	var _requirements = _furniture.requirements;
	var _padding = 20;
	var _requirementSize = 56;
	var _requirementGap = 6;
	var _requirementBorder = 12;

	draw_set_font(fnt_gui_title);
	var _titleWidth = string_width(_furniture.title);
	var _titleHeight = string_height(_furniture.title);

	draw_set_font(fnt_gui_default);
	var _categoryText = "Categoria: " + getCategoryTitle(selectedCategory);
	var _footerText = _canAfford ? "Clique para construir" : "Materiais insuficientes";
	var _lineHeight = string_height("A");
	var _contentWidth = max(_titleWidth, string_width(_categoryText), string_width(_footerText));

	var _requirementData = [];
	for (var i = 0; i < array_length(_requirements); i++) {
		var _requirement = _requirements[i];
		var _item = global.items[_requirement.type][_requirement.itemId];
		var _current = getItemQuantityInInventory(global.inventory, _requirement.itemId, _requirement.type);
		var _text = string(_current) + "/" + string(_requirement.quantity) + " " + _item.name;
		_contentWidth = max(_contentWidth, _requirementSize + _requirementBorder * 2 + string_width(_text));
		array_push(_requirementData, { item: _item, current: _current, quantity: _requirement.quantity });
	}

	var _width = _contentWidth + _padding * 2;
	var _height = _padding + _titleHeight + 4 + _lineHeight + 14 + array_length(_requirementData) * (_requirementSize + _requirementGap) + 8 + _lineHeight + _padding;

	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	var _rightX = hoveredCardRect.x + hoveredCardRect.size + 20;
	var _goLeft = _rightX + _width > _guiWidth - 16;
	var _destinyX = clamp(_goLeft ? hoveredCardRect.x - 20 - _width : _rightX, 16, _guiWidth - _width - 16);
	var _destinyY = clamp(hoveredCardRect.y, 16, _guiHeight - _height - 16);

	if (hoverFurnitureForUI.x == 0) {
		hoverFurnitureForUI.x = _destinyX;
		hoverFurnitureForUI.y = _destinyY;
	}
	hoverFurnitureForUI.x = lerp(hoverFurnitureForUI.x, _destinyX, .25);
	hoverFurnitureForUI.y = lerp(hoverFurnitureForUI.y, _destinyY, .25);

	var _alpha = _ui.alpha;
	var _x = hoverFurnitureForUI.x + (_goLeft ? -_ui.slide : _ui.slide);
	var _y = hoverFurnitureForUI.y;

	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_x, _y, spr_inventory_box, 0, 0, _width, _height);
	draw_sprite_stretched_ext(spr_inventory_box, 0, _x, _y, _width, _height, c_white, _alpha);

	var _contentX = _x + _padding;
	var _contentY = _y + _padding;
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	draw_set_font(fnt_gui_title);
	drawTextShadow(_contentX, _contentY, _furniture.title, _alpha);
	draw_set_color(c_white);
	draw_text(_contentX, _contentY, _furniture.title);
	_contentY += _titleHeight + 4;

	draw_set_font(fnt_gui_default);
	draw_set_color(#b8b8b8);
	draw_text(_contentX, _contentY, _categoryText);
	draw_set_color(c_white);
	_contentY += _lineHeight + 14;

	for (var i = 0; i < array_length(_requirementData); i++) {
		var _data = _requirementData[i];
		drawRequirement(_data.item.sprite, _data.item.name, _requirementSize, _contentX, _contentY, _data.current, _data.quantity, _alpha);
		_contentY += _requirementSize + _requirementGap;
	}
	_contentY += 8;

	var _pulse = .75 + sin(current_time / 200) * .25;
	drawTextShadow(_contentX, _contentY, _footerText, _alpha);
	draw_set_color(_canAfford ? #6fdc6f : #ff6b6b);
	draw_set_alpha(_alpha * (_canAfford ? _pulse : 1));
	draw_text(_contentX, _contentY, _footerText);

	draw_set_alpha(1);
	draw_set_color(c_white);
}

function handleSelectionFurniture(_index){
	if (!mouse_check_button_released(mb_left)) return;
	var _furniture = global.furniture[selectedCategory][_index];
	if (!checkRequirements(_furniture)) {
		playFailSound();
		hoverIndicatorUIData.failEffect = 5;
		getCardAnim(_index).shake = 6;
		return false;
	}
	playClickSound();
	getCardAnim(_index).velocity = .25;
	menuNotActiveSelectingFurnatureMenuButOnBuildMode();
	selectedFurnitureIndex.category = selectedFurniture;
	selectedFurnitureIndex.index = _index;
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

function checkMouseOnClick(){
	if(!mouseIsOnListOfFurniture || !mouse_check_button_released(mb_left)) return;
	global.stopInteractions = true;
	playSwiiimmmSound();
	if (!activeSelectingFurniture){
		listOfElementsDestinyYPosition = 50;
		arrowDirection = -1;
		activeSelectingFurniture = true;
		furnitureDisplay.isDisplaying = false;
		selectedFurniture = BLANK_INVENTORY_SPACE;
		resetMenuAnimations();

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
	arrowFlip = lerp(arrowFlip, arrowDirection, .25);
	arrowDestinyScale = mouseIsOnListOfFurniture ? 2 : 1.5;
	arrowScale = lerp(arrowScale, arrowDestinyScale, .3);

	var _bobbing = arrowDirection == 1 ? sin(current_time / 200) * 3 : 0;
	var _yPosition = _box.yPosition + _box.yMarginFromBottom/2 - _bobbing;
	var _yScale = arrowScale * arrowFlip;
	_xPosition += sprite_get_width(_sprite) * arrowScale;

	drawSpriteShadow(_xPosition, _yPosition, _sprite, 0, 0, arrowScale, _yScale);
	draw_sprite_ext(_sprite, 0, _xPosition, _yPosition, arrowScale, _yScale, 0, c_white, 1);

	return _xPosition + sprite_get_width(_sprite) * arrowScale / 2;
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