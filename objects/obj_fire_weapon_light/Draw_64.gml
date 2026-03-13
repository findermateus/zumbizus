if (!global.debug) return;

var _debug = [
	"Range: " + string(range),
	"Alpha: " + string(alpha),
	"Timer: " + string(flash_timer)
];

for (var i = 0; i < array_length(_debug); i++) {
	var _x = roomToGuiX(x);
	var _y = roomToGuiY(y) + 50 * i;
	draw_text(_x, _y, _debug[i]);
}