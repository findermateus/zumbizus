/// @constructor CampfireData
function CampfireSlot() constructor {
	
	itemId = global.blankInventorySpace;
	type = -1;
	itemQuantity = 0;
	resultId = global.blankInventorySpace;
	resultType = -1;
	resultQuantity = 0;
	resultCurrentProgress = 0;
	requiredResultProgress = 100
	
	function getItem() {
		return itemId == global.blankInventorySpace ? global.blankInventorySpace : constructItem(type, global.items[type, itemId]);
	}
	
	function getResult() {
		return resultId == global.blankInventorySpace ? global.blankInventorySpace : constructItem(resultType, global.items[resultType, resultId]);
	}
	
	function canAddItem(_itemId, _itemType) {
		return itemId == global.blankInventorySpace || itemId == _itemId && _itemType == type;
	}
	
	function setResult(_itemId, _itemType) {
		resultId = _itemId;
		resultType = _itemType;
		resultQuantity = 0;
	}
	
	function addItem(_itemId, _itemType, _resultId, _resultType, _quantity = 1) {
		if (itemId == global.blankInventorySpace) {
			itemId = _itemId;
			type = _itemType;
			itemQuantity = _quantity;
			setResult(_resultId, _resultType)
			return true;
		}
		if (itemId == _itemId && _itemType == type) {
			itemQuantity += _quantity;
			return true;
		}
		return false;
	}
	
	function getCurrentItem() {
		if (resultQuantity > 0) {
			return getResult();
		}
		return resultQuantity > 0 ? getResult() : getItem();
	}
	
	function resetValues() {
		itemId = global.blankInventorySpace;
		type = -1;
		itemQuantity = 0;
		resultId = global.blankInventorySpace;
		resultType = -1;
		resultQuantity = 0;
		resultCurrentProgress = 0;
	}
	
	function removeItem() {
		var _quantity = 1;
		if (resultQuantity > 0) {
			resultQuantity -= _quantity;
			if (itemQuantity == 0 && resultQuantity == 0) {
				resetValues();
			}
			return;
		}
		itemQuantity -= _quantity;
		if (itemQuantity > 0) return;
		resetValues();
	}
	
	function handle(_increaseValue) {
		if (itemQuantity < 1) return false;
		resultCurrentProgress += _increaseValue;
		if (resultCurrentProgress < 100) return true;
		resultQuantity ++;
		resultCurrentProgress = 0;
		itemQuantity --;	
	}
	
	function loadFromSave(
		_itemId = global.blankInventorySpace,
		_type = -1,
		_itemQuantity = 0,
		_resultId = global.blankInventorySpace,
		_resultType = -1,
		_resultQuantity = 0,
		_resultCurrentProgress = 0,
		_requiredResultProgress = 100
	) {
		itemId = _itemId;
		type = _type;
		itemQuantity = _itemQuantity;
		resultId = _resultId;
		resultType = _resultType;
		resultQuantity = _resultQuantity;
	}
}

function CampfireData(_slotLength, _objectId): ProductiveFurnitureData(furnitureIds.campfire, _objectId) constructor {
    slotData = [];
	repeat(_slotLength) {
		array_push(slotData, new CampfireSlot());
	}
}