if (global.pause) exit;

event_inherited();

drawInterface();

var _isNear = isHovering;

var _targetBubbleScale = 0;
var _targetBubbleAlpha = 0;

if (canPlayerTalk()) {
    if (!activeInteraction && !isCurrentMenu(Menus.Dialogue)) {
        _targetBubbleAlpha = _isNear ? 1.0 : 0.5;
        _targetBubbleScale = _isNear ? 1.0 : 0.7;
    } else {
        _targetBubbleScale = 0.0;
        _targetBubbleAlpha = 0.0;
    }
}

bubble_scale = lerp(bubble_scale, _targetBubbleScale, 0.15);
bubble_alpha = lerp(bubble_alpha, _targetBubbleAlpha, 0.2);

if (bubble_alpha > 0.01) {
    var _sprite = spr_dialogue_popup;
    var _baseScale = getScale(30, sprite_get_width(_sprite));
    var _finalScale = _baseScale * bubble_scale;
    
    var _hoverY = dsin(current_time * 0.3) * 3;
    
    var _flyUpY = activeInteraction ? ((1 - bubble_alpha) * -20) : 0;
    
    draw_sprite_ext(
        _sprite, 
        0, 
        roomToGuiX(bbox_left) - 5, 
        roomToGuiY(bbox_top) - 35 + _hoverY + _flyUpY, 
        _finalScale, 
        _finalScale, 
        0, 
        c_white, 
        bubble_alpha
    );
}

if (!activeInteraction) {
    alpha = 0;
    animProgress = 0;
    hover_offset1 = 0;
    hover_offset2 = 0;
    hover_offset3 = 0;
	
    return;
}

if (global.activeBuilding || global.activeInventory) {
    closeInteractOptions();
    return;
}

if(!checkObstacules(obj_player) || !checkDistance(obj_player)) {
    closeInteractOptions();
    return;
}

var _optionCount = array_length(interactOptions);

animProgress = lerp(animProgress, 1, 0.15);
alpha = lerp(alpha, 1, 0.1);

var _oldAlpha = draw_get_alpha();
draw_set_alpha(alpha);
draw_set_font(fnt_gui_default);

var _canInteract = animProgress >= .9;

var _dspr = spr_bar;
var _hdspr = spr_bar_white;
var _pad = 12;
var _margin = 50;

var _originX = roomToGuiX(getMiddlePoint(bbox_left, bbox_right));
var _originY = roomToGuiY((bbox_top + bbox_bottom) / 2);

var _lineOriginX = _originX;
var _lineOriginY = roomToGuiY(bbox_top);

var _targetFirstX = roomToGuiX(bbox_left) - _margin;
var _targetFirstY = roomToGuiY(bbox_bottom) - sprite_get_height(sprite_index);

var _targetSecondX = roomToGuiX(bbox_right) + _margin;
var _targetSecondY = _targetFirstY;

var _firstOptionX = lerp(_originX, _targetFirstX, animProgress);
var _firstOptionY = lerp(_originY, _targetFirstY, animProgress);

var _secondOptionX = lerp(_originX, _targetSecondX, animProgress);
var _secondOptionY = lerp(_originY, _targetSecondY, animProgress);

var _option1 = interactOptions[0];

var _str1 = _option1.label;
var _w1 = string_width(_str1);
var _h1 = string_height(_str1);

var _box1_x = _firstOptionX - _w1 - _pad;
var _box1_y = _firstOptionY - _pad;
var _box1_w = _w1 + (_pad * 2);
var _box1_h = _h1 + (_pad * 2);

var _hover1 = mouseIsOnRectangle(_box1_x, _box1_y, _box1_x + _box1_w, _box1_y + _box1_h);
hover_offset1 = lerp(hover_offset1, _hover1 ? -8 : 0, 0.2);

var _btn1_centerX = _box1_x + (_box1_w / 2);
var _btn1_centerY = _box1_y + hover_offset1 + (_box1_h / 2);

draw_ui_connection(_lineOriginX, _lineOriginY, _btn1_centerX, _btn1_centerY, alpha);

draw_interaction_button(
    _hover1 ? _hdspr : _dspr, 
    _box1_x, _box1_y + hover_offset1, _box1_w, _box1_h, 
    _firstOptionX, _firstOptionY + hover_offset1, 
    _str1, fa_right, alpha
);

if (_canInteract && _hover1 && mouse_check_button_released(mb_left)) {
	handleNPCOption(_option1.action);
}

var _option2 = interactOptions[1];

var _str2 = _option2.label;
var _w2 = string_width(_str2);
var _h2 = string_height(_str2);

var _box2_x = _secondOptionX - _pad;
var _box2_y = _secondOptionY - _pad;
var _box2_w = _w2 + (_pad * 2);
var _box2_h = _h2 + (_pad * 2);

var _hover2 = mouseIsOnRectangle(_box2_x, _box2_y, _box2_x + _box2_w, _box2_y + _box2_h);
hover_offset2 = lerp(hover_offset2, _hover2 ? -8 : 0, 0.2);

var _btn2_centerX = _box2_x + (_box2_w / 2);
var _btn2_centerY = _box2_y + hover_offset2 + (_box2_h / 2);

draw_ui_connection(_lineOriginX, _lineOriginY, _btn2_centerX, _btn2_centerY, alpha);

draw_interaction_button(
    _hover2 ? _hdspr : _dspr, 
    _box2_x, _box2_y + hover_offset2, _box2_w, _box2_h, 
    _secondOptionX, _secondOptionY + hover_offset2, 
    _str2, fa_left, alpha
);

if (_canInteract && _hover2 && mouse_check_button_released(mb_left)) {
	handleNPCOption(_option2.action);
}

if (_optionCount == 3) {
    var _targetThirdX = roomToGuiX(getMiddlePoint(bbox_left, bbox_right));
    var _targetThirdY = roomToGuiY(bbox_top) - 140;
    
    var _x = lerp(_originX, _targetThirdX, animProgress);
    var _y = lerp(_originY, _targetThirdY, animProgress);
    
    var _str3 = interactOptions[2].label;
    var _w3 = string_width(_str3);
    var _h3 = string_height(_str3);
    
    var _box3_x = _x - (_w3 / 2) - _pad;
    var _box3_y = _y - _pad;
    var _box3_w = _w3 + (_pad * 2);
    var _box3_h = _h3 + (_pad * 2);
    
    var _hover3 = mouseIsOnRectangle(_box3_x, _box3_y, _box3_x + _box3_w, _box3_y + _box3_h);
    hover_offset3 = lerp(hover_offset3, _hover3 ? -8 : 0, 0.2);
    
    var _btn3_centerX = _box3_x + (_box3_w / 2);
    var _btn3_centerY = _box3_y + hover_offset3 + (_box3_h / 2);

    draw_ui_connection(_lineOriginX, _lineOriginY, _btn3_centerX, _btn3_centerY, alpha);
    
    draw_interaction_button(
        _hover3 ? _hdspr : _dspr, 
        _box3_x, _box3_y + hover_offset3, _box3_w, _box3_h, 
        _x, _y + hover_offset3, 
        _str3, fa_center, alpha
    );
}

draw_set_halign(fa_left);
draw_set_alpha(_oldAlpha);