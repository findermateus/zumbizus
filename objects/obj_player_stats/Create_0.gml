#macro EQUIPED_ITEM_GRID_SIZE 90
#macro QUICK_USE_WIDTH 250
#macro QUICK_USE_HEIGHT 150
#macro QUICK_USE_SLOT_SIZE 60
#macro QUICK_USE_SELECTED_SLOT_SIZE 75
#macro STATUS_HUD_MARGIN 30
#macro STATUS_BAR_WIDTH 230
#macro STATUS_BAR_GAP 6
#macro LEVEL_MEDALLION_RADIUS 36
#macro LEVEL_MEDALLION_PADDING 6

gui_height = display_get_gui_height();
gui_width = display_get_gui_width();
xMouseToGui = device_mouse_x_to_gui(0);
yMouseToGui = device_mouse_y_to_gui(0);
healthStatus = { value: 1, max: 1, jiggleTimer: 0 };
staminaStatus = { value: 1, max: 1, jiggleTimer: 0 };
equipedItemsUI = [];
equipedItemsY = gui_height + EQUIPED_ITEM_GRID_SIZE;
equipedItemsX2 = 0;

quickUseItemsY = gui_height + QUICK_USE_HEIGHT;

#region painel de status (vida, stamina, nível/XP)

function createVitalBarUI() {
	return {
		display: 0,
		trail: 0,
		lastValue: 0,
		flash: 0,
		shake: 0,
		glow: 0,
		recovering: false,
		initialized: false
	};
}

healthBarUI = createVitalBarUI();
staminaBarUI = createVitalBarUI();
panelOffsetX = 0;
staminaIdleTimer = 0;
levelUI = {
	pop: 0,
	popVelocity: 0,
	flash: 0,
	xpDisplay: 0,
	xpTrail: 0,
	lastLevel: global.player.level
};
panelSparks = [];

/// @param _reactsToDrops false para a stamina, que cai um pouquinho todo frame ao correr
function updateVitalBar(_ui, _value, _reactsToDrops) {
	if (!_ui.initialized) {
		_ui.display = _value;
		_ui.trail = _value;
		_ui.lastValue = _value;
		_ui.initialized = true;
	}

	if (_value < _ui.lastValue - .01 && _reactsToDrops) {
		_ui.flash = 1;
		_ui.shake = min(9, 3 + (_ui.lastValue - _value) * .3);
	}
	if (_value > _ui.lastValue + .01) _ui.glow = 1;
	_ui.recovering = _value > _ui.lastValue + .001;
	_ui.lastValue = _value;

	_ui.display = lerp(_ui.display, _value, .25);
	_ui.trail = _ui.display < _ui.trail ? lerp(_ui.trail, _ui.display, .035) : _ui.display;
	_ui.flash = max(0, _ui.flash - .08);
	_ui.shake = lerp(_ui.shake, 0, .2);
	_ui.glow = max(0, _ui.glow - .03);
}


function drawStatusFillOverlay(_sprite, _x, _y, _scale, _fromRatio, _toRatio, _color, _alpha) {
	if (_toRatio <= _fromRatio || _alpha <= 0) return;

	var _fillStart = 21;
	var _fillableWidth = sprite_get_width(_sprite) - _fillStart;
	var _left = _fillStart + _fillableWidth * _fromRatio;

	gpu_set_fog(true, _color, 0, 0);
	draw_sprite_general(_sprite, 1, _left, 0, _fillableWidth * (_toRatio - _fromRatio), sprite_get_height(_sprite), _x + _left * _scale, _y, _scale, _scale, 0, c_white, c_white, c_white, c_white, _alpha);
	gpu_set_fog(false, c_white, 0, 0);
}

/// @param _options { isExhausted, alpha }
function drawHudStatusBar(_ui, _sprite, _x, _y, _width, _maxValue, _options = {}) {
	var _isExhausted = _options[$ "isExhausted"] ?? false;
	var _oldAlpha = draw_get_alpha();
	var _alpha = _oldAlpha * (_options[$ "alpha"] ?? 1);

	if (_ui.shake > .2) {
		_x += random_range(-_ui.shake, _ui.shake);
		_y += random_range(-_ui.shake, _ui.shake) * .5;
	}

	var _scale = _width / sprite_get_width(_sprite);
	var _max = max(1, _maxValue);
	var _ratio = clamp(_ui.display / _max, 0, 1);
	var _valueRatio = clamp(_ui.lastValue / _max, 0, 1);

	draw_set_alpha(_alpha);
	drawSpriteWithGpuFog(c_black, _sprite, 0, _x + 3, _y + 4, _scale, _scale, 0, _alpha * .35);
	drawInventoryStatusRow(_sprite, _ui.display, _maxValue, _ui.trail, _x, _y, _width);

	if (_ui.flash > 0) drawStatusFillOverlay(_sprite, _x, _y, _scale, 0, _ratio, c_white, _alpha * _ui.flash * .8);

	if (_ui.glow > 0) {
		gpu_set_blendmode(bm_add);
		drawStatusFillOverlay(_sprite, _x, _y, _scale, _ratio, _valueRatio, #5fd35f, _alpha * _ui.glow * .6);
		gpu_set_blendmode(bm_normal);
	}

	if (_ui.recovering && !_isExhausted && _ratio > .05) {
		var _band = .18;
		var _position = ((current_time / 900) mod (1 + _band)) - _band;
		gpu_set_blendmode(bm_add);
		drawStatusFillOverlay(_sprite, _x, _y, _scale, max(0, _position) * _ratio, min(1, _position + _band) * _ratio, c_white, _alpha * .25);
		gpu_set_blendmode(bm_normal);
	}

	if (_isExhausted) {
		var _labelAlpha = _alpha * (.6 + sin(current_time / 120) * .4);
		var _labelY = _y + sprite_get_height(_sprite) * _scale / 2;
		draw_set_font(fnt_default_small);
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		drawTextShadow(_x + _width + 10, _labelY, "Exausto", _labelAlpha, 2);
		draw_set_alpha(_labelAlpha);
		draw_set_color(#ffb3b3);
		draw_text(_x + _width + 10, _labelY, "Exausto");
		draw_set_color(c_white);
		draw_set_valign(fa_top);
		draw_set_font(fnt_gui_default);
	}

	draw_set_alpha(_oldAlpha);
}

function onXpPopArrive() {
	levelUI.pop = max(levelUI.pop, .18);
	levelUI.popVelocity = 0;
	levelUI.flash = 1;
}

function updateLevelMedallion() {
	if (global.player.level > levelUI.lastLevel) {
		levelUI.lastLevel = global.player.level;
		levelUI.pop = .5;
		levelUI.popVelocity = 0;
		levelUI.flash = 1;
		levelUI.xpDisplay = 0;
		levelUI.xpTrail = 0;
		addPanelSparks(24, #ffd166);
	}

	var _ratio = clamp(global.player.xp / max(1, global.xpNext), 0, 1);
	levelUI.xpTrail = lerp(levelUI.xpTrail, _ratio, .2);
	levelUI.xpDisplay = lerp(levelUI.xpDisplay, _ratio, .06);

	levelUI.popVelocity += -levelUI.pop * .25;
	levelUI.popVelocity *= .7;
	levelUI.pop += levelUI.popVelocity;
	levelUI.flash = max(0, levelUI.flash - .05);
}

function getLevelMedallionCenter() {
	var _layout = getStatusLayout();
	return [_layout.medallionX, _layout.medallionY];
}

function addPanelSparks(_count, _color) {
	var _center = getLevelMedallionCenter();
	repeat (_count) {
		var _direction = random(360);
		var _speed = random_range(2, 6);
		array_push(panelSparks, {
			x: _center[0] + lengthdir_x(LEVEL_MEDALLION_RADIUS, _direction),
			y: _center[1] + lengthdir_y(LEVEL_MEDALLION_RADIUS, _direction),
			hsp: lengthdir_x(_speed, _direction),
			vsp: lengthdir_y(_speed, _direction),
			life: 1,
			color: _color
		});
	}
}

function drawLevelMedallion(_cx, _cy) {
	var _radius = LEVEL_MEDALLION_RADIUS * (1 + levelUI.pop);
	var _ringThickness = 7;
	var _alpha = draw_get_alpha();

	draw_set_color(c_black);
	draw_set_alpha(_alpha * .35);
	draw_circle(_cx + 3, _cy + 4, _radius, false);
	draw_set_color(#1b1b1b);
	draw_set_alpha(_alpha * .92);
	draw_circle(_cx, _cy, _radius, false);

	drawRadialProgress(_cx, _cy, _radius - _ringThickness, _radius, 1, c_black, _alpha * .55);
	drawRadialProgress(_cx, _cy, _radius - _ringThickness, _radius, levelUI.xpTrail, #fff1d6, _alpha * .45);
	drawRadialProgress(_cx, _cy, _radius - _ringThickness, _radius, levelUI.xpDisplay, #ffd166, _alpha);

	if (levelUI.flash > 0) {
		gpu_set_blendmode(bm_add);
		drawRadialProgress(_cx, _cy, _radius - _ringThickness - 3, _radius + 3, 1, #ffd166, _alpha * levelUI.flash * .5);
		gpu_set_blendmode(bm_normal);
	}

	var _label = "NÍVEL";
	var _levelText = string(global.player.level);
	var _gap = 2;
	draw_set_font(fnt_default_small);
	var _labelWidth = string_width(_label);
	var _labelHeight = string_height(_label);
	draw_set_font(fnt_gui_title);
	var _numberWidth = string_width(_levelText);
	var _numberHeight = string_height(_levelText);

	var _innerRadius = LEVEL_MEDALLION_RADIUS - _ringThickness - LEVEL_MEDALLION_PADDING;
	var _available = _innerRadius * 2 * .78;
	var _contentHeight = _labelHeight + _gap + _numberHeight;
	var _fitScale = min(1, _available / _contentHeight, _available / max(_labelWidth, _numberWidth));
	var _popScale = 1 + levelUI.pop;

	var _top = _cy - _contentHeight * _fitScale * _popScale / 2;
	var _labelY = _top + _labelHeight * _fitScale * _popScale / 2;
	var _numberY = _top + (_labelHeight + _gap) * _fitScale * _popScale + _numberHeight * _fitScale * _popScale / 2;

	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_font(fnt_default_small);
	draw_set_alpha(_alpha);
	draw_set_color(#a8a8a8);
	draw_text_transformed(_cx, _labelY, _label, _fitScale * _popScale, _fitScale * _popScale, 0);

	var _levelScale = _fitScale * _popScale;
	draw_set_font(fnt_gui_title);
	drawTextShadow(_cx, _numberY, _levelText, _alpha, 3, _levelScale);
	draw_set_color(merge_color(c_white, #ffd166, levelUI.flash));
	draw_text_transformed(_cx, _numberY, _levelText, _levelScale, _levelScale, 0);

	draw_set_color(c_white);
	draw_set_alpha(_alpha);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
}

function drawPanelSparks() {
	gpu_set_blendmode(bm_add);
	for (var i = array_length(panelSparks) - 1; i >= 0; i--) {
		var _spark = panelSparks[i];
		_spark.x += _spark.hsp;
		_spark.y += _spark.vsp;
		_spark.hsp *= .9;
		_spark.vsp *= .9;
		_spark.life -= .035;

		if (_spark.life <= 0) {
			array_delete(panelSparks, i, 1);
			continue;
		}

		var _size = 1 + _spark.life * 3;
		draw_set_alpha(_spark.life);
		draw_set_color(_spark.color);
		draw_rectangle(_spark.x - _size, _spark.y - _size, _spark.x + _size, _spark.y + _size, false);
	}
	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function getStatusHudWidth() {
	return STATUS_BAR_WIDTH;
}

function getStatusLayout() {
	var _barHeight = sprite_get_height(spr_life_bar) * STATUS_BAR_WIDTH / sprite_get_width(spr_life_bar);
	var _left = STATUS_HUD_MARGIN + panelOffsetX;
	var _top = gui_height - STATUS_HUD_MARGIN - (_barHeight * 2 + STATUS_BAR_GAP);

	return {
		barHeight: _barHeight,
		medallionX: _left + LEVEL_MEDALLION_RADIUS,
		medallionY: _top - 14 - LEVEL_MEDALLION_RADIUS,
		barsX: _left,
		barsY: _top
	};
}

function drawStatusPanel() {
	var _hudWidth = getStatusHudWidth();
	panelOffsetX = lerp(panelOffsetX, isMenuOpen() ? -(_hudWidth + STATUS_HUD_MARGIN + 20) : 0, .12);

	var _healthMax = max(global.player.defaultMaxHealth, global.player.maxHealth);
	var _staminaMax = max(global.player.defaultMaxStamina, global.player.maxStamina);
	updateVitalBar(healthBarUI, global.player.health, true);
	updateVitalBar(staminaBarUI, global.player.stamina, false);
	updateLevelMedallion();

	staminaIdleTimer = global.player.stamina >= global.player.maxStamina - .5 ? staminaIdleTimer + 1 : 0;
	var _staminaAlpha = staminaIdleTimer > 120 ? .55 : 1;

	var _layout = getStatusLayout();
	if (instance_exists(obj_xp_controller)) {
		obj_xp_controller.xpX2Position = _layout.medallionX;
		obj_xp_controller.xpYMiddlePosition = _layout.medallionY;
	}

	if (panelOffsetX < -(_hudWidth + STATUS_HUD_MARGIN)) return;

	drawLevelMedallion(_layout.medallionX, _layout.medallionY);

	var _xpText = "XP " + string(global.player.xp) + "/" + string(global.xpNext);
	var _xpTextX = _layout.medallionX + LEVEL_MEDALLION_RADIUS + 14;
	draw_set_font(fnt_default_small);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	drawTextShadow(_xpTextX, _layout.medallionY, _xpText, 1, 2);
	draw_set_color(#ffd166);
	draw_text(_xpTextX, _layout.medallionY, _xpText);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);

	drawHudStatusBar(healthBarUI, spr_life_bar, _layout.barsX, _layout.barsY, STATUS_BAR_WIDTH, _healthMax);
	drawHudStatusBar(staminaBarUI, spr_energy_bar, _layout.barsX, _layout.barsY + _layout.barHeight + STATUS_BAR_GAP, STATUS_BAR_WIDTH, _staminaMax, {
		isExhausted: global.player.stamina <= 0,
		alpha: _staminaAlpha
	});

	drawPanelSparks();
}

function setHealthGuiJiggle() {
	healthStatus.jiggleTimer = 5;
}

function setStaminaGuiJiggle() {
	staminaStatus.jiggleTimer = 5;
}

#endregion

function equipedItemUi() {
	return {
		x: getMiddlePoint(0, display_get_gui_width()),
		y: display_get_gui_height() + EQUIPED_ITEM_GRID_SIZE,
		dx: 0,
		dy: 0,
		size: EQUIPED_ITEM_GRID_SIZE,
		dsize: EQUIPED_ITEM_GRID_SIZE
	}
}

//função responsável por desenhar a tool bar in game
//drawToolbarInGame
function drawEquipedItems() {
	static _y = equipedItemsY;
	_y = lerp(_y, equipedItemsY, .1);
	
	if (global.activeInventory || isMenuOpen()) { 
		equipedItemsY = gui_height + EQUIPED_ITEM_GRID_SIZE;
		return;
	}
	
	var _activeIndex = global.activeEquipedItemIndex;
	
	var _margin = 15;
	var _toolBarSize = ds_list_size(global.equipedItems);
	var _totalWidth = EQUIPED_ITEM_GRID_SIZE * _toolBarSize;
	_totalWidth += _margin * (_toolBarSize - 1);
	_totalWidth = round(_totalWidth);
	var _totalHeight = EQUIPED_ITEM_GRID_SIZE;
	var _padding = 35;
	var _initialX = gui_width / 2 - _totalWidth / 2;

	equipedItemsY = gui_height - _totalHeight - _padding;
	
	if (equipedItemsY > gui_height) return;
	
	var _x1 = round(_initialX - _padding/2);
	var _y1 = round(_y - _padding / 2);
	var _width = round(_totalWidth + _padding);
	var _height = round(_totalHeight + _padding);
	
	equipedItemsX2 = round(_initialX - _padding/2) + _totalWidth + _padding;

	var _sprite = spr_toolbar_grid;

	for (var i = 0; i < _toolBarSize; i++) {
		var _item = global.equipedItems[| i];
		var _ui = equipedItemsUI[i];
		var _active = _activeIndex == i;

		_ui.dsize = EQUIPED_ITEM_GRID_SIZE + (_active * 20);

		_ui.dx = _initialX + (i * (EQUIPED_ITEM_GRID_SIZE + _margin));
		_ui.dy = _y;

		var _lerpEffect = 0.1;

		_ui.x = lerp(_ui.x, _ui.dx, _lerpEffect);
		_ui.y = lerp(_ui.y, _ui.dy, _lerpEffect);
		_ui.size = lerp(_ui.size, _ui.dsize, _lerpEffect);

		var _offset = (EQUIPED_ITEM_GRID_SIZE - _ui.size) / 2;
		
		if (_item != BLANK_INVENTORY_SPACE) {
			var _gridX = _ui.x + _offset;
			var _gridY = _ui.y + _offset;
		
			var _itemHasDurability = itemHasDurability(_item);
		
			if (_itemHasDurability) {
				var _minusSize = 8;
				var _size = _ui.size - _minusSize;
			
				drawItemDurability(_item, _gridX + _minusSize / 2, _gridY + _minusSize / 2, _size, _size);
			}
		}

		
		draw_sprite_stretched(
			_sprite,
			_active,
			_ui.x + _offset,
			_ui.y + _offset,
			_ui.size,
			_ui.size
		);

		if (_item == BLANK_INVENTORY_SPACE) {
			var _iconSprite = spr_pistol;
			var _scale = getScale(EQUIPED_ITEM_GRID_SIZE * .5, sprite_get_width(_iconSprite));
			drawSpriteWithGpuFog(
				c_white,
				_iconSprite,
				0,
				_ui.x + EQUIPED_ITEM_GRID_SIZE / 2,
				_ui.y + EQUIPED_ITEM_GRID_SIZE / 2,
				_scale,
				_scale, 
				0,
				.2
			);
			continue;
		} 

		var _scale = getItemScaleInGrid(_item, _ui.size);
		
		var _ix = _gridX + (_ui.size / 2);
		var _iy = _gridY + (_ui.size / 2);

		draw_sprite_ext(
			_item.sprite,
			0,
			_ix,
			_iy,
			_scale,
			_scale,
			0,
			c_white,
			draw_get_alpha()
		);
		
		var _tx = _ui.x + _offset + 10;
		var _ty = _ui.y;
		
		drawTextShadow(_tx, _ty, i + 1, .6);
		draw_text(
			_tx,
			_ty,
			i + 1
		);
	}
}

function getItemScaleInGrid(_item, _size) {
	var _itemWidth = sprite_get_width(_item.sprite);
	var _itemHeight = sprite_get_height(_item.sprite);
	var _scale = getScale(_size, _itemHeight);
	
	if (_item.fitInGrid == fitInGridType.horizontaly){
		_scale = getScale(_size, _itemWidth);
	}
	
	return _scale;
}

function drawQuickUse() {
	static _y = equipedItemsY;
	_y = lerp(_y, equipedItemsY, .08);
	var _quickUseSize = ds_list_size(global.quickUse);
	var _sprite = spr_bar;
	
	var _gridMargin = 20;
	var _margin = 60;
	var _totalWidth = QUICK_USE_SLOT_SIZE * _quickUseSize;
	_totalWidth += _gridMargin * (_quickUseSize - 1);
	_totalWidth = round(_totalWidth);
	var _padding = 35;
	
	var _height = QUICK_USE_SLOT_SIZE * 1.5;
	var _initialX = equipedItemsX2 + _margin;

	if (equipedItemsY > gui_height) return;
	
	var tx = round(_initialX - _padding / 2), ty = round(_y - _padding / 2), tw = round(_totalWidth + _padding), th = round(_height + _padding)
	
	//drawSpriteShadowStretched(
	//	tx,
	//	ty,
	//	_sprite,
	//	0,
	//	0,
	//	tw,
	//	th,
	//);
	
	draw_sprite_stretched_ext(
		_sprite,
		0,
		tx,
		ty,
		tw,
		th,
		c_white,
		1
	);

	var _textX = getMiddlePoint(tx, tx + tw);
	
	draw_set_font(fnt_default_small);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	drawTextShadow(_textX, ty + 15, "Uso Rápido [E]", draw_get_alpha());
	draw_text(_textX, ty + 15, "Uso Rápido [E]");
	draw_set_valign(fa_top);
	draw_set_halign(fa_left)
	draw_set_font(fnt_default);

    if (_quickUseSize <= 0) return;
	
    var _centerX = _initialX + _totalWidth * 0.5;
    var _centerY = _y + _height * 0.5;

    var _equippedIndex = global.activeQuickUseIndex;
    var _equippedItem = global.quickUse[| _equippedIndex];

    var _leftIndex = (_equippedIndex - 1 + _quickUseSize) mod _quickUseSize;
    var _rightIndex = (_equippedIndex + 1) mod _quickUseSize;

    var _leftItem = global.quickUse[| _leftIndex];
    var _rightItem = global.quickUse[| _rightIndex];
	
	var _gridY = _y + _height - QUICK_USE_SLOT_SIZE;
	var _gridX = _initialX + QUICK_USE_SLOT_SIZE;
	
	for (var i = 0; i < _quickUseSize; i++) {
		var _item = global.quickUse[| i];
		var _active = global.activeQuickUseIndex == i;
		var _x = _initialX + (i * (QUICK_USE_SLOT_SIZE + _gridMargin));
		drawQuickUseGrid(_x, _gridY, _item, _active, QUICK_USE_SLOT_SIZE);
	}
}

function drawQuickUseGrid(_x, _y, _item, _active = false, _slotSize = QUICK_USE_SLOT_SIZE) {
	var _gridSprite = spr_bar_white;
	_y -= _active * 5;
	
	var _color = _active ? c_white : c_gray;
	
	draw_sprite_stretched_ext(_gridSprite, _active, _x, _y, _slotSize, _slotSize, _color, draw_get_alpha());
	
	if (_item == BLANK_INVENTORY_SPACE) return;
	
	var _sprite = _item.sprite;
	var _scale = getScale(_slotSize * .8, sprite_get_width(_sprite));
	draw_sprite_ext(_sprite, 0, _x + _slotSize / 2, _y + _slotSize / 2, _scale, _scale, 0, c_white, draw_get_alpha());
	
	if (_item.quantity <= 1) return;
	
	draw_set_font(fnt_default_small);
	var _text = string(_item.quantity) + "x";
	var _textWidth = string_width(_text);
	var _textHeight = string_height(_text);
	var _tx = _x + _slotSize - _textWidth, _ty = _y + _slotSize - _textHeight;
	drawTextShadow(_tx, _ty, _text, draw_get_alpha());
	draw_text(_tx, _ty, _text);
	draw_set_font(fnt_default);
}
