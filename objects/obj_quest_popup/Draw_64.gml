if (global.pause) return;
if (state == POPUP_STATE.QUEUED) return;

draw_set_font(fnt_gui_title);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_alpha(alpha);

var _x = (guiW / 2) + random_range(-shakeAmount, shakeAmount);
var _y = currentY   + random_range(-shakeAmount, shakeAmount);

if (label != "") {
    var _labelScale = 0.7;
    var _labelY     = _y - (28 * textScale);

    drawTextShadow(_x, _labelY, label, alpha, 2 * _labelScale, _labelScale);
    
    draw_set_color(textColor);
    draw_text_transformed(_x, _labelY, label, _labelScale, _labelScale, 0);
}

drawTextShadow(_x, _y, textContent, alpha, 2 * textScale, textScale);

draw_set_color(textColor);
draw_text_transformed(_x, _y, textContent, textScale, textScale, 0);

if (showLine && lineProgress > 0.01) {
    var _textWidth  = (string_width(textContent) * textScale) + linePadding;
    var _lineStartX = _x - (_textWidth / 2);
    var _lineEndX   = _lineStartX + (_textWidth * lineProgress);
    var _lineY      = _y + (2 * textScale);

    draw_set_color(textColor);
    draw_line_width(_lineStartX, _lineY, _lineEndX, _lineY, 4 * textScale);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(fnt_gui_default);