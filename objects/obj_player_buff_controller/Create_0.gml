#macro BUFF_MEDALLION_RADIUS 32
#macro BUFF_MEDALLION_SPACING 80
#macro BUFF_HUD_MARGIN 44

totalHealthMultiplier = 1;
totalStaminaMultiplier = 1;

buffVisuals = {};
leavingBuffs = [];
buffSparks = [];
buffPopups = [];
hudOffsetY = 0;
hudAlpha = 1;
tooltip = {
	alpha: 0,
	buff: undefined,
	x: 0,
	y: 0
};

#region ciclo de vida

function runApplyHook(_buff) {
	var _definition = getBuffDefinition(_buff.id);
	if (!is_undefined(_definition)) _definition.onApply();
}

function runRemoveHook(_buff) {
	var _definition = getBuffDefinition(_buff.id);
	if (!is_undefined(_definition)) _definition.onRemove();
}

function recalculatePlayerStats() {
	totalHealthMultiplier = 1;
	totalStaminaMultiplier = 1;

	for (var i = 0; i < array_length(global.player.buffList); i++) {
		var _buff = global.player.buffList[i];
		var _effects = _buff[$ "effects"] ?? [new BuffEffect(_buff.type, _buff.multiplier)];

		for (var j = 0; j < array_length(_effects); j++) {
			var _effect = _effects[j];
			if (_effect.stat == buffTypes.health) totalHealthMultiplier *= _effect.multiplier;
			if (_effect.stat == buffTypes.stamina) totalStaminaMultiplier *= _effect.multiplier;
		}
	}

	global.player.maxHealth = global.player.defaultMaxHealth * totalHealthMultiplier;
	global.player.maxStamina = global.player.defaultMaxStamina * totalStaminaMultiplier;
}

function findBuffIndex(_buffId) {
	for (var i = 0; i < array_length(global.player.buffList); i++) {
		if (global.player.buffList[i].id == _buffId) return i;
	}
	return -1;
}

function applyBuff(_buff, _silent = false) {
	if (!is_struct(_buff)) return;

	var _index = findBuffIndex(_buff.id);
	if (_index != -1) {
		var _savedBuff = global.player.buffList[_index];
		_savedBuff.currentTime = _savedBuff.timeInSeconds;
		if (!_silent) playRefreshFeedback(_savedBuff);
		return;
	}

	array_push(global.player.buffList, _buff);
	runApplyHook(_buff);
	recalculatePlayerStats();
	createBuffVisual(_buff, _silent);
	if (!_silent) addBuffPopup(_buff);
}

function removeBuff(_index, _expired = false) {
	if (_index < 0 || _index >= array_length(global.player.buffList)) return;

	var _buff = global.player.buffList[_index];
	array_delete(global.player.buffList, _index, 1);
	runRemoveHook(_buff);
	recalculatePlayerStats();
	sendVisualToLeaving(_buff, _expired);
}

function removeBuffByBuffId(_buffId) {
	for (var i = array_length(global.player.buffList) - 1; i >= 0; i--) {
		if (global.player.buffList[i].id == _buffId) removeBuff(i);
	}
}

function clearBuffs() {
	for (var i = array_length(global.player.buffList) - 1; i >= 0; i--) {
		runRemoveHook(global.player.buffList[i]);
	}
	global.player.buffList = [];
	buffVisuals = {};
	leavingBuffs = [];
	recalculatePlayerStats();
}

function onBuffListLoaded() {
	for (var i = 0; i < array_length(global.player.buffList); i++) {
		var _buff = global.player.buffList[i];
		runApplyHook(_buff);
		createBuffVisual(_buff, true);
	}
	recalculatePlayerStats();
}

function tickBuffs() {
	var _delta = delta_time / 1000000;

	for (var i = array_length(global.player.buffList) - 1; i >= 0; i--) {
		var _buff = global.player.buffList[i];
		if (_buff.timeInSeconds == -1) continue;

		_buff.currentTime = max(0, _buff.currentTime - _delta);
		if (_buff.currentTime <= 0) removeBuff(i, true);
	}
}

#endregion

#region debuffs de condição (fome e sede)

function setConditionBuff(_group, _desiredId) {
	var _activeId = -1;
	for (var i = 0; i < array_length(_group); i++) {
		if (findBuffIndex(_group[i]) != -1) {
			_activeId = _group[i];
			break;
		}
	}

	if (_activeId == _desiredId) return;
	if (_activeId != -1) removeBuffByBuffId(_activeId);
	if (_desiredId != -1) applyBuff(buildBuffFromDefinition(_desiredId));
}

function observeDebuffs() {
	var _hunger = global.player.currentHunger;
	var _totalHunger = global.player.defaultTotalHunger;
	var _hungerLevel = _hunger < _totalHunger * .15 ? buffs.veryHungry : (_hunger < _totalHunger * .3 ? buffs.hungry : -1);
	setConditionBuff([buffs.hungry, buffs.veryHungry], _hungerLevel);

	var _thirst = global.player.currentThirst;
	var _totalThirst = global.player.defaultTotalThirst;
	var _thirstLevel = _thirst < _totalThirst * .15 ? buffs.veryThirst : (_thirst < _totalThirst * .3 ? buffs.thirst : -1);
	setConditionBuff([buffs.thirst, buffs.veryThirst], _thirstLevel);
}

#endregion

#region estado visual e feedback

function getBuffVisual(_buff) {
	return buffVisuals[$ string(_buff.id)];
}

function createBuffVisual(_buff, _silent) {
	buffVisuals[$ string(_buff.id)] = {
		x: _silent ? -1 : display_get_gui_width() + 80,
		scale: _silent ? 1 : 1.5,
		scaleVelocity: 0,
		flash: _silent ? 0 : 1,
		ring: 0,
		hover: 0
	};
}

function playRefreshFeedback(_buff) {
	var _visual = getBuffVisual(_buff);
	if (is_undefined(_visual)) return;
	_visual.scale = 1.3;
	_visual.scaleVelocity = 0;
	_visual.ring = 1;
	_visual.flash = .6;
}

function sendVisualToLeaving(_buff, _expired) {
	var _visual = getBuffVisual(_buff);
	variable_struct_remove(buffVisuals, string(_buff.id));
	if (is_undefined(_visual) || _visual.x < 0) return;

	array_push(leavingBuffs, {
		buff: _buff,
		x: _visual.x,
		scale: _visual.scale,
		angle: 0,
		life: 1
	});

	if (_expired) {
		var _y = BUFF_HUD_MARGIN + BUFF_MEDALLION_RADIUS + hudOffsetY;
		repeat (10) {
			var _direction = random(360);
			var _speed = random_range(2, 5);
			array_push(buffSparks, {
				x: _visual.x,
				y: _y,
				hsp: lengthdir_x(_speed, _direction),
				vsp: lengthdir_y(_speed, _direction),
				life: 1,
				color: getBuffColor(_buff)
			});
		}
	}
}

function addBuffPopup(_buff) {
	if (!instance_exists(obj_player)) return;

	var _text = _buff.type == buffTypes.custom ? _buff.description : getBuffEffectText(_buff);
	array_push(buffPopups, {
		text: _text,
		color: getBuffColor(_buff),
		x: obj_player.x,
		y: obj_player.bbox_top - 12,
		life: 0,
		maxLife: 100
	});
}

function updateBuffVisual(_visual, _targetX) {
	_visual.x = _visual.x < 0 ? _targetX : lerp(_visual.x, _targetX, .2);
	_visual.scaleVelocity += (1 - _visual.scale) * .25;
	_visual.scaleVelocity *= .7;
	_visual.scale += _visual.scaleVelocity;
	_visual.flash = max(0, _visual.flash - .06);
	_visual.ring = max(0, _visual.ring - .04);
}

#endregion

#region HUD

function isBuffHudVisible() {
	var _isChestOpen = global.activeInventory && instance_exists(obj_inventory) && obj_inventory.secundaryInventory != false;
	if (_isChestOpen) return true;
	return !(global.stopInteractions || isMenuOpen() || global.activeInventory);
}

function drawBuffHud() {
	var _isVisible = isBuffHudVisible();
	hudOffsetY = lerp(hudOffsetY, _isVisible ? 0 : -(BUFF_HUD_MARGIN + BUFF_MEDALLION_RADIUS * 2 + 20), .15);
	hudAlpha = lerp(hudAlpha, _isVisible, .15);

	var _guiWidth = display_get_gui_width();
	var _centerY = BUFF_HUD_MARGIN + BUFF_MEDALLION_RADIUS + hudOffsetY;
	var _hoveredBuff = undefined;
	var _hoveredX = 0;

	for (var i = 0; i < array_length(global.player.buffList); i++) {
		var _buff = global.player.buffList[i];
		var _visual = getBuffVisual(_buff);
		if (is_undefined(_visual)) {
			createBuffVisual(_buff, true);
			_visual = getBuffVisual(_buff);
		}

		var _targetX = _guiWidth - BUFF_HUD_MARGIN - BUFF_MEDALLION_RADIUS - i * BUFF_MEDALLION_SPACING;
		updateBuffVisual(_visual, _targetX);

		var _isHover = hudAlpha > .5 && point_distance(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), _visual.x, _centerY) <= BUFF_MEDALLION_RADIUS;
		_visual.hover = lerp(_visual.hover, _isHover, .25);
		if (_isHover) {
			_hoveredBuff = _buff;
			_hoveredX = _visual.x;
		}

		if (hudAlpha < .02) continue;
		draw_set_alpha(hudAlpha);
		drawBuffMedallion(_buff, _visual.x, _centerY + getBuffJiggle(_buff), BUFF_MEDALLION_RADIUS, _visual.scale * (1 + _visual.hover * .08), _visual.flash, _visual.ring);
		draw_set_alpha(1);
	}

	drawLeavingBuffs(_centerY);
	drawBuffSparks();
	drawBuffTooltip(_hoveredBuff, _hoveredX, _centerY + BUFF_MEDALLION_RADIUS + 14);
}

function getBuffJiggle(_buff) {
	if (_buff.isPermanent() || _buff.getTimeRatio() >= .3) return 0;
	return sin(current_time / 60) * 1.5;
}

function drawLeavingBuffs(_centerY) {
	for (var i = array_length(leavingBuffs) - 1; i >= 0; i--) {
		var _leaving = leavingBuffs[i];
		_leaving.life -= .07;
		_leaving.scale = lerp(_leaving.scale, 0, .18);
		_leaving.angle += 8;

		if (_leaving.life <= 0) {
			array_delete(leavingBuffs, i, 1);
			continue;
		}

		draw_set_alpha(_leaving.life * hudAlpha);
		drawBuffMedallion(_leaving.buff, _leaving.x, _centerY, BUFF_MEDALLION_RADIUS, _leaving.scale, 0, 0, _leaving.angle);
		draw_set_alpha(1);
	}
}

function drawBuffSparks() {
	for (var i = array_length(buffSparks) - 1; i >= 0; i--) {
		var _spark = buffSparks[i];
		_spark.x += _spark.hsp;
		_spark.y += _spark.vsp;
		_spark.hsp *= .9;
		_spark.vsp *= .9;
		_spark.life -= .04;

		if (_spark.life <= 0) {
			array_delete(buffSparks, i, 1);
			continue;
		}

		draw_set_alpha(_spark.life * hudAlpha);
		draw_set_color(_spark.color);
		draw_rectangle(_spark.x - 2, _spark.y - 2, _spark.x + 2, _spark.y + 2, false);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function drawBuffTooltip(_buff, _x, _y) {
	if (!is_undefined(_buff)) tooltip.buff = _buff;
	tooltip.alpha = lerp(tooltip.alpha, !is_undefined(_buff), .2);

	if (tooltip.alpha < .02 || is_undefined(tooltip.buff)) return;
	if (findBuffIndex(tooltip.buff.id) == -1) {
		tooltip.alpha = 0;
		return;
	}

	if (!is_undefined(_buff)) {
		tooltip.x = tooltip.alpha < .1 ? _x : lerp(tooltip.x, _x, .3);
		tooltip.y = _y;
	}

	drawBuffDetailsPanel(tooltip.buff, tooltip.x, tooltip.y + (1 - tooltip.alpha) * -8, tooltip.alpha, true);
}

function drawBuffPopups() {
	for (var i = array_length(buffPopups) - 1; i >= 0; i--) {
		var _popup = buffPopups[i];
		_popup.life++;

		if (_popup.life >= _popup.maxLife) {
			array_delete(buffPopups, i, 1);
			continue;
		}

		var _progress = _popup.life / _popup.maxLife;
		var _rise = (1 - power(1 - _progress, 3)) * 60;
		var _scale = _progress < .15 ? lerp(1.6, 1, _progress / .15) : 1;
		var _alpha = _progress > .7 ? 1 - (_progress - .7) / .3 : 1;
		var _x = roomToGuiX(_popup.x);
		var _y = roomToGuiY(_popup.y) - _rise - i * 26;

		draw_set_font(fnt_gui_default);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		drawTextShadow(_x, _y, _popup.text, _alpha, 3, _scale);
		draw_set_alpha(_alpha);
		draw_set_color(_popup.color);
		draw_text_transformed(_x, _y, _popup.text, _scale, _scale, 0);
	}
	draw_set_color(c_white);
	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

#endregion

onBuffListLoaded();
