draw_set_font(fnt_gui_title);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);      

var _x = gui_w / 2;         
var _y = current_y;         

var _text_width = string_width(questStepDescription) + line_padding;
var _line_start_x = _x - (_text_width / 2);
var _line_end_x = _line_start_x + (_text_width * line_progress);
var _line_y = _y + 2;

drawTextShadow(_x + 2, _y + 2, questStepDescription, alpha);

draw_set_color(c_yellow); 
draw_text(_x, _y, questStepDescription);

if (line_progress > 0.01) {
	draw_line_width(_line_start_x, _line_y, _line_end_x, _line_y, 4);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(fnt_gui_default);