if (global.pause) exit;

draw_set_font(fnt_default);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var _shadowOffset = 2;
draw_set_color(c_black);
draw_set_alpha(image_alpha * 0.6);
draw_text_transformed(xPosition + _shadowOffset, yPosition + _shadowOffset, textAlert, scale, scale, 0);

draw_set_color(alertColor);
draw_set_alpha(image_alpha);
draw_text_transformed(xPosition, yPosition, textAlert, scale, scale, 0);

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);