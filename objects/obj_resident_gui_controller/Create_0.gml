#macro MODAL_BORDER 50
#macro RESIDENT_OFFSET_VALUE 3
#macro FURNITURE_OFFSET_VALUE 1
#macro FURNITURE_COUNT_PER_PAGE 4
#macro MARGIN_WHEN_HOVER 20

// --- VARIÁVEIS DE ESTADO E LOGICA ---
residentList = [];
residentDisplayOffset = 0;
residentHover = -1;
furnitureHover = -1;
productiveFurnitureList = [];
productiveFurnitureDisplayOffset = 0;
guiHeight = display_get_gui_height();
guiWidth = display_get_gui_width();
guiMouseX = 0;
guiMouseY = 0;
currentState = function (){};
guiCurrentState = function (){};
isHoldingNpc = false;
holdingNpcIndex = -1;
attributeFilter = -1;

// --- ADICIONAL DE JUICE: ESCALAS INDIVIDUAIS ---
npc_grid_scales = array_create(9, 1);           // Escala para os 9 slots de NPCs
furniture_row_scales = array_create(4, 1);      // Escala para as 4 linhas de móveis
category_hover_scales = array_create(5, 1);     // Escala para os 5 botões de categoria
holding_npc_scale = 1;                          // Escala do NPC sendo arrastado
modal_opening_pop = 0.8;                        // Escala de impacto ao abrir o modal

attributes = [
	new BaseAttributeDisplay(baseAttribute.crafting, "Criação", spr_attribute_crafting),
	new BaseAttributeDisplay(baseAttribute.production, "Produção e reciclagem", spr_attribute_production),
	new BaseAttributeDisplay(baseAttribute.supplies, "Suprimentos", spr_attribute_supply),
	new BaseAttributeDisplay(baseAttribute.economy, "Ecônomia", spr_attribute_economy),
	new BaseAttributeDisplay(baseAttribute.battle, "Combate", spr_attribute_battle)
];

npcAttributesUiValues = {
	y: 0,
	x: 0,
	alpha: 0
};

npcAttributeYUiPosition = [0,0,0,0,0,0,0,0,0];

guiModalClosed = {
	destinyHeight: 0,
	destinyWidth: 0,
	destinyX: guiWidth/2,
	destinyY: guiHeight/2,
	destinyAlpha: 0
}

guiModalOpen = {
	destinyHeight: guiHeight - MODAL_BORDER * 2,
	destinyWidth: guiWidth - MODAL_BORDER * 2,
	destinyX: MODAL_BORDER,
	destinyY: MODAL_BORDER,
	destinyAlpha: 1
}

guiModal = {
	x: guiModalClosed.destinyX,
	y: guiModalClosed.destinyY,
	destinyX: guiModalClosed.destinyX,
	destinyY: guiModalClosed.destinyY,
	width: guiModalClosed.destinyWidth,
	height: guiModalClosed.destinyHeight,
	destinyWidth: guiModalClosed.destinyWidth,
	destinyHeight: guiModalClosed.destinyHeight,
	alpha: guiModalClosed.destinyAlpha,
	destinyAlpha: guiModalClosed.destinyAlpha,
	horizontalMargin: 25,
	verticalMargin: 90
}

hoverUiFurnitureIndicator =  {
	x: 0,
	y: 0,
	destinyX: 0,
	destinyY: 0,
	size: 0,
	destinySize: 0,
	alpha: 0,
	destinyAlpha: 1,
	isHoveringTarget: false
};

// --- FUNÇÕES DE CARREGAMENTO ---

function loadNpcMock() {
    return [
        new NPC("Alice The Brave of the Northern Lands", 1, genders.female, "#FFDAB9", new PersonHair(hairIds.afro, "#A52A2A")),
        new NPC("John The Hunter", 2, genders.male, "#8D5524", new PersonHair(hairIds.longStraight, "#A52A2A")),
        new NPC("Riley The Rogue of the Shadows", 3, genders.female, "#C68642", new PersonHair(hairIds.mohawk, "#FF69B4")),
        new NPC("Zara The Wise", 4, genders.others, "#E0AC69", new PersonHair(hairIds.bald, "#FFD700")),
        new NPC("Mateus Who Never Falls?", 5, genders.male, "#F1C27D", new PersonHair(hairIds.quiff, "#ffffff")),
        new NPC("Liam Ironfist", 6, genders.male, "#F1C27D", new PersonHair(hairIds.buzzCut, "#333333")),
        new NPC("Clara Storm of the West", 7, genders.female, "#E0AC69", new PersonHair(hairIds.longStraight, "#B22222")),
        new NPC("Marcus Flame", 8, genders.male, "#C68642", new PersonHair(hairIds.mohawk, "#000000")),
        new NPC("Ella Moonshade", 9, genders.others, "#FFDAB9", new PersonHair(hairIds.afro, "#8B4513")),
        new NPC("Noa Wild", 10, genders.others, "#8D5524", new PersonHair(hairIds.bald, "#7FFF00")),
        new NPC("Victor Dustwalker Silent Arrow", 11, genders.male, "#C68642", new PersonHair(hairIds.quiff, "#AAAAAA")),
        new NPC("Nina Blight", 12, genders.male, "#E0AC69", new PersonHair(hairIds.buzzCut, "#DA70D6")),
        new NPC("Alex Starfall Crimson Moon", 13, genders.male, "#F1C27D", new PersonHair(hairIds.longStraight, "#DC143C")),
        new NPC("Bruce Ironjaw", 14, genders.male, "#8D5524", new PersonHair(hairIds.mohawk, "#D2691E")),
        new NPC("Maya Frost", 15, genders.male, "#FFDAB9", new PersonHair(hairIds.afro, "#191970")),
        new NPC("Sam Echo", 16, genders.male, "#E0AC69", new PersonHair(hairIds.bald, "#00CED1")),
        new NPC("Dante Hollow", 17, genders.male, "#C68642", new PersonHair(hairIds.quiff, "#2F4F4F")),
        new NPC("Ivy Dawn", 18, genders.male, "#F1C27D", new PersonHair(hairIds.buzzCut, "#F08080")),
        new NPC("Sky Ember of the Wastes", 19, genders.male, "#8D5524", new PersonHair(hairIds.longStraight, "#9ACD32")),
        new NPC("Logan Ashfall Flameborne", 20, genders.male, "#FFDAB9", new PersonHair(hairIds.mohawk, "#4B0082"))
    ];
}

function loadResidentList(){
	if (array_length(global.npcList) == 0) {
		residentList = loadNpcMock();
		for (var i = 0; i < array_length(residentList); i ++) {
			var _resident = residentList[i];
			global.npcList[_resident.id] = _resident;
		}
		return;
	}
	
	residentList = [];
	for (var i = 0; i < array_length(global.npcList); i++) {
		if (!is_struct(global.npcList[i])) continue;
		array_push(residentList, global.npcList[i]);
	}
}

function verifyMenuInput(){
	var _keyPressed = keyboard_check_pressed(ord("M"));
	if (!_keyPressed) return;
	if (global.currentBaseMenuOption == menu.resident) {
		deactivateLateralMenuOption(menu.resident);
		return;
	}
	selectLateralMenuOption(menu.resident);
}

// --- CONTROLE DO MODAL ---

function hideMenu() {
	playSwiiimmmSound();
	global.stopInteractions = false;
	guiModal.destinyX = guiModalClosed.destinyX;
	guiModal.destinyY = guiModalClosed.destinyY;
	guiModal.destinyWidth = guiModalClosed.destinyWidth;
	guiModal.destinyHeight = guiModalClosed.destinyHeight;
	guiModal.destinyAlpha = guiModalClosed.destinyAlpha;
	// JUICE: Reset de animações
	modal_opening_pop = 0.8;
}

function setUpModal(){
	loadBaseFurnituresData();
	loadDisplayFurnitures();
	playSwiiimmmSound();
	global.stopInteractions = true;
	guiModal.destinyX = guiModalOpen.destinyX;
	guiModal.destinyY = guiModalOpen.destinyY;
	guiModal.destinyWidth = guiModalOpen.destinyWidth;
	guiModal.destinyHeight = guiModalOpen.destinyHeight;
	guiModal.destinyAlpha = guiModalOpen.destinyAlpha;
	currentState = activeState;
}

function loadDisplayFurnitures() {
	productiveFurnitureList = array_map(global.baseProductiveFurnitures, function (_item) {
		return _item;
	});
	productiveFurnitureDisplayOffset = 0;
}

function activeState() {
	guiCurrentState = drawModalState;
}

// --- SISTEMA DE DESENHO (DRAW LOGIC) ---

function drawModalState() {
	var _modal = getNpcModal();
	drawNpcModal(_modal);
	
	if (guiModal.width < guiModalOpen.destinyWidth/2) return;
	
	var _guiModalData = {
		x: guiModal.x + guiModal.horizontalMargin,
		y: guiModal.y + guiModal.verticalMargin,
		y2: 0
	}
	_guiModalData.y2 = _guiModalData.y + guiModal.height - guiModal.verticalMargin * 2;
	
	drawNpcList(_guiModalData, _modal);
	drawNpcPagination(_guiModalData);
	drawAttributeCategories(_guiModalData, _guiModalData.x, _guiModalData.y);
	drawProductiveFurnitures(_guiModalData, _guiModalData.x, _guiModalData.y);
	
	var _isHoveringNpc = residentHover != -1;
	handleHoldNpc(_isHoveringNpc);
	drawNpcInformationModal();
}

function drawXpBarStatic(_x1, _y1, _x2, _height, _currentXp, _maxXp) {
	var _sprite = spr_level_bar;
	var _totalWidth = _x2 - _x1;
	draw_sprite_stretched(_sprite, 0, _x1, _y1, _totalWidth, _height);
	
	var _progress = (_maxXp > 0) ? clamp(_currentXp / _maxXp, 0, 1) : 0;
	var _fillWidth = _totalWidth * _progress;
	draw_sprite_stretched(_sprite, 2, _x1, _y1, _fillWidth, _height);
	
	draw_set_font(fnt_default_small);
	draw_set_valign(fa_middle);
	draw_set_halign(fa_left);
	
	var _currentXpText = " XP " + string(_currentXp) + "/" + string(_maxXp);
	drawTextShadow(_x1 + 8, _y1 + (_height / 2), _currentXpText, draw_get_alpha());
	draw_text(_x1 + 8, _y1 + (_height / 2), _currentXpText);
	
	draw_set_font(fnt_default);
	draw_set_valign(fa_top);
}

function drawNpcInformationModal() {
	static _y = 0;
	static _x = 0;
	static _residentHover = residentHover;
	static alpha = 0;
	
	var _isHoveringNpc = residentHover != -1;
	var _hasNpcToDraw = _isHoveringNpc && !isHoldingNpc;
	
	alpha = lerp(alpha, _hasNpcToDraw, .15);
	_x = lerp(_x, npcAttributesUiValues.x, .1);
	_y = lerp(_y, npcAttributesUiValues.y, .1);
	
	_residentHover = (residentHover != -1 && residentHover != _residentHover) ? residentHover : _residentHover;
	
	if (alpha <= .1) return;
	
	var _npc = residentList[_residentHover];
	var _height = 64;
	var _margin = 5;
	var _attributesLength = array_length(_npc.attributes);
	
	var _oldAlpha = draw_get_alpha();
	draw_set_alpha(alpha);
	
	for (var i = 0; i < _attributesLength; i++) {
		var _actualY = _y + (i * (_height + _margin));
		var _npcAttribute = _npc.attributes[i];
		var _baseAttribute = getAttributeById(_npcAttribute.id);
		
		var _color = _npcAttribute.level > 0 ? #2E7D32 : c_dkgray;
		var _textDisplay = "[fa_middle]" + _baseAttribute.displayName + " " + string(_npcAttribute.level);
	
		draw_set_font(fnt_gui_long_text);
		var _boxWidth = _height + 24 + string_width(_textDisplay);
	
		draw_sprite_stretched_ext(spr_npc_attribute_block, 1, _x, _actualY, _boxWidth, _height, _color, alpha);
	
		var _iconScale = getScale(_height - 24, sprite_get_height(_baseAttribute.icon));
		drawSpriteShadow(_x + _height/2, _actualY + _height/2, _baseAttribute.icon, 1, 0, _iconScale, _iconScale, 2, 2, alpha);
		draw_sprite_ext(_baseAttribute.icon, 0, _x + _height/2, _actualY + _height/2, _iconScale, _iconScale, 0, c_white, alpha);
	
		drawTextShadowScribble(_x + _height, _actualY + _height/2, _textDisplay, alpha);
		draw_text_scribble(_x + _height, _actualY + _height/2, _textDisplay);
	}
	draw_set_alpha(_oldAlpha);
}

// --- PAGINAÇÃO E OFFSETS ---

function increaseNpcDisplayOffset() {
	var _auxMax = array_length(residentList) - RESIDENT_OFFSET_VALUE * 3;
	var _max = _auxMax >= 0 ? _auxMax : 0;
	if (residentDisplayOffset < _max) {
		residentDisplayOffset += RESIDENT_OFFSET_VALUE;
		return true;
	}
	playFailSound();
	return false;
}

function decreaseNpcDisplayOffset() { 
	if (residentDisplayOffset > 0) {
		residentDisplayOffset -= RESIDENT_OFFSET_VALUE;
		return true;
	}
	playFailSound();
	return false;
}

function increaseFurnitureDisplayOffset() {
	var _max = max(array_length(productiveFurnitureList) - FURNITURE_COUNT_PER_PAGE, 0);
	if (productiveFurnitureDisplayOffset < _max) {
		productiveFurnitureDisplayOffset += FURNITURE_OFFSET_VALUE;
		return true;
	}
	playFailSound();
	return false;
}

function decreaseFurnitureDisplayOffset() { 
	if (productiveFurnitureDisplayOffset > 0) {
		productiveFurnitureDisplayOffset -= FURNITURE_OFFSET_VALUE;
		return true;
	}
	playFailSound();
	return false;
}

function drawNpcPagination(_guiModalData) {
	static _button1Y = getButton1Value();
	static _button2Y = getButton2Value();
	static _hoverPagination = -1;
	var _isHovering = drawPaginationButton(_guiModalData, _button1Y, _button2Y, decreaseNpcDisplayOffset, increaseNpcDisplayOffset);
	var _canApply = verifyConditionsToApplyHoverEffects();
	
	if (!_canApply) {
		_button1Y = getButton1Value();
		_button2Y = getButton2Value();
	} else {
		_button1Y = lerp(_button1Y, getButton1Value() + (_isHovering.up ? -MARGIN_WHEN_HOVER : 0), .1);
		_button2Y = lerp(_button2Y, getButton2Value() + (_isHovering.down ? MARGIN_WHEN_HOVER : 0), .1);
		if (_isHovering.up || _isHovering.down) {
			var _val = _isHovering.up ? 1 : 2;
			if (_hoverPagination != _val) playHoverSound();
			_hoverPagination = _val;
		}
	}
}

function getButton1Value(){ return guiModal.y + guiModal.verticalMargin; }
function getButton2Value() {
	var _usableHeight = guiModal.height - (guiModal.verticalMargin * 2);
	return (guiModal.y + guiModal.verticalMargin) + (_usableHeight * 0.48) + (_usableHeight - (2 * (_usableHeight * 0.48)));
}

function drawNpcModal(_modal) {
	modal_opening_pop = lerp(modal_opening_pop, 1, 0.1);
	draw_set_alpha(guiModal.alpha);
	// JUICE: Aplicando o Pop de abertura no modal
	var _drawW = _modal.width * modal_opening_pop;
	var _drawH = _modal.height * modal_opening_pop;
	var _offX = (_modal.width - _drawW) / 2;
	var _offY = (_modal.height - _drawH) / 2;
	
	draw_sprite_stretched(spr_inventory_box, 0, _modal.x + _offX, _modal.y + _offY, _drawW, _drawH);
	draw_set_alpha(1);
}

function drawNpcList(_guiModal, _currentModal) {
	var _totalHeight = _guiModal.y2 - _guiModal.y;
	var _margin = 20;
	var _squareSize = (_totalHeight - (_margin * 2)) / 3;
	var _xStart = _guiModal.x;
	var _x = _xStart;
	var _y = _guiModal.y;
	static _npcGridUIValues = getNpcGridUIValues();
	var _isHoveringAny = false;
	var _xEndPosition = _x;
	
	for (var i = 0; i < 9; i++) {
		var _npcUiValue = _npcGridUIValues[i];
		var _count = i + residentDisplayOffset;
		var _npc = _count < array_length(residentList) ? residentList[_count] : undefined;
		var _mouseOn = mouseIsOnRectangle(_x, _y - MARGIN_WHEN_HOVER, _x + _squareSize, _y + _squareSize);
		
		handleUiData(_npcUiValue, _x, _y, residentHover == _count);
		
		// JUICE: Escala individual do NPC
		npc_grid_scales[i] = lerp(npc_grid_scales[i], (_mouseOn && _npc != undefined) ? 1.1 : 1.0, 0.2);
		
		if (_mouseOn && _npc != undefined) {
			if (residentHover != _count) playHoverSound();
			residentHover = _count;
			_isHoveringAny = true;
			
			//DEBUG SÓ PRA AUMENTAR O NÍVEL
			if (mouse_check_button_pressed(mb_right)) {
		        var _attrToBoost = (attributeFilter != -1) ? attributeFilter : baseAttribute.supplies;
        
		        _npc.attributes[_attrToBoost].increaseXp(100); 
		        playClickSound();
		    }
			
			npcAttributesUiValues.x = _x + _squareSize;
			npcAttributesUiValues.y = _npcUiValue.y;
		}
		
		// Aplicando escala no desenho da Box
		var _s = npc_grid_scales[i];
		var _drawS = _squareSize * _s;
		var _off = (_squareSize - _drawS) / 2;
		drawNpcBox(_npcUiValue.x + _off, _npcUiValue.y + _off, _drawS, _npc, _mouseOn && verifyConditionsToApplyHoverEffects() || holdingNpcIndex == _count, i);
		
		_x += _squareSize + _margin;
		if ((i + 1) % 3 == 0) {
			_xEndPosition = _x;
	        _x = _xStart;
	        _y += _squareSize + _margin;
	    }
	}
	if (!_isHoveringAny) residentHover = -1;
	_guiModal.x = _xEndPosition;
}

function findWorkerIndexInDisplayListByNpcId(_id){
	for (var i = 0; i < array_length(residentList); i++) {
		if (residentList[i].id == _id) return i;
	}
	return false;
}

function handleHoldNpc(_isHoveringNpc){
	if (mouse_check_button(mb_left) && _isHoveringNpc && holdingNpcIndex == -1) {
		if (holdingNpcIndex != residentHover) playClickSound();
		holdingNpcIndex = residentHover;
		isHoldingNpc = true;
	}
	
	if (mouse_check_button(mb_left) && holdingNpcIndex != -1) {
		var _npc = residentList[holdingNpcIndex];
		var _mouseX = device_mouse_x_to_gui(0);
		var _mouseY = device_mouse_y_to_gui(0);
		
		holding_npc_scale = lerp(holding_npc_scale, 1.2, 0.2);
		var _boxSize = 90 * holding_npc_scale;
		
		draw_set_alpha(.7);
		drawNpcHead(_mouseX, _mouseY - _boxSize*.1, _boxSize, _boxSize, _npc.hair, getHexFromString(_npc.skinColor), _npc.gender);
		draw_set_alpha(1);
	}
	
	if (!mouse_check_button(mb_left)) {
		isHoldingNpc = false;
		holdingNpcIndex = -1;
		holding_npc_scale = 1;
	}
}

function drawPaginationButton(_gui, _button1Y, _button2Y, _actionUp, _actionDown) {
	var _buttonWidth = 60;
	var _usableHeight = guiModal.height - (guiModal.verticalMargin * 2);
	var _buttonHeight = _usableHeight * 0.48;
	var _isHovering = { up: false, down: false }
	
	// Botão Up
	var _hUp = mouseIsOnRectangle(_gui.x, _button1Y - MARGIN_WHEN_HOVER, _gui.x + _buttonWidth, _button1Y + _buttonHeight);
	if (_hUp) {
		_isHovering.up = true;
		drawSpriteShadowStretched(_gui.x, _button1Y, spr_base_resident_grid, 0, 0, _buttonWidth, _buttonHeight, 0);
		if (mouse_check_button_released(mb_left)) { playClickSound(); _actionUp(); }
	}
	draw_sprite_stretched(spr_base_resident_grid, _hUp, _gui.x, _button1Y, _buttonWidth, _buttonHeight);
	draw_sprite_ext(spr_builder_arrow_indicator, 0, _gui.x + _buttonWidth/2, _button1Y + _buttonHeight/2, _hUp ? 1.4 : 1.2, _hUp ? 1.4 : 1.2, 0, c_white, 1);
	
	// Botão Down
	var _hDown = mouseIsOnRectangle(_gui.x, _button2Y, _gui.x + _buttonWidth, _button2Y + _buttonHeight + MARGIN_WHEN_HOVER);
	if (_hDown) {
		_isHovering.down = true;
		drawSpriteShadowStretched(_gui.x, _button2Y, spr_base_resident_grid, 0, 0, _buttonWidth, _buttonHeight, 0, -4);
		if (mouse_check_button_released(mb_left)) { playClickSound(); _actionDown(); }
	}
	draw_sprite_stretched(spr_base_resident_grid, _hDown, _gui.x, _button2Y, _buttonWidth, _buttonHeight);
	draw_sprite_ext(spr_builder_arrow_indicator, 0, _gui.x + _buttonWidth/2, _button2Y + _buttonHeight/2, _hDown ? 1.4 : 1.2, _hDown ? -1.4 : -1.2, 0, c_white, 1);
	
	_gui.x += _buttonWidth + 30;
	return _isHovering;
}

function drawAttributeCategories(_gui, _x, _y) {
	var _totalItems = array_length(attributes);
	var _usableHeight = guiModal.height - (guiModal.verticalMargin * 2);
	var _boxSize = _usableHeight / (_totalItems + (_totalItems - 1));
	var _startY = guiModal.y + guiModal.verticalMargin;
	static _categoryValues = npcAttributesInitialStats(5);
	static hoverCategory = -1;

	for (var i = 0; i < _totalItems; i++) {
		var _attribute = attributes[i];
		var _currentY = _startY + i * (_boxSize + _boxSize);
		var _catUI = _categoryValues[i];
		var _isHover = mouseIsOnRectangle(_x, _currentY - MARGIN_WHEN_HOVER, _x + _boxSize + MARGIN_WHEN_HOVER, _currentY + _boxSize);
		var _isSelected = _attribute.id == attributeFilter;
		
		if (_catUI.x == 0) { _catUI.x = _x; _catUI.y = _currentY; }
		
		// JUICE: Escala do ícone de categoria
		category_hover_scales[i] = lerp(category_hover_scales[i], (_isHover || _isSelected) ? 1.15 : 1.0, 0.2);
		var _s = category_hover_scales[i];
		
		var _canApply = verifyConditionsToApplyHoverEffects() * _isHover;
		_catUI.y = lerp(_catUI.y, _currentY - (MARGIN_WHEN_HOVER * _canApply), .1);
		_catUI.x = lerp(_catUI.x, _x, .1);
		
		var _drawS = _boxSize * _s;
		var _off = (_boxSize - _drawS) / 2;

		if (_isHover) {
			drawSpriteShadowStretched(_catUI.x + _off, _catUI.y + _off, spr_base_resident_button, 0, 0, _drawS, _drawS);
			if (hoverCategory != i) playHoverSound();
			hoverCategory = i;
		}
		draw_sprite_stretched( (_isHover || _isSelected) ? spr_base_resident_button : spr_base_resident_box, 0, _catUI.x + _off, _catUI.y + _off, _drawS, _drawS);
		
		var _scale = getScale(_boxSize * .7, sprite_get_width(_attribute.icon)) * _s;
		draw_sprite_ext(_attribute.icon, 0, _catUI.x + _boxSize/2, _catUI.y + _boxSize/2, _scale, _scale, 0, c_white, 1);
		
		if (_isHover && mouse_check_button_pressed(mb_left)) handleCategoryClick(_attribute.id);
	}
	_gui.x += _boxSize + 30; 
}

function handleCategoryClick(_attributeId) {
	playClickSound();
	attributeFilter = _attributeId == attributeFilter ? -1 : _attributeId;
	array_foreach(npcAttributeYUiPosition, function (_item, _index) { npcAttributeYUiPosition[_index] -= 25; })
	residentDisplayOffset = 0;
	productiveFurnitureDisplayOffset = 0;
	
	if (attributeFilter == -1) { loadDisplayFurnitures(); return; }
	
	array_sort(residentList, function(a, b) {
		var attrA = a.attributes[attributeFilter];
		var attrB = b.attributes[attributeFilter];
		return (attrA.level != attrB.level) ? attrB.level - attrA.level : attrB.xp - attrA.xp;
	});
	
	productiveFurnitureList = array_filter(global.baseProductiveFurnitures, function (_item) {
		return global.productiveFurnitures[? _item.furnitureId].attribute == attributeFilter;
	});
}

function drawProductiveFurnitures(_gui, _x, _y) {
	var _totalItemsPerPage = FURNITURE_COUNT_PER_PAGE;
	var _spacing = 20;
	var _usableHeight = guiModal.height - (guiModal.verticalMargin * 2);
	var _boxHeight = (_usableHeight - ((_totalItemsPerPage - 1) * _spacing)) / _totalItemsPerPage;
	var _boxWidth = ((guiModal.x + guiModal.width) - guiModal.horizontalMargin * 2) - _gui.x - 60;
	var _startY = guiModal.y + guiModal.verticalMargin;
	static furnitureUiValues = getFurnitureUIValues(FURNITURE_COUNT_PER_PAGE);
	hoverUiFurnitureIndicator.isHoveringTarget = false;
	static hoverFurniture = -1;

	for (var i = 0; i < _totalItemsPerPage; i++) {
		var _idx = i + productiveFurnitureDisplayOffset;
		if (array_length(productiveFurnitureList) <= _idx) continue;
		
		var _furniture = productiveFurnitureList[_idx];
		var _isHover = mouseIsOnRectangle(_x, _startY + i*(_boxHeight+_spacing) - MARGIN_WHEN_HOVER, _x + _boxWidth, _startY + i*(_boxHeight+_spacing) + _boxHeight);
		
		// JUICE: Escala da linha do móvel
		furniture_row_scales[i] = lerp(furniture_row_scales[i], _isHover ? 1.02 : 1.0, 0.15);
		var _s = furniture_row_scales[i];
		
		if (_isHover) { if (hoverFurniture != _idx) playHoverSound(); hoverFurniture = _idx; }
		
		handleUiData(furnitureUiValues[i], _x, _startY + i*(_boxHeight+_spacing), _isHover, false, 10);
		
		var _drawW = _boxWidth * _s;
		var _drawH = _boxHeight * _s;
		var _offX = (_boxWidth - _drawW) / 2;
		var _offY = (_boxHeight - _drawH) / 2;
		
		draw_sprite_stretched(spr_base_resident_box, 0, furnitureUiValues[i].x + _offX, furnitureUiValues[i].y + _offY, _drawW, _drawH);
		
        drawProductiveFurnitureIcon(furnitureUiValues[i].x, furnitureUiValues[i].y, _boxHeight, 15, _furniture.furniture);
        drawFurnitureTitle(furnitureUiValues[i].x + _boxHeight, furnitureUiValues[i].y, 15, _boxHeight, _furniture.furniture, _boxWidth - _boxHeight - 40);
        drawFurnitureWorkers(furnitureUiValues[i].x + _boxHeight + 15, furnitureUiValues[i].y, 15, _boxHeight, furnitureUiValues[i].x + _boxWidth - 10, _furniture);
		
		var _attrIcon = attributes[global.productiveFurnitures[? _furniture.furnitureId].attribute].icon;
		drawSpriteShadowStretched(furnitureUiValues[i].x + 10, furnitureUiValues[i].y + 10, _attrIcon, 0, 0, 40, 40);
		draw_sprite_stretched(_attrIcon, 0, furnitureUiValues[i].x + 10, furnitureUiValues[i].y + 10, 40, 40);
	}
	loadFurnitureHoverIndicatorValues();
	drawFurnitureHoverIndicatorValues();
	_gui.x += _boxWidth + 15;
	drawFurniturePagination(_gui)
}

// --- AUXILIARES E INDICADORES ---

function drawFurnitureHoverIndicatorValues() {
	draw_sprite_stretched_ext(spr_hover_indicator, 0, hoverUiFurnitureIndicator.x, hoverUiFurnitureIndicator.y, hoverUiFurnitureIndicator.size, hoverUiFurnitureIndicator.size, c_white, hoverUiFurnitureIndicator.alpha);
}

function loadFurnitureHoverIndicatorValues() {
	if (hoverUiFurnitureIndicator.x == 0) {
		hoverUiFurnitureIndicator.x = hoverUiFurnitureIndicator.destinyX;
		hoverUiFurnitureIndicator.y = hoverUiFurnitureIndicator.destinyY;
		hoverUiFurnitureIndicator.size = hoverUiFurnitureIndicator.destinySize;
		return;
	}
	hoverUiFurnitureIndicator.x = lerp(hoverUiFurnitureIndicator.x, hoverUiFurnitureIndicator.destinyX, .2);
	hoverUiFurnitureIndicator.y = lerp(hoverUiFurnitureIndicator.y, hoverUiFurnitureIndicator.destinyY, .2);
	hoverUiFurnitureIndicator.alpha = lerp(hoverUiFurnitureIndicator.alpha, hoverUiFurnitureIndicator.isHoveringTarget, .2);
	hoverUiFurnitureIndicator.size = lerp(hoverUiFurnitureIndicator.size, hoverUiFurnitureIndicator.destinySize, .2);
}

function drawFurnitureWorkers(_x, _y, _margin, _boxHeight, _boxX2, _furniture) {
	var _productiveFurniture = global.productiveFurnitures[? _furniture.furniture.furnitureId];
    var _totalWorkers = _productiveFurniture.workerQuantity;
    var _maxSize = _boxHeight * .4;
    var _adjustedSize = min(_maxSize, ((_boxX2 - _x) - ((_totalWorkers - 1) * _margin)) / _totalWorkers);
	
	var _workerIsAbleToWork = false;
	var _holdingNpc = (holdingNpcIndex != -1) ? residentList[holdingNpcIndex] : -1;
	if (_holdingNpc != -1) _workerIsAbleToWork = verifyAllFurnitureWorkerRequirements(_productiveFurniture.workerRequirements, _holdingNpc);
	
	for (var i = 0; i < _totalWorkers; i++) {
		var _boxX = _x + i * (_adjustedSize + _margin);
		var _boxY = _y + _boxHeight - _adjustedSize - 10;
		var _isHover = mouseIsOnRectangle(_boxX, _boxY, _boxX + _adjustedSize, _boxY + _adjustedSize);
		var _color = c_white;
		var _sprite = spr_base_resident_box;
		
		if (_isHover){
			var _resp = handleWorkerBoxHover(_boxX, _boxY, _boxX + _adjustedSize, _boxY + _adjustedSize, _furniture.furniture.furnitureId, _furniture.objectId, i, _holdingNpc, _workerIsAbleToWork);
			_color = _resp ? c_white : #d42f2f;
			_sprite = spr_base_resident_button;
		}
		draw_sprite_stretched_ext(_sprite, 0, _boxX, _boxY, _adjustedSize, _adjustedSize, _color, 1);
		drawFurnitureWorker(_boxX + _adjustedSize/2, _boxY, _adjustedSize, _furniture.furniture.furnitureId, _furniture.objectId, i);
    }
}

function drawFurnitureWorker(_x, _y, _size, _furnitureId, _objectId, _index){
	var _worker = getFurnitureWorkers(_furnitureId, _objectId)[_index];
	if (_worker == -1) {
		var _lvl = global.productiveFurnitures[? _furnitureId].workerRequirements[0].level;
		var _scale = getScale(_size * .6, string_width("Lv " + string(_lvl)));
		draw_set_font(fnt_gui_default);
		draw_text_scribble(_x, _y + _size / 2, "[fa_center][fa_middle][scale," + string(_scale) + "]Lv " + string(_lvl));
		return;
	}
	var _npc = global.npcList[_worker.id];
	drawNpcHead(_x, _y, _size * .6, _size, _npc.hair, getHexFromString(_npc.skinColor), _npc.gender);
}

function handleWorkerBoxHover(_x, _y, _x2, _y2, _fId, _oId, i, _hNpc, _able){
	hoverUiFurnitureIndicator.destinyX = _x;
	hoverUiFurnitureIndicator.destinyY = _y;
	hoverUiFurnitureIndicator.destinySize = _x2 - _x;
	
	if (_hNpc == -1) {
		var _w = getFurnitureWorkers(_fId, _oId)[i];
		hoverUiFurnitureIndicator.isHoveringTarget = true;
		if (_w != -1 && mouse_check_button(mb_left)) holdNpcFromFurniture(_w);
	
		return true;
	}
	
	if (!_able){
		hoverUiFurnitureIndicator.isHoveringTarget = false;
		
		return false;
	}
	
	hoverUiFurnitureIndicator.isHoveringTarget = true;
	if (mouse_check_button_released(mb_left)) {
		playTickSound();
		addWorkerToFurniture(_fId, _oId, i, _hNpc.id);
	}
	
	return true;
}

function holdNpcFromFurniture(_worker) {
	playClickSound();
	holdingNpcIndex = findWorkerIndexInDisplayListByNpcId(_worker.id);
}

function verifyAllFurnitureWorkerRequirements(_reqs, _worker) {
	var _can = true;
	for (var i = 0; i < array_length(_reqs); i ++) if (!_reqs[i].verifyWorker(_worker)) _can = false;
	return _can;
}

function drawFurnitureLevel(_x, _y, _margin, _size, _boxX2, _furniture) {
	var _productiveFurniture = global.productiveFurnitures[? _furniture.furnitureId]
}

function drawFurnitureTitle(_x, _y, _margin, _size, _furniture, _maxWidth) {
	_x += 10;
	var _scale = min(1, _maxWidth / string_width(_furniture.title)); 
	var _midY = getMiddlePoint(_y + _margin, _y + _margin + ((_size - _margin * 2) * .4));
	var _text = "[scale," + string(_scale) + "][fa_middle]" + _furniture.title;
	drawTextShadowScribble(_x, _midY, _text, 1);
	draw_text_scribble(_x, _midY, _text);
	return _x + (string_width(_furniture.title) * _scale);
}

function getFurnitureUIValues(_qty){
	var _l = [];
	for (var i = 0; i < _qty; i ++) array_push(_l, {x:0, y:0, destinyY:0, destinyX:0, lerpEffect:.1});
	return _l;
}

function getAttributeById(_id){
	for (var i = 0; i < array_length(attributes); i ++) if (attributes[i].id == _id) return attributes[i];
	return false;
}

function drawProductiveFurnitureIcon(_x, _y, _size, _margin, _furniture){
	var _icon = _furniture.icon;
	var _actualSize = _size - (_margin * 2);
	var _scale = getScale(_actualSize - 10, sprite_get_width(_icon));
	draw_sprite_ext(_icon, 0, _x + _size/2 - (sprite_get_width(_icon)*_scale)/2 + 5, _y + _size/2 - (sprite_get_height(_icon)*_scale)/2 + 5, _scale, _scale, 0, c_white, 1);
	return _x + _actualSize;
}

function drawFurniturePagination(_gui) {
	static _b1Y = getButton1Value();
	static _b2Y = getButton2Value();
	static _hPag = -1;
	var _isH = drawPaginationButton(_gui, _b1Y, _b2Y, decreaseFurnitureDisplayOffset, increaseFurnitureDisplayOffset);
	if (!verifyConditionsToApplyHoverEffects()) { _b1Y = getButton1Value(); _b2Y = getButton2Value(); }
	else {
		_b1Y = lerp(_b1Y, getButton1Value() + (_isH.up ? -MARGIN_WHEN_HOVER : 0), .1);
		_b2Y = lerp(_b2Y, getButton2Value() + (_isH.down ? MARGIN_WHEN_HOVER : 0), .1);
		if (_isH.up || _isH.down) { var _v = _isH.up ? 1 : 2; if (_hPag != _v) playHoverSound(); _hPag = _v; }
	}
}

function npcAttributesInitialStats(_total) {
	var _v = [];
	for (var i = 0; i < _total; i++) _v[i] = { hOffset: 0, vOffset: 0, x: 0, y: 0 };
	return _v;
}

function verifyConditionsToApplyHoverEffects(_ignoreHold = true) {
	var _animating = (guiModal.width < guiModal.destinyWidth * .95) || guiModal.destinyWidth == guiModalClosed.destinyWidth;
	return !_animating && (_ignoreHold ? !isHoldingNpc : true);
}

function handleUiData(_ui, _x, _y, _isH, _ignore = true, _force = 20){
	if (_ui.x == 0) { _ui.x = _x; _ui.y = _y; }
	if (!verifyConditionsToApplyHoverEffects(_ignore)) { _ui.x = _x; _ui.y = _y; return; }
	_ui.destinyX = _x;
	_ui.destinyY = _isH ? _y - _force : _y;
	_ui.x = lerp(_ui.x, _ui.destinyX, _ui.lerpEffect);
	_ui.y = lerp(_ui.y, _ui.destinyY, _ui.lerpEffect);
}

function getNpcGridUIValues(){
	var _v = [];
	for(var i=0; i<9; i++) array_push(_v, {x:0, y:0, destinyY:0, destinyX:0, lerpEffect:.1});
	return _v;
}

function drawNpcBox(_x, _y, _size, _npc, _mouseOn, i){
	draw_set_alpha(!_mouseOn ? .6 : .8);
	draw_sprite_stretched(spr_base_resident_grid, !_mouseOn ? 0 : 1, _x, _y, _size, _size);
	draw_set_alpha(1);
	if (_npc != undefined) drawNpcInsideBox(_x + 6, _y + 6, _npc, _size - 12, i);
}

function drawNpcInsideBox(_x, _y, _npc, _size, i) {
	var _midX = _x + (_size/2);
	var _scale = min(1, _size / string_width(_npc.name)) * (guiModal.width / guiModalOpen.destinyWidth);
	
	drawNpcHead(_midX, _y, 110, _size, _npc.hair, getHexFromString(_npc.skinColor), _npc.gender);
	draw_set_halign(fa_center); draw_set_valign(fa_middle);
	drawTextShadow(_midX, _y + _size*.9, _npc.name, 1, 4, _scale);
	draw_text_transformed(_midX, _y + _size*.9, _npc.name, _scale, _scale, 0);
	draw_set_valign(fa_top); draw_set_halign(fa_left);
	
	if (attributeFilter == -1) npcAttributeYUiPosition[i] = _y - 25;
	else drawNpcAttributeLevel(_npc, _size, _x, _y, i);
}

function drawNpcAttributeLevel(_npc, _size, _x, _y, i){
	npcAttributeYUiPosition[i] = lerp(npcAttributeYUiPosition[i], _y, .1);
	var _attrData = global.attributes[attributeFilter];
	var _iconS = _size * .20;
	
	drawSpriteShadowStretched(_x, npcAttributeYUiPosition[i] + 10, _attrData.icon, 0, 0, _iconS, _iconS, 2, 2);
	draw_sprite_stretched(_attrData.icon, 0, _x, npcAttributeYUiPosition[i] + 10, _iconS, _iconS);
	
	var _lvlText = "Nível: " + string(_npc.attributes[attributeFilter].level);
	draw_set_font(fnt_default_small); draw_set_valign(fa_middle);
	drawTextShadow(_x + _iconS + 10, npcAttributeYUiPosition[i] + 15, _lvlText, 1);
	draw_text(_x + _iconS + 10, npcAttributeYUiPosition[i] + 15, _lvlText);
	drawXpBarStatic(_x + _iconS + 10, npcAttributeYUiPosition[i] + 15 + _iconS * .3, _x + _size - 10, _iconS/2, _npc.attributes[attributeFilter].xp, 100);
	draw_set_valign(fa_top); draw_set_font(fnt_gui_default);
}

function getNpcModal(){
	guiModal.x = lerp(guiModal.x, guiModal.destinyX, .1);
	guiModal.y = lerp(guiModal.y, guiModal.destinyY, .1);
	guiModal.width = lerp(guiModal.width, guiModal.destinyWidth, .1);
	guiModal.height = lerp(guiModal.height, guiModal.destinyHeight, .1);
	guiModal.alpha = lerp(guiModal.alpha, guiModal.destinyAlpha, .1);
	return { x: guiModal.x, y: guiModal.y, width: guiModal.width, height: guiModal.height };
}

function handleOffsetCount() {
	residentDisplayOffset = clamp(residentDisplayOffset, 0, max(array_length(residentList) - RESIDENT_OFFSET_VALUE * 3, 0));
	productiveFurnitureDisplayOffset = clamp(productiveFurnitureDisplayOffset, 0, max(array_length(productiveFurnitureList) - FURNITURE_COUNT_PER_PAGE, 0));
}

loadResidentList();