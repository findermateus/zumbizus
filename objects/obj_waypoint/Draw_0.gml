if (!global.debug) exit;

var _color = disabled ? c_red : c_white;

draw_rectangle_color(bbox_left, bbox_top, bbox_right, bbox_bottom, _color, _color, _color, _color, false);