function buildTradeItem(_tradeItem) {
	var _itemData = global.items[_tradeItem.itemType][_tradeItem.itemId];
	var _item = constructItem(_tradeItem.itemType, _itemData);

	_item.quantity = _tradeItem.quantity;

	return _item;
}

enum TradeTransactionResult {
	Success,
	NotEnoughMoney,
	NotEnoughInventory
}

function buyTradeItem(_tradeItem) {
	var _totalPrice = _tradeItem.price * _tradeItem.quantity;

	if (!playerHasMoney(_totalPrice)) {
		return TradeTransactionResult.NotEnoughMoney;
	}

	var _item = buildTradeItem(_tradeItem);

	var _added = addAbsoluteItemToGrid(global.inventory, _item);

	if (_added != true) {
		return TradeTransactionResult.NotEnoughInventory;
	}

	removePlayerMoney(_totalPrice);

	return TradeTransactionResult.Success;
}