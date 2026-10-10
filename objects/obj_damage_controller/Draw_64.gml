var _font = draw_get_font();

for (var i = array_length(damageList) - 1; i >= 0; i--) {
    var _damage = damageList[i];

    _damage.x += _damage.hsp;
    _damage.y += _damage.vsp;
    _damage.vsp += _damage.grav;

    _damage.scale = lerp(_damage.scale, _damage.targetScale, 0.2);
	_damage.angle = lerp(_damage.angle, 0, 0.15);
    _damage.alpha -= _damage.isKill ? 0.015 : 0.02;

    var _gx = roomToGuiX(_damage.x);
    var _gy = roomToGuiY(_damage.y);

    var _str = "[fa_center][fa_middle][scale," + string(_damage.scale) + "]" + _damage.color + string(_damage.value);
	var _text = scribble(_str, "__damage_number__").transform(1, 1, _damage.angle);
	if (font_exists(_font)) _text.starting_format(font_get_name(_font), c_white);

	_text.blend(c_black, max(0, _damage.alpha) * .6).draw(_gx + 3, _gy + 3);
	_text.blend(c_white, max(0, _damage.alpha)).draw(_gx, _gy);

    if (_damage.alpha <= 0) {
        array_delete(damageList, i, 1);
    }
}
