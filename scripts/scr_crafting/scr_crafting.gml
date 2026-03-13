function verifyIfHasAllItems(_requirementItem){
	var _requirementList = _requirementItem.requirements;
	for (var i = 0; i < array_length(_requirementList); i ++) {
		var _requirement = _requirementList[i];
		var _itemQuantity = getItemQuantityInInventory(global.inventory, _requirement.itemId, _requirement.type);
		var _hasSuficientItems = _itemQuantity >= _requirement.quantity;
		if (! _hasSuficientItems) {
			return false;
		}
	}
	return true;
}
