function setUpCookingGlobals() {
	global.craftingItems[craftingCategories.cooking] = []

	var _recipe = new CraftingItem(consumableItems.cooked_meat_1, itemType.consumables, 1, [
		new RequirementBuilder(consumableItems.raw_meat_1, 1, itemType.consumables)
	], blueprints.cookedMeat1)
	array_push(global.craftingItems[craftingCategories.cooking], _recipe)
	
	_recipe = new CraftingItem(consumableItems.cooked_meat_2, itemType.consumables, 1, [
		new RequirementBuilder(consumableItems.raw_meat_2, 1, itemType.consumables)
	], blueprints.cookedMeat2)
	array_push(global.craftingItems[craftingCategories.cooking], _recipe)
	
	_recipe = new CraftingItem(consumableItems.watter_bottle, itemType.consumables, 1, [
		new RequirementBuilder(consumableItems.dirt_water, 1, itemType.consumables)
	])
	array_push(global.craftingItems[craftingCategories.cooking], _recipe)
}