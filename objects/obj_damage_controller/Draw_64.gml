// Percorrendo de trás para frente para evitar bugs ao deletar itens
for (var i = array_length(damageList) - 1; i >= 0; i--) {
    var _damage = damageList[i];
    
    _damage.x += _damage.hsp;
    _damage.y += _damage.vsp;
    _damage.vsp += _damage.grav;
    
    _damage.scale = lerp(_damage.scale, 1, 0.2);
    _damage.alpha -= 0.02;

    var _gx = roomToGuiX(_damage.x);
    var _gy = roomToGuiY(_damage.y);
    
    var _str = "[fa_center][fa_middle][outline, c_black][scale," + string(_damage.scale) + "]" + string(_damage.value);
    
    draw_set_alpha(_damage.alpha);
	drawTextShadowScribble(_gx, _gy, _str, _damage.alpha * .6);
    draw_text_scribble(_gx, _gy, _str);
    draw_set_alpha(1);

    if (_damage.alpha <= 0) {
        array_delete(damageList, i, 1);
    }
}