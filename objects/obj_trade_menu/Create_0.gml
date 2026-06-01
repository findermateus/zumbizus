openMenu(Menus.Trade);
blockPlayerMenus();

obj_player.currentState = playerTradeState;

if (!instance_exists(target)) {
	instance_destroy(id);
}

merchant = target;

if (!instance_exists(merchant)) {
	instance_destroy(id);
	return;
}

tradeItems = merchant.tradeItems;
selectedIndex = -1;
scrollIndex = 0;
visibleRows = 6;
rowHeight = 42;

function closeTrade() {
	closeMenu();
	unBlockPlayerMenus();

	if (instance_exists(merchant)) {
		merchant.isInteracting = false;
	}

	obj_player.currentState = playerIddleState;

	instance_destroy(id);
}

function handleTradeScroll() {
	var _itemCount = array_length(tradeItems);
	var _maxScroll = max(0, _itemCount - visibleRows);

	if (mouse_wheel_up()) {
		scrollIndex--;
	}

	if (mouse_wheel_down()) {
		scrollIndex++;
	}

	scrollIndex = clamp(scrollIndex, 0, _maxScroll);
}

function drawTradingMenu() {
	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	var _alpha = draw_get_alpha();
	
	var _menuW = 800;
	var _menuH = _guiHeight * .8;
	
	var _menuX = (_guiWidth / 2) - (_menuW / 2);
	var _menuY = (_guiHeight / 2) - (_menuH / 2);

	var _padding = 20;
	var _gap = 20;

	var _menuSprite = spr_inventory_box;
	
	draw_sprite_stretched(_menuSprite, 0, _menuX, _menuY, _menuW, _menuH);

	// ==========================================
	// TOPO
	// ==========================================
	draw_set_font(fnt_gui_title);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	var _topY = _menuY + _padding;
	var _titleX = _menuX + _padding;

	var _titleText = "Comerciante - " + target.name;
	var _moneyText = "$" + string(global.player.money);

	var _moneyX = _menuX + _menuW - _padding;
	var _moneyW = string_width(_moneyText);

	var _titleMaxW = _menuW - (_padding * 2) - _moneyW - _gap;
	var _titleW = string_width(_titleText);
	var _titleScale = 1;

	if (_titleW > _titleMaxW) {
		_titleScale = _titleMaxW / _titleW;
	}

	drawTextShadow(_titleX + 3, _topY + 3, _titleText, _alpha, 3, _titleScale);
	draw_text_transformed(_titleX, _topY, _titleText, _titleScale, _titleScale, 0);

	draw_set_halign(fa_right);
	drawTextShadow(_moneyX, _topY, _moneyText, _alpha);
	draw_set_color($1F8E00); // Verde destaque
	draw_text(_moneyX, _topY, _moneyText);

	draw_set_halign(fa_left);
	draw_set_color(c_white);

	// ==========================================
	// TABS / TÍTULO DA ABA
	// ==========================================
	var _topHeight = string_height(_titleText) * _titleScale;
	var _tabsY = _topY + _topHeight + 25;

	draw_set_font(fnt_gui_title);
	drawTextShadow(_menuX + _padding, _tabsY, "Comprar", _alpha);
	draw_set_color(c_white);
	draw_text(_menuX + _padding, _tabsY, "Comprar");

	// ==========================================
	// LISTA (Tabela Dinâmica)
	// ==========================================
	draw_set_font(fnt_gui_default);

	var _listX = _menuX + _padding;
	var _listY = _tabsY + 75;


	var _start = scrollIndex;
	var _end = min(scrollIndex + visibleRows, array_length(tradeItems));
	
	for (var i = _start; i < _end; i++) {
		var _drawIndex = i - scrollIndex;
		var _rowY = _listY + (_drawIndex * rowHeight);
		var _centerY = _rowY + (rowHeight / 2);
		var _initialX = _listX;
		var _tradeItem = tradeItems[i];
		var _itemData = global.items[_tradeItem.itemType][_tradeItem.itemId];

		var _name = _itemData.name;
		var _quantity = _tradeItem.quantity;
		var _price = _tradeItem.price;
		var _totalPrice = _price * _quantity;
		var _icon = _itemData.sprite;

		var _quantityText = "x" + string(_quantity);
		var _priceText = "$" + string(_totalPrice);

		draw_sprite_stretched(spr_bar_white, 0, _initialX, _rowY, _menuW - _padding * 2, rowHeight);

		draw_set_valign(fa_middle);

		var _iconSize = 64;
		var _scale = getScale(_iconSize, sprite_get_height(_icon));
		drawSpriteShadow( _initialX + _iconSize / 2, _centerY, _icon, 0, 0, _scale, _scale);
		draw_sprite_ext(_icon, 0, _initialX + _iconSize / 2, _centerY, _scale, _scale, 0, c_white, _alpha);

		var _nameX = _initialX + _iconSize;

		draw_set_halign(fa_left);
		drawTextShadow(_nameX, _centerY, _name, _alpha);
		draw_set_color(c_white);
		var _nameWidth = string_width(_name);
		draw_text(_nameX, _centerY, _name);


		var _quantityX = _nameX + _nameWidth + 10;
		drawTextShadow(_quantityX, _centerY, _quantityText, _alpha);
		draw_set_color(c_white);
		var _quantityWidth = string_width(_quantityText);
		draw_text(_quantityX, _centerY, _quantityText);
		
		var _priceX = _quantityX + _quantityWidth + 10;
		drawTextShadow(_priceX, _centerY, _priceText, _alpha);
		draw_set_color($1F8E00);
		draw_text(_priceX, _centerY, _priceText);
	}

	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
}