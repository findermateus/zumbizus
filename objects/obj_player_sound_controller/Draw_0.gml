handleSound();

if (global.debug) {
    array_foreach(soundList, function(_sound) {
        draw_set_color(c_yellow);
        draw_circle(_sound.x, _sound.y, _sound.radius, true);
    });
}