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
    
    var _boxHeight = _guiHeight * 0.3;
    var _finalTopY = _guiHeight - _boxHeight;
    
    var _yOffset = _boxHeight * (1 - _normProg);
    var _currentTopY = _finalTopY + _yOffset;

    draw_sprite_stretched(spr_button, 0, 0, _currentTopY, _guiWidth, _boxHeight);
    
    var _reservedWidthForParticipant = _guiWidth * 0.2;
	draw_sprite_stretched(spr_button, 0, 0, _currentTopY, _reservedWidthForParticipant, _boxHeight)
    //draw_rectangle(0, _currentTopY, _reservedWidthForParticipant, _guiHeight, true);
    
	var _padding = 20;
    var _reservedSpaceForText = _guiWidth - _reservedWidthForParticipant - _padding * 2;
    var _textX1 = _reservedWidthForParticipant + _padding;
    var _textY1 = _currentTopY + _padding;
    
    var _currentText = dialogue.texts[currentPage];
    var _text = _currentText.text;
    var _textSize = string_length(_text);
    
	var _pageQuantity = array_length(dialogue.texts);
	
    if(textIndex <= _textSize){
        textIndex += dialogue.textSpeed;
    }
    
	if(keyboard_check_pressed(vk_space)){
		if(textIndex < _textSize){
			textIndex = _textSize;
		} else if(currentPage < _pageQuantity -1) {
			currentPage ++;
			textIndex = 0;
		}else{
			endDialogue();
		}
	}
	
    var _currentTextPart = string_copy(_text, 1, textIndex);
    
    draw_set_font(fnt_gui_long_text);
    
    var _lineHeight = -1; 
    
	drawTextExtShadow(_textX1, _textY1, _currentTextPart, _lineHeight, _reservedSpaceForText, draw_get_alpha());
    draw_text_ext(_textX1, _textY1, _currentTextPart, _lineHeight, _reservedSpaceForText);
    
    draw_set_font(fnt_gui_default);
	
	var _personCentralPoint = getMiddlePoint(0, _reservedWidthForParticipant);
	
	var _scale = getScale(_boxHeight * .6, sprite_get_height(spr_human_male_iddle));
	
	var _participantY = _currentTopY + _boxHeight - _padding;
	
	drawPersonBody(_personCentralPoint, _participantY, genders.male, 0, _scale, 0, 1, #D39B6A, new PersonHair(hairIds.mohawk, #ffffff));

	var _bar = spr_button;
	var _name = "Mateus";

	var _padH = 24; 
	var _padV = 5;  

	draw_set_font(fnt_gui_title);

	var _txtW = string_width(_name);
	var _txtH = string_height(_name);

	var _barW = _txtW + (_padH * 2);
	var _barH = _txtH + (_padV * 2);

	var _barX = _padding;

	var _barY = _currentTopY + _padding;

	drawTextShadow(_barX, _barY, _name, draw_get_alpha());
	draw_text(_barX, _barY, _name);

	draw_set_valign(fa_top);
	draw_set_halign(fa_left);
}