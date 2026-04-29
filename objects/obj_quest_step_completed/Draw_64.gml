if (global.pause) return;
if (state == POPUP_STATE.QUEUED) return;

draw_set_font(fnt_gui_title);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);

var _x         = (guiW / 2) + random_range(-shakeAmount, shakeAmount);
var _y         = currentY   + random_range(-shakeAmount, shakeAmount);
var _textWidth = (string_width(textContent) * textScale) + linePadding;
var _lineStartX = _x - (_textWidth / 2);
var _lineEndX   = _lineStartX + (_textWidth * lineProgress);

if (!isStep) {
    var _glowSize = 4 * textScale;
    draw_set_color(textColor);
    draw_set_alpha(alpha * 0.2);
    draw_text_transformed(_x - _glowSize, _y, textContent, textScale, textScale, 0);
    draw_text_transformed(_x + _glowSize, _y, textContent, textScale, textScale, 0);
    draw_text_transformed(_x, _y - _glowSize, textContent, textScale, textScale, 0);
    draw_text_transformed(_x, _y + _glowSize, textContent, textScale, textScale, 0);
    draw_set_alpha(alpha);
}

draw_set_color(c_black);
draw_text_transformed(_x + (2 * textScale), _y + (2 * textScale), textContent, textScale, textScale, 0);
draw_set_color(textColor);
draw_text_transformed(_x, _y, textContent, textScale, textScale, 0);

if (lineProgress > 0.01) {
    draw_set_color(textColor);
    var _lineY         = _y + (2 * textScale);
    var _lineThickness = 4  * textScale;
    draw_line_width(_lineStartX, _lineY, _lineEndX, _lineY, _lineThickness);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(fnt_gui_default);