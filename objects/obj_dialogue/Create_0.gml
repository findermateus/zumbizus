openMenu(Menus.Dialogue);
blockPlayerMenus();

currentPage = 0;
textIndex = 0;
animationProgress = 0;

obj_player.currentState = playerDialogueState;

if (!is_struct(dialogue)) {
	instance_destroy(id);
}

if (instance_exists(target)) {
	obj_camera.setTargetWithZoom(target);
}

function endDialogue() {
	closeMenu();
	unBlockPlayerMenus();
	
	obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {});
	
	obj_camera.setDefaultScale();
	obj_camera.target = obj_player;
	
	obj_player.currentState = playerIddleState;
	
	instance_destroy(id);
}

function drawDialogueBox() {
    animationProgress = lerp(animationProgress, 100, 0.07);
    var _normProg = animationProgress / 100;
    
    var _guiWidth = display_get_gui_width();
    var _guiHeight = display_get_gui_height();
    
    var _marginSide = 20;
    var _marginBottom = 20;
    var _gap = 15;
    
    var _boxHeight = _guiHeight * 0.3;
    var _finalTopY = _guiHeight - _boxHeight - _marginBottom;
    var _yOffset = (_boxHeight + _marginBottom) * (1 - _normProg);
    var _currentTopY = _finalTopY + _yOffset;

    var _usableWidth = _guiWidth - (_marginSide * 2) - _gap;
    var _reservedWidthForParticipant = _usableWidth * 0.2;
    var _textBlockW = _usableWidth - _reservedWidthForParticipant;
    
    var _drawXStart = _marginSide;

    var _currentText = dialogue.texts[currentPage];
    var _participantIndex = _currentText.participantIndex;
    var _pdata = dialogue.participants[_participantIndex];
    var _isPlayer = !is_struct(_pdata);
    
    var _avatarBoxX, _textBlockX;
    
    if (_isPlayer) {
        _avatarBoxX = _drawXStart;
        _textBlockX = _drawXStart + _reservedWidthForParticipant + _gap;
    } else {
        _textBlockX = _drawXStart;
        _avatarBoxX = _drawXStart + _textBlockW + _gap;
    }

    draw_sprite_stretched(spr_inventory_box, 0, _avatarBoxX, _currentTopY, _reservedWidthForParticipant, _boxHeight);
    draw_sprite_stretched(spr_inventory_box, 0, _textBlockX, _currentTopY, _textBlockW, _boxHeight);
    
    var _padding = 20;
    var _reservedSpaceForText = _textBlockW - _padding * 2;
    var _textX1 = _textBlockX + _padding;
    var _textY1 = _currentTopY + _padding;
    
    var _text = _currentText.text;
    var _textSize = string_length(_text);
    var _pageQuantity = array_length(dialogue.texts);
    
    if(textIndex <= _textSize) textIndex += dialogue.textSpeed;
    
    if(keyboard_check_pressed(vk_space)){
        if(textIndex < _textSize){
            textIndex = _textSize;
        } else if(currentPage < _pageQuantity - 1) {
            currentPage++;
            textIndex = 0;
        } else {
            endDialogue();
        }
    }
    
    var _currentTextPart = string_copy(_text, 1, textIndex);
    draw_set_font(fnt_gui_default);
    drawTextExtShadow(_textX1, _textY1, _currentTextPart, -1, _reservedSpaceForText, draw_get_alpha());
    draw_text_ext(_textX1, _textY1, _currentTextPart, -1, _reservedSpaceForText);
    
    var _personCentralPoint = getMiddlePoint(_avatarBoxX, _avatarBoxX + _reservedWidthForParticipant);
    var _expectedBodySize = _boxHeight * .6;
    var _scale = getScale(_expectedBodySize, sprite_get_height(spr_human_male_iddle));
    var _participantY = getMiddlePoint(_currentTopY, _currentTopY + _boxHeight) + _expectedBodySize / 2;
    
    var _name = "";
    if (_isPlayer) {
        _name = global.player.name;
        drawPersonBody(
			_personCentralPoint,
			_participantY,
			global.player.gender,
			0,
			_scale,
			0,
			1,
			global.player.skinColor,
			global.player.hair, 
			is_struct(global.equipments.armor) ? global.equipments.armor.itemId : -1, 
			is_struct(global.equipments.head) ? global.equipments.head.itemId : -1, 
			is_struct(global.equipments.bag) ? global.equipments.bag.itemId : -1);
    } else {
        _name = _pdata.name;
        drawPersonBody(_personCentralPoint, _participantY, _pdata.gender, 0, _scale, 0, 1, _pdata.skinColor, new PersonHair(_pdata.hairId, _pdata.hairColor), -1, -1, -1, -1);
    }

    draw_set_font(fnt_gui_title);
    var _txtW = string_width(_name);
    var _nameX = _avatarBoxX + _padding;
    var _nameY = _currentTopY + _padding;
    var _availableNameWidth = _reservedWidthForParticipant - _padding * 2;

    if (_txtW >= _availableNameWidth) {
        var _tscale = getScale(_availableNameWidth, _txtW);
        draw_text_transformed(_nameX, _nameY, _name, _tscale, _tscale, 0);
    } else {
        drawTextShadow(_nameX, _nameY, _name, draw_get_alpha());
        draw_text(_nameX, _nameY, _name);
    }

    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}