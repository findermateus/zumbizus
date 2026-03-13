event_inherited();
actionDescription = "Iniciar Expedição";
isUsing = false;
hasSelected = false;
hoverMap = undefined;
defaultMenuYPosition = display_get_gui_height() + 100;
menuYPosition = defaultMenuYPosition;
titleAlpha = 0;
loadFurnitureByDefaultId();
setShadow(sprite_index, image_index, 1);

activationMethod = function () {
	
	//sons
	playClickSound();
	audio_play_sound(snd_open_crafting_station, 0, false);
	
	//padrão e obrigatório
	openMenu();
	setVariablesOpenFurniture();
	
	//do objeto
	isUsing = true;
	menuYPosition = defaultMenuYPosition;
}

function hide(){
	if (!global.activeInventory) {
		obj_camera.setDefaultScale();
		obj_camera.target = obj_player;
	}
	isUsing = false;
	
	setVariablesCloseFurniture();
	closeMenu();
}

map_hover_scales = [];
content_alpha = 0;    
last_hovered_id = -1; 

function drawUI() {
    var _guiWidth = display_get_gui_width();
    var _guiHeight = display_get_gui_height();
    
    var _targetY = isUsing ? _guiHeight * 0.2 : defaultMenuYPosition;
    menuYPosition = lerp(menuYPosition, _targetY, 0.1);
    titleAlpha = lerp(titleAlpha, isUsing, 0.1);
    
    if (!isUsing && menuYPosition > _guiHeight + 10) return;

    var _middlePoint = _guiWidth / 2;
    var _titleY = menuYPosition - 100 + (sin(current_time * 0.003) * 5);
    
    draw_set_alpha(titleAlpha);
    draw_set_font(fnt_gui_title);
	var _selectDestinyText = "[fa_center][fa_middle]" + "Selecionar Destino"
    drawTextShadowScribble(_middlePoint, _titleY, _selectDestinyText, titleAlpha);
    draw_text_scribble(_middlePoint, _titleY, _selectDestinyText);

    var _maps = global.maps;
    var _mapKeys = struct_get_names(_maps);
    var _mapsBlockWidth = _guiWidth * .2;
    var _mapListX = (_guiWidth / 2) - _mapsBlockWidth - 100;
    var _menuBoxY = menuYPosition - 20;
    var _menuHeight = 600;
    
    draw_sprite_stretched_ext(spr_map_list_box, 0, _mapListX - 20, _menuBoxY, _mapsBlockWidth + 40, _menuHeight, c_white, titleAlpha);
    
    var _mapListY = menuYPosition + 10;
    var _currentHovered = undefined;

    for (var i = 0; i < array_length(_mapKeys); i++) {
        var _map = _maps[$ _mapKeys[i]];
        
        if (i >= array_length(map_hover_scales)) map_hover_scales[i] = 1;
        
        var _buttonHeight = 60;
        var _buttonY = _mapListY + (i * (_buttonHeight + 10));
        
        var _mouseIsHovering = mouseIsOnRectangle(_mapListX, _buttonY, _mapListX + _mapsBlockWidth, _buttonY + _buttonHeight) && isUsing;
        
        var _targetScale = _mouseIsHovering ? 1.1 : 1.0;
        map_hover_scales[i] = lerp(map_hover_scales[i], _targetScale, 0.2);
        
        var _scale = map_hover_scales[i];
        var _bW = _mapsBlockWidth * _scale;
        var _bH = _buttonHeight * _scale;
        var _offX = (_mapsBlockWidth - _bW) / 2;
        var _offY = (_buttonHeight - _bH) / 2;

        draw_sprite_stretched_ext(spr_map_button, _mouseIsHovering, _mapListX + _offX, _buttonY + _offY, _bW, _bH, c_white, titleAlpha);
        
		draw_set_font(fnt_gui_default);
        draw_text_scribble(_mapListX + _mapsBlockWidth/2, _buttonY + _buttonHeight/2, "[fa_center][fa_middle]" + _map.name);
        
        if (_mouseIsHovering) {
            _currentHovered = _map;
            if (mouse_check_button_pressed(mb_left) && !hasSelected) {
                hide();
                playClickSound();
                instance_create_layer(0, 0, "Controllers", obj_map_transition, { destination: _map.room, mapName: _map.name });
            }
        }
    }

    if (_currentHovered != undefined) {
        if (hoverMap == undefined || _currentHovered.name != hoverMap.name) {
            hoverMap = _currentHovered;
            content_alpha = 0;
            playHoverSound();
        }
    }

    if (hoverMap != undefined) {
        content_alpha = lerp(content_alpha, 1, 0.1);
        var _descX = _guiWidth / 2 - 50;
        var _descW = 600;
        
        draw_sprite_stretched_ext(spr_map_list_box, 0, _descX, _menuBoxY, _descW, _menuHeight, c_white, titleAlpha);
        
        var _drawAlpha = content_alpha * titleAlpha;
        draw_set_alpha(_drawAlpha);
        
        var _midX = _descX + (_descW / 2);
        var _contentY = _menuBoxY + 40 + (10 * (1 - content_alpha));
        
        draw_set_font(fnt_gui_title);
		
		var _hoverMap = "[fa_center][fa_middle]" + hoverMap.name;
        drawTextShadowScribble(_midX, _contentY, _hoverMap, _drawAlpha);
        draw_text_scribble(_midX, _contentY, _hoverMap);
        
        var _imgW = _descW - 80;
        var _imgH = _menuHeight * 0.4;
        draw_sprite_stretched(hoverMap.image, 0, _midX - _imgW/2, _contentY + 60, _imgW, _imgH);
        
        draw_set_font(fnt_gui_long_text);
        draw_text_ext(_descX + 40, _contentY + 60 + _imgH + 40, hoverMap.description, -1, _descW - 80);
    }
    
    draw_set_alpha(1);
}