displayHeight = display_get_gui_height();
guiWidth = display_get_gui_width();
defaultBarWidth = guiWidth * .35;
barWidth = defaultBarWidth;
textAlpha = 1;
barHeight = 30;
barXPosition = guiWidth / 2 - barWidth / 2;
currentXpBarWidth = 0;
currentXpSubBarWidth = 0;
xpX2Position = 0;
xpYMiddlePosition = 0;
xpPopList = ds_list_create();

titlePercent = 0;
titlePosition = 0;
isLevelingUp = false;

function handleLevelUp() {
	currentXpBarWidth = 0;
	currentXpSubBarWidth = 0;
	
	audio_play_sound(snd_level_up, 0, false);
	pauseSystems();
	isLevelingUp = true;
	obj_controller.setDefaultCursor();
	if (!audio_is_playing(snd_level_up_music)) {
		audio_play_sound(snd_level_up_music, 0, true);
	}
}

function XpPopUp(_x, _y, _text, _direction) constructor {
	startX = _x;
	startY = _y;
	x = _x;
	y = _y;
	size = 0;
	text = _text;
	pursuing = false;
	direction = _direction;
	xrange = random(2);
	alpha = 1;
}

function handleGainXp(_value) {
	var _x = roomToGuiX(getMiddlePoint(obj_player.bbox_left, obj_player.bbox_right));
	var _y = roomToGuiY(obj_player.bbox_top - irandom_range(60, 80));
	var _text = "+" + string(_value) + "xp";
	var _direction = choose(-1, 1);
	
	ds_list_add(xpPopList, new XpPopUp(_x, _y, _text, _direction));
	
	audio_play_sound(snd_xp_earning, 0, false);
}

function handleXpPopUps() {
	draw_set_font(fnt_default_small);
	for (var i = ds_list_size(xpPopList) - 1; i >= 0; i--) {
		var _popUp = xpPopList[| i];
		
		drawTextShadow(_popUp.x, _popUp.y, _popUp.text, _popUp.alpha, 1, _popUp.size);
		var _textColor = #21B243;
		draw_text_transformed_color(
			_popUp.x,
			_popUp.y,
			_popUp.text,
			_popUp.size,
			_popUp.size,
			0,
			_textColor,
			_textColor,
			_textColor,
			_textColor,
			_popUp.alpha
		);
		
		var _bigSize = 1.3;
		
		if (!_popUp.pursuing && _popUp.size >= _bigSize - .01) {
			_popUp.pursuing = true;
		}
		
		var _size = _popUp.pursuing ? .2 : _bigSize
		var _sizeSpeed = _popUp.pursuing ? .07 : .1;
		_popUp.size = lerp(_popUp.size, _size, _sizeSpeed);
		
		
		if (!_popUp.pursuing) {
			_popUp.x += sign(_popUp.direction) * _popUp.xrange;
			_popUp.y --;
			
			continue;
		}
		
		var _lerpEffect = .09;
		
		_popUp.x = lerp(_popUp.x, xpX2Position, _lerpEffect);
		_popUp.y = lerp(_popUp.y, xpYMiddlePosition, _lerpEffect);
		_popUp.alpha = lerp(_popUp.alpha, 0, _lerpEffect);
		if (_popUp.pursuing && _popUp.size < .22) ds_list_delete(xpPopList, i);
	}
	draw_set_font(fnt_default);
}

function drawXpBar() {
	var _barYPosition = 34;
	var _sprite = spr_level_bar;
	draw_sprite_stretched(_sprite, 0, barXPosition, _barYPosition, barWidth, barHeight);
	 
	var _progress = global.player.xp / global.xpNext;
	var _barWidthByXp = barWidth * clamp(_progress, 0, 1);
	currentXpSubBarWidth = lerp(currentXpSubBarWidth, _barWidthByXp, .2);
	currentXpBarWidth = lerp(currentXpBarWidth, _barWidthByXp, .06);
	
	draw_sprite_stretched(_sprite, 1, barXPosition, _barYPosition, currentXpSubBarWidth, barHeight);
	draw_sprite_stretched(_sprite, 2, barXPosition, _barYPosition, currentXpBarWidth, barHeight);
	
	xpX2Position = barXPosition + currentXpBarWidth;
	
	draw_set_font(fnt_default_small);
	draw_set_valign(fa_middle);
	var _alpha = draw_get_alpha();
	draw_set_alpha(textAlpha);
	
	var _textX = barXPosition + 8;
	var _currentXpText = string(" XP ") + string(global.player.xp) + "/" + string(global.xpNext);
	var _currentXpY = _barYPosition + barHeight / 2;
	xpYMiddlePosition = _currentXpY
	drawTextShadow(_textX, _currentXpY, _currentXpText, draw_get_alpha());
	draw_text(_textX, _currentXpY, _currentXpText);
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	var _currentLevelText = "Level " + string(global.player.level);
	var _textHeight = string_height(_currentLevelText);
	var _levelTextY = _barYPosition - _textHeight - 3;
	
	drawTextShadow(_textX, _levelTextY, _currentLevelText, textAlpha);
	draw_text(_textX, _levelTextY, _currentLevelText);
	
	draw_set_alpha(_alpha);
	draw_set_font(fnt_default);
}

function handleStopLevelingUp() {
	titlePercent = 0;
	isLevelingUp = false;
	array_foreach(options, function (_option) {
		_option.selectionProgress = 0;
		_option.animPercent = 0;
	});
	audio_stop_sound(snd_level_up_music);
	unPauseSystems();
}

function drawLevelUpWarning() {
	drawLevelUpButtonOptions();
	drawLevelUpTitle();
}

function drawLevelUpTitle() {
	var _guiWidth  = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	
	var _y = 250;
	
	titlePercent = min(titlePercent + 0.02, 1);
	var _oAlpha = draw_get_alpha();
	
	draw_set_alpha(titlePercent);
	
	var _text = "[wave][fnt_gui_level_up][fa_center]Subiu de Nível[/wave]"
	
	drawTextShadowScribble(_guiWidth / 2, _y, _text, 1);
	
	draw_text_scribble(
		_guiWidth / 2,
		_y,
		_text
	);
	
	draw_set_alpha(_oAlpha);
}


upgradeOptionBuilder = function (_type, _icon, _color) {
	return {
		type: _type,
		icon: _icon,
		y: -1,
		animPercent: 0,
		color: _color,
		selectionProgress: 0
	}
};

options = [
	upgradeOptionBuilder(upgradeStatusOption.health, spr_icon_health, c_red),
	upgradeOptionBuilder(upgradeStatusOption.stamina, spr_icon_stamina, c_green),
];

levelUpAnimTimer = 0;

upgradeOptionAnimCurve = animcurve_get_channel(ac_gui, "levelUp");

function drawLevelUpButtonOptions() {
	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	
	var _optionSize = 300;
	var _marginBetween = 30;
	var _optionSprite = spr_upgrade_option;
	var _middlePoint = _guiWidth / 2;
	
	var _totalWidth = array_length(options) * _optionSize + (array_length(options) - 1) * _marginBetween;

	var _startX = _middlePoint - (_totalWidth / 2);
	var _delayPerItem = 30;
	var _isHoveringAny = false;
	for(var i = 0; i < array_length(options); i ++) {
		var _upgradeOption = options[i];
		var _x = _startX + i * (_optionSize + _marginBetween);
		
		var _endY = (_guiHeight / 2) - (_optionSize / 2);
		
		if (levelUpAnimTimer < i * _delayPerItem) {
			continue;
		}
		
		var _startY = _guiHeight + 50;
		var _isHovering = mouseIsOnRectangle(_x, _upgradeOption.y, _x + _optionSize, _upgradeOption.y + _optionSize);
		
		if (_upgradeOption.y == -1) {
			_upgradeOption.y = _startY;
			_upgradeOption.animPercent = 0;
		}
		
		if (_upgradeOption.animPercent != 1) {
			_upgradeOption.animPercent = min(_upgradeOption.animPercent + 0.008, 1);

			var _animEvaluation = animcurve_channel_evaluate(
				upgradeOptionAnimCurve,
				_upgradeOption.animPercent
			);

			_upgradeOption.y = lerp(_startY, _endY, _animEvaluation);
		} else {
			_isHoveringAny = _isHovering ? true : _isHoveringAny;
			_upgradeOption.y = lerp(_upgradeOption.y, _endY - (20 * _isHovering), .1);
			var _progressSpeed = .01;
			if (_isHovering && mouse_check_button(mb_left)) {
				_upgradeOption.selectionProgress = min(_upgradeOption.selectionProgress + _progressSpeed, 1);
				if (!audio_is_playing(snd_level_up_progress)) {
					audio_play_sound(snd_level_up_progress, 0, false);
				}
			} else {
				_upgradeOption.selectionProgress = max(_upgradeOption.selectionProgress - _progressSpeed, 0);
			}
		}
		
		if (_upgradeOption.selectionProgress > 0) {
			var _progressH = _optionSize * _upgradeOption.selectionProgress;
	
			var _left   = _x + 5;
			var _right  = _x + _optionSize - 5;
			var _bottom = _upgradeOption.y + _optionSize - 5;
			var _top    = _bottom - _progressH + 6;
			
			var _color = _upgradeOption.color;
			var _oAlpha = draw_get_alpha();
			draw_set_alpha(.4);
			draw_rectangle_color(
				_left,
				_top,
				_right,
				_bottom,
				_color,
				_color,
				_color,
				_color,
				false
			);
			
			draw_set_alpha(_oAlpha);
		}

		draw_sprite_stretched_ext(_optionSprite, 0, _x, _upgradeOption.y, _optionSize, _optionSize, _upgradeOption.color, draw_get_alpha());
		
		var _middleXPoint = getMiddlePoint(_x, _x + _optionSize);
		var _middleYPoint = getMiddlePoint(_upgradeOption.y, _upgradeOption.y + _optionSize);
		
		var _icon = _upgradeOption.icon;
		var _iconSize = _optionSize * .3;
		var _iscale = getScale(_iconSize, sprite_get_height(_icon))
		var _ix = _middleXPoint;
		var _iy =  _middleYPoint;
		
		draw_sprite_ext(_icon, 0, _ix, _iy, _iscale, _iscale, 0, c_white, 1);
		
		var _screenValues = getValuesByUpgradeType(_upgradeOption.type);
		
		var _border = 20;
		var _ty = _upgradeOption.y + _border;
		var _tx = _x + _border;
		
		draw_set_font(fnt_gui_title);
		
		var _title = _screenValues.name + ": " + string(_screenValues.currentValue);
		
		drawTextShadow(_tx, _ty, _title, 1);
		draw_text(_tx, _ty, _title);
		draw_set_font(fnt_gui_long_text);
		
		var _dy = _upgradeOption.y + _optionSize - _border - string_height("TXT");
		drawTextShadow(_tx, _dy, _screenValues.description, 1);
		draw_text(_tx, _dy, _screenValues.description);
		
		var _lt = "Lv" + string(_screenValues.currentLevel);
		var _lx = _x + _optionSize - _border - string_width(_lt);
		drawTextShadow(_lx, _dy, _lt, 1);
		draw_text(_lx, _dy, _lt);
		draw_set_font(fnt_gui_default);
		
		if (_upgradeOption.selectionProgress >= 1) {
			handleUpgradeSelected(_upgradeOption.type);
		}
	}
	
	if (!_isHoveringAny || !mouse_check_button(mb_left)) {
		audio_stop_sound(snd_level_up_progress);
	}
	
	levelUpAnimTimer++;
}

function handleUpgradeSelected(_upgradeType) {
	audio_stop_sound(snd_level_up_progress);
	audio_play_sound(snd_level_up, 0, false);
	
	if (_upgradeType == upgradeStatusOption.health) {
		increaseHealthLevel();
	}
	
	if (_upgradeType == upgradeStatusOption.stamina) {
		increaseStaminaLevel();
	}
	
	handleStopLevelingUp();
}

function getValuesByUpgradeType(_type) {
	var _response = {
		currentValue: 0,
		increaseValue: 0,
		name: "",
		description: "",
		currentLevel: 1
	};
	
	if (_type == upgradeStatusOption.health) {
		_response.currentValue  = global.player.defaultMaxHealth;
		_response.increaseValue = global.healthPerLevel;
		_response.name          = "Vida";
		_response.description   = _response.name + " +" + string(_response.increaseValue);
		_response.currentLevel = global.player.stats.healthLevel;
		return _response;
	}
	
	if (_type == upgradeStatusOption.stamina) {
		_response.currentValue  = global.player.defaultMaxStamina;
		_response.increaseValue = global.staminaPerLevel;
		_response.name          = "Stamina";
		_response.description   = _response.name + " +" + string(_response.increaseValue);
		_response.currentLevel = global.player.stats.staminaLevel;
		
		return _response;
	}
	
	return _response;
}
