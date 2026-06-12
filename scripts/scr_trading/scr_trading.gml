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
	var _totalPrice = getBuyItemValue(_tradeItem.itemId, _tradeItem.type, _tradeItem.quantity);

	if (!playerHasMoney(_totalPrice)) {
		return TradeResult.NotEnoughMoney;
	}

	var _item = buildTradeItem(_tradeItem);

	var _added = addAbsoluteItemToGrid(global.inventory, _item);

	if (_added != true) {
		return TradeResult.NotEnoughInventory;
	}

	removePlayerMoney(_totalPrice);

	obj_quest_manager.notifyEvent(QuestEvent.ItemBought, {
		itemId: _tradeItem.itemId,
		itemType: _tradeItem.type,
		quantity: _tradeItem.quantity
	});

	return TradeResult.Success;
}

function getBuyItemValue(_id, _type, _quantity = 1) {
	if (!is_array(global.items)) return 0;

	var _itemData = global.items[_type][_id];

	if (!is_struct(_itemData)) return 0;
	if (!variable_struct_exists(_itemData, "value")) return 0;

	return _itemData.value * _quantity;
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

	return sellInventoryItemQuantity(_inventory, _x, _y, _quantity);
}

function sellInventoryItemQuantity(_inventory, _x, _y, _quantity) {
	var _item = _inventory[# _x, _y];

	if (_item == BLANK_INVENTORY_SPACE || !is_struct(_item)) {
		return TradeResult.InvalidItem;
	}

	var _availableQuantity = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;

	if (_quantity <= 0 || _quantity > _availableQuantity) {
		return TradeResult.InvalidQuantity;
	}

	var _sellValue = getSellItemValue(_item, _quantity);

	addPlayerMoney(_sellValue);

	if (variable_struct_exists(_item, "quantity")) {
		_item.quantity -= _quantity;

		if (_item.quantity <= 0) {
			_inventory[# _x, _y] = BLANK_INVENTORY_SPACE;
		}
	} else {
		_inventory[# _x, _y] = BLANK_INVENTORY_SPACE;
	}

	var _itemId = _item.itemId;
	var _itemType = _item.type;

	obj_quest_manager.notifyEvent(QuestEvent.ItemSold, {
		itemId: _itemId,
		itemType: _itemType,
		quantity: _quantity
	});

	return TradeResult.Success;
}