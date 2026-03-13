xMouseGui = device_mouse_x_to_gui(0);
yMouseGui = device_mouse_y_to_gui(0);
var _lerpEffect = 0.3
currentXScale = lerp(currentXScale, option.xScale, _lerpEffect);
currentYScale = lerp(currentYScale, option.yScale, _lerpEffect);
currentTextScale = lerp(currentTextScale, 1, _lerpEffect);
activeOption();
