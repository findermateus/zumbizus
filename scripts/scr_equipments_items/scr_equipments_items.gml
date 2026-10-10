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
		equipmentData: {},
		type: itemType.equipment,
		value: 0
	};
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleBag;
	_config.equipType = equipmentType.bag;
	_config.name = "Mochila Zoada";
	_config.description = "Mochila fraca feita a partir de panos.";
	_config.sprite = spr_simple_bag;
	_config.equipmentData.capacity = 10;
	_config.value = 115;

	global.items[itemType.equipment][equipmentItems.simpleBag] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.simpleBag] = [
		new ItemMethod("Equipar", "wear")
	];
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.trailBag;
	_config.equipType = equipmentType.bag;
	_config.name = "Mochila de Trilha";
	_config.description = "Mochila grande e reforçada, cheia de bolsos.";
	_config.sprite = spr_simple_bag;
	_config.equipmentData.capacity = 15;
	_config.value = 320;

	global.items[itemType.equipment][equipmentItems.trailBag] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.trailBag] = [
		new ItemMethod("Equipar", "wear")
	];
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleOutfit;
	_config.equipType = equipmentType.armor;
	_config.name = "Roupa simples";
	_config.description = "Roupa feita a trapos simples.";
	_config.sprite = spr_simple_shirt_icon;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.value = 12;

	global.items[itemType.equipment][equipmentItems.simpleOutfit] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.simpleOutfit] = [
		new ItemMethod("Equipar", "wear"),
		new ItemMethod("Rasgar", "dismantle")
	];
}

{
	var _config = EquipmentConfig();

	_config.itemId = equipmentItems.tornLabCoat;
	_config.equipType = equipmentType.armor;

	_config.name = "Jaleco Rasgado";
	_config.description = "Um jaleco velho e rasgado. Não oferece muita proteção, mas é melhor do que continuar exposto.";

	_config.sprite = spr_torn_lab_coat_icon;
	_config.fitInGrid = fitInGridType.verticaly;

	_config.equipmentData.damageAbsortion = 2;

	_config.value = 7;

	global.items[itemType.equipment][equipmentItems.tornLabCoat] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.tornLabCoat] = [
		new ItemMethod("Equipar", "wear")
	];
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.leatherJacket;
	_config.equipType = equipmentType.armor;
	_config.name = "Jaqueta de couro";
	_config.description = "Roupa preta com uma jaqueta de couro.";
	_config.sprite = spr_leather_jacket_icon;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.value = 50;


	global.items[itemType.equipment][equipmentItems.leatherJacket] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.leatherJacket] = [
		new ItemMethod("Equipar", "wear")
	];
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.simpleCap;
	_config.equipType = equipmentType.head;
	_config.name = "Boné";
	_config.description = "Um boné simples e bonitinho.";
	_config.sprite = spr_simple_cap;
	_config.value = 15;
	
	global.items[itemType.equipment][equipmentItems.simpleCap] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.simpleCap] = [
		new ItemMethod("Equipar", "wear")
	];
}

{
	var _config = EquipmentConfig();
	_config.itemId = equipmentItems.boonieHat;
	_config.equipType = equipmentType.head;
	_config.name = "Chapéu de Selva";
	_config.description = "Bucket Hat";
	_config.sprite = spr_boonie_hat;
	_config.value = 30;

	
	global.items[itemType.equipment][equipmentItems.boonieHat] = _config;
	global.itemMethods[itemType.equipment][equipmentItems.boonieHat] = [
		new ItemMethod("Equipar", "wear")
	];
}