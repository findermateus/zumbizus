openMenu(Menus.Dialogue);
blockPlayerMenus();

currentPage = 0;
textIndex = 0;
animationProgress = 0;

avatarTransitionProgress = 0;
avatarTransitionState = "idle";
lastParticipantIndex = -1;

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
	
	obj_camera.setDefaultValues();
	obj_camera.target = obj_player;
	
	obj_player.currentState = playerIddleState;
	
	if (instance_exists(target)) {
		obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {
			npc: target
		});
	}
	
	if (is_callable(dialogue.onEnd)) {
		dialogue.onEnd();
	}
	
	if (instance_exists(target)) {
		target.isInteracting = false;
	}
	instance_destroy(id);
}

function drawDialogueBox() {
    animationProgress = lerp(animationProgress, 100, 0.07);
    var _normProg = animationProgress / 100;

    var _guiWidth  = display_get_gui_width();
    var _guiHeight = display_get_gui_height();

    var _marginSide   = 60;
    var _marginBottom = 20;

    var _dialogBoxH = _guiHeight * 0.25;
    var _dialogBoxW = _guiWidth - (_marginSide * 2);
    var _dialogBoxX = _marginSide;
    var _finalDialogTopY = _guiHeight - _dialogBoxH - _marginBottom;

    var _avatarBoxW = _dialogBoxW * 0.14;
    var _avatarBoxH = _dialogBoxH * 1.2;

    var _currentText = dialogue.texts[currentPage];
    var _isPlayer    = _currentText.isPlayer;

    var _avatarMargin = 120;
    var _avatarBoxX;
    if (_isPlayer) {
        _avatarBoxX = _dialogBoxX + _avatarMargin;
    } else {
        _avatarBoxX = _dialogBoxX + _dialogBoxW - _avatarBoxW - _avatarMargin;
    }

    var _yOffset           = (_dialogBoxH + _marginBottom) * (1 - _normProg);
    var _currentDialogTopY = _finalDialogTopY + _yOffset;
    var _currentAvatarTopY = _finalDialogTopY - (_avatarBoxH * 0.9) + _yOffset;

    draw_sprite_stretched(spr_dialogue, 0, _dialogBoxX, _currentDialogTopY, _dialogBoxW, _dialogBoxH);

    var _padding              = 20;
    var _reservedSpaceForText = _dialogBoxW - _padding * 2;
    var _textX1 = _dialogBoxX + _padding;
    var _textY1 = _currentDialogTopY + _padding;

    var _text         = _currentText.text;
    var _textSize     = string_length(_text);
    var _pageQuantity = array_length(dialogue.texts);

    if (textIndex <= _textSize) textIndex += dialogue.textSpeed;

    if (keyboard_check_pressed(vk_space)) {
        if (textIndex < _textSize) {
            textIndex = _textSize;
        } else if (currentPage < _pageQuantity - 1) {
            currentPage++;
            textIndex = 0;
        } else {
            endDialogue();
        }
    }

    var _alpha = draw_get_alpha();

    var _currentTextPart = string_copy(_text, 1, textIndex);
    draw_set_font(fnt_gui_default);
    drawTextShadowScribble(_textX1, _textY1, _currentTextPart, _alpha, 4, _reservedSpaceForText);
    draw_text_scribble_ext(_textX1, _textY1, _currentTextPart, -1, _reservedSpaceForText);

    var _personCentralPoint = getMiddlePoint(_avatarBoxX, _avatarBoxX + _avatarBoxW);
    var _expectedBodySize   = _avatarBoxH * 0.65;
    var _scale              = getScale(_expectedBodySize, sprite_get_height(spr_human_male_iddle));
    var _participantY       = _currentDialogTopY;

    var _name = "";
    if (_isPlayer) {
        _name = global.player.name;
        drawPersonBody(
            _personCentralPoint, _participantY,
            global.player.gender, 0, _scale, 0, 1,
            global.player.skinColor,
            global.player.hair,
            is_struct(global.equipments.armor) ? global.equipments.armor.itemId : -1,
            is_struct(global.equipments.head)  ? global.equipments.head.itemId  : -1,
            is_struct(global.equipments.bag)   ? global.equipments.bag.itemId   : -1
        );
    } else {
        var _npc = dialogue.npc;
        _name = _npc.name;
        drawPersonBody(
            _personCentralPoint, _participantY,
            _npc.gender, 0, _scale, 0, 1,
            _npc.skinColor,
            new PersonHair(_npc.hairId, _npc.hairColor),
            -1, -1, -1, -1
        );
    }

    draw_set_font(fnt_gui_title);

    var _nameX              = _avatarBoxX + _padding;
    var _nameY              = _currentAvatarTopY + _avatarBoxH - _padding - 10;
    var _availableNameWidth = _avatarBoxW - _padding * 2;
    var _txtW               = string_width(_name);

    draw_set_valign(fa_bottom);

    if (_txtW >= _availableNameWidth) {
        var _tscale = getScale(_availableNameWidth, _txtW);
        drawTextShadow(_nameX, _nameY, _name, _alpha, 4, _tscale);
        draw_text_transformed(_nameX, _nameY, _name, _tscale, _tscale, 0);
    } else {
        drawTextShadow(_nameX, _nameY, _name, _alpha);
        draw_text(_nameX, _nameY, _name);
    }

    if (textIndex >= _textSize) {
        var _hintText  = "Pressione Espaço para avançar";
        var _hintAlpha = (sin(current_time * 0.003) + 1) / 2;

        draw_set_font(fnt_gui_default);
        draw_set_halign(fa_right);
        draw_set_valign(fa_bottom);

        var _hintX = _dialogBoxX + _dialogBoxW - _padding;
        var _hintY = _currentDialogTopY + _dialogBoxH - _padding;

        draw_set_alpha(_hintAlpha * _alpha);
        drawTextShadow(_hintX, _hintY, _hintText, _hintAlpha * _alpha, 4);
        draw_text(_hintX, _hintY, _hintText);
        draw_set_alpha(_alpha);
    }

    draw_set_valign(fa_top);
    draw_set_halign(fa_left);
}
