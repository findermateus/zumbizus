event_inherited();

actionDescription = "Criar";
isUsing = false;

enum itemCategories {
	allTypes,
	resources,
	tools
}

activeCategory = itemCategories.allTypes;

availableItems = [];

availableItems[itemCategories.resources] = [
	{ id: trashItems.wood_board, type: itemType.trash},
	{ id: trashItems.rope, type: itemType.trash}
];
availableItems[itemCategories.tools] = [
	{ id: weaponItems.axe, type: itemType.weapons}
];
availableItems[itemCategories.allTypes] = array_concat(
    availableItems[itemCategories.resources],
    availableItems[itemCategories.tools]
);

categoryList = [
	{ id: itemCategories.allTypes, title: "Todos" },
	{ id: itemCategories.resources, title: "Recursos" },
	{ id: itemCategories.tools, title: "Ferramentas" }
];

loadFurnitureByDefaultId();

spriteToDrawShadow = sprite_index;

function setUpLight(){
	var _spriteWidth = sprite_get_width(sprite_index);
	var _spriteHeight = sprite_get_height(sprite_index);
	var _x = x + _spriteWidth/2;
	var _y = y + _spriteHeight/2;
	var _range = _spriteHeight;
	var _alpha = .4;
	furnitureIluminator = instance_create_layer(_x, _y, "Particles", obj_furniture_light, {
		range: _range,
		alpha: _alpha,
		father: id
	});
}

setUpLight();

menuId = Menus.SimpleCrafting;

#macro CRAFTING_PANEL_WIDTH 720
#macro CRAFTING_COLUMNS 4
#macro CRAFTING_CARD_GAP 20
#macro CRAFTING_TAB_HEIGHT 56
#macro CRAFTING_TAB_GAP 14
#macro CRAFTING_TAB_PADDING 22

menuOpenness = 0;
menuVelocity = 0;
inputTimer = 0;
hoverIndex = -1;
lastHoveredCard = -1;
hoverCategory = -1;
categoryTabAnim = [];
cardAnim = [];
closeButtonUI = { hover: 0, angle: 0, isHovering: false };
hoveredCardRect = { x: 0, y: 0, size: 0 };
craftDetailsUI = { x: 0, y: 0, alpha: 0, slide: 0, index: -1, category: -1 };

function activateFurniture() {
	openMenu(menuId, hide);
	obj_camera.setTargetWithZoom(id);
	isUsing = true;
	setVariablesOpenFurniture();
	resetMenuAnimations();
	playSwiiimmmSound(.6);
}


activationMethod = function () {
    playClickSound();
    audio_play_sound(snd_open_crafting_station, 0, false);
    activateFurniture();

    inputTimer = 5;
}

function hide(){
	if (!isUsing) return;

    if (!global.activeInventory) {
        obj_camera.setDefaultValues();
        obj_camera.target = obj_player;
    }

    isUsing = false;
    inputTimer = 0;
	audio_play_sound(snd_close_crafting_station, 0, false);

    setVariablesCloseFurniture();

	if (isCurrentMenu(menuId)) {
		closeMenu();
	}
}

#region animação

function easeOutBack(_t) {
	var _c1 = 1.70158;
	var _c3 = _c1 + 1;
	return 1 + _c3 * power(_t - 1, 3) + _c1 * power(_t - 1, 2);
}

function resetCardAnimations() {
	cardAnim = [];
	lastHoveredCard = -1;
	craftDetailsUI.alpha = 0;
}

function resetMenuAnimations() {
	categoryTabAnim = [];
	hoverIndex = -1;
	resetCardAnimations();
}

function getCardAnim(_index) {
	while (array_length(cardAnim) <= _index) {
		array_push(cardAnim, {
			scale: 0,
			velocity: 0,
			lift: 0,
			hover: 0,
			shake: 0,
			flash: 0,
			delay: array_length(cardAnim) * 3
		});
	}
	return cardAnim[_index];
}

function updateCraftingMenu() {
	if (inputTimer > 0) inputTimer--;

	menuVelocity += ((isUsing ? 1 : 0) - menuOpenness) * .14;
	menuVelocity *= .66;
	menuOpenness += menuVelocity;
}

function isMenuVisible() {
	return isUsing || menuOpenness > .02;
}

#endregion

#region desenho

function canAffordCraft(_entry) {
	var _craft = getCraftingItem(_entry.type, _entry.id);
	return is_struct(_craft) && verifyIfHasAllItems(_craft);
}

function getCraftingPanelHeight(_itemCount) {
	var _cardSize = getCraftingCardSize();
	var _rows = max(1, ceil(_itemCount / CRAFTING_COLUMNS));
	return INVENTORY_PANEL_PADDING * 2
		+ INVENTORY_PANEL_HEADER
		+ 8 + CRAFTING_TAB_HEIGHT + 32
		+ _rows * _cardSize + (_rows - 1) * CRAFTING_CARD_GAP;
}

function getCategoryTabMinWidth() {
	var _width = 0;
	draw_set_font(fnt_gui_default);

	for (var i = 0; i < array_length(categoryList); i++) {
		var _itemCount = array_length(availableItems[categoryList[i].id]);
		_width = max(_width, CRAFTING_TAB_PADDING * 2 + string_width(categoryList[i].title) + 10 + string_width(string(_itemCount)));
	}

	return _width;
}

function getCraftingPanelWidth() {
	var _count = array_length(categoryList);
	var _tabsWidth = getCategoryTabMinWidth() * _count + CRAFTING_TAB_GAP * (_count - 1);
	return max(CRAFTING_PANEL_WIDTH, _tabsWidth + INVENTORY_PANEL_PADDING * 2);
}

function getCraftingCardSize() {
	return (getCraftingPanelWidth() - INVENTORY_PANEL_PADDING * 2 - CRAFTING_CARD_GAP * (CRAFTING_COLUMNS - 1)) / CRAFTING_COLUMNS;
}

function drawCraftingBackdrop() {
	var _alpha = .35 * clamp(menuOpenness, 0, 1);
	if (_alpha <= .01) return;

	draw_set_color(c_black);
	draw_set_alpha(_alpha);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function drawSimpleCraftingStationUI() {
	if (menuOpenness > .02) {
		var _guiWidth = display_get_gui_width();
		var _guiHeight = display_get_gui_height();
		var _items = availableItems[activeCategory];
		var _uiAlpha = clamp(menuOpenness * 1.4, 0, 1);
		var _canInteract = isUsing && menuOpenness > .6;

		var _panelW = getCraftingPanelWidth();
		var _panelH = getCraftingPanelHeight(array_length(_items));
		var _panelX = (_guiWidth - _panelW) / 2;
		var _panelY = (_guiHeight - _panelH) / 2 - 20 + (1 - menuOpenness) * 160;

		drawCraftingBackdrop();

		draw_set_alpha(_uiAlpha);
		drawInventoryPanelBackground(_panelX, _panelY, _panelW, _panelH);

		var _contentX = _panelX + INVENTORY_PANEL_PADDING;
		var _contentW = _panelW - INVENTORY_PANEL_PADDING * 2;
		var _contentY = drawCraftingTitle(_contentX, _panelY + INVENTORY_PANEL_PADDING, _uiAlpha);

		var _area = { x1: _contentX, x2: _contentX + _contentW, y: _contentY + 8 };
		var _cardsY = drawCategoryTabs(_area, _uiAlpha, _canInteract);
		drawCraftingCards(_area, _cardsY, _items, _uiAlpha, _canInteract);
		drawCraftDetails(_items, _uiAlpha);
		drawCloseButton(_panelX + _panelW - 8, _panelY + 8, _uiAlpha, _canInteract);
		drawCraftingLegend(_guiWidth / 2, _panelY + _panelH + 36, _uiAlpha);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function drawCraftingTitle(_x, _y, _alpha) {
	var _title = "Bancada";
	var _centerY = _y + INVENTORY_PANEL_HEADER / 2 - 6;

	draw_set_font(fnt_gui_title);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	drawTextShadow(_x, _centerY, _title, _alpha);
	draw_text(_x, _centerY, _title);

	draw_set_font(fnt_gui_default);
	draw_set_valign(fa_top);

	return _y + INVENTORY_PANEL_HEADER;
}

function drawCloseButton(_centerX, _centerY, _alpha, _canInteract) {
	var _size = 52;
	var _isHovering = _canInteract && mouseIsOnRectangle(_centerX - _size / 2, _centerY - _size / 2, _centerX + _size / 2, _centerY + _size / 2);

	if (_isHovering && !closeButtonUI.isHovering) playHoverSound();
	closeButtonUI.isHovering = _isHovering;
	closeButtonUI.hover = lerp(closeButtonUI.hover, _isHovering, .25);
	closeButtonUI.angle = _isHovering ? sin(current_time / 60) * 8 : lerp(closeButtonUI.angle, 0, .2);

	var _sprite = spr_icon_close_button;
	var _scale = getScale(_size, sprite_get_width(_sprite)) * (1 + closeButtonUI.hover * .2);
	var _offset = rotateSpriteVector(sprite_get_width(_sprite) / 2 * _scale, sprite_get_height(_sprite) / 2 * _scale, closeButtonUI.angle);
	var _x = _centerX - _offset[0];
	var _y = _centerY - _offset[1];

	drawSpriteShadow(_x, _y, _sprite, _isHovering, closeButtonUI.angle, _scale, _scale, 3, 3, _alpha);
	draw_sprite_ext(_sprite, _isHovering, _x, _y, _scale, _scale, closeButtonUI.angle, merge_color(c_white, #ff6b6b, closeButtonUI.hover), _alpha);

	if (_isHovering && mouse_check_button_pressed(mb_left)) {
		playClickSound();
		hide();
	}
}

function drawCategoryTabs(_area, _uiAlpha, _canInteract) {
	var _count = array_length(categoryList);
	var _gap = CRAFTING_TAB_GAP;
	var _width = max(getCategoryTabMinWidth(), (_area.x2 - _area.x1 - _gap * (_count - 1)) / _count);
	var _totalWidth = _width * _count + _gap * (_count - 1);

	draw_set_font(fnt_gui_default);

	while (array_length(categoryTabAnim) < _count) {
		array_push(categoryTabAnim, { alpha: 0, yOffset: -20, scale: 1, lift: 0 });
	}

	var _x = getMiddlePoint(_area.x1, _area.x2) - _totalWidth / 2;
	var _y = _area.y;
	var _hoverAny = false;

	for (var i = 0; i < _count; i++) {
		var _category = categoryList[i];
		var _anim = categoryTabAnim[i];
		var _itemCount = array_length(availableItems[_category.id]);
		var _isSelected = _category.id == activeCategory;

		var _canStart = i == 0 ? menuOpenness > .5 : categoryTabAnim[i - 1].alpha > .4;
		if (_canStart) {
			_anim.alpha = lerp(_anim.alpha, 1, .2);
			_anim.yOffset = lerp(_anim.yOffset, 0, .2);
		}

		var _isHover = _canInteract && mouseIsOnRectangle(_x, _y - 6, _x + _width, _y + CRAFTING_TAB_HEIGHT);
		if (_isHover) {
			_hoverAny = true;
			if (hoverCategory != _category.id) {
				playHoverSound();
				hoverCategory = _category.id;
			}
			if (mouse_check_button_pressed(mb_left) && !_isSelected) {
				playClickSound();
				activeCategory = _category.id;
				hoverIndex = -1;
				resetCardAnimations();
				_isSelected = true;
			}
		}

		_anim.lift = lerp(_anim.lift, _isHover ? 6 : 0, .25);
		_anim.scale = lerp(_anim.scale, _isSelected ? 1.08 : (_isHover ? 1.05 : 1), .2);

		var _scale = _anim.scale;
		var _drawWidth = _width * _scale;
		var _drawHeight = CRAFTING_TAB_HEIGHT * _scale;
		var _drawX = _x + (_width - _drawWidth) / 2;
		var _drawY = _y + (CRAFTING_TAB_HEIGHT - _drawHeight) / 2 - _anim.lift + _anim.yOffset;
		var _centerY = _drawY + _drawHeight / 2;
		var _isLit = _isSelected || _isHover;
		var _alpha = _anim.alpha * _uiAlpha;

		draw_set_alpha(_alpha);
		drawSpriteShadowStretched(_drawX, _drawY, spr_builder_furniture_box, _isLit, 0, _drawWidth, _drawHeight, 0, 4 + _anim.lift * .5);
		draw_sprite_stretched_ext(spr_builder_furniture_box, _isLit, _drawX, _drawY, _drawWidth, _drawHeight, _isSelected ? c_white : #c8c8c8, _alpha);

		var _contentWidth = string_width(_category.title) + 10 + string_width(string(_itemCount));
		var _textX = _drawX + (_drawWidth - _contentWidth * _scale) / 2;
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		drawTextShadow(_textX, _centerY, _category.title, _alpha, 3, _scale);
		draw_set_color(_isSelected ? c_white : #d0d0d0);
		draw_text_transformed(_textX, _centerY, _category.title, _scale, _scale, 0);

		var _countText = string(_itemCount);
		var _countX = _textX + (string_width(_category.title) + 10) * _scale;
		drawTextShadow(_countX, _centerY, _countText, _alpha, 3, _scale);
		draw_set_color(#a0a0a0);
		draw_text_transformed(_countX, _centerY, _countText, _scale, _scale, 0);
		draw_set_color(c_white);

		_x += _width + _gap;
	}

	if (!_hoverAny) hoverCategory = -1;

	draw_set_alpha(_uiAlpha);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	return _y + CRAFTING_TAB_HEIGHT + 32;
}

function drawCraftingCards(_area, _y, _items, _uiAlpha, _canInteract) {
	var _count = array_length(_items);
	var _cardSize = getCraftingCardSize();
	var _hovered = -1;

	if (_count == 0) {
		var _alpha = (.55 + sin(current_time / 300) * .2) * _uiAlpha;
		draw_set_font(fnt_gui_default);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		drawTextShadow(getMiddlePoint(_area.x1, _area.x2), _y + _cardSize / 2, "Nada para criar aqui ainda", _alpha);
		draw_set_alpha(_alpha);
		draw_text(getMiddlePoint(_area.x1, _area.x2), _y + _cardSize / 2, "Nada para criar aqui ainda");
		draw_set_alpha(_uiAlpha);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	}

	var _columns = min(CRAFTING_COLUMNS, max(1, _count));
	var _gridWidth = _columns * _cardSize + (_columns - 1) * CRAFTING_CARD_GAP;
	var _startX = getMiddlePoint(_area.x1, _area.x2) - _gridWidth / 2;

	for (var i = 0; i < _count; i++) {
		var _x = _startX + (i mod CRAFTING_COLUMNS) * (_cardSize + CRAFTING_CARD_GAP);
		var _cardY = _y + (i div CRAFTING_COLUMNS) * (_cardSize + CRAFTING_CARD_GAP);
		if (drawCraftingCard(_items[i], i, _x, _cardY, _cardSize, _uiAlpha, _canInteract)) _hovered = i;
	}

	if (_hovered == -1) lastHoveredCard = -1;
	hoverIndex = _hovered;
}

function drawCraftingCard(_entry, _index, _x, _y, _size, _uiAlpha, _canInteract) {
	var _anim = getCardAnim(_index);

	if (_anim.delay > 0) {
		if (menuOpenness > .5) _anim.delay--;
		return false;
	}
	_anim.velocity += (1 - _anim.scale) * .22;
	_anim.velocity *= .68;
	_anim.scale += _anim.velocity;

	var _config = global.items[_entry.type][_entry.id];
	var _canAfford = canAffordCraft(_entry);
	var _isHover = _canInteract && mouseIsOnRectangle(_x, _y - 8, _x + _size, _y + _size);

	if (_isHover) {
		if (lastHoveredCard != _index) playHoverSound();
		lastHoveredCard = _index;
		hoveredCardRect.x = _x;
		hoveredCardRect.y = _y - _anim.lift;
		hoveredCardRect.size = _size;

		if (mouse_check_button_released(mb_left) && inputTimer <= 0) {
			if (handleClick(availableItems[activeCategory], _index, getMouseXGui(), getMouseYGui())) {
				_anim.velocity = .25;
				_anim.flash = 1;
				screenShake(2);
			} else {
				_anim.shake = 6;
			}
		}
	}

	_anim.lift = lerp(_anim.lift, _isHover ? 8 : 0, .25);
	_anim.hover = lerp(_anim.hover, _isHover, .2);
	_anim.shake = lerp(_anim.shake, 0, .2);
	_anim.flash = lerp(_anim.flash, 0, .12);

	var _shakeX = _anim.shake > .2 ? random_range(-_anim.shake, _anim.shake) : 0;
	var _drawSize = _size * _anim.scale * (1 + _anim.hover * .04);
	var _centerX = _x + _size / 2 + _shakeX;
	var _centerY = _y + _size / 2 - _anim.lift;
	var _boxX = _centerX - _drawSize / 2;
	var _boxY = _centerY - _drawSize / 2;
	var _alpha = clamp(_anim.scale, 0, 1) * _uiAlpha;

	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_boxX, _boxY, spr_builder_furniture_box, _isHover, 0, _drawSize, _drawSize, 0, 4 + _anim.lift);
	draw_sprite_stretched_ext(spr_builder_furniture_box, _isHover, _boxX, _boxY, _drawSize, _drawSize, _canAfford ? c_white : #9a9a9a, _alpha);

	var _iconAngle = _anim.hover * sin(current_time / 120) * 5;
	var _iconScale = 1 + _anim.hover * .1 + _anim.flash * .15;
	drawSpriteFitCentered(_config.sprite, _centerX + 3, _centerY + 4, _drawSize * .62, _iconScale, _iconAngle, c_black, _alpha * .35);
	drawSpriteFitCentered(_config.sprite, _centerX, _centerY, _drawSize * .62, _iconScale, _iconAngle, _canAfford ? c_white : c_gray, _alpha * (_canAfford ? 1 : .55));

	if (_anim.flash > .02) {
		drawSpriteWithGpuFogStretched(c_white, spr_builder_furniture_box, 0, _boxX, _boxY, _drawSize, _drawSize, 0, _anim.flash * .6 * _alpha);
	}

	if (_anim.hover > .05) {
		var _padding = 6 + (1 - _anim.hover) * 10 + sin(current_time / 180) * 2;
		drawCornerBrackets(_boxX - _padding, _boxY - _padding, _boxX + _drawSize + _padding, _boxY + _drawSize + _padding, _canAfford ? c_white : #ff6b6b, _anim.hover * .9 * _alpha, 10, 2);
	}

	draw_set_alpha(_uiAlpha);
	return _isHover;
}

function drawCraftDetails(_items, _uiAlpha) {
	var _ui = craftDetailsUI;
	var _isHovering = hoverIndex != -1 && isUsing;

	if (_isHovering && (_ui.index != hoverIndex || _ui.category != activeCategory)) {
		_ui.index = hoverIndex;
		_ui.category = activeCategory;
		_ui.slide = 14;
		_ui.alpha = min(_ui.alpha, .4);
	}

	_ui.alpha = lerp(_ui.alpha, _isHovering, .2);
	_ui.slide = lerp(_ui.slide, 0, .2);

	if (_ui.alpha < .02) return;
	if (_ui.category != activeCategory || _ui.index < 0 || _ui.index >= array_length(_items)) return;

	var _entry = _items[_ui.index];
	var _config = global.items[_entry.type][_entry.id];
	var _craft = getCraftingItem(_entry.type, _entry.id);
	var _requirements = is_struct(_craft) ? _craft.requirements : [];
	var _canAfford = canAffordCraft(_entry);
	var _owned = getItemQuantityInInventory(global.inventory, _entry.id, _entry.type);
	var _padding = 20;
	var _requirementSize = 56;
	var _requirementGap = 6;
	var _requirementBorder = 12;

	draw_set_font(fnt_gui_title);
	var _titleWidth = string_width(_config.name);
	var _titleHeight = string_height(_config.name);

	draw_set_font(fnt_gui_default);
	var _ownedText = "Você tem: " + string(_owned);
	var _footerText = _canAfford ? "Clique para criar" : "Materiais insuficientes";
	var _lineHeight = string_height("A");
	var _contentWidth = max(_titleWidth, string_width(_ownedText), string_width(_footerText));

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

	if (_ui.x == 0) {
		_ui.x = _destinyX;
		_ui.y = _destinyY;
	}
	_ui.x = lerp(_ui.x, _destinyX, .25);
	_ui.y = lerp(_ui.y, _destinyY, .25);

	var _alpha = _ui.alpha * _uiAlpha;
	var _x = _ui.x + (_goLeft ? -_ui.slide : _ui.slide);
	var _y = _ui.y;

	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_x, _y, spr_inventory_box, 0, 0, _width, _height);
	draw_sprite_stretched_ext(spr_inventory_box, 0, _x, _y, _width, _height, c_white, _alpha);

	var _contentX = _x + _padding;
	var _contentY = _y + _padding;
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	draw_set_font(fnt_gui_title);
	drawTextShadow(_contentX, _contentY, _config.name, _alpha);
	draw_set_color(c_white);
	draw_text(_contentX, _contentY, _config.name);
	_contentY += _titleHeight + 4;

	draw_set_font(fnt_gui_default);
	draw_set_color(#b8b8b8);
	draw_text(_contentX, _contentY, _ownedText);
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

	draw_set_alpha(_uiAlpha);
	draw_set_color(c_white);
}

function drawCraftingLegend(_x, _y, _uiAlpha) {
	var _legend = "[fa_center][fa_middle][scale,1.5][spr_mouse][/scale] Criar      [#9a9a9a]ESC[/c] Fechar";
	draw_set_font(fnt_gui_default);
	draw_set_alpha(_uiAlpha);
	drawTextShadowScribble(_x, _y, _legend, _uiAlpha);
	draw_text_scribble(_x, _y, _legend);
}

#endregion

function handleClick(_items, _hoverIndex, _xMouse, _yMouse) {
    if (_hoverIndex == -1 || !arrayKeyExists(_items, _hoverIndex)) return false;

    var _hIt = _items[_hoverIndex];
    var _craft = getCraftingItem(_hIt.type, _hIt.id);
    var _conf = global.items[_hIt.type][_hIt.id];

    if (!is_struct(_craft) || !verifyIfHasAllItems(_craft)) {
        playFailSound();
        return false;
    }

    var _gIdx = findCleanIndexFromInventory(global.inventory, "");
    if (_gIdx[0] == -1) {
        var _res = findItemInInventoryById(global.inventory, _conf.itemId, _conf.type);
        if (_res == false) {
            playFailSound();
            createGUINotifyIndicator("Inventário cheio!", _xMouse, _yMouse);
            return false;
        }

        var _qI = global.inventory[# _res[0], _res[1]];
        if (_qI.quantity >= _qI.limit) {
            playFailSound();
            createGUINotifyIndicator("Inventário cheio!", _xMouse, _yMouse);
            return false;
        }
        _gIdx = _res;
    }

    var _bld = constructItem(_conf.type, _conf);
    _bld.quantity = 1;

    if (!addItemToGrid(global.inventory, _bld)) {
        playFailSound();
        createGUINotifyIndicator("Inventário cheio!", _xMouse, _yMouse);
        return false;
    }

	createIndicatorModal(_bld, 1);
    audio_play_sound(snd_builded_item, 0, false);
    audio_play_sound(snd_equip_item, 0, false);

    for (var k = 0; k < array_length(_craft.requirements); k++) {
        var _req = _craft.requirements[k];
        cleanItemInInventoryById(global.inventory, _req.itemId, _req.type, _req.quantity);
    }

	obj_quest_manager.notifyEvent(QuestEvent.ItemCollected, { itemId: _bld.itemId, itemType: _bld.type, quantity: 1});
	return true;
}
