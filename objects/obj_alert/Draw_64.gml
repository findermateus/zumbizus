var _xPositionToGui = roomToGuiX(x);
var _yPositionToGui = roomToGuiY(y)
draw_set_halign(fa_center);
draw_set_font(fnt_default);
draw_set_alpha(image_alpha);
draw_set_color(alertColor);
drawTextShadow(_xPositionToGui, _yPositionToGui, textAlert, image_alpha, 2);
draw_text(_xPositionToGui, _yPositionToGui, textAlert);
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);