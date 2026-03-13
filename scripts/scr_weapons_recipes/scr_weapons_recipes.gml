function setUpWeaponCraftingGlobals() {
	var _nailBoardRequirements = [
		new RequirementBuilder(trashItems.wood_board, 1, itemType.trash),
		new RequirementBuilder(trashItems.nail, 10, itemType.trash)
	];
	
	var _baseballNailsBatRequirements = [
		new RequirementBuilder(weaponItems.baseballBat, 1, itemType.weapons),
		new RequirementBuilder(trashItems.nail, 8, itemType.trash)
	];
	
	var _axeRequirements = [
		new RequirementBuilder(trashItems.twig, 3, itemType.trash),
		new RequirementBuilder(trashItems.rock, 2, itemType.trash)
	];
	
	global.craftingItems[craftingCategories.weapons] = [
		new CraftingItem(weaponItems.nailBoard, itemType.weapons, 1, _nailBoardRequirements, blueprints.nailBoard),
		new CraftingItem(weaponItems.baseballBatWithNails, itemType.weapons, 1, _baseballNailsBatRequirements, blueprints.baseballBatWithNails),
		new CraftingItem(weaponItems.axe, itemType.weapons, 1, _axeRequirements, blueprints.axe)
	];
}

function setUpWeaponRepairGlobals() {
	var _nailBoardRepairRequirements = [
		new RequirementBuilder(trashItems.nail, 5, itemType.trash)
	];
	
	var _baseballBatWithNailsRequirements = [
		new RequirementBuilder(trashItems.wood_board, 1, itemType.trash),
		new RequirementBuilder(trashItems.nail, 4, itemType.trash)
	];
	
	var _bladeReq = [
		new RequirementBuilder(trashItems.duct_tape, 3, itemType.trash)
	];
	
	var _baseballBatRequirements = [
		new RequirementBuilder(trashItems.duct_tape, 3, itemType.trash)
	]
	
	var _axeRequirements = [
		new RequirementBuilder(trashItems.rock, 1, itemType.trash),
		new RequirementBuilder(trashItems.twig, 1, itemType.trash)
	];
	
	global.repairItems = [];
	
	global.repairItems[itemType.weapons] = [
		new CraftingItem(weaponItems.nailBoard, itemType.weapons, 1, _nailBoardRepairRequirements, blueprints.nailBoard),
		new CraftingItem(weaponItems.baseballBat, itemType.weapons, 1, _baseballBatWithNailsRequirements),
		new CraftingItem(weaponItems.baseballBatWithNails, itemType.weapons, 1, _baseballBatWithNailsRequirements, blueprints.baseballBatWithNails),
		new CraftingItem(weaponItems.sword, itemType.weapons, 1, _bladeReq),
		new CraftingItem(weaponItems.axe, itemType.weapons, 1, _axeRequirements)
	];
}