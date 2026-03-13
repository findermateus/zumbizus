alpha = 0;
animProgress = 0;

var _min_depth = depth;

with(obj_dialogue_simple_pop_up) {
    if (id != other.id) {
        if (depth < _min_depth) {
            _min_depth = depth;
        } else if (depth == _min_depth) {
             _min_depth = depth;
        }
    }
}

depth = _min_depth - 1;

function draw() {
	lifeSpan--;

	var _maxDialogueWidth = 600;
	var _padding = 15;
	var _sprite = spr_simple_dialogue;
	var _font = fnt_default_small;

	draw_set_font(_font);

	var _textWidth = string_width_ext(textContent, -1, _maxDialogueWidth);
	var _textHeight = string_height_ext(textContent, -1, _maxDialogueWidth);

	var _boxW = _textWidth + (_padding * 2);
	var _boxH = _textHeight + (_padding * 2);

	animProgress = lerp(animProgress, 1, 0.15);

	var _yOffset = (1 - animProgress) * 30;
	var _alpha = animProgress;

	var _initialX = getMiddlePoint(father.bbox_left, father.bbox_right);
	var _initialY = father.bbox_top - _boxH - _padding;
	
	var _x = roomToGuiX(_initialX);
	var _y = roomToGuiY(_initialY);

	var _drawX = _x - (_boxW / 2);
	var _drawY = (_y - _boxH - 10) + _yOffset;

	var _oldAlpha = draw_get_alpha();
	var _destinyAlpha = global.activeMenu ? 0 : alpha;
	draw_set_alpha(_destinyAlpha);

	draw_sprite_stretched(_sprite, 0, _drawX, _drawY, _boxW, _boxH);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_white);

	draw_text_ext(_drawX + _padding, _drawY + _padding, textContent, -1, _maxDialogueWidth);
	
	draw_set_font(fnt_gui_default);
	draw_set_alpha(_oldAlpha);
}
