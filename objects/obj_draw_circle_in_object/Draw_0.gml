if (father != noone && instance_exists(father)) {
    x = lerp(x, getMiddlePoint(father.bbox_left, father.bbox_right), 0.2);
    y = lerp(y, getMiddlePoint(father.bbox_top, father.bbox_bottom), 0.2);
}

draw_set_colour(c_white);

draw_set_alpha(currentAlpha);
for (var i = 0; i < thicknessCurrent; i++) {
    draw_circle(x, y, currentRadius - i, true);
}

var _echoAlpha = currentAlpha * 0.4;
draw_set_alpha(_echoAlpha);

for (var j = 0; j < thicknessCurrent / 2; j++) {
    draw_circle(x, y, echoRadius - j, true);
}

draw_set_alpha(currentAlpha * 0.2);
draw_circle(x, y, currentRadius * 0.25, false);

draw_set_alpha(1);