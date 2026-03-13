displayWidth = display_get_width();
displayHeight = display_get_height();
destinyAlpha = 0;
currentAlpha = 0;
alphaConverter = .1;

lateralMenuGUIInfo = {
	alpha: 0,
	destinyAlpha: 1,
	selectedOption: -1,
	shakeEffect: 0
}

function setUpResourceViewer(_display = true){
	destinyAlpha = _display ? 1 : 0
}

function drawResource(_x, _y, _icon, _iconSize, _color, _value, _maxValue, _title = ""){
	drawIcon(_icon, _x, _y, _iconSize);
	var _barSize = _iconSize * .3;
	var _barWidth = _iconSize * 3;
	var _rectangleY = _y + _iconSize - _barSize;
	var _margin = 15;
	var _rectangleX = _x + _iconSize + _margin;
	drawTitle(_rectangleX, _y, _title);
	var _currentAlpha = draw_get_alpha();
	var _ratio = _value / _maxValue;
	drawResourceBar(_barSize, _barWidth, _rectangleX, _rectangleY, _color, _ratio, _value, _maxValue, currentAlpha, 9, currentAlpha * .6);
	return _barWidth + _iconSize + _margin;
}

function drawIcon(_icon, _x, _y, _iconSize){
	var _xScale = getScale(_iconSize, sprite_get_width(_icon));
	var _yScale = getScale(_iconSize, sprite_get_height(_icon));
	drawSpriteShadow(_x, _y, _icon, 0, 0, _xScale, _yScale);
	draw_sprite_stretched(_icon, 0, _x, _y, _iconSize, _iconSize);
}

function drawTitle(_x, _y, _text){
	drawTextShadow(_x, _y, _text, currentAlpha)
	draw_text(_x, _y, _text);
}

function drawLateralMenu() {
	handleEveryStepLateralMenuGUI();
    var _menu = [
        new IconMenu("Construção", "T", spr_builder_icon, menu.builder),
		new IconMenu("Construção", "M", spr_resident_icon, menu.resident),
    ];
	var _guiHeight = display_get_gui_height();
	var _guiWidth = display_get_gui_width();
    var _iconSize = 128;
	var _optionSpacing = _iconSize * 1.5;
	var _startX = _guiWidth - _iconSize * 1.2;
    var _startY = _guiHeight/2 - _iconSize;
    for (var i = 0; i < array_length(_menu); i++) {
        var _option = _menu[i];
        var _x = _startX;
        var _y = _startY + i * _optionSpacing;
        drawLateralOptionMenu(_option, _x, _y, _iconSize);
    }
}

function handleEveryStepLateralMenuGUI(){
	lateralMenuGUIInfo.shakeEffect = lerp(lateralMenuGUIInfo.shakeEffect, 0, .2);
	
	var _alphaEffect = lateralMenuGUIInfo.destinyAlpha == 0 ? .1 : .2;
	
	lateralMenuGUIInfo.alpha = lerp(lateralMenuGUIInfo.alpha, !global.activeMenu && !global.activeInventory, _alphaEffect);
}

function drawLateralOptionMenu(_option, _x, _y, _size) {
	var _iconScale = getScale(_size, sprite_get_width(_option.icon));
    var _alpha = lateralMenuGUIInfo.alpha;
	if (_option.id == lateralMenuGUIInfo.selectedOption && lateralMenuGUIInfo.shakeEffect > .1) {
		_alpha = .6
		draw_sprite_stretched(spr_hover_indicator, 0, _x, _y, _size, _size);
	}
	draw_set_alpha(_alpha);
	drawSpriteShadow(_x, _y, _option.icon, 0, 0, _iconScale + .1, _iconScale + .1);
	draw_sprite_ext(_option.icon, 0, _x, _y, _iconScale, _iconScale, 0, c_white, _alpha);
    var _label = "[" + string(_option.key) + "] ";
	var _textHeight = string_height(_label);
    var _textY = _y + _size - _textHeight;
	var _textX = _x;
    draw_set_color(c_white);
	draw_set_valign(fa_top);
	draw_set_halign(fa_center);
	drawTextShadow(_textX, _textY, _label, _alpha);
	draw_text(_textX, _textY, _label);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
}

function createNpcs() {
	var _npcListSize = array_length(global.npcList);
	if (!_npcListSize) return;
	
	var _existingNpcs = [];
	
	with (obj_npc_resident) {
		array_push(_existingNpcs, name);
	}
	
	for (var i = 0; i < _npcListSize; i ++) {
		var _npcData = global.npcList[i];
		
		if (!is_struct(_npcData)) continue;
		
		if(verifyIfNpcIsAlreadyCreated(_npcData.name, _existingNpcs)) continue;
		
		var _npc = instance_create_layer(irandom_range(64, room_width - 64), irandom_range(64, room_height - 64), "Instances", obj_npc_resident, {
			name: _npcData.name,
			hairOption: _npcData.hair.hairId,
			hairColor: _npcData.hair.color,
			skinColor: getHexFromString(_npcData.skinColor),
			genderId: _npcData.gender,
			workerId: _npcData.id
		});
	}
}

function verifyIfNpcIsAlreadyCreated(_name, _npcList) {
	for (var i = 0; i < array_length(_npcList); i ++) {
		if (_npcList[i] == _name) return true;
	}
	return false;
}