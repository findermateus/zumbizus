if (global.pause) exit;

var _xPositionToGui = roomToGuiX(x);
var _yPositionToGui = roomToGuiY(y);

draw_set_font(fnt_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

drawTextShadow(_xPositionToGui, _yPositionToGui, textAlert, image_alpha, 2, scale);

draw_set_color(alertColor);
draw_set_alpha(image_alpha);
draw_text_transformed(_xPositionToGui, _yPositionToGui, textAlert, scale, scale, 0);

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);