#macro SELL_PRICE_MULTIPLIER 0.5

enum TradeResult {
	Success,
	NotEnoughMoney,
	NotEnoughInventory,
	InvalidItem,
	InvalidQuantity
}

function buildTradeItem(_tradeItem) {
	var _itemData = global.items[_tradeItem.type][_tradeItem.itemId];
	var _item = constructItem(_tradeItem.type, _itemData);

	_item.quantity = _tradeItem.quantity;

	return _item;
}

function buyTradeItem(_tradeItem) {
	var _totalPrice = _tradeItem.price * _tradeItem.quantity;

	if (!playerHasMoney(_totalPrice)) {
		return TradeResult.NotEnoughMoney;
	}

	var _item = buildTradeItem(_tradeItem);

	var _added = addAbsoluteItemToGrid(global.inventory, _item);

	if (_added != true) {
		return TradeResult.NotEnoughInventory;
	}

	removePlayerMoney(_totalPrice);

	return TradeResult.Success;
}

function getSellItemValue(_item, _quantity = 1) {
	if (!is_struct(_item)) return 0;
	if (!variable_struct_exists(_item, "value")) return 0;

	return floor(_item.value * _quantity * SELL_PRICE_MULTIPLIER);
}

function sellInventoryItem(_inventory, _x, _y) {
	var _item = _inventory[# _x, _y];

	if (_item == BLANK_INVENTORY_SPACE || !is_struct(_item)) {
		
		return TradeResult.InvalidItem;
	}

	var _quantity = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;

	if (_quantity <= 0) {
		
		return TradeResult.InvalidQuantity;
	}

	var _sellValue = getSellItemValue(_item, _quantity);
	addPlayerMoney(_sellValue);
	
	_inventory[# _x, _y] = BLANK_INVENTORY_SPACE;

	return TradeResult.Success;
}