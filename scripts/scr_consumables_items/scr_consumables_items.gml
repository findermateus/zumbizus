

function ConsumableConfig() {
	return {
		itemId: 0,
		name: "",
		description: "",
		sprite: spr_item_default,
		sound: snd_can,
		consumableType: -1,
		fitInGrid: fitInGridType.verticaly,
		limit: 1,
		stackable: false,
		type: itemType.consumables
	};
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.watter_bottle;
	_config.name = "Água";
	_config.description = "Água em temperatura ambiente.";
	_config.sprite = spr_water_bottle;
	_config.sound = snd_water_bottle;
	_config.consumableType = consumableTypes.drink;
	_config.limit = 4;
	_config.stackable = true;

	global.items[itemType.consumables][consumableItems.watter_bottle] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.dirt_water;
	_config.name = "Água Suja";
	_config.description = "Água suja prejudicial de tomada.";
	_config.sprite = spr_dirt_water_bottle;
	_config.sound = snd_water_bottle;
	_config.consumableType = consumableTypes.drink;
	_config.limit = 4;
	_config.stackable = true;

	global.items[itemType.consumables][consumableItems.dirt_water] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.canned_food;
	_config.name = "Comida enlatada";
	_config.description = "Miúdos salgados sortidos.";
	_config.sprite = spr_canned_food;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 4;

	global.items[itemType.consumables][consumableItems.canned_food] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.canned_fish;
	_config.name = "Peixe enlatado";
	_config.description = "Bastante saboroso e oleoso.";
	_config.sprite = spr_canned_fish;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 4;

	global.items[itemType.consumables][consumableItems.canned_fish] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.canned_pineapple;
	_config.name = "Abacaxi Enlatado";
	_config.description = "Refrescante.";
	_config.sprite = spr_canned_pineapple;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 4;

	global.items[itemType.consumables][consumableItems.canned_pineapple] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.orange_juice;
	_config.name = "Suco de Laranja";
	_config.description = "O que menos tem aí é laranja";
	_config.sprite = spr_orange_juice;
	_config.consumableType = consumableTypes.drink;
	_config.stackable = true;
	_config.limit = 4;

	global.items[itemType.consumables][consumableItems.orange_juice] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.raw_meat_1;
	_config.name = "Carne crua de cervo";
	_config.description = "Está crua, logo, comer pode ser prejudicial.";
	_config.sprite = spr_raw_meat_1;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 8;
	
	global.items[itemType.consumables][consumableItems.raw_meat_1] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.cooked_meat_1;
	_config.name = "Carne assada de cerva";
	_config.description = "Está assada e gostosinha.";
	_config.sprite = spr_cooked_meat_1;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 8;
	
	global.items[itemType.consumables][consumableItems.cooked_meat_1] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.raw_meat_2;
	_config.name = "Carne crua de cordeiro";
	_config.description = "Carne que eu acho que é de cordeiro, está crua, logo, comer pode ser prejudicial.";
	_config.sprite = spr_raw_meat_2;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 8;
	
	global.items[itemType.consumables][consumableItems.raw_meat_2] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.cooked_meat_2;
	_config.name = "Carne assada de cordeiro";
	_config.description = "Carne que eu acho que é de cordeiro, está assada e gostosinha.";
	_config.sprite = spr_cooked_meat_2;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 8;
	
	global.items[itemType.consumables][consumableItems.cooked_meat_2] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.bandage;
	_config.name = "Bandagem";
	_config.description = "Para sangramentos";
	_config.sprite = spr_bandage;
	_config.consumableType = consumableTypes.health;
	_config.stackable = true;
	_config.limit = 6;
	
	global.items[itemType.consumables][consumableItems.bandage] = _config;
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.medicine;
	_config.name = "Remédios";
	_config.description = "Capsulas medicinais capazes de recuperar parcialmente a sua vida";
	_config.sprite = spr_medicine;
	_config.consumableType = consumableTypes.health;
	_config.stackable = true;
	_config.limit = 3;
	_config.sound = snd_medicine;
	
	global.items[itemType.consumables][consumableItems.medicine] = _config;
}