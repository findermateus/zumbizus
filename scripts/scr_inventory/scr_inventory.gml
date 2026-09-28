function openInventory(_sound = snd_open_inventory) {
	if (instance_exists(obj_base_controller) && global.currentBaseMenuOption != -1) {
		deactivateLateralMenuOption(global.currentBaseMenuOption);
	}
	obj_camera.target = obj_player;
	obj_camera.setInventoryZoom();
	audio_play_sound(_sound, 0, false);
	global.activeInventory = true;
	openMenu(Menus.Inventory, closeInventory);
}

function openInventoryWithContainer(_target, _sound, _containerData){
	obj_camera.target = _target;
	obj_camera.currentState = obj_camera.followTarget;
	obj_camera.currentState();
	openInventory(_sound)
	obj_inventory.secundaryInventory = _containerData;
}

function closeInventory(){
	if (!global.activeInventory) return;
	if (isCurrentMenu(Menus.Inventory)) closeMenu();
	
	obj_camera.setDefaultValues();
	obj_camera.target = obj_player;
	
	with (obj_inventory) {
		currentState = hide;
	}
}

function drawItemDetails(_x, _y, _alpha, _itemId, _itemType) {
	
	var _configuration = getItemConfiguration(_itemId, _itemType);
	
	var _auxAlpha = draw_get_alpha();

	var _name = _configuration.name;
	var _namePadding = 10;
	
	draw_set_font(fnt_gui_title);
	
	var _nameHeight = string_height(_name);
	var _nameWidth = string_width(_name);
	
	var _nameBoxWidth = _nameWidth + _namePadding * 2;
	var _nameBoxHeight = _nameHeight + _namePadding * 2;
	
	draw_set_alpha(_alpha);
	
	draw_sprite_stretched_ext(
		spr_item_collected_indicator,
		1,
		_x,
		_y,
		_nameBoxWidth,
		_nameBoxHeight,
		c_dkgray,
		_alpha
	);
	
	var _nameX = _x + _nameBoxWidth / 2;
	var _nameY = _y + _nameBoxHeight / 2;
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	drawTextShadow(
		_nameX,
		_nameY,
		_name,
		_alpha
	);
	draw_text(_nameX, _nameY, _name);
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	_y += _nameBoxHeight;
	
	draw_set_font(fnt_gui_long_text);
	
	var _description = _configuration.description;
	
	var _descriptionPadding = 10;
	var _descriptionMaxWidth = min(350, display_get_gui_width() - _x - _descriptionPadding * 2);
	var _descriptionWidth = string_width_ext(_description, -1, _descriptionMaxWidth);
	var _descriptionHeight = string_height_ext(_description, -1, _descriptionMaxWidth);
	
	var _descriptionWidthBox = _descriptionWidth + _descriptionPadding * 2;
	var _descriptionHeightBox = max(64, _descriptionHeight + _descriptionPadding * 2);
	
	draw_sprite_stretched(
		spr_item_collected_indicator,
		0,
		_x,
		_y,
		_descriptionWidthBox,
		_descriptionHeightBox
	);
	
	draw_set_alpha(_alpha);
	
	var _descriptionX = _x + _descriptionPadding;
	var _descriptionY = _y + _descriptionHeightBox / 2;
	
	draw_set_valign(fa_middle);

	drawTextExtShadow(
		_descriptionX,
		_descriptionY,
		_description,
		-1,
		_descriptionMaxWidth,
		_alpha
	);

	draw_text_ext(
		_descriptionX,
		_descriptionY,
		_description,
		-1,
		_descriptionMaxWidth
	);

	draw_set_valign(fa_top);
	
	draw_set_alpha(_auxAlpha);
	draw_set_font(fnt_gui_default);
}