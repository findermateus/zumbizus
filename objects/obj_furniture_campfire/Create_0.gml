event_inherited();
actionDescription = "Cozinhar";
furnitureCategory = furnitureCategories.creation;
furnitureId = furnitureIds.campfire;
furnitureIluminator = noone;
isUsing = false;
allowedRecipees = ds_map_create();
cookingSlots = 6;
furnitureData = new CampfireData(cookingSlots, objectId);
holdingItem = global.blankInventorySpace;
hoverItem = global.blankInventorySpace;
recipe = undefined;
audioEmitter = audio_emitter_create();
playingSound = -1;
particleEmitter = undefined;
spriteToDrawShadow = spr_circle;
hoverUiValues = {
	x: 0,
	y: 0,
	desX: 0,
	desY: 0,
	alpha: 0,
	desAlpha: 0,
	failEffect: 0
};

workerList = [];

loadFurnitureByDefaultId();

setShadow(sprite_index, image_index, 1);

{
    var _cookingRecipees = global.craftingItems[craftingCategories.cooking];
    var _type = itemType.consumables;

    var _index = array_find_index(_cookingRecipees, function (_recipee) {
        return _recipee.id == consumableItems.cooked_meat_1;
    });
    
	allowedRecipees[? string(_type) + "_" + string(consumableItems.raw_meat_1)] = _cookingRecipees[_index];
    
    _index = array_find_index(_cookingRecipees, function (_recipee) {
        return _recipee.id == consumableItems.cooked_meat_2;
    });
    
	allowedRecipees[? string(_type) + "_" + string(consumableItems.raw_meat_2)] = _cookingRecipees[_index];
    
    _index = array_find_index(_cookingRecipees, function (_recipee) {
        return _recipee.id == consumableItems.watter_bottle;
    });
    
	allowedRecipees[? string(_type) + "_" + string(consumableItems.dirt_water)] = _cookingRecipees[_index];
}

function loadSavedData(_data = false) {
	var _savedData = getFurnitureData(furnitureId, objectId);
	
	if (is_undefined(_savedData) || _savedData == false) {
		var _setupData = _data == false ? new CampfireData(cookingSlots, objectId) : loadSlots(_data);
		setFurnitureData(furnitureId, objectId, _setupData);
	}
	
	var _fData = getFurnitureData(furnitureId, objectId);
	setUpFurnitureData(_fData);
}

function setUpFurnitureData(_fData) {
	furnitureData = _fData;
	for (var i = 0; i < array_length(furnitureData.slotData); i ++) {
	
	}
}

function loadSlots(_data) {
	var _productiveData = _data.productiveData;
	var _setupData = new CampfireData(cookingSlots, objectId);
	if (_productiveData == false || _productiveData == undefined) return _setupData;
	var _cookingSlots = _productiveData.slotData;
	for (var i = 0; i < array_length(_cookingSlots); i ++) {
		// @type {CampfireSlot}
		var _slot = _cookingSlots[i];
		if (_slot == undefined) continue;
		var _slotData = _setupData.slotData[i];
		_slotData.loadFromSave(
			_slot.itemId,
			_slot.type,
			_slot.itemQuantity,
			_slot.resultId,
			_slot.resultType,
			_slot.resultQuantity
		);
	}
	return _setupData;
}

#macro FOOD_BLOCK_SIZE 120
#macro HORIZONTAL_MARGIN 150
#macro TOP_MARGIN 100
#macro MODAL_HEIGHT display_get_gui_height() * .25
#macro BORDER_THICKNESS 14

guiModal = {
	x: HORIZONTAL_MARGIN,
	y: display_get_gui_height() + 1,
	destinyX: HORIZONTAL_MARGIN,
	destinyY: display_get_gui_height() + 1
}

guiModalOpen = {
	destinyX: HORIZONTAL_MARGIN,
	destinyY: display_get_gui_height() - MODAL_HEIGHT
}

guiModalClosed = {
	destinyX: HORIZONTAL_MARGIN,
	destinyY: display_get_gui_height() + 1,
}

activationMethod = function () {
	playClickSound();
	playSwiiimmmSound();
	activateFurniture();
}

function activateFurniture() {
	obj_camera.setTargetWithZoom(id);
	setVariablesOpenFurniture();
	openMenu();
	defineModalValues(guiModalOpen);
	isUsing = true;
    
    modal_scale = 0.8; 
}

function hideModal(){
	isUsing = false;
	currentState = innactive;
	playSwiiimmmSound();
	closeMenu();
	if (!global.activeInventory) {
		obj_camera.setDefaultScale();
		obj_camera.target = obj_player;
	}
	defineModalValues(guiModalClosed);
	setVariablesCloseFurniture();
    
    modal_scale = 0.8;
}

function defineModalValues(_pattern = {
	destinyX: 0,
	destinyY: 0,
}) {
	guiModal.destinyX = _pattern.destinyX;
	guiModal.destinyY = _pattern.destinyY;
}

function checkConditionsToClose(){
	if (global.activeBuilding || global.activeInventory || global.currentBaseMenuOption != -1){ 
		return true;
	}
	var _player = checkPlayerExistence();
	if (!_player) return true;
	if(checkObstacules(_player) && checkDistance(_player)) return false;
	closeMenu();
	return true;
}

function loadModalValues() {
	var _lerpEffect = .1;
	guiModal.x = lerp(guiModal.x, guiModal.destinyX, _lerpEffect);
	guiModal.y = lerp(guiModal.y, guiModal.destinyY, _lerpEffect);
}

function getRecipe(_itemId, _itemType) {
    if (_itemId == global.blankInventorySpace) return undefined;

    var _key = string(_itemType) + "_" + string(_itemId);
    
    if (ds_map_exists(allowedRecipees, _key)) {
        return allowedRecipees[? _key];
    }
    
    return undefined;
}

modal_scale = 0.8;
ready_pulse = 0;
slot_visual_scales = array_create(cookingSlots, 1);
slot_jitter = array_create(cookingSlots, 0);

function drawFurnitureGUI() {
	if (guiModalClosed.destinyY - guiModal.y < 10 && !isUsing) return;
	var _mouseIsOnModal = drawCookingModal();
	if (!isUsing) return;

	var _handleInventory = function (_mouseIsOnModal, _object) {
		_object.drawPersonalizedInventory(HORIZONTAL_MARGIN, TOP_MARGIN, global.inventory, _mouseIsOnModal);
		holdingItem = _object.activeHoldingItem;
		hoverItem = _object.activeHoverItem;
		
		if (holdingItem == global.blankInventorySpace) {
			resetInventoryValues();
			return;
		}
		
		recipe = getRecipe(holdingItem.itemId, holdingItem.type);
	}
	drawContentsInsideModal();
	with obj_inventory {
		_handleInventory(_mouseIsOnModal, self);
	}
}

function resetInventoryValues() {
	recipe = undefined;
	holdingItem = global.blankInventorySpace;
}

function drawCookingModal() {
    modal_scale = lerp(modal_scale, 1, 0.15);
    var _uiAlpha = modal_scale > 0.9 ? 1 : (modal_scale - 0.8) * 5;

	var _modalWidth = (display_get_gui_width() - HORIZONTAL_MARGIN * 2) * modal_scale;
    var _drawHeight = MODAL_HEIGHT * modal_scale;
    
	var _modalX = guiModal.x + ((display_get_gui_width() - HORIZONTAL_MARGIN * 2) - _modalWidth) / 2;
    var _modalY = guiModal.y + (MODAL_HEIGHT - _drawHeight) / 2;
    
	var _sprite = spr_campfire_modal_background;
    
	drawHeader(_modalX + BORDER_THICKNESS, _modalY, _modalWidth);
	draw_sprite_stretched_ext(_sprite, 0, _modalX, _modalY, _modalWidth, _drawHeight, c_white, _uiAlpha);
    
	return mouseIsOnRectangle(_modalX, _modalY, _modalX + _modalWidth, _modalY + _drawHeight);
}

function drawContentsInsideModal() {
	var startX = guiModal.x + BORDER_THICKNESS;
    var startY = guiModal.y + BORDER_THICKNESS;
    var _modalWidth = display_get_gui_width() - HORIZONTAL_MARGIN * 2 - BORDER_THICKNESS * 2;
    var slotSize = FOOD_BLOCK_SIZE;
	var _campfire = furnitureData;
	var _slots = _campfire.slotData;
    var slotsQuantity = array_length(_slots);
    var totalWidthOfSlots = slotsQuantity * slotSize;
    var remainingSpace = _modalWidth - totalWidthOfSlots;
    var gap = remainingSpace / slotsQuantity;
    var offsetStartX = startX + (gap / 2);
	var _y = getMiddlePoint(startY, display_get_gui_height()) - slotSize / 2;
	
	hoverUiValues.desAlpha = 0;
    static uiValues = getSlotsUiValues(cookingSlots);
	var _lastOneIsFull = false;
	for (var i = 0; i < slotsQuantity; i++) {
		var _x = floor(offsetStartX + i * (slotSize + gap));
		var _ui = uiValues[i];
		var _slot = _slots[i];
		var _item = _slot.getItem();
		
		_ui.desX = _x;
		_ui.desY = _y;

		var _mouseOver = mouseIsOnRectangle(_x, _y, _x + slotSize, _y + slotSize);
		var _holdingItem = (holdingItem != global.blankInventorySpace);
		var _mouseIsOnSlotAndHoldingItem = _mouseOver && _holdingItem;
		var _validRecipe = (recipe != undefined);
		
		handleUiValues(_ui);
		drawSlot(_ui.x, _ui.y, slotSize, _item, _slot, _mouseIsOnSlotAndHoldingItem, _validRecipe);
		
		var _itemToTakeConsideration = holdingItem != global.blankInventorySpace ? holdingItem : hoverItem;
		
		if (_itemToTakeConsideration != global.blankInventorySpace) {
			drawCompatibleItemIndicator(_itemToTakeConsideration, _item, _ui.x, _ui.y, slotSize);
		}
		
		if (_mouseIsOnSlotAndHoldingItem) {
			var _valid = _validRecipe && (_item == global.blankInventorySpace || _item.itemId == holdingItem.itemId);
			if (_valid) {
				hoverUiValues.desAlpha = 1;
				hoverUiValues.desX = _ui.x;
				hoverUiValues.desY = _ui.y;
			}
			_ui.desY += _valid ? -20 : 10;
		}
		
		if (_mouseOver && !_holdingItem && _item != global.blankInventorySpace) {
			hoverUiValues.desAlpha = 1;
			hoverUiValues.desX = _ui.x;
			hoverUiValues.desY = _ui.y;
			
			_ui.desY += -20;
		
		if (mouse_check_button_pressed(mb_left)) {
				handleClickOnItemThatIsBeingCooked(_slot);
			}
		}
		
		if (_validRecipe && _mouseIsOnSlotAndHoldingItem) {
			if (_slot.canAddItem(holdingItem.itemId, holdingItem.type)) {
				handleItemCanBeAdded(_slot);
			}
		}
	}
	handleHoverUi();
}


function drawCompatibleItemIndicator(_selectedItem, _itemInGrid, _x, _y, _size) {
	if (_itemInGrid != global.blankInventorySpace){ 
		if (_selectedItem.itemId != _itemInGrid.itemId || _selectedItem.type != _itemInGrid.type) {
			return;
		}
	}
	var _recipe = getRecipe(_selectedItem.itemId, _selectedItem.type);
	
	if (_recipe == undefined) return;
	
	var _sprite = spr_hover_indicator;
	draw_sprite_stretched(_sprite, 0, _x, _y, _size, _size);
}

function drawHeader(_x, _y, _modalWidth) {
    static _yPos = _y;
	var _height = 120;
	var _sprite = spr_campfire_modal_background;
	_yPos = guiModal.destinyY == guiModalClosed.destinyY ? lerp(_yPos, display_get_gui_height() + _height, .1) : lerp(_yPos, _y, .1);
    if (objectId != -1) {
		var _workerSize = _height - BORDER_THICKNESS;
		var _workerQuantity = array_length(workerList); 
		var _width = _workerSize * _workerQuantity + 15 * _workerQuantity + BORDER_THICKNESS;
		draw_sprite_stretched(_sprite, 1, _x, _yPos - _height, _width, _height);
		drawWorkerList(_x + BORDER_THICKNESS, _x + _width - BORDER_THICKNESS, _yPos - _height + BORDER_THICKNESS, _workerSize, workerList);
	}
	drawCloseButton(_x + _modalWidth - BORDER_THICKNESS, _yPos, 150, _height);
}

function drawWorkerList(_x, _x2, _y, _size, _workerList) {
	var _count = array_length(_workerList);
	if (_count <= 0) return;

	var _totalWidth = _x2 - _x;
	var _gap = (_count > 1) ? (_totalWidth - (_size * _count)) / (_count - 1) : 0;
	var _posX = _x;

	for (var i = 0; i < array_length(_workerList); i++) {
		var _worker = _workerList[i];
		if (_worker == -1) {
			drawEmptyNpcInsideBlock(_posX, _y, _size, 1);
			_posX += _size + _gap;
			continue;	
		}

		var _npc = global.npcList[_worker.id];
		drawNpcInsideBlock(_posX, _y, _size, _npc.hair, _npc.skinColor, _npc.gender, 1);

		_posX += _size + _gap;
	}
}

function drawCloseButton(_x2, _yPos, _width, _height) {
	var _x = _x2 - _width;
    draw_sprite_stretched(spr_campfire_modal_background, 1, _x, _yPos - _height, _width, _height);
	
	var _buttonExpectedSize = _height * .7;
    var _buttonSprite = spr_campfire_close;
    var _buttonX = getMiddlePoint(_x, _x + 150) - _buttonExpectedSize / 2;

    var _buttonY = getMiddlePoint(_yPos - _height + BORDER_THICKNESS / 2, _yPos) - _buttonExpectedSize / 2;
	var _spriteIndex = mouseIsOnRectangle(_buttonX, _buttonY, _buttonX + _buttonExpectedSize, _buttonY + _buttonExpectedSize);
    var _drawY = _buttonY - (_spriteIndex * 2);
    
	draw_sprite_stretched(_buttonSprite, _spriteIndex, _buttonX, _drawY, _buttonExpectedSize, _buttonExpectedSize);
    
	if (_spriteIndex && mouse_check_button_pressed(mb_left)) {
        hideModal();
    }
	return _buttonX + _buttonExpectedSize + BORDER_THICKNESS * 3;
}

function handleClickOnItemThatIsBeingCooked(_slot){
	var _item = _slot.getCurrentItem();
	var _result = addItemToGrid(global.inventory, _item);
	if (_result == true) {
		_slot.removeItem();
		createIndicatorModal(_item, _item.quantity);
		audio_play_sound(_item.sound, 0, false);
		return;
	}
	setFailEffect();
}

function setFailEffect(_force = 3) {
	hoverUiValues.failEffect = _force;
	playFailSound();
}

function handleUiValues(_ui) {
	var _lerpEffect = .1;
	if (_ui.x == 0) {
		_ui.x = _ui.desX;
		_ui.y = _ui.desY;
	}
	_ui.x = lerp(_ui.x, _ui.desX, _lerpEffect);
	_ui.y = lerp(_ui.y, _ui.desY, _lerpEffect);
}

function getSlotsUiValues(_quantity) {
	var _response = [];
	for (var i = 0; i < _quantity; i ++) {
		_response[i] = {
			x: 0,
			y: 0,
			desX: 0,
			desY: 0
		}
	}
	return _response;
}

function handleItemCanBeAdded(_slot){
	if (!mouse_check_button_released(mb_left)) return;
	_slot.addItem(holdingItem.itemId, holdingItem.type, recipe.id, itemType.consumables, holdingItem.quantity);
	cleanItemInInventoryById(global.inventory, holdingItem.itemId, holdingItem.type, holdingItem.quantity);
	resetInventoryValues();
}

function handleHoverUi() {
	
	var _lerpEffect = .1;
	hoverUiValues.x = lerp(hoverUiValues.x, hoverUiValues.desX, _lerpEffect);
	hoverUiValues.y = lerp(hoverUiValues.y, hoverUiValues.desY, _lerpEffect);
	hoverUiValues.alpha = lerp(hoverUiValues.alpha, hoverUiValues.desAlpha, _lerpEffect);
	
	if (hoverUiValues.failEffect != 0) {
		var _x = random_range(-hoverUiValues.failEffect, hoverUiValues.failEffect); 
		var _y = random_range(-hoverUiValues.failEffect, hoverUiValues.failEffect); 
		hoverUiValues.x += _x * 5;
		hoverUiValues.y += _y * 5;
	}
	hoverUiValues.failEffect = lerp(hoverUiValues.failEffect, 0, _lerpEffect);
	
	draw_sprite_stretched_ext(
		spr_hover_indicator,
		0,
		hoverUiValues.x,
		hoverUiValues.y,
		FOOD_BLOCK_SIZE,
		FOOD_BLOCK_SIZE,
		c_white,
		hoverUiValues.alpha
	);
}

function drawSlot(_x, _y, _size, _item, _slot, _mouseIsOnSlot = false, _validRecipe = false) {
	var _sprite = spr_campfire_slot;
	var _isReady = (_slot.resultQuantity > 0);
    var _isCooking = (_slot.itemQuantity > 0 && !_isReady);
    
    var _s = 1;
    var _jx = 0; var _jy = 0;
    
    if (_isReady) {
		_s = 1 + ((sin(current_time * 0.005) + 1) / 2) * 0.07; 
	}
	
	if (_isCooking) {
		_jx = sin(current_time * 0.01) * 1.2; 
		_jy = cos(current_time * 0.007) * 1.2;
	}

    var _drawSize = _size * _s;
    var _off = (_size - _drawSize) / 2;
    var _alpha = _mouseIsOnSlot && !_validRecipe ? .6 : 1;
    
    var _color = _isReady ? c_lime : c_white;
	draw_sprite_stretched_ext(_sprite, 0, _x + _off + _jx, _y + _off + _jy, _drawSize, _drawSize, _color, _alpha);
	
	if (_item == global.blankInventorySpace) return;
	
	var _result = _slot.resultQuantity > 0 ? constructItem(_slot.resultType, global.items[_slot.resultType][_slot.resultId]) : global.blankInventorySpace;
	var _itemSprite = _result == global.blankInventorySpace ? _item.sprite : _result.sprite;
	
	var _expectedSize = (_size - BORDER_THICKNESS * 2) * _s;
	
    drawProgressBar(_slot, _x + BORDER_THICKNESS + _off + _jx, _y + BORDER_THICKNESS + _off + _jy, _expectedSize);
	
    drawItemInsideCookingBox(_expectedSize - 15, _itemSprite, _x + _size /2 + _jx, _y + _size /2 + _jy, _alpha);
	
	drawSlotQuantityData(_x + BORDER_THICKNESS, _y + _off, _size - BORDER_THICKNESS, _slot, _alpha);
}

function drawSlotQuantityData(_x, _y, _size, _slot, _alpha) {
	draw_set_alpha(_alpha);
	
	var _drawQuantity = function (_qtd, _x, _y) {
		var _quantityText = string(_qtd) + "x";
		drawTextShadow(_x, _y, _quantityText, 1);
		draw_text(_x, _y, _quantityText);
	}
	
	if (_slot.itemQuantity > 0) {
		draw_set_halign(fa_left);
		_drawQuantity(_slot.itemQuantity, _x, _y)
	}
	
	if (_slot.resultQuantity > 0) {
		draw_set_halign(fa_right);
		draw_set_color(c_lime);
		_drawQuantity(_slot.resultQuantity, _x + _size, _y);
		draw_set_color(c_white);
	}
	
	draw_set_halign(fa_left);
	draw_set_alpha(1);
}

function drawItemInsideCookingBox(_itemSize, _itemSprite, _itemX, _itemY, _alpha) {
	var _scale = getScale(_itemSize, sprite_get_width(_itemSprite));
	draw_sprite_ext(_itemSprite, 0, _itemX, _itemY, _scale, _scale, 0, c_white, _alpha);
}

function drawProgressBar(_slot, _x, _y, _expectedSize) {
	if (_slot.itemQuantity <= 0) return;
	
	draw_set_alpha(0.3);
	draw_rectangle_color(_x, _y, _x + _expectedSize, _y + _expectedSize, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);

	var _prog = _slot.resultCurrentProgress / _slot.requiredResultProgress;
	var _fillHeight = _expectedSize * _prog;
	
	var _color = merge_color(c_orange, c_red, _prog);
	
	draw_rectangle_color(
		_x, 
		_y + _expectedSize - _fillHeight, 
		_x + _expectedSize, 
		_y + _expectedSize, 
		_color, _color, _color, _color, 
		false
	);
}

function handleSlots() {
    var _anySlotWorking = false;
    
    var _worker = undefined;
    for (var i = 0; i < array_length(workerList); i++) {
        var _currentWorker = workerList[i];
        if (is_struct(_currentWorker)) {
            _worker = _currentWorker;
            break;
        }
    }
    
    var _slotSpeed = _worker == undefined ? 0.1 : 0.2;
    
    var _slots = furnitureData.slotData;
    for (var i = 0; i < array_length(_slots); i++) {
        var _slot = _slots[i];
    
		if (_slot.handle(_slotSpeed)) {
            _anySlotWorking = true;
        }
    }
    
    if (_anySlotWorking) {
        if (!audio_is_playing(playingSound)) {
            playingSound = playSoundRelativeToPlayer(audioEmitter, snd_campfire_active, false, 0, 200, 3030, 1.2);
        }
        
        if (!part_system_exists(particleEmitter)) {
            particleEmitter = part_system_create(ps_campfire);
            part_system_layer(particleEmitter, "PS");
            part_system_depth(particleEmitter, depth - 1);
        }
        
        part_system_position(particleEmitter, getMiddlePoint(bbox_left, bbox_right), bbox_bottom - 20);
		
		return
    }
    
	if (audio_is_playing(playingSound)) {
        audio_stop_sound(playingSound);
        playingSound = -1;
    }
        
    if (part_system_exists(particleEmitter)) {
        part_system_destroy(particleEmitter);
        particleEmitter = undefined;
    }
}

defineWorkersPositions = function () {
	workerPositions = [
		getWorkerPosition(getMiddlePoint(bbox_left, bbox_right), bbox_bottom - 30)
	];
}

defineWorkersPositions();