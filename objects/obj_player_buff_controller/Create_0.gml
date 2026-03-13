totalHealthMultiplier = 1;
totalStaminaMultiplier = 1;
animationCurve = animcurve_get_channel(ac_gui, "buff");
drawY = 0;
buffUIPosition = [];
buffEffectDescriptionX = 0;
buffDescriptionX = 0;
hoveringI = -1;
textAlpha = 0;
hoveringX = 0;

function handleBuffs() {
	resetStats()
	
	array_foreach(global.player.buffList, function (_buff, _index) {
		_buff.passTime();
		
		if (_buff.type == buffTypes.health) {
			totalHealthMultiplier *= _buff.multiplier;
		}
		
		if (_buff.type == buffTypes.stamina) {
			totalStaminaMultiplier *= _buff.multiplier;
		}
		
		if (_buff.type == buffTypes.custom) {
			handleCustomBuff(_buff);
		}
	})
	
	for (var i = 0; i < array_length(global.player.buffList); i ++) {
		if (global.player.buffList[i].timeInSeconds != -1 && global.player.buffList[i].currentTime <= 0) {
			removeBuff(i);
		}
	}
	
	global.player.maxHealth = global.player.defaultMaxHealth * totalHealthMultiplier;
	global.player.maxStamina = global.player.defaultMaxStamina * totalStaminaMultiplier;
}

function handleCustomBuff(_buff) {
	switch (_buff.id) {
		case buffs.bleeding: 
			if (!instance_exists(obj_player_bleeding_handler)) {
				instance_create_layer(0, 0, "Controllers", obj_player_bleeding_handler);
			}
		break;
	}
}

function resetStats() {
	totalHealthMultiplier = 1;
	totalStaminaMultiplier = 1;
	global.player.maxStamina = global.player.defaultMaxStamina;
	global.player.maxHealth = global.player.defaultMaxHealth;
}

function applyBuff(_buff) {
	for (var i = 0; i < array_length(global.player.buffList); i++) {
		var _savedBuff = global.player.buffList[i];
		if (_savedBuff.id == _buff.id) {
			_savedBuff.currentTime = _savedBuff.timeInSeconds;
			return;
		}
	}
	array_push(global.player.buffList, _buff);
}

function drawBuffs() {
	var _size = 70;
	var _margin = 40;
	var _target = global.stopInteractions || global.activeMenu || global.activeInventory ? - (_size + 5) : _margin;
	drawY = lerp(drawY, _target, .1);
	
	if (drawY < -_size) return;
	
	var _guiWidth = display_get_gui_width();
	var _initialY = _margin;
	var _initialX = _guiWidth - _margin - _size;
	var _boxSprite = spr_buff_icon;
	var _animationSpeed = (delta_time / 1000000) * .8;
	
	var _isHovering = false;
	for (var i = 0; i < array_length(global.player.buffList); i++) {
	   
	   if (i >= array_length(buffUIPosition)) {
	        buffUIPosition[i] = {
	            animCurveIndex: 0,
				jiggle: 0
	        };
	    }
		
	    var _buff = global.player.buffList[i];
	    var _y = drawY;
	    var _x = _initialX - ((_size + 15) * i);
	    var _icon = _buff.icon == undefined ? getIconByBuffType(_buff.type) : _buff.icon;
	    var _positive = _buff.positive;

	    buffUIPosition[i].animCurveIndex = max(0, buffUIPosition[i].animCurveIndex + _animationSpeed * 1.1);

	    var _curveValue = animcurve_channel_evaluate(animationCurve, buffUIPosition[i].animCurveIndex);
	    var _animX = lerp(_x, _guiWidth, _curveValue);

		var _jiggleX = 0;
	    var _jiggleIntensity = 5;
	    var _jiggleSpeed = 12;
		var _timeRatio = _buff.currentTime / _buff.timeInSeconds;

	    if (_timeRatio < .3) {
	        buffUIPosition[i].jiggle += _jiggleSpeed;
	        _jiggleX = sin(degtorad(buffUIPosition[i].jiggle)) * _jiggleIntensity;
	    } else {
	        buffUIPosition[i].jiggle = max(0, buffUIPosition[i].jiggle - 10);
	    }

		_animX += _jiggleX; 

	    draw_sprite_stretched(_boxSprite, 0, _animX, _y, _size, _size);
	    
		var _fullWidth = sprite_get_width(_boxSprite);
		var _fullHeight = sprite_get_height(_boxSprite);

		var _drawHeight = _fullHeight * _timeRatio; 

		draw_sprite_part_ext(
		    _boxSprite,                                   
		    1,                                            
		    0,                                            
		    _fullHeight - _drawHeight,                    
		    _fullWidth,                                   
		    _drawHeight,                                  
		    _animX,                                       
		    _y + (_size - (_size * _timeRatio)),          
		    _size / _fullWidth,
		    _size / _fullHeight,
		    _positive ? c_lime : c_red,
		    1                          
		);

	    var _iconSize = sprite_get_height(_icon);
	    var _desiredScale = getScale(_size * .6, _iconSize);
	    var _ix = _animX + _size / 2;
	    var _iy = _y + _size / 2;

		drawSpriteShadow(_ix, _iy, _icon, 0, 0, _desiredScale, _desiredScale);
	    draw_sprite_ext(_icon, 0, _ix, _iy, _desiredScale, _desiredScale, 0, c_white, 1);
		
		if (mouseIsOnRectangle(_animX, _y, _animX + _size, _y + _size)) {
			hoveringI = i;
			hoveringX = _ix;
			_isHovering = true;
		}
	}
	
	textAlpha = lerp(textAlpha, _isHovering, .1);
	
	if (hoveringI == -1 || textAlpha <= 0) return;
	draw_set_font(fnt_default_small)
	var _buff = global.player.buffList[hoveringI];
	var _description = _buff.description;
	var _baseTextX = hoveringX;
	var _textY = drawY + _size + 7

	var _effectDescription = "";
	if (_buff.type != buffTypes.custom) {
	    var _multiplier = multiplierToPercent(_buff.multiplier);
	    var _percent = _multiplier > 0 ? "+" + string(_multiplier) + "%" : string(_multiplier) + "%";
	    _effectDescription = _percent + getEffectDescriptionByType(_buff.type);
	} else {
	    _effectDescription = _buff.customDescription;
	}
	
	var _descriptionWidth = string_width(_description);
	var _effectDescriptionWidth = string_width(_effectDescription);

	var _targetDescX = _baseTextX;
	while(_targetDescX + _descriptionWidth/2 >= _guiWidth - 15) {
	    _targetDescX--;
	}

	var _targetEffectX = _baseTextX;
	while(_targetEffectX + _effectDescriptionWidth/2 >= _guiWidth - 15) {
	    _targetEffectX--;
	}

	buffDescriptionX = lerp(buffDescriptionX, _targetDescX, .1);
	buffEffectDescriptionX = lerp(buffEffectDescriptionX, _targetEffectX, .1);

	draw_set_halign(fa_center);
	var _setAlpha = draw_get_alpha();
	draw_set_alpha(textAlpha);

	drawTextShadow(buffDescriptionX, _textY, _description, textAlpha);
	draw_text(buffDescriptionX, _textY, _description);

	drawTextShadow(buffEffectDescriptionX, _margin, _effectDescription, textAlpha);
	draw_text(buffEffectDescriptionX, _margin, _effectDescription);

	draw_set_halign(fa_left);
	draw_set_alpha(_setAlpha);
	draw_set_font(fnt_gui_default)
}

function getEffectDescriptionByType(_type) {
	switch(_type) {
		case buffTypes.health:
			return " de vida";
		case buffTypes.stamina:
			return " de stamina"
		case buffTypes.damageAbsortion:
			return " de absorção de dano"
		default:
			return "";
	}
}

function getIconByBuffType(_type) {
	if (_type == buffTypes.health) {
		return spr_icon_health;
	}
	
	if (_type == buffTypes.stamina) {
		return spr_icon_stamina
	}
}

function multiplierToPercent(_multiplier)
{
    var _percent = (_multiplier - 1) * 100;
    return round(_percent);
}

function observeDebuffs() {
	var _buffIds = array_map(global.player.buffList, function (_buff) {
		return _buff.id;
	});
	
	var _hungryDebuffKey = array_get_index(_buffIds, buffs.hungry);
	var _hasHungryDebuff = _hungryDebuffKey != -1;
	var _isHungry = global.player.currentHunger < global.player.defaultTotalHunger * .3;
	
	if (_isHungry && !_hasHungryDebuff) {
		var _isVeryHungry = global.player.currentHunger < global.player.defaultTotalHunger * .15;
		var _multiplier = _isVeryHungry ? .7 : .9;
		var _description = _isVeryHungry ? "Está com muita fome" : "Está com fome";
		var _hungerDebuff = new Buff(buffs.hungry, _multiplier, buffTypes.health, _description, -1, false, spr_icon_hunger_centralized);
		array_push(global.player.buffList, _hungerDebuff);
	}
	
	if (!_isHungry && _hasHungryDebuff) {
		removeBuff(_hungryDebuffKey);
	}
	
	var _thirstDebuffKey = array_get_index(_buffIds, buffs.thirst);
	var _hasThirstDebuff = _thirstDebuffKey != -1;
	var _isThirsty = global.player.currentThirst < global.player.defaultTotalThirst * .3;
	
	if (_isThirsty && !_hasThirstDebuff) {
		var _isVeryThirsty = global.player.currentThirst < global.player.defaultTotalThirst * .15;
		var _multiplier = _isVeryThirsty ? .6 : .4;
		var _description = _isVeryThirsty ? "Está com muita sede" : "Está com sede";
		var _thirstDebuff = new Buff(buffs.thirst, _multiplier, buffTypes.stamina, _description, -1, false, spr_icon_thirst_centralized);
		array_push(global.player.buffList, _thirstDebuff);
	}
	
	if (!_isThirsty && _hasThirstDebuff) {
		removeBuff(_thirstDebuffKey);
	}
}

function removeBuff(_key) {
	
	//sei lá pq adicionei esse if, mas estava quebrando dizendo que a chave não existia no array.
	if (arrayKeyExists(buffUIPosition, _key)) {
		buffUIPosition[_key].animCurveIndex = 0;
	}
	
	var _lastKey = array_length(global.player.buffList) - 1;
	
	if (arrayKeyExists(buffUIPosition, _lastKey)) {
		buffUIPosition[_lastKey].animCurveIndex = 0;
	}
	array_delete(global.player.buffList, _key, 1);
	hoveringI = -1;
}

function removeBuffByBuffId(_buffId) {
	for (var i = 0; i < array_length(global.player.buffList); i ++) {
		if (global.player.buffList[i].id == _buffId) {
			removeBuff(i);
		}
	}
}