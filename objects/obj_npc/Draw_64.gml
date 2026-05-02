if (global.pause) exit;

event_inherited();

drawInterface();

if (!activeInteraction) {
    alpha = 0;
    animProgress = 0;
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

if (_optionCount == 1) {
    handleNPCOption(interactOptions[0].action);
    activeInteraction = false;  
    return;
}

animProgress = lerp(animProgress, 1, 0.15);
alpha = lerp(alpha, 1, 0.1);

var _yOffset = (1 - animProgress) * 30;
var _oldAlpha = draw_get_alpha();

draw_set_alpha(alpha);

var _dspr = spr_bar;
var _hdspr = spr_bar_white;
var _pad = 12;
var _margin = 50;

var _firstOptionX = roomToGuiX(bbox_left) - _margin;
var _firstOptionY = roomToGuiY(bbox_bottom) - sprite_get_height(sprite_index);

var _secondOptionX = roomToGuiX(bbox_right) + _margin;
var _secondOptionY = _firstOptionY;

var _str1 = interactOptions[0].label;
var _w1 = string_width(_str1);
var _h1 = string_height(_str1);

var _box1_x = _firstOptionX - _w1 - _pad;
var _box1_y = _firstOptionY - _pad;
var _box1_w = _w1 + (_pad * 2);
var _box1_h = _h1 + (_pad * 2);

var _hover1 = mouseIsOnRectangle(_box1_x, _box1_y + _yOffset, _box1_x + _box1_w, _box1_y + _box1_h + _yOffset);
var _scale1 = 1;

var _draw1_w = _box1_w * _scale1;
var _draw1_h = _box1_h * _scale1;
var _draw1_x = (_box1_x + _box1_w / 2) - (_draw1_w / 2);
var _draw1_y = (_box1_y + _box1_h / 2) - (_draw1_h / 2) + _yOffset;

draw_sprite_stretched(_hover1 ? _hdspr : _dspr, 0, _draw1_x, _draw1_y, _draw1_w, _draw1_h);

draw_set_halign(fa_right);
drawTextShadow(_firstOptionX, _firstOptionY + _yOffset, _str1, alpha);
draw_set_color(c_white);
draw_text_transformed(_firstOptionX, _firstOptionY + _yOffset, _str1, _scale1, _scale1, 0);

var _str2 = interactOptions[1].label;
var _w2 = string_width(_str2);
var _h2 = string_height(_str2);

var _box2_x = _secondOptionX - _pad;
var _box2_y = _secondOptionY - _pad;
var _box2_w = _w2 + (_pad * 2);
var _box2_h = _h2 + (_pad * 2);

var _hover2 = mouseIsOnRectangle(_box2_x, _box2_y + _yOffset, _box2_x + _box2_w, _box2_y + _box2_h + _yOffset);
var _scale2 = 1;

var _draw2_w = _box2_w * _scale2;
var _draw2_h = _box2_h * _scale2;
var _draw2_x = (_box2_x + _box2_w / 2) - (_draw2_w / 2);
var _draw2_y = (_box2_y + _box2_h / 2) - (_draw2_h / 2) + _yOffset;

draw_sprite_stretched(_hover2 ? _hdspr : _dspr, 0, _draw2_x, _draw2_y, _draw2_w, _draw2_h);

draw_set_halign(fa_left);
drawTextShadow(_secondOptionX, _secondOptionY, _str2, alpha);
draw_text_transformed(_secondOptionX, _secondOptionY + _yOffset, _str2, _scale2, _scale2, 0);


if (_optionCount == 3) {
    var _x = roomToGuiX(getMiddlePoint(bbox_left, bbox_right));
    var _y = roomToGuiY(bbox_top) - 140;
    
    var _str3 = interactOptions[2].label;
    var _w3 = string_width(_str3);
    var _h3 = string_height(_str3);
    
    var _box3_x = _x - (_w3 / 2) - _pad;
    var _box3_y = _y - _pad;
    var _box3_w = _w3 + (_pad * 2);
    var _box3_h = _h3 + (_pad * 2);
    
    var _hover3 = mouseIsOnRectangle(_box3_x, _box3_y + _yOffset, _box3_x + _box3_w, _box3_y + _box3_h + _yOffset);
    var _scale3 = 1;
    
    var _draw3_w = _box3_w * _scale3;
    var _draw3_h = _box3_h * _scale3;
    var _draw3_x = (_box3_x + _box3_w / 2) - (_draw3_w / 2);
    var _draw3_y = (_box3_y + _box3_h / 2) - (_draw3_h / 2) + _yOffset;
    
    draw_sprite_stretched(_hover3 ? _hdspr : _dspr, 0, _draw3_x, _draw3_y, _draw3_w, _draw3_h);
    
    draw_set_halign(fa_center);
	drawTextShadow(_x, _y + _yOffset, _str3, alpha);
    draw_text_transformed(_x, _y + _yOffset, _str3, _scale3, _scale3, 0);
}

draw_set_halign(fa_left);
draw_set_alpha(_oldAlpha);