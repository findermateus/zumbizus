if (global.pause) return;
if (state == POPUP_STATE.QUEUED) return;

var _shakeX = random_range(-shakeAmount, shakeAmount);
var _shakeY = random_range(-shakeAmount, shakeAmount);
var _cx = guiW / 2 + _shakeX;
var _cy = currentY + _shakeY;

#region medidas

var _secondaryWrap = 640;
var _labelScale = .6;
var _rewardIconSize = 44;
var _rewardGap = 28;

draw_set_font(fnt_gui_title);
var _labelHeight = string_height(label) * _labelScale;
var _labelWidth  = string_width(label) * _labelScale;
var _titleWidth  = string_width(textContent) * textScale;
var _titleHeight = string_height(textContent) * textScale;
var _checkSpace  = showCheck ? 44 * textScale : 0;

draw_set_font(fnt_gui_default);
var _secondaryLabelHeight = secondaryLabel != "" ? string_height(secondaryLabel) * .75 + 8 : 0;
var _secondaryWidth  = 0;
var _secondaryHeight = 0;

if (secondaryText != "") {
	_secondaryWidth  = string_width_ext(secondaryText, -1, _secondaryWrap) + 30;
	_secondaryHeight = string_height_ext(secondaryText, -1, _secondaryWrap);
} else if (hasRewards) {
	if (rewardXpText != "") _secondaryWidth += string_width(rewardXpText) + _rewardGap;
	for (var i = 0; i < array_length(rewardEntries); i++) {
		_secondaryWidth += _rewardIconSize + 8 + string_width(rewardEntries[i].text) + _rewardGap;
	}
	_secondaryWidth -= _rewardGap;
	_secondaryHeight = _rewardIconSize;
}

var _contentWidth = max(360, _labelWidth, _titleWidth + _checkSpace, _secondaryWidth);
var _bandWidth = _contentWidth + 120;
var _secondaryBlock = hasSecondary ? (18 + _secondaryLabelHeight + _secondaryHeight) * secondaryProgress : 0;
var _bandFullHeight = 26 + _labelHeight + 10 + _titleHeight + 26 + _secondaryBlock;
var _bandHeight = _bandFullHeight * max(0, openness);

#endregion

#region faixa

var _bandX = _cx - _bandWidth / 2;
var _bandY = _cy - _bandHeight / 2;

if (_bandHeight > 16) {
	draw_set_alpha(alpha);
	drawSpriteShadowStretched(_bandX, _bandY, spr_dialogue, 0, 0, _bandWidth, _bandHeight, 0, 6);
	draw_sprite_stretched_ext(spr_dialogue, 0, _bandX, _bandY, _bandWidth, _bandHeight, c_white, alpha);

	if (flash > .02) {
		drawSpriteWithGpuFogStretched(c_white, spr_dialogue, 0, _bandX, _bandY, _bandWidth, _bandHeight, 0, flash * .3 * alpha);
	}

	var _halfLine = (_bandWidth / 2 - 24) * (1 - sqr(1 - lineProgress));
	draw_set_color(accentColor);
	for (var i = 0; i < 2; i++) {
		var _lineY = i == 0 ? _bandY + 10 : _bandY + _bandHeight - 13;
		draw_set_alpha(alpha * .3);
		draw_rectangle(_cx - _halfLine - 4, _lineY - 2, _cx + _halfLine + 4, _lineY + 5, false);
		draw_set_alpha(alpha);
		draw_rectangle(_cx - _halfLine, _lineY, _cx + _halfLine, _lineY + 2, false);
	}
	draw_set_color(c_white);
}

#endregion

#region conteúdo

var _contentAlpha = alpha * clamp((openness - .5) * 2, 0, 1);

if (_contentAlpha > .02) {
	var _y = _cy - _bandFullHeight / 2 + 26;

	draw_set_font(fnt_gui_title);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	var _labelY = _y - (1 - _contentAlpha) * 8;
	drawTextShadow(_cx, _labelY, label, _contentAlpha, 2, _labelScale);
	draw_set_alpha(_contentAlpha);
	draw_set_color(accentColor);
	draw_text_transformed(_cx, _labelY, label, _labelScale, _labelScale, 0);
	_y += _labelHeight + 10;

	var _scale = textScale * (1 + titlePop);
	var _groupStartX = _cx - (_titleWidth + _checkSpace) / 2;
	var _titleCenterY = _y + _titleHeight / 2;

	if (showCheck) {
		var _checkSize = 12 * textScale;
		drawCheckMark(_groupStartX + _checkSize + 4, _titleCenterY, _checkSize * (1 + titlePop), accentColor, _contentAlpha, checkProgress, 4 * textScale);
	}

	var _titleX = _groupStartX + _checkSpace + _titleWidth / 2;
	draw_set_valign(fa_middle);
	drawTextShadow(_titleX, _titleCenterY, textContent, _contentAlpha, 3 * textScale, _scale);
	draw_set_color(merge_color(textColor, c_white, flash * .5));
	draw_text_transformed(_titleX, _titleCenterY, textContent, _scale, _scale, 0);
	_y += _titleHeight + 18;

	var _secondaryAlpha = _contentAlpha * secondaryProgress;

	if (hasSecondary && _secondaryAlpha > .02) {
		var _slide = (1 - secondaryProgress) * 14;
		var _dividerHalf = 60 * secondaryProgress;

		draw_set_color(c_white);
		draw_set_alpha(_secondaryAlpha * .25);
		draw_line_width(_cx - _dividerHalf, _y, _cx + _dividerHalf, _y, 2);
		draw_set_alpha(_secondaryAlpha);
		_y += 10;

		draw_set_font(fnt_gui_default);
		draw_set_valign(fa_top);

		if (secondaryLabel != "") {
			drawTextShadow(_cx, _y + _slide, secondaryLabel, _secondaryAlpha, 2, .75);
			draw_set_alpha(_secondaryAlpha);
			draw_set_color(#a8a8a8);
			draw_text_transformed(_cx, _y + _slide, secondaryLabel, .75, .75, 0);
		}
		_y += _secondaryLabelHeight;

		if (secondaryText != "") {
			var _textWidth = string_width_ext(secondaryText, -1, _secondaryWrap);
			var _arrowX = _cx - _textWidth / 2 - 18 + sin(current_time / 150) * 3;
			var _arrowY = _y + string_height("A") / 2 + _slide;

			draw_set_color(c_black);
			draw_triangle(_arrowX - 5 + 2, _arrowY - 7 + 2, _arrowX - 5 + 2, _arrowY + 7 + 2, _arrowX + 6 + 2, _arrowY + 2, false);
			draw_set_color(QUEST_COLOR);
			draw_triangle(_arrowX - 5, _arrowY - 7, _arrowX - 5, _arrowY + 7, _arrowX + 6, _arrowY, false);

			drawTextExtShadow(_cx + 10 + _slide, _y + _slide, secondaryText, -1, _secondaryWrap, _secondaryAlpha, 2, 1);
			draw_set_color(QUEST_COLOR);
			draw_text_ext(_cx + 10 + _slide, _y + _slide, secondaryText, -1, _secondaryWrap);
		} else {
			var _x = _cx - _secondaryWidth / 2;
			var _rowCenterY = _y + _rewardIconSize / 2 + _slide;
			draw_set_valign(fa_middle);
			draw_set_halign(fa_left);

			if (rewardXpText != "") {
				drawTextShadow(_x, _rowCenterY, rewardXpText, _secondaryAlpha);
				draw_set_color(QUEST_COLOR);
				draw_text(_x, _rowCenterY, rewardXpText);
				_x += string_width(rewardXpText) + _rewardGap;
			}

			for (var i = 0; i < array_length(rewardEntries); i++) {
				var _entry = rewardEntries[i];
				var _pop = max(0, _entry.pop);
				var _entryAlpha = _secondaryAlpha * clamp(_pop, 0, 1);
				var _iconCenterX = _x + _rewardIconSize / 2;

				drawSpriteFitCentered(_entry.sprite, _iconCenterX + 3, _rowCenterY + 3, _rewardIconSize, _pop, 0, c_black, _entryAlpha * .35);
				drawSpriteFitCentered(_entry.sprite, _iconCenterX, _rowCenterY, _rewardIconSize, _pop, 0, c_white, _entryAlpha);

				var _textX = _x + _rewardIconSize + 8;
				drawTextShadow(_textX, _rowCenterY, _entry.text, _entryAlpha);
				draw_set_alpha(_entryAlpha);
				draw_set_color(c_white);
				draw_text(_textX, _rowCenterY, _entry.text);

				_x = _textX + string_width(_entry.text) + _rewardGap;
			}
		}
	}
}

#endregion

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(fnt_gui_default);
