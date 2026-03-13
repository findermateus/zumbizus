loadPlayerData();

if (instance_exists(obj_extraction_sign)) {
	with(obj_extraction_sign) {
		sprite_index = spr_traffic_sign_destroyed;
		image_xscale = 3;
		image_yscale = 3;
	}
}

var _possibleItems = [
    // --- MUITO COMUNS (Latas, Garrafas e Pregos) ---
    buildPossibleItemDrop(trashItems.empty_canned_fish, itemType.trash, 35),
    buildPossibleItemDrop(trashItems.empty_canned_food, itemType.trash, 35),
    buildPossibleItemDrop(trashItems.empty_canned_pineapple, itemType.trash, 35),
    buildPossibleItemDrop(trashItems.empty_watter_bottle, itemType.trash, 40),
    buildPossibleItemDrop(trashItems.nail, itemType.trash, 45),
    
    // --- COMUNS (Materiais de construção) ---
    buildPossibleItemDrop(trashItems.duct_tape, itemType.trash, 15),
    buildPossibleItemDrop(trashItems.wood_board, itemType.trash, 15),
    
    // --- RAROS (Consumíveis e Água) ---
    buildPossibleItemDrop(consumableItems.dirt_water, itemType.consumables, 8),
    buildPossibleItemDrop(consumableItems.canned_food, itemType.consumables, 3),
    buildPossibleItemDrop(consumableItems.canned_fish, itemType.consumables, 3),
    buildPossibleItemDrop(consumableItems.canned_pineapple, itemType.consumables, 3),
	
	buildPossibleItemDrop(weaponItems.nailBoard, itemType.weapons, 2)
];

with (obj_item) {
    var _selectedItem = getWeightItemRandom(_possibleItems);
    
    self.item = convertRandomItemToBuildedItem(_selectedItem, 3);
}

var _fridgePossibleItems = [
	buildPossibleItemDrop(consumableItems.dirt_water, itemType.consumables, 15),
    buildPossibleItemDrop(consumableItems.canned_food, itemType.consumables, 15),
    buildPossibleItemDrop(consumableItems.canned_fish, itemType.consumables, 15),
    buildPossibleItemDrop(consumableItems.canned_pineapple, itemType.consumables, 15),
	
	buildPossibleItemDrop(trashItems.empty_canned_fish, itemType.trash, 8),
    buildPossibleItemDrop(trashItems.empty_canned_food, itemType.trash, 8),
    buildPossibleItemDrop(trashItems.empty_canned_pineapple, itemType.trash, 8),
    buildPossibleItemDrop(trashItems.empty_watter_bottle, itemType.trash, 8),
];

with (obj_chest) {
    var _chestCode = containerId;
    var _isAFridge = (_chestCode == "fridgeBroken");
    var _itemList = _isAFridge ? _fridgePossibleItems : _possibleItems;
    
    var _gw = ds_grid_width(containerData);
    var _gh = ds_grid_height(containerData);
    
    // i percorre a largura (X)
    for (var i = 0; i < _gw; i++) {
        // j percorre a altura (Y)
        for (var j = 0; j < _gh; j++) {
            
            // Lembre-se: choose(false, false, true) dá apenas 33% de chance de vir loot
            var _gridWillHaveLoot = choose(false, false, true);
            
            if (_gridWillHaveLoot) {
                var _selectedItem = getWeightItemRandom(_itemList);
                containerData[# i, j] = convertRandomItemToBuildedItem(_selectedItem, 3);
            }
        }
    }
}
