function setUpMaterialCraftingGlobals() {
	var _woodBoardReq = [
		new RequirementBuilder(trashItems.wood_log, 1, itemType.trash)
	];
	
	var _rope = [
		new RequirementBuilder(trashItems.plant_fiber, 6, itemType.trash)
	];
	
	global.craftingRecipes[craftingCategories.materials] = [
		new CraftingItem(trashItems.wood_board, itemType.trash, 1, _woodBoardReq),
		new CraftingItem(trashItems.rope, itemType.trash, 1, _rope)
	];
}