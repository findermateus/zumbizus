function buildTradeItem(_tradeItem) {
	var _itemData = global.items[_tradeItem.itemType][_tradeItem.itemId];
	var _item = constructItem(_tradeItem.itemType, _itemData);

	_item.quantity = _tradeItem.quantity;

	return _item;
}

function buyTradeItem(_tradeItem) {
	var _totalPrice = _tradeItem.price * _tradeItem.quantity;

	if (!playerHasMoney(_totalPrice)) {
		show_message("Dinheiro insuficiente");
		return false;
	}

	var _item = buildTradeItem(_tradeItem);

	var _added = addAbsoluteItemToGrid(global.inventory, _item);

	if (_added != true) {
		show_message("Inventário cheio");
		return false;
	}

	removePlayerMoney(_totalPrice);

	show_message("Compra realizada");

	return true;
}