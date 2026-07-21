event_inherited();

scale_x = lerp(scale_x, 1, 0.15);
scale_y = lerp(scale_y, 1, 0.15);
shake_power = max(0, shake_power - shake_decay);

if (isDying) {
    processDeath();
}