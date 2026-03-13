if (global.pause) exit;

draw_set_halign(fa_center);
draw_set_font(fnt_default);
draw_set_alpha(image_alpha);
draw_set_color(alertColor);
draw_text(xPosition, yPosition, textAlert);
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);