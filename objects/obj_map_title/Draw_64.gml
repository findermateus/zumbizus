var _old_alpha = draw_get_alpha();
draw_set_alpha(alpha);

var _text = "[fa_center][fa_middle][scale," + string(scale) + "]" + title;

var _middlePointX = display_get_gui_width() / 2;
var _middlePointY = display_get_gui_height() / 2;

draw_set_font(fnt_gui_title);

drawTextShadowScribble(_middlePointX, _middlePointY, _text, alpha);

draw_text_scribble(_middlePointX, _middlePointY, _text);

draw_set_font(fnt_gui_default);
draw_set_alpha(_old_alpha);