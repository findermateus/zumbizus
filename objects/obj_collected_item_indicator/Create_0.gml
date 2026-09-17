guiHeight = display_get_gui_height();
guiWidth = display_get_gui_width();
fatherIndicator = noone;
xPosition = guiWidth + 100;
yPosition = guiHeight;
destinyXPosition = guiWidth * .98;
destinyYPosition = yPosition;
totalHeight = 0;
shouldFadeOut = false;

box = {
	width: 0,
	height: 0,
	textContent: "Item",
	quantity: -1,
	sprite: spr_item_default,
	itemId: -1,
	collecting: true,
	isQuestReward: false
};

alarm[0] = 60 * 2;
//fatherIndicator = noone;
function defineVerticalPosition(){
	static lastIndicator = noone;
	fatherIndicator = lastIndicator;
	lastIndicator = self;
	totalHeight = string_height(box.textContent);
	if (fatherIndicator == noone){
		yPosition = guiHeight * .7;
		destinyYPosition = yPosition;
		return;
	}
	var _marginBetweenItems = 10;
	yPosition = fatherIndicator.yPosition;
	destinyYPosition = yPosition;
	fatherIndicator.updatePosition(fatherIndicator.totalHeight + _marginBetweenItems + 24);
}

defineVerticalPosition();

function updatePosition(_height){
	destinyYPosition -= _height;
	if (fatherIndicator == noone) return;
	fatherIndicator.updatePosition(_height);
}

function drawItemIndicator(){
	xPosition = lerp(xPosition, destinyXPosition, .1);
	yPosition = lerp(yPosition, destinyYPosition, .1);

	draw_set_font(fnt_gui_default);

	var _quantityText = box.quantity != -1 ? "(x" + string(box.quantity) + ") " : "";
	var _textContent = _quantityText + box.textContent;
	var _textWidth = string_width(_textContent);
	var _textHeight = string_height(_textContent);
	var _border = 12;

	var _scale = 1;
	var _spriteWidth = sprite_get_width(box.sprite);
	var _spriteHeight = sprite_get_height(box.sprite);
	var _targetHeight = _textHeight;
	_scale = _targetHeight / _spriteHeight;
	_spriteWidth *= _scale;
	
	var _rectWidth = _spriteWidth + _textWidth + _border * 2;
	var _rectHeight = _textHeight + _border * 2;
	var _xPosition = xPosition - _rectWidth;

	var _index = 0;
	var _boxColor = c_white;
	var _spriteColor = c_white;
	var _textColor = c_white;
	

	if (box.isQuestReward) {
		_index = 1; 
		_boxColor = #1e8449;
		_textColor = c_white;
	} else if (box.collecting) {
		_index = 0;
		_boxColor = c_white;
	} else {
		_index = 1;
		_boxColor = #660707;
	}

	draw_set_alpha(image_alpha);
	
	draw_sprite_stretched_ext(spr_item_collected_indicator, _index, _xPosition - _border, yPosition - _border, _rectWidth, _rectHeight, _boxColor, 1);

	if (box.sprite != noone) {
		draw_sprite_ext(
			box.sprite, 0,
			_xPosition + _spriteWidth/2,
			yPosition + _targetHeight/2, 
			_scale, _scale, 0, _spriteColor, 1
		);
	}

	draw_set_color(_textColor);

	var _textScribble = "[fa_left, fa_top]" + _textContent;

	drawTextShadowScribble(_xPosition + _spriteWidth + _border / 2, yPosition, _textScribble, image_alpha);
	draw_text_scribble(_xPosition + _spriteWidth + _border / 2, yPosition, _textScribble);
	
	draw_set_color(c_white);

	draw_set_alpha(1);
	fadeOut();
}

function fadeOut(){
	if (shouldFadeOut){
		image_alpha -= .1;
	}
	if (image_alpha <= 0){
		instance_destroy(id);
	}
}