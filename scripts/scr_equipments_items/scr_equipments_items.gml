function EquipmentConfig() {
	return {
		itemId: 0,
		equipType: -1,
		name: "",
		description: "",
		sprite: spr_item_default,
		sound: snd_can,
		actionSound: snd_equip_item,
		fitInGrid: fitInGridType.verticaly,
		equipmentData: {
			capacity: 0
		},
		type: itemType.equipment
	};
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleBag;
	_config.equipType = equipmentType.bag;
	_config.name = "Mochila Zoada";
	_config.description = "Mochila fraca feita a partir de panos.";
	_config.sprite = spr_simple_bag;
	_config.equipmentData.capacity = 2;

	global.items[itemType.equipment][equipmentItems.simpleBag] = _config;
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleOutfit;
	_config.equipType = equipmentType.armor;
	_config.name = "Roupa simples";
	_config.description = "Roupa feita a trapos simples.";
	_config.sprite = spr_simple_shirt_icon;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.equipmentData.capacity = 2;

	global.items[itemType.equipment][equipmentItems.simpleOutfit] = _config;
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.leatherJacket;
	_config.equipType = equipmentType.armor;
	_config.name = "Jaqueta de couro";
	_config.description = "Roupa preta com uma jaqueta de couro.";
	_config.sprite = spr_leather_jacket_icon;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.equipmentData.capacity = 2;

	global.items[itemType.equipment][equipmentItems.leatherJacket] = _config;
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleOutfit;
	_config.equipType = equipmentType.armor;
	_config.name = "Roupa simples";
	_config.description = "Roupa feita a trapos simples.";
	_config.sprite = spr_simple_shirt_icon;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.equipmentData.capacity = 2;

	global.items[itemType.equipment][equipmentItems.simpleOutfit] = _config;
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleCap;
	_config.equipType = equipmentType.head;
	_config.name = "Boné";
	_config.description = "Um boné simples e bonitinho.";
	_config.sprite = spr_simple_cap;
	_config.equipmentData.capacity = 2;
	
	global.items[itemType.equipment][equipmentItems.simpleCap] = _config;
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.boonieHat;
	_config.equipType = equipmentType.head;
	_config.name = "Chapéu de Selva";
	_config.description = "Bucket Hat";
	_config.sprite = spr_boonie_hat;
	_config.equipmentData.capacity = 2;
	
	global.items[itemType.equipment][equipmentItems.boonieHat] = _config;
}