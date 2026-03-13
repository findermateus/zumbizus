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

hoverCraftingForUI = {
	x: 0,
	y: 0,
	dX: 0,
	dY: 0,
	alpha: 0,
	dAlpha: 0
}

hoverIndex = -1;

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

function activateFurniture() {
	openMenu();
	obj_camera.setTargetWithZoom(id);
	isUsing = true;
	setVariablesOpenFurniture();
}

// --- Variáveis de Controle e Juice ---
category_scales = [1, 1, 1]; 
grid_item_scales = array_create(12, 1); 
req_panel_alpha = 0;
modal_opening_scale = 0.8;
modal_y_offset = 1000; // Começa bem abaixo da tela
inputTimer = 0;

// --- Abertura ---
activationMethod = function () {
    playClickSound();
    audio_play_sound(snd_open_crafting_station, 0, false);
    activateFurniture();
    
    // Garantimos que o timer de segurança ainda exista por precaução, 
    // mas o movimento Y fará o trabalho pesado.
    inputTimer = 5; 
}

function hide(){
    if (!global.activeInventory) {
        obj_camera.setDefaultScale();
        obj_camera.target = obj_player;
    }
    
    isUsing = false;
    
    modal_opening_scale = 0.8; 
    modal_y_offset = 1000; // Joga o modal para baixo novamente
    req_panel_alpha = 0;
    inputTimer = 0;
    
    setVariablesCloseFurniture();
    closeMenu();
}

function drawSimpleCraftingStationUI() {
    var _guiWidth = display_get_gui_width();
    var _guiHeight = display_get_gui_height();
    var _xMouse = getMouseXGui();
    var _yMouse = getMouseYGui();
    
    if (inputTimer > 0) inputTimer--;

    // --- ANIMAÇÃO DE ENTRADA (Escala + Deslize Vertical) ---
    modal_opening_scale = lerp(modal_opening_scale, 1, 0.12);
    modal_y_offset = lerp(modal_y_offset, 0, 0.12); // Desliza de 1000 para 0
    
    // O Alpha acompanha a subida
    var _uiAlpha = modal_opening_scale > 0.9 ? 1 : (modal_opening_scale - 0.8) * 5;
    
    var _guiMiddlePoint = _guiWidth / 2;
    var _craftingModalWidth = (_guiWidth * .4) * modal_opening_scale;
    var _craftingModalHeight = (_guiHeight * .8) * modal_opening_scale;
    
    var _craftingModalX = _guiMiddlePoint - (_craftingModalWidth / 2);
    
    // Aplicamos o modal_y_offset aqui para ele surgir de baixo
    var _craftingModalY = ((_guiHeight - _craftingModalHeight) / 2) + modal_y_offset;
    
    // Fundo do Modal
    draw_sprite_stretched_ext(spr_map_list_box, 0, _craftingModalX, _craftingModalY, _craftingModalWidth, _craftingModalHeight, c_white, _uiAlpha);
    
    var _padding = 30;
    var _cx = _craftingModalX + _padding;
    var _cx2 = _craftingModalX + _craftingModalWidth - _padding;
    var _cy = _craftingModalY + _padding;
    
    // --- BOTÃO FECHAR ---
    var _closeBtnSize = 54;
    var _closeX = _craftingModalX + _craftingModalWidth - _closeBtnSize - _padding;
    var _closeY = _craftingModalY + _padding;
    var _isHoverClose = mouseIsOnRectangle(_closeX, _closeY, _closeX + _closeBtnSize, _closeY + _closeBtnSize);
    var _cScale = _isHoverClose ? 1.1 : 1.0;
    
    draw_sprite_stretched_ext(spr_icon_close_button, _isHoverClose, _closeX - (_closeBtnSize*(_cScale-1))/2, _closeY - (_closeBtnSize*(_cScale-1))/2, _closeBtnSize * _cScale, _closeBtnSize * _cScale, c_white, _uiAlpha);
    
    if (_isHoverClose && mouse_check_button_pressed(mb_left)) {
        hide();
        playClickSound();
        return;
    }

    // --- TÍTULO ---
    draw_set_font(fnt_gui_title);
    var _titleText = "[fa_center][fa_middle]Criar Recursos";
    var _titleX = _guiMiddlePoint;
    var _titleY = _cy + 25;
    drawTextShadowScribble(_titleX, _titleY, _titleText, _uiAlpha);
    draw_text_scribble(_titleX, _titleY, _titleText);
    
    _cy += 100;
    
    // --- CATEGORIAS ---
    var _categories = [
        { id: itemCategories.allTypes, title: "Todos"},
        { id: itemCategories.resources, title: "Recursos"},
        { id: itemCategories.tools, title: "Ferramentas"}
    ];
    var _num = array_length(_categories);
    var _tabWidth = (_cx2 - _cx) / _num;

    for (var i = 0; i < _num; i++) {
        var _cat = _categories[i];
        var _tx = _cx + (i * _tabWidth);
        var _isHover = mouseIsOnRectangle(_tx, _cy - 25, _tx + _tabWidth, _cy + 25);
        var _isActive = activeCategory == _cat.id;
        
        category_scales[i] = lerp(category_scales[i], (_isHover || _isActive) ? 1.2 : 1.0, 0.2);
        var _s = category_scales[i];
        
        var _drawH = 50 * _s;
        var _yOffset = (_isHover || _isActive) ? -5 : 0;
        
        draw_sprite_stretched_ext(spr_map_button, _isHover || _isActive, _tx, _cy - (_drawH / 2) + _yOffset, _tabWidth, _drawH, c_white, _uiAlpha);
        
        draw_set_font(fnt_gui_default);
        draw_text_scribble(_tx + _tabWidth/2, _cy + _yOffset, "[fa_center][fa_middle]" + _cat.title);
        
        if (_isHover && mouse_check_button_pressed(mb_left)) {
            playClickSound();
            activeCategory = _cat.id;
            hoverIndex = -1;
        }
    }
    
    _cy += 60;
    
    // --- GRID DE ITENS ---
    var _cols = 4;
    var _mgn = 15;
    var _sqSize = ((_cx2 - _cx) - (_mgn * (_cols + 1))) / _cols;
    var _items = availableItems[activeCategory];
    var _anyHover = false;

    for (var i = 0; i < 12; i++) {
        var _c = i % _cols;
        var _r = floor(i / _cols);
        var _x1 = _cx + _mgn + (_c * (_sqSize + _mgn));
        var _y1 = _cy + _mgn + (_r * (_sqSize + _mgn));
        
        var _exists = arrayKeyExists(_items, i);
        var _isH = mouseIsOnRectangle(_x1, _y1, _x1 + _sqSize, _y1 + _sqSize) && _exists;
        
        grid_item_scales[i] = lerp(grid_item_scales[i], _isH ? 1.15 : 1.0, 0.2);
        var _gs = grid_item_scales[i];
        var _drawSize = _sqSize * _gs;
        var _off = (_sqSize - _drawSize) / 2;

        draw_sprite_stretched_ext(spr_map_button, _isH, _x1 + _off, _y1 + _off, _drawSize, _drawSize, c_white, _uiAlpha);
        
        if (_exists) {
            var _it = _items[i];
            var _conf = global.items[_it.type][_it.id];
            var _itScale = getScale(_sqSize * .7, sprite_get_height(_conf.sprite)) * _gs;
            draw_sprite_ext(_conf.sprite, 0, _x1 + _sqSize/2, _y1 + _sqSize/2, _itScale, _itScale, 0, c_white, _uiAlpha);
            
            if (_isH) {
                if (hoverIndex != i) playHoverSound();
                _anyHover = true;
                hoverIndex = i;
                hoverCraftingForUI.dX = _x1 + _sqSize + 20;
                hoverCraftingForUI.dY = _y1;
            }
        }
    }

    // --- TOOLTIP DE REQUISITOS ---
    req_panel_alpha = lerp(req_panel_alpha, _anyHover ? 1 : 0, 0.15);
    
    if (req_panel_alpha > 0.05 && hoverIndex != -1) {
        var _hIt = _items[hoverIndex];
        var _craft = getItemRequirements(_hIt.type, _hIt.id);
        var _conf = global.items[_hIt.type][_hIt.id];
        
        hoverCraftingForUI.x = lerp(hoverCraftingForUI.x, hoverCraftingForUI.dX, 0.2);
        hoverCraftingForUI.y = lerp(hoverCraftingForUI.y, hoverCraftingForUI.dY, 0.2);
        
        var _finalAlpha = req_panel_alpha * _uiAlpha;
        draw_set_alpha(_finalAlpha);
        draw_set_font(fnt_gui_title);
        
        var _reqText = "[fa_left][fa_bottom][scale,1.1]" + _conf.name;
        drawTextShadowScribble(hoverCraftingForUI.x, hoverCraftingForUI.y, _reqText, _finalAlpha);
        draw_text_scribble(hoverCraftingForUI.x, hoverCraftingForUI.y, _reqText);
        
        for (var j = 0; j < array_length(_craft.requirements); j++) {
            var _r = _craft.requirements[j];
            var _ri = global.items[_r.type][_r.itemId];
            var _cur = getItemQuantityInInventory(global.inventory, _r.itemId, _r.type);
            drawRequirement(_ri.sprite, _ri.name, 64, hoverCraftingForUI.x, hoverCraftingForUI.y + (64 * j), _cur, _r.quantity, _finalAlpha);
        }
        draw_set_alpha(1);
    }

    // --- LÓGICA DE CRAFT (Proteção contra abertura acidental) ---
    if (mouse_check_button_released(mb_left) && _anyHover && inputTimer <= 0) {
        handleClick(_items, hoverIndex, _xMouse, _yMouse);
    }

    draw_set_alpha(1);
}

// --- CLÁUSULAS DE GUARDA (EARLY RETURNS) ---
function handleClick(_items, _hoverIndex, _xMouse, _yMouse) {
    if (_hoverIndex == -1 || !arrayKeyExists(_items, _hoverIndex)) return;
    
    var _hIt = _items[_hoverIndex];
    var _craft = getItemRequirements(_hIt.type, _hIt.id);
    var _conf = global.items[_hIt.type][_hIt.id];

    if (!verifyIfHasAllItems(_craft)) {
        playFailSound();
        return;
    }

    var _gIdx = findCleanIndexFromInventory(global.inventory, "");
    if (_gIdx[0] == -1) {
        var _res = findItemInInventoryById(global.inventory, _conf.itemId, _conf.type);
        if (_res == false) {
            createNotifyIndicator("Inventário cheio!", _xMouse, _yMouse);
            return;
        }
        
        var _qI = global.inventory[# _res[0], _res[1]];
        if (_qI.quantity >= _qI.limit) {
            createNotifyIndicator("Inventário cheio!", _xMouse, _yMouse);
            return;
        }
        _gIdx = _res;
    }

    var _bld = constructItem(_conf.type, _conf);
    _bld.quantity = 1;

    if (!addItemToGrid(global.inventory, _bld)) {
        createNotifyIndicator("Inventário cheio!", _xMouse, _yMouse);
        return;
    }

    createIndicatorModal(_bld, 1);
    audio_play_sound(snd_builded_item, 0, false);
    audio_play_sound(snd_equip_item, 0, false);
    
    for (var k = 0; k < array_length(_craft.requirements); k++) {
        var _req = _craft.requirements[k];
        cleanItemInInventoryById(global.inventory, _req.itemId, _req.type, _req.quantity);
    }
}