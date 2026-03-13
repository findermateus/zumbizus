function roomToGuiX(_x) {
     var cl = camera_get_view_x(view_camera[0]);
     var off_x = _x - cl;
     var off_x_percent = off_x / camera_get_view_width(view_camera[0]);
     return off_x_percent * display_get_gui_width();   
}

function roomToGuiY(_y) {
	var _cameraYPosition = camera_get_view_y(view_camera[0])
	var off_y = _y - _cameraYPosition;
    var off_y_percent = off_y / camera_get_view_height(view_camera[0]);
	return off_y_percent * display_get_gui_height();
}

function getAlphaWithTimer(_alphaTimer){
	var _timer = get_timer()/100000;
	return (sin(_timer * 0.5) + 1) * _alphaTimer;
}

function createNotifyIndicator(_text, _x, _y){
	var _alert = instance_create_layer(_x, _y, "Alert", obj_alert_gui, {
		xPosition: _x,
		yPosition: _y
	});
	_alert.textAlert = _text;
}

function drawTextShadow(_x, _y, _text, _alpha, _offset = 3, _scale = 1){
	var _color = c_black;
	draw_text_transformed_color(_x + _offset, _y + _offset, _text, _scale, _scale, 0, _color, _color, _color, _color, _alpha);
}

function drawTextShadowScribble(_x, _y, _text, _alpha, _offset = 3) {
	var _oldColor = draw_get_color();
	var _oldAlpha = draw_get_alpha();
	
	draw_set_alpha(_alpha);
	draw_set_color(c_black);
	
	draw_text_scribble(_x + _offset, _y + _offset, _text);
	
	draw_set_color(_oldColor);
	draw_set_alpha(_oldAlpha);
}

function drawActionText(_text, _x, _y) {
	scribble_anim_wave(5, .1, .1);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text_scribble(_x + 3, _y + 3, "[scale,.8][c_black][wave]" + _text);
	draw_text_scribble(_x, _y, "[scale,.8][wave]" + _text);
	scribble_anim_reset();
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}