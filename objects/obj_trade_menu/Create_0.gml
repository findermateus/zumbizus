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
visibleRows = 9;
rowHeight = 42;

isClosing = false;

headerAnimYOffset = -50;
headerAnimAlpha = 0;

listBgAnimYOffset = -30;
listBgAnimAlpha = 0;

itemAnimYOffset = array_create(visibleRows, -20);
itemAnimAlpha = array_create(visibleRows, 0);

itemHoverOffset = array_create(visibleRows, 0);
itemShakeAmount = array_create(visibleRows, 0);

function performClose() {
	closeMenu();
	unBlockPlayerMenus();

	if (instance_exists(merchant)) {
		merchant.isInteracting = false;
	}

	obj_player.currentState = playerIddleState;
	instance_destroy(id);
}

function closeTrade() {
	isClosing = true; 
}

function handleTradeScroll() {
	var _itemCount = array_length(tradeItems);
	var _maxScroll = max(0, _itemCount - visibleRows);

	var _lastScrollIndex = scrollIndex;

	if (mouse_wheel_up()) {
		scrollIndex--;
	}

	if (mouse_wheel_down()) {
		scrollIndex++;
	}

	scrollIndex = clamp(scrollIndex, 0, _maxScroll);
	
	if (_lastScrollIndex != scrollIndex) {
		playHoverSound();
	}
}

function drawTradingMenu() {
	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	var _globalAlpha = draw_get_alpha();
	
	var _hAlpha = _globalAlpha * headerAnimAlpha;
	var _bgAlpha = _globalAlpha * listBgAnimAlpha;
	
	var _menuW = 800;
	var _menuH = _guiHeight * .8;
	
	var _menuX = (_guiWidth / 2) - (_menuW / 2);
	var _menuY = (_guiHeight / 2) - (_menuH / 2);

	var _padding = 20;
	var _gap = 20;

	var _menuSprite = spr_inventory_box;

	draw_set_font(fnt_gui_title);

	var _titleText = "Comerciante - " + target.name;
	var _moneyText = "$" + string(global.player.money);
	
	var _moneyW = string_width(_moneyText);
	var _titleMaxW = _menuW - (_padding * 2) - _moneyW - _gap;
	var _titleW = string_width(_titleText);
	var _titleScale = 1;

	if (_titleW > _titleMaxW) {
		_titleScale = _titleMaxW / _titleW;
	}

	var _topHeight = string_height(_titleText) * _titleScale;
	var _tabHeight = string_height("Comprar");

	var _headerH = _padding + _topHeight + 25 + _tabHeight + _padding;
	var _panelGap = 15; 
	
	var _listBgY = _menuY + _headerH + _panelGap;
	var _listBgH = _menuH - _headerH - _panelGap;

	var _animHeaderY = _menuY + headerAnimYOffset;

	draw_set_alpha(_hAlpha);
	draw_sprite_stretched(_menuSprite, 0, _menuX, _animHeaderY, _menuW, _headerH);

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	var _topY = _animHeaderY + _padding;
	var _titleX = _menuX + _padding;
	var _moneyX = _menuX + _menuW - _padding;

	drawTextShadow(_titleX + 3, _topY + 3, _titleText, _hAlpha, 3, _titleScale);
	draw_text_transformed(_titleX, _topY, _titleText, _titleScale, _titleScale, 0);

	draw_set_halign(fa_right);
	drawTextShadow(_moneyX, _topY, _moneyText, _hAlpha);
	draw_set_color($1F8E00);
	draw_text(_moneyX, _topY, _moneyText);

	draw_set_halign(fa_left);
	draw_set_color(c_white);

	var _tabsY = _topY + _topHeight + 25;

	drawTextShadow(_menuX + _padding, _tabsY, "Comprar", _hAlpha);
	draw_set_color(c_white);
	draw_text(_menuX + _padding, _tabsY, "Comprar");

	var _animListBgY = _listBgY + listBgAnimYOffset;
	
	draw_set_alpha(_bgAlpha);
	draw_sprite_stretched(_menuSprite, 0, _menuX, _animListBgY, _menuW, _listBgH);

	draw_set_font(fnt_gui_default);

	var _listX = _menuX + _padding;
	var _listY = _animListBgY + _padding + 7; 

	var _start = scrollIndex;
	var _end = min(scrollIndex + visibleRows, array_length(tradeItems));
	
	var _rowWidth = _menuW - (_padding * 2);
	var _paddingX = 15;
	var _paddingY = 12; 
	var _rowMargin = 5; 
	var _barHeight = rowHeight + (_paddingY * 2);
	var _stepHeight = _barHeight + _rowMargin;

	for (var i = _start; i < _end; i++) {
		var _drawIndex = i - scrollIndex;
		
		var _iAlpha = _globalAlpha * itemAnimAlpha[_drawIndex];
		var _iYOffset = itemAnimYOffset[_drawIndex];
		
		if (_iAlpha <= 0) continue;

		var _rowY = _listY + (_drawIndex * _stepHeight) + _iYOffset;
		var _centerY = _rowY + (_barHeight / 2);
		
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

		var _isHovering = mouseIsOnRectangle(_initialX, _rowY, _initialX + _rowWidth, _rowY + _barHeight);
		var _canAfford = (global.player.money >= _totalPrice);
		var _priceColor = _canAfford ? $1F8E00 : c_red;
		
		var _targetHover = _isHovering ? 10 : 0;
		itemHoverOffset[_drawIndex] = lerp(itemHoverOffset[_drawIndex], _targetHover, 0.2);
		
		var _shakeX = 0;
		if (itemShakeAmount[_drawIndex] > 0.5) {
			_shakeX = random_range(-itemShakeAmount[_drawIndex], itemShakeAmount[_drawIndex]);
		}
		
		var _finalX = _initialX + itemHoverOffset[_drawIndex] + _shakeX;

		draw_set_alpha(_iAlpha);
		
		var _bgColor = _isHovering ? c_white : c_ltgray; 
		draw_sprite_stretched_ext(spr_bar_white, 0, _finalX, _rowY, _rowWidth, _barHeight, _bgColor, _iAlpha);

		draw_set_valign(fa_middle);

		var _iconSize = 48; 
		var _scale = getScale(_iconSize, sprite_get_height(_icon));
		var _iconX = _finalX + _paddingX + (_iconSize / 2);
		
		drawSpriteShadow(_iconX, _centerY, _icon, 0, 0, _scale, _scale);
		draw_sprite_ext(_icon, 0, _iconX, _centerY, _scale, _scale, 0, c_white, _iAlpha);

		var _nameX = _finalX + _paddingX + _iconSize + 10;
		draw_set_halign(fa_left);
		drawTextShadow(_nameX, _centerY, _name, _iAlpha);
		draw_set_color(c_white);
		var _nameWidth = string_width(_name);
		draw_text(_nameX, _centerY, _name);

		var _quantityX = _nameX + _nameWidth + 10;
		drawTextShadow(_quantityX, _centerY, _quantityText, _iAlpha);
		draw_set_color(c_white);
		draw_text(_quantityX, _centerY, _quantityText);
		
		var _priceX = _finalX + _rowWidth - _paddingX;
		draw_set_halign(fa_right);
		drawTextShadow(_priceX, _centerY, _priceText, _iAlpha);
		draw_set_color(_priceColor);
		draw_text(_priceX, _centerY, _priceText);
		
		draw_set_halign(fa_left);
		
		var _hasClicked = mouse_check_button_released(mb_left);
		
		if (!_isHovering || !_hasClicked) continue;
		playClickSound();
		
		var _result = buyTradeItem(_tradeItem);
		
		if (_result == TradeTransactionResult.Success) {
			audio_play_sound(snd_shells, 0, false);
			createIndicatorModal(_itemData, _tradeItem.quantity);
			
			itemShakeAmount[_drawIndex] = 6; 
			continue;
		}
		
		if (_result == TradeTransactionResult.NotEnoughMoney) {
			playFailSound();
			itemShakeAmount[_drawIndex] = 15; 
			continue;
		}
		
		if (_result == TradeTransactionResult.NotEnoughInventory) {
			playFailSound();
			itemShakeAmount[_drawIndex] = 10; 
			createGUINotifyIndicator("Inventário cheio!", getMiddlePoint(_initialX, _initialX + _rowWidth), _rowY);
		}
	}

	var _itemCount = array_length(tradeItems);
	var _canScrollUp = (scrollIndex > 0);
	var _canScrollDown = ((scrollIndex + visibleRows) < _itemCount);

	if (_canScrollUp || _canScrollDown) {
		var _arrowSize = 20;
		var _arrowScale = getScale(_arrowSize, sprite_get_height(spr_arrow_indicator));
		var _arrowX = getMiddlePoint(_menuX, _menuX + _menuW);
		
		var _bobbing = sin(current_time / 150) * 3;

		if (_canScrollUp) {
			var _upY = _animListBgY + 12 + _bobbing;
			drawSpriteShadow(_arrowX, _upY, spr_arrow_indicator, 0, 0, _arrowScale, _arrowScale);
			draw_sprite_ext(spr_arrow_indicator, 0, _arrowX, _upY, _arrowScale, _arrowScale, 0, c_white, _bgAlpha);
		}

		if (_canScrollDown) {
			var _downY = _animListBgY + _listBgH - 12 - _bobbing;
			drawSpriteShadow(_arrowX, _downY, spr_arrow_indicator, 0, 0, _arrowScale, -_arrowScale);
			draw_sprite_ext(spr_arrow_indicator, 0, _arrowX, _downY, _arrowScale, -_arrowScale, 0, c_white, _bgAlpha);
		}
	}

	draw_set_alpha(_globalAlpha);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_font(fnt_gui_default);
}