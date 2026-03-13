inventoryItem = {
	j: global.blankInventorySpace,
	i: global.blankInventorySpace
};
option = {
	text: "",
	x1: 0,
	xScale: 0,
	y1: 0,
	yScale: 0,
	comesFromInventory: true,
	itemId: noone,
	itemType: noone
};

disabled = false;
currentXScale = 0;
currentYScale = 0;
currentTextScale = 0;
item = {};
xMouseGui = 0;
yMouseGui = 0;
largestText = option.text;
textColor = c_white;
isCurrentOptionMenu = false;

function drawOption(){
	draw_set_valign(fa_middle);
	draw_set_halign(fa_center);
	var _sprite = spr_menu_option;
	var _index = 0;
	if (isCurrentOptionMenu) _index = 1;
	var _alpha = disabled ? .6 : 1;
	drawSpriteShadow(option.x1, option.y1, _sprite, _index, 0, currentXScale, currentYScale);
	draw_sprite_ext(_sprite, _index, option.x1, option.y1, currentXScale, currentYScale, 0, c_white, _alpha);
	draw_set_halign(fa_center);
	var _optionHeight = sprite_get_height(_sprite);
	var _optionWidth = sprite_get_width(_sprite);
	var _xPosition = option.x1 + (_optionWidth * currentXScale)/2;
	var yPosition = option.y1 + (_optionHeight * currentYScale)/2;
	draw_text_transformed_color(_xPosition, yPosition, option.text, currentTextScale, currentTextScale, 0, textColor, textColor, textColor, textColor, _alpha);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function activeOption(){
	isCurrentOptionMenu = false;
	verifyConditionsToExecute();
	textColor = c_white;
}

function verifyConditionsToExecute(){
	if (disabled){
		if (global.currentOptionMenu == id) global.currentOptionMenu = noone;
		return;
	}
	var _sprite = spr_menu_option;
	var _optionHeight = sprite_get_height(_sprite) * currentYScale;
	var _optionWidth = sprite_get_width(_sprite) * currentXScale;
	if((xMouseGui >= option.x1 && xMouseGui <= option.x1 + _optionWidth) && (yMouseGui >= option.y1 && yMouseGui <= option.y1 + _optionHeight + 4)){
		if (global.currentOptionMenu != id) {
			global.currentOptionMenu = id;
			audio_play_sound(snd_hover, 0, false);
		}
		isCurrentOptionMenu = true;
		if(mouse_check_button_released(mb_left)){
			execute();
		}
		return;
	}
	if(global.currentOptionMenu == id) global.currentOptionMenu = noone;
}

function execute(){
	audio_play_sound(snd_click, 0, false);
	with(obj_player) {
		executeItemMethod(other.item, other.option.key, true, global.activeInventoryAction, global.currentItemPlayingTheAction.j, global.currentItemPlayingTheAction.i)
	}
	cleanScreen();
	disabled = true;
}

function cleanScreen(){
	cleanMenuOptions();
	if(option.comesFromInventory && instance_exists(obj_inventory)){
		with obj_inventory{
			currentState = nothing;
		}
	}
}