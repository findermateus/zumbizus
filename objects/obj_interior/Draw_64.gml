var _bbox_left   = roomToGuiX(bbox_left);
var _bbox_top    = roomToGuiY(bbox_top);
var _bbox_right  = roomToGuiX(bbox_right);
var _bbox_bottom = roomToGuiY(bbox_bottom);

var _centerX = _bbox_left + ((_bbox_right - _bbox_left) / 2);
var _centerY = _bbox_top + ((_bbox_bottom - _bbox_top) / 2);

var _time = current_time * 0.002;

var _movX = cos(_time) * 12;
var _movY = sin(_time * 2) * 8;

var _pulse = 1.15 + (sin(_time * 1.5) * 0.15);

var _angle = sin(_time) * 5; 

draw_set_font(fnt_gui_title);

draw_text_scribble(_centerX + _movX, _centerY + _movY, 
    "[alpha," + string(alpha) + "]" +
    "[scale," + string(_pulse) + "]" +
    "[angle," + string(_angle) + "]" +
    "[fa_center][fa_middle][c_white]?"
);

draw_set_font(fnt_gui_default);