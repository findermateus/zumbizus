if (keyboard_check_pressed(ord("C"))) {
	var _itemConfig = global.items[itemType.consumables][consumableItems.canned_fish];
	var _buildedItem = constructItem(itemType.consumables, _itemConfig);
			
	createIndicatorForQuestItem(_buildedItem, 1);
}			