if (!global.debug) return;

draw_path(currentPath, x, y, true);

draw_set_color(c_red);
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);

if (path_exists(currentPath)) {
    draw_set_color(c_green);
    draw_path(currentPath, x, y, true);
}

draw_set_color(c_white);