#macro CHARACTER_PANEL_WIDTH 520
#macro INVENTORY_PANEL_PADDING 24
#macro INVENTORY_PANEL_HEADER 56
#macro INVENTORY_SECTION_TITLE 36
#macro STATUS_COLUMN_GAP 16
#macro STATUS_ROW_GAP 12
#macro EQUIPMENT_SLOT_SIZE 76
#macro PLAYER_TOOL_SLOT_SIZE 100
#macro PLAYER_TOOL_SLOT_GAP 12

#region

function getSlotAnim(_key) {
	var _anim = slotAnim[$ _key];
	if (is_undefined(_anim)) {
		_anim = { hover: 0, pop: 0, popVelocity: 0 };
		slotAnim[$ _key] = _anim;
	}
	return _anim;
}

function popSlot(_key, _force = .22) {
	var _anim = getSlotAnim(_key);
	_anim.pop = _force;
	_anim.popVelocity = 0;
}

function registerSlotHover(_key, _x, _y, _size, _item = BLANK_INVENTORY_SPACE) {
	hoveringSlot = true;
	hoverIndicatorUIData.destinyX = _x;
	hoverIndicatorUIData.destinyY = _y;
	hoverIndicatorUIData.destinySize = _size;
	if (_item != BLANK_INVENTORY_SPACE) tooltipItem = _item;

	if (lastHoveredSlotKey != _key) {
		lastHoveredSlotKey = _key;
		if (!audio_is_playing(snd_hover)) playHoverSound();
	}
}

/// @param _options { isHover, isTarget, isGhost, isDimmed, isActive, placeholder }
function drawInventorySlot(_key, _x, _y, _size, _item, _options = {}) {
	var _anim = getSlotAnim(_key);
	var _isHover = _options[$ "isHover"] ?? false;
	var _isTarget = _options[$ "isTarget"] ?? false;
	var _isGhost = _options[$ "isGhost"] ?? false;
	var _isDimmed = _options[$ "isDimmed"] ?? false;
	var _isActive = _options[$ "isActive"] ?? false;
	var _placeholder = _options[$ "placeholder"] ?? undefined;
	var _baseAlpha = draw_get_alpha();

	_anim.hover = lerp(_anim.hover, _isHover, .25);
	_anim.popVelocity += -_anim.pop * .3;
	_anim.popVelocity *= .65;
	_anim.pop += _anim.popVelocity;

	var _drawSize = _size * (1 + _anim.pop);
	var _centerX = _x + _size / 2;
	var _centerY = _y + _size / 2 - _anim.hover * 3;
	var _drawX = _centerX - _drawSize / 2;
	var _drawY = _centerY - _drawSize / 2;
	var _alpha = _baseAlpha * (_isDimmed ? .45 : 1);

	draw_sprite_stretched_ext(spr_inventory_grid, 0, _drawX, _drawY, _drawSize, _drawSize, c_white, _alpha * (.8 + _anim.hover * .2));

	if (_isTarget) {
		var _pulse = .15 + (sin(current_time / 160) + 1) * .15;
		drawSpriteWithGpuFogStretched(#ffe08a, spr_inventory_grid, 0, _drawX, _drawY, _drawSize, _drawSize, 0, _pulse * _alpha);
	}

	if (_item != BLANK_INVENTORY_SPACE) {
		if (itemHasDurability(_item)) drawSlotDurability(_drawX, _drawY, _drawSize, _item, _alpha);

		var _iconAlpha = _alpha * (_isGhost ? .3 : 1);
		var _iconSize = _drawSize * .66;
		var _iconScale = 1 + _anim.hover * .12;
		var _iconAngle = _anim.hover * sin(current_time / 140) * 6;

		drawSpriteFitCentered(_item.sprite, _centerX + 3, _centerY + 4, _iconSize, _iconScale, _iconAngle, c_black, _iconAlpha * .35);
		drawSpriteFitCentered(_item.sprite, _centerX, _centerY, _iconSize, _iconScale, _iconAngle, c_white, _iconAlpha);

		if (_anim.hover > .05 && !_isGhost) {
			gpu_set_fog(true, c_white, 0, 0);
			drawSpriteFitCentered(_item.sprite, _centerX, _centerY, _iconSize, _iconScale, _iconAngle, c_white, _iconAlpha * _anim.hover * .15);
			gpu_set_fog(false, c_white, 0, 0);
		}
	} else if (!is_undefined(_placeholder)) {
		drawSpriteFitCentered(_placeholder, _centerX, _centerY, _drawSize * .42, 1, 0, #8a8a8a, _alpha * .45);
	}

	draw_sprite_stretched_ext(spr_inventory_grid, 1, _drawX, _drawY, _drawSize, _drawSize, _isActive ? #ffd166 : c_white, _alpha);

	if (_item != BLANK_INVENTORY_SPACE && !_isGhost) drawSlotQuantity(_drawX, _drawY, _drawSize, _item, _alpha);
}

function drawSlotQuantity(_x, _y, _size, _item, _alpha) {
	if (!variable_struct_exists(_item, "quantity") || _item.quantity <= 1) return;
	if (!(_item[$ "stackable"] ?? true)) return;

	var _text = string(_item.quantity) + "x";
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	drawTextShadow(_x + _size - 6, _y + _size - 2, _text, _alpha);
	draw_set_alpha(_alpha);
	draw_text(_x + _size - 6, _y + _size - 2, _text);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function drawSlotDurability(_x, _y, _size, _item, _alpha) {
	var _ratio = clamp(_item.durability / max(1, _item.maxDurability), 0, 1);
	var _color = _ratio > .5 ? merge_color(#e0c341, #5fd35f, (_ratio - .5) * 2) : merge_color(#d64545, #e0c341, _ratio * 2);
	var _barX = _x + 10;
	var _barY = _y + _size - 14;
	var _barWidth = _size - 20;
	var _oldAlpha = draw_get_alpha();

	draw_set_alpha(_alpha * .55);
	draw_set_color(c_black);
	draw_rectangle(_barX - 1, _barY - 1, _barX + _barWidth + 1, _barY + 5, false);
	draw_set_alpha(_alpha);
	draw_set_color(_color);
	draw_rectangle(_barX, _barY, _barX + _barWidth * _ratio, _barY + 4, false);
	draw_set_color(c_white);
	draw_set_alpha(_oldAlpha);
}

#endregion

#region painel do personagem

function getCharacterPanelHeight() {
	return INVENTORY_PANEL_PADDING * 2
		+ INVENTORY_PANEL_HEADER
		+ 252
		+ 16 + INVENTORY_SECTION_TITLE + getStatusRowHeight() * 2 + STATUS_ROW_GAP
		+ 16 + INVENTORY_SECTION_TITLE + PLAYER_TOOL_SLOT_SIZE
		+ 12 + INVENTORY_SECTION_TITLE + PLAYER_TOOL_SLOT_SIZE;
}

function getStatusCellWidth() {
	return (CHARACTER_PANEL_WIDTH - INVENTORY_PANEL_PADDING * 2 - STATUS_COLUMN_GAP) / 2;
}

function getStatusRowHeight() {
	return sprite_get_height(spr_life_bar) * getStatusCellWidth() / sprite_get_width(spr_life_bar);
}

function drawInventoryPanelBackground(_x, _y, _width, _height) {
	drawSpriteShadowStretched(_x, _y, spr_inventory_box, 0, 0, _width, _height, 0, 8);
	draw_sprite_stretched_ext(spr_inventory_box, 0, _x, _y, _width, _height, c_white, draw_get_alpha());
}

function drawPanelHeader(_x, _y, _width, _title, _subtitle = "", _rightText = "", _rightColor = c_white) {
	var _alpha = draw_get_alpha();
	var _centerY = _y + INVENTORY_PANEL_HEADER / 2 - 6;

	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	draw_set_font(fnt_gui_title);
	drawTextShadow(_x, _centerY, _title, _alpha);
	draw_text(_x, _centerY, _title);

	if (_subtitle != "") {
		var _subtitleX = _x + string_width(_title) + 14;
		draw_set_font(fnt_gui_default);
		draw_set_color(#a8a8a8);
		draw_text(_subtitleX, _centerY + 4, _subtitle);
		draw_set_color(c_white);
	}

	if (_rightText != "") {
		draw_set_font(fnt_gui_default);
		draw_set_halign(fa_right);
		drawTextShadow(_x + _width, _centerY, _rightText, _alpha);
		draw_set_color(_rightColor);
		draw_text(_x + _width, _centerY, _rightText);
		draw_set_color(c_white);
	}

	var _lineY = _y + INVENTORY_PANEL_HEADER - 10;
	draw_set_alpha(_alpha * .25);
	draw_line_width(_x, _lineY, _x + _width, _lineY, 2);
	draw_set_alpha(_alpha);

	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	return _y + INVENTORY_PANEL_HEADER;
}

function drawSectionTitle(_x, _y, _title, _hint = "") {
	var _alpha = draw_get_alpha();
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(#c9c9c9);
	draw_text(_x, _y, _title);

	if (_hint != "") {
		draw_set_color(#7d7d7d);
		draw_text(_x + string_width(_title) + 10, _y, _hint);
	}

	draw_set_color(c_white);
	draw_set_alpha(_alpha);
	return _y + INVENTORY_SECTION_TITLE;
}

function drawPlayerInfo(_panel) {
	drawInventoryPanelBackground(_panel.x, _panel.y, _panel.width, _panel.height);

	var _x = _panel.x + INVENTORY_PANEL_PADDING;
	var _width = _panel.width - INVENTORY_PANEL_PADDING * 2;
	var _y = _panel.y + INVENTORY_PANEL_PADDING;

	_y = drawPanelHeader(_x, _y, _width, "Personagem", global.player.name);
	_y = drawCharacterSection(_x, _y, _width);
	_y = drawPlayerStatsSection(_x, _y + 16, _width);
	_y = drawWeaponsSection(_x, _y + 16, _width);
	drawQuickUseSection(_x, _y + 12, _width);

	mouseIsOnPlayerInfo = mouseIsOnRectangle(_panel.x, _panel.y, _panel.x + _panel.width, _panel.y + _panel.height);
	if (mouseIsOnPlayerInfo && !mouseIsOnEquipments) {
		handleDropOnPlayerInfo();
	}
}

function drawCharacterSection(_x, _y, _width) {
	var _height = 252;
	var _equipmentColumnWidth = EQUIPMENT_SLOT_SIZE + 180;
	var _dollWidth = _width - _equipmentColumnWidth;

	drawCharacterDoll(_x + _dollWidth / 2, _y + _height - 22);

	var _slots = [
		{ type: "head", label: "Cabeça", placeholder: spr_head_icon },
		{ type: "armor", label: "Roupa", placeholder: spr_clothing_icon },
		{ type: "bag", label: "Mochila", placeholder: spr_bag_icon }
	];
	var _slotX = _x + _width - EQUIPMENT_SLOT_SIZE;

	for (var i = 0; i < array_length(_slots); i++) {
		var _slot = _slots[i];
		var _slotY = _y + 4 + i * (EQUIPMENT_SLOT_SIZE + 8);
		drawEquipmentGrid(_slotX, _slotY, EQUIPMENT_SLOT_SIZE, _slot.type, variable_struct_get(global.equipments, _slot.type), _slot.label, _slot.placeholder);
	}

	return _y + _height;
}

function drawCharacterDoll(_centerX, _feetY) {
	static lastEquipmentSignature = undefined;
	static bounce = 0;
	static bounceVelocity = 0;

	var _armor = global.equipments.armor;
	var _helmet = global.equipments.head;
	var _bag = global.equipments.bag;
	var _armorId = is_struct(_armor) ? _armor.itemId : -1;
	var _helmetId = is_struct(_helmet) ? _helmet.itemId : -1;
	var _bagId = is_struct(_bag) ? _bag.itemId : -1;

	var _signature = string(_armorId) + ":" + string(_helmetId) + ":" + string(_bagId);
	if (!is_undefined(lastEquipmentSignature) && lastEquipmentSignature != _signature) {
		bounce = .35;
		bounceVelocity = 0;
	}
	lastEquipmentSignature = _signature;

	bounceVelocity += -bounce * .25;
	bounceVelocity *= .72;
	bounce += bounceVelocity;

	var _alpha = draw_get_alpha();
	var _scale = 3 * (1 + sin(current_time / 600) * .012) * (1 + bounce * .15);
	var _jump = max(0, bounce) * 30;

	gpu_set_blendmode(bm_add);
	draw_set_alpha(_alpha * .22);
	draw_circle_colour(_centerX, _feetY - 95, 120, #6b6b6b, c_black, false);
	gpu_set_blendmode(bm_normal);

	var _shadowWidth = 70 * (1 - min(_jump, 20) / 60);
	draw_set_color(c_black);
	draw_set_alpha(_alpha * .35);
	draw_ellipse(_centerX - _shadowWidth, _feetY - 12, _centerX + _shadowWidth, _feetY + 12, false);
	draw_set_color(c_white);
	draw_set_alpha(_alpha);

	drawPersonBody(
		_centerX,
		_feetY - _jump,
		global.player.gender,
		0,
		_scale,
		0,
		_alpha,
		global.player.skinColor,
		global.player.hair,
		global.player.eyeId,
		_armorId,
		_helmetId,
		_bagId,
		1,
		drawStates.iddle
	);
}

function drawPlayerStatsSection(_x, _y, _width) {
	static statusBars = [
		new StatusBar(global.player.health, global.player.defaultMaxHealth, spr_life_bar),
		new StatusBar(global.player.stamina, global.player.defaultMaxStamina, spr_energy_bar),
		new StatusBar(global.player.currentHunger / 10, global.player.defaultTotalHunger / 10, spr_hunger_bar),
		new StatusBar(global.player.currentThirst / 10, global.player.defaultTotalThirst / 10, spr_thirst_bar)
	];
	static statusTrails = [global.player.health, global.player.stamina, global.player.currentHunger / 10, global.player.currentThirst / 10];

	var _targets = [
		[global.player.health, global.player.maxHealth],
		[global.player.stamina, global.player.maxStamina],
		[global.player.currentHunger / 10, global.player.defaultTotalHunger / 10],
		[global.player.currentThirst / 10, global.player.defaultTotalThirst / 10]
	];

	_y = drawSectionTitle(_x, _y, "Status");

	var _columnGap = STATUS_COLUMN_GAP;
	var _rowGap = STATUS_ROW_GAP;
	var _cellWidth = getStatusCellWidth();
	var _rowHeight = getStatusRowHeight();

	for (var i = 0; i < array_length(statusBars); i++) {
		var _bar = statusBars[i];
		_bar.value = lerp(_bar.value, _targets[i][0], .1);
		_bar.maxValue = lerp(_bar.maxValue, _targets[i][1], .1);

		statusTrails[i] = _bar.value < statusTrails[i] ? lerp(statusTrails[i], _bar.value, .04) : _bar.value;

		var _column = i mod 2;
		var _row = i div 2;
		drawInventoryStatusRow(_bar.icon, _bar.value, _bar.maxValue, statusTrails[i], _x + _column * (_cellWidth + _columnGap), _y + _row * (_rowHeight + _rowGap), _cellWidth);
	}

	return _y + _rowHeight * 2 + _rowGap;
}

function drawInventoryStatusRow(_sprite, _value, _maxValue, _trail, _x, _y, _width) {
	var _alpha = draw_get_alpha();
	var _spriteWidth = sprite_get_width(_sprite);
	var _spriteHeight = sprite_get_height(_sprite);
	var _scale = _width / _spriteWidth;
	var _fillStart = 21;
	var _fillableWidth = _spriteWidth - _fillStart;
	var _ratio = clamp(_value / max(1, _maxValue), 0, 1);
	var _trailRatio = clamp(_trail / max(1, _maxValue), 0, 1);
	var _isLow = _ratio < .25;
	var _barY = _y;

	draw_sprite_ext(_sprite, 0, _x, _barY, _scale, _scale, 0, c_white, _alpha);

	if (_trailRatio > _ratio) {
		gpu_set_fog(true, c_white, 0, 0);
		draw_sprite_general(_sprite, 1, _fillStart, 0, _fillableWidth * _trailRatio, _spriteHeight, _x + _fillStart * _scale, _barY, _scale, _scale, 0, c_white, c_white, c_white, c_white, _alpha * .55);
		gpu_set_fog(false, c_white, 0, 0);
	}

	draw_sprite_general(_sprite, 1, _fillStart, 0, _fillableWidth * _ratio, _spriteHeight, _x + _fillStart * _scale, _barY, _scale, _scale, 0, c_white, c_white, c_white, c_white, _alpha);

	if (_isLow) {
		var _pulse = (sin(current_time / 150) + 1) * .25;
		gpu_set_fog(true, c_red, 0, 0);
		draw_sprite_general(_sprite, 1, _fillStart, 0, _fillableWidth * _ratio, _spriteHeight, _x + _fillStart * _scale, _barY, _scale, _scale, 0, c_white, c_white, c_white, c_white, _alpha * _pulse);
		gpu_set_fog(false, c_white, 0, 0);
	}

	var _text = string(round(_value)) + "/" + string(round(_maxValue));
	var _textX = _x + (_fillStart + _fillableWidth / 2) * _scale;
	var _textY = _barY + _spriteHeight * _scale / 2;
	draw_set_font(fnt_default_small);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	drawTextShadow(_textX, _textY, _text, _alpha, 2);
	draw_set_color(_isLow ? #ffb3b3 : c_white);
	draw_text(_textX, _textY, _text);
	draw_set_color(c_white);
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function drawWeaponsSection(_x, _y, _width) {
	_y = drawSectionTitle(_x, _y, "Armas", "[1-" + string(global.toolBarSize) + "]");

	var _count = global.toolBarSize;
	var _x2 = _x + _count * PLAYER_TOOL_SLOT_SIZE + (_count - 1) * PLAYER_TOOL_SLOT_GAP;
	var _toolBar = getToolBarBox(_x, _x2, 0, _y, undefined, PLAYER_TOOL_SLOT_SIZE / GRIDSIZE, false);
	drawToolBarItems(_toolBar);

	return _y + PLAYER_TOOL_SLOT_SIZE;
}

function drawQuickUseSection(_x, _y, _width) {
	_y = drawSectionTitle(_x, _y, "Uso rápido", "[E]");

	var _count = ds_list_size(global.quickUse);
	var _x2 = _x + _count * PLAYER_TOOL_SLOT_SIZE + (_count - 1) * PLAYER_TOOL_SLOT_GAP;
	drawQuickUseItemsInInventory(_x, _x2, _y, PLAYER_TOOL_SLOT_SIZE);

	return _y + PLAYER_TOOL_SLOT_SIZE;
}

#endregion

#region equipamentos

function getEquipmentSlotFromItem(_item) {
	if (_item == BLANK_INVENTORY_SPACE || _item.type != itemType.equipment) return BLANK_INVENTORY_SPACE;
	switch (_item.equipType) {
		case equipmentType.armor: return "armor";
		case equipmentType.bag: return "bag";
		case equipmentType.head: return "head";
	}
	return BLANK_INVENTORY_SPACE;
}

function drawEquipmentGrid(_x, _y, _size, _indicatorType, _item, _label, _placeholder){
	var _key = "eq:" + _indicatorType;
	var _mouseIsOnGrid = mouseIsOnRectangle(_x, _y, _x + _size, _y + _size);
	var _isHoldingThis = holdingItemFromEquipments && indicatorToWhereItemShouldBePut == _indicatorType;
	var _isTarget = indicatorToWhereItemShouldBePut == _indicatorType && !holdingItemFromEquipments;

	if (_mouseIsOnGrid) {
		registerSlotHover(_key, _x, _y, _size, _item);
		if (_isTarget && activeHoldingItem != BLANK_INVENTORY_SPACE && mouse_check_button_released(mb_left)) popSlot(_key);
	}

	if (_mouseIsOnGrid && indicatorToWhereItemShouldBePut == _indicatorType){
		mouseIsOnEquipments = true;
		handleHoldingOverItem(_indicatorType);
	}

	if (global.activeInventory && _mouseIsOnGrid && activeHoldingItem == BLANK_INVENTORY_SPACE){
		holdItemFromEquipment(_item);
	}

	drawInventorySlot(_key, _x, _y, _size, _item, {
		isHover: _mouseIsOnGrid,
		isTarget: _isTarget,
		isGhost: _isHoldingThis,
		placeholder: _placeholder
	});

	var _alpha = draw_get_alpha();
	var _textX = _x - 14;
	var _centerY = _y + _size / 2;
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_set_font(fnt_gui_default);
	draw_set_color(_mouseIsOnGrid ? c_white : #a8a8a8);
	draw_text(_textX, _centerY, _label);

	var _itemName = _item != BLANK_INVENTORY_SPACE ? _item.name : "Vazio";
	var _nameScale = min(1, 165 / max(1, string_width(_itemName)));
	draw_set_valign(fa_top);
	draw_set_color(_item != BLANK_INVENTORY_SPACE ? c_white : #6f6f6f);
	drawTextShadow(_textX, _centerY + 2, _itemName, _alpha * .6, 2, _nameScale);
	draw_text_transformed(_textX, _centerY + 2, _itemName, _nameScale, _nameScale, 0);

	draw_set_color(c_white);
	draw_set_halign(fa_left);
}

function holdItemFromEquipment(_item){
	if(!mouse_check_button(mb_left)) return;
	cleanMenuOptions();
	if (_item == BLANK_INVENTORY_SPACE) return;
	holdingItemFromEquipments = true;
	activeHoldingItem = _item;
	holdingItem.scale = getItemScale(EQUIPMENT_SLOT_SIZE, sprite_get_height(_item.sprite));
	onItemPickedUp();
	currentState = holdItem;
}

function handleHoldingOverItem(_indicatorType){
	if (!mouse_check_button_released(mb_left)) return;
	if (holdingItemFromEquipments) return;
	var _alreadyPlacedItem = variable_struct_get(global.equipments, _indicatorType)
	if (_alreadyPlacedItem != BLANK_INVENTORY_SPACE){
		var _inventoryItem = activeHoldingItem;
		global.activeInventoryAction[# holdingItem.j, holdingItem.i] = _alreadyPlacedItem;
		equipEquipment(_indicatorType, _inventoryItem);
		return;
	}
	global.activeInventoryAction[# holdingItem.j, holdingItem.i] = BLANK_INVENTORY_SPACE;
	equipEquipment(_indicatorType, activeHoldingItem);
}

function equipEquipment(_type, _inventoryItem) {
	playEquipEquipmentSound();
	variable_struct_set(global.equipments, _type, _inventoryItem);
	handleEquipmentSwitch(_type);

	obj_quest_manager.notifyEvent(QuestEvent.ItemEquiped, {
		type: _type,
		item: _inventoryItem
	});
}

function playEquipEquipmentSound() {
	audio_play_sound(snd_equip_equipment, 0, false);
}

function storeEquipment(){
	var _inventorySpace = global.activeInventoryAction[# hoverItem.j, hoverItem.i];
	if (_inventorySpace != BLANK_INVENTORY_SPACE) return;
	global.activeInventoryAction[# hoverItem.j, hoverItem.i] = variable_struct_get(global.equipments, indicatorToWhereItemShouldBePut);
	variable_struct_set(global.equipments, indicatorToWhereItemShouldBePut, BLANK_INVENTORY_SPACE);
	handleEquipmentSwitch(indicatorToWhereItemShouldBePut);
}

function handleEquipmentDropping(){
	holdingItemFromEquipments = false;
	if (mouseIsOnInventoryGrid){
		storeEquipment();
		return;
	}
	if (mouseIsOnEquipments || mouseIsOnInventory || mouseIsOnPlayerInfo){
		return;
	}
	var _droppedItem = instance_create_layer(obj_player.x, obj_player.y, "Items", obj_item);
	_droppedItem.item = activeHoldingItem;
	variable_struct_set(global.equipments, indicatorToWhereItemShouldBePut, BLANK_INVENTORY_SPACE);
	handleEquipmentSwitch(indicatorToWhereItemShouldBePut);
}

#endregion

#region soltar no painel do personagem

function handleDropOnPlayerInfo() {
	if (currentState != holdItem || holdingItemFromToolBar || holdingItemFromEquipments) return;
	if (activeHoldingItem == BLANK_INVENTORY_SPACE) return;

	if (activeHoldingItem.type == itemType.weapons) {
		handleWeaponDropOnPlayerInfo();
		return;
	}

	if (itemCanBeAddedToQuickBarUse(activeHoldingItem)) {
		handleQuickUseDropOnPlayerInfo();
		return;
	}

	var _slot = getEquipmentSlotFromItem(activeHoldingItem);
	if (_slot == BLANK_INVENTORY_SPACE) return;
	handleHoldingOverItem(_slot);
}

function handleWeaponDropOnPlayerInfo() {
	if (hoverToolbarIndex != BLANK_INVENTORY_SPACE) return;
	if (!mouse_check_button_released(mb_left)) return;
	addItemToToolBar(undefined, global.activeInventoryAction);
}

function handleQuickUseDropOnPlayerInfo() {
	if (mouseIsOnQuickUseBar) return;
	if (!mouse_check_button_released(mb_left)) return;
	var _index = getQuickUseIndexForItem(activeHoldingItem);
	if (_index == BLANK_INVENTORY_SPACE) return;
	addToQuickUseWithIndex(_index, activeHoldingItem, activeHoldingItem.quantity);
}

#endregion

#region uso rápido

function drawQuickUseItemsInInventory(_x1, _x2, _y, _size) {
	var _numItems = ds_list_size(global.quickUse);
	if (_numItems <= 0) return;

	var _actualItem = activeHoldingItem == BLANK_INVENTORY_SPACE ? activeHoverItem : activeHoldingItem;
	var _showTargets = itemCanBeAddedToQuickBarUse(_actualItem);

	var _spaceBetweenBoxes = PLAYER_TOOL_SLOT_GAP;
	var _totalGroupWidth = _numItems * _size + (_numItems - 1) * _spaceBetweenBoxes;
	var _startX = _x1 + (_x2 - _x1) / 2 - _totalGroupWidth / 2;
	var _isHoveringAny = false;

	for (var i = 0; i < _numItems; i++) {
		var _key = "qu:" + string(i);
		var _actualX = _startX + i * (_size + _spaceBetweenBoxes);
		var _item = getItemFromQuickUse(i);
		var _mouseIsHovering = mouseIsOnRectangle(_actualX, _y, _actualX + _size, _y + _size);

		if (_mouseIsHovering) {
			_isHoveringAny = true;
			registerSlotHover(_key, _actualX, _y, _size, _item != false ? _item : BLANK_INVENTORY_SPACE);

			if (itemCanBeAddedToQuickBarUse(activeHoldingItem) && mouse_check_button_released(mb_left)) {
				addToQuickUseWithIndex(i, activeHoldingItem, activeHoldingItem.quantity);
				popSlot(_key);
			}
			if (mouse_check_button_pressed(mb_left) && _item != false) {
				addQuickUseItemToInventory(i);
				popSlot(_key, -.15);
			}
		}

		drawInventorySlot(_key, _actualX, _y, _size, _item != false ? _item : BLANK_INVENTORY_SPACE, {
			isHover: _mouseIsHovering,
			isTarget: _showTargets,
			placeholder: spr_attribute_supply
		});
	}

	mouseIsOnQuickUseBar = _isHoveringAny;
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

#endregion

#region

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

function StatusBar(_value, _maxValue, _icon) constructor {
	value = _value;
	maxValue = _maxValue;
	icon = _icon;
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

#endregion
