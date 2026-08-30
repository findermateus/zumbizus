if (!instance_exists(obj_player)) exit;
if (global.pause) exit;
    
var _floatOffset = sin(floatTimer) * 4; 
    
var _guiX = roomToGuiX(obj_player.x) + offsetX + shakeX;
var _guiY = roomToGuiY(obj_player.y) + offsetY + shakeY + _floatOffset + slideY;

draw_set_alpha(alpha);
draw_set_color(c_white);
draw_set_font(fnt_gui_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

drawTextShadow(_guiX + 2, _guiY + 2, currentText, alpha, 2, scale);
draw_text_transformed(_guiX, _guiY, currentText, scale, scale, 0); 

if (lineProgress > 0.01) {
    var _contentWidth    = string_width(currentText);
    var _lineWidthActual = (_contentWidth * scale) + linePadding;
    var _lineStartX      = _guiX - (_lineWidthActual / 2);
    var _lineEndX        = _lineStartX + (_lineWidthActual * lineProgress);
    var _lineY           = _guiY;

    draw_set_color(c_white);
    draw_line_width(_lineStartX, _lineY, _lineEndX, _lineY, 4 * scale);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);