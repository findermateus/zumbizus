enum buffTypes {
    health,
    stamina,
    damageAbsortion,
	custom
}

enum buffs {
	cookedMeat,
	dirtWater,
	rawMeat,
	ratMeat,
	hungry,
	veryHungry,
	thirst,
	veryThirst,
	bleeding
};

/// @param _effects { stat: buffTypes, multiplier }[]
/// @param _duration
function BuffDefinition(_id, _title, _effects, _duration, _positive, _icon = undefined, _customDescription = "") constructor {
	id = _id;
	title = _title;
	effects = _effects;
	duration = _duration;
	positive = _positive;
	icon = _icon;
	customDescription = _customDescription;
	onApply = function () {};
	onRemove = function () {};

	static setHooks = function (_onApply, _onRemove) {
		onApply = _onApply;
		onRemove = _onRemove;
		return self;
	}
}

function BuffEffect(_stat, _multiplier) constructor {
	stat = _stat;
	multiplier = _multiplier;
}

function initBuffDefinitions() {
	global.buffDefinitions = [];

	global.buffDefinitions[buffs.cookedMeat] = new BuffDefinition(buffs.cookedMeat, "Comeu uma boa carne nutritiva", [new BuffEffect(buffTypes.health, 1.1)], 60, true);
	global.buffDefinitions[buffs.dirtWater] = new BuffDefinition(buffs.dirtWater, "Bebeu uma água de procedência duvidosa", [new BuffEffect(buffTypes.health, .9)], 120, false);
	global.buffDefinitions[buffs.rawMeat] = new BuffDefinition(buffs.rawMeat, "Comeu carne crua", [new BuffEffect(buffTypes.health, .9)], 120, false);
	global.buffDefinitions[buffs.ratMeat] = new BuffDefinition(buffs.ratMeat, "Comeu carne crua de RATO (????)", [new BuffEffect(buffTypes.health, .8)], 300, false);

	global.buffDefinitions[buffs.hungry] = new BuffDefinition(buffs.hungry, "Está com fome", [new BuffEffect(buffTypes.health, .9)], -1, false, spr_icon_hunger_centralized);
	global.buffDefinitions[buffs.veryHungry] = new BuffDefinition(buffs.veryHungry, "Está com muita fome", [new BuffEffect(buffTypes.health, .7)], -1, false, spr_icon_hunger_centralized);
	global.buffDefinitions[buffs.thirst] = new BuffDefinition(buffs.thirst, "Está com sede", [new BuffEffect(buffTypes.stamina, .6)], -1, false, spr_icon_thirst_centralized);
	global.buffDefinitions[buffs.veryThirst] = new BuffDefinition(buffs.veryThirst, "Está com muita sede", [new BuffEffect(buffTypes.stamina, .4)], -1, false, spr_icon_thirst_centralized);

	global.buffDefinitions[buffs.bleeding] = new BuffDefinition(buffs.bleeding, "Sangramento", [], -1, false, spr_bleed_icon, "Perda de vida constante").setHooks(
		function () {
			if (!instance_exists(obj_player_bleeding_handler)) {
				instance_create_layer(0, 0, "Controllers", obj_player_bleeding_handler);
			}
		},
		function () {
			instance_destroy(obj_player_bleeding_handler);
		}
	);
}

function initConsumableBuffs() {
    global.consumableBuffs = [];
    global.consumableBuffs[consumableItems.cooked_meat_1] = buffs.cookedMeat;
    global.consumableBuffs[consumableItems.cooked_meat_2] = buffs.cookedMeat;
    global.consumableBuffs[consumableItems.dirt_water] = buffs.dirtWater;
	global.consumableBuffs[consumableItems.raw_meat_1] = buffs.rawMeat;
	global.consumableBuffs[consumableItems.raw_meat_2] = buffs.rawMeat;
	global.consumableBuffs[consumableItems.raw_rat_meat] = buffs.ratMeat;
}

initBuffDefinitions();
initConsumableBuffs();

function getBuffDefinition(_id) {
	if (!arrayKeyExists(global.buffDefinitions, _id)) return undefined;
	var _definition = global.buffDefinitions[_id];
	return is_struct(_definition) ? _definition : undefined;
}

function Buff(_id, _multiplier, _type, _description, _timeInSeconds = 60, _positive = true, _icon = undefined, _customDescription = "") constructor {
    id = _id;
	multiplier = _multiplier;
    type = _type;
    description = _description;
    timeInSeconds = _timeInSeconds;
    currentTime = _timeInSeconds;
    positive = _positive;
	icon = _icon;
	customDescription = _customDescription;
	effects = [new BuffEffect(_type, _multiplier)];

	static isPermanent = function () {
		return timeInSeconds == -1;
	}

	static getTimeRatio = function () {
		if (isPermanent() || timeInSeconds <= 0) return 1;
		return clamp(currentTime / timeInSeconds, 0, 1);
	}
}

function buildBuffFromDefinition(_id) {
	var _definition = getBuffDefinition(_id);
	if (is_undefined(_definition)) return false;

	var _mainEffect = array_length(_definition.effects) > 0 ? _definition.effects[0] : new BuffEffect(buffTypes.custom, 1);
	var _buff = new Buff(
		_definition.id,
		_mainEffect.multiplier,
		array_length(_definition.effects) > 0 ? _mainEffect.stat : buffTypes.custom,
		_definition.title,
		_definition.duration,
		_definition.positive,
		_definition.icon,
		_definition.customDescription
	);
	_buff.effects = _definition.effects;
	return _buff;
}

function getBuffByItemId(_id) {
    if (!arrayKeyExists(global.consumableBuffs, _id)) return false;
	var _buffId = global.consumableBuffs[_id];
	if (is_undefined(_buffId)) return false;
	return buildBuffFromDefinition(_buffId);
}

function buildCustomBuffByBuffId(_id) {
	return buildBuffFromDefinition(_id);
}

function getBuffIcon(_buff) {
	if (!is_undefined(_buff.icon) && sprite_exists(_buff.icon)) return _buff.icon;
	if (_buff.type == buffTypes.stamina) return spr_icon_stamina;
	return spr_icon_health;
}

function getBuffEffectText(_buff) {
	if (_buff.type == buffTypes.custom) return _buff.customDescription;

	var _texts = [];
	for (var i = 0; i < array_length(_buff.effects); i++) {
		var _effect = _buff.effects[i];
		var _percent = round((_effect.multiplier - 1) * 100);
		var _sign = _percent > 0 ? "+" : "";
		array_push(_texts, _sign + string(_percent) + "%" + getBuffStatName(_effect.stat));
	}

	var _result = "";
	for (var i = 0; i < array_length(_texts); i++) {
		_result += (i > 0 ? ", " : "") + _texts[i];
	}
	return _result;
}

function getBuffStatName(_stat) {
	switch(_stat) {
		case buffTypes.health:
			return " de vida máxima";
		case buffTypes.stamina:
			return " de stamina máxima";
		case buffTypes.damageAbsortion:
			return " de absorção de dano";
		default:
			return "";
	}
}

function getBuffColor(_buff) {
	return _buff.positive ? #5fd35f : #ff5a5a;
}

#region identidade visual (compartilhada entre HUD e inventário)

function drawBuffMedallion(_buff, _cx, _cy, _radius, _scale = 1, _flash = 0, _ring = 0, _angle = 0) {
	var _alpha = draw_get_alpha();
	var _r = _radius * _scale;
	if (_r < 1) return;

	var _color = getBuffColor(_buff);
	var _ratio = _buff.getTimeRatio();
	var _ringThickness = max(3, _radius * .2) * _scale;
	var _ringAlpha = 1;

	if (_buff.isPermanent()) {
		_ringAlpha = .55 + sin(current_time / 400) * .25;
	} else if (_ratio < .3) {
		var _blinkSpeed = _buff.currentTime < 5 ? 60 : 140;
		_ringAlpha = .55 + sin(current_time / _blinkSpeed) * .45;
	}

	draw_set_color(c_black);
	draw_set_alpha(_alpha * .35);
	draw_circle(_cx + 3, _cy + 4, _r, false);
	draw_set_color(#1d1d1d);
	draw_set_alpha(_alpha * .88);
	draw_circle(_cx, _cy, _r, false);

	drawRadialProgress(_cx, _cy, _r - _ringThickness, _r, 1, c_black, _alpha * .5);
	drawRadialProgress(_cx, _cy, _r - _ringThickness, _r, _ratio, _color, _alpha * _ringAlpha);

	var _icon = getBuffIcon(_buff);
	var _iconSize = (_r - _ringThickness) * 1.25;
	drawSpriteFitCentered(_icon, _cx + 2, _cy + 3, _iconSize, 1, _angle, c_black, _alpha * .35);
	drawSpriteFitCentered(_icon, _cx, _cy, _iconSize, 1, _angle, c_white, _alpha);

	if (_flash > 0) {
		gpu_set_blendmode(bm_add);
		draw_set_color(c_white);
		draw_set_alpha(_alpha * _flash * .6);
		draw_circle(_cx, _cy, _r, false);
		gpu_set_blendmode(bm_normal);
	}

	if (_ring > 0) {
		var _ringRadius = _r + (1 - _ring) * 22;
		draw_set_color(_color);
		draw_set_alpha(_alpha * _ring);
		draw_circle(_cx, _cy, _ringRadius, true);
		draw_circle(_cx, _cy, _ringRadius - 1, true);
	}

	draw_set_color(c_white);
	draw_set_alpha(_alpha);
}

function getBuffTimeText(_buff) {
	return _buff.isPermanent() ? "Enquanto durar a condição" : "Restam " + formatSeconds(_buff.currentTime);
}

/// @param _centered true: _x é o centro do painel
function drawBuffDetailsPanel(_buff, _x, _y, _alpha, _centered = false) {
	var _padding = 14;
	var _lineHeight = 30;
	var _title = _buff.description;
	var _effect = getBuffEffectText(_buff);
	var _time = getBuffTimeText(_buff);

	draw_set_font(fnt_gui_default);
	var _width = max(string_width(_title), string_width(_effect), string_width(_time)) + _padding * 2;
	var _hasTimeBar = !_buff.isPermanent();
	var _height = _padding * 2 + _lineHeight * 3 + (_hasTimeBar ? 10 : 0);
	var _guiWidth = display_get_gui_width();
	var _left = _centered ? _x - _width / 2 : _x;
	_left = clamp(_left, 12, _guiWidth - _width - 12);

	var _oldAlpha = draw_get_alpha();
	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_left, _y, spr_inventory_box, 0, 0, _width, _height, 0, 6);
	draw_sprite_stretched_ext(spr_inventory_box, 0, _left, _y, _width, _height, c_white, _alpha);

	var _textX = _left + _padding;
	var _textY = _y + _padding;
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	drawTextShadow(_textX, _textY, _title, _alpha);
	draw_text(_textX, _textY, _title);

	drawTextShadow(_textX, _textY + _lineHeight, _effect, _alpha);
	draw_set_color(getBuffColor(_buff));
	draw_text(_textX, _textY + _lineHeight, _effect);

	draw_set_color(#a8a8a8);
	draw_text(_textX, _textY + _lineHeight * 2, _time);

	if (_hasTimeBar) {
		var _barY = _textY + _lineHeight * 3 + 2;
		var _barWidth = _width - _padding * 2;
		draw_set_color(c_black);
		draw_set_alpha(_alpha * .5);
		draw_rectangle(_textX, _barY, _textX + _barWidth, _barY + 4, false);
		draw_set_color(getBuffColor(_buff));
		draw_set_alpha(_alpha);
		draw_rectangle(_textX, _barY, _textX + _barWidth * _buff.getTimeRatio(), _barY + 4, false);
	}

	draw_set_color(c_white);
	draw_set_alpha(_oldAlpha);
}

#endregion
