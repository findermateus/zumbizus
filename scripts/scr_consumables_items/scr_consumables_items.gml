enum consumableItems {
	watter_bottle,
	canned_food,
	canned_fish,
	raw_meat_1,
	cooked_meat_1,
	raw_meat_2,
	raw_rat_meat,
	cooked_rat_meat,
	cooked_meat_2,
	dirt_water,
	bandage,
	medicine,
	canned_pineapple,
	orange_juice
}

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
		type: itemType.consumables,
		value: 0
	};
}

global.consumableUsageData = [];

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
	_config.value = 20;

	global.items[itemType.consumables][consumableItems.watter_bottle] = _config;
	global.itemMethods[itemType.consumables][consumableItems.watter_bottle] = [ new ItemMethod("Beber", "drink") ];
	global.consumableUsageData[consumableItems.watter_bottle] = new ConsumableUsageData(600, snd_drink_water_bottle, trashItems.empty_watter_bottle, [
		otherEffectsData(otherEffectTypes.staminaIncrease, 40)
	]);
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
	_config.value = 8;

	global.items[itemType.consumables][consumableItems.dirt_water] = _config;
	global.itemMethods[itemType.consumables][consumableItems.dirt_water] = [ new ItemMethod("Beber", "drink") ];
	global.consumableUsageData[consumableItems.dirt_water] = new ConsumableUsageData(100, snd_drink_water_bottle, trashItems.empty_watter_bottle, [
		otherEffectsData(otherEffectTypes.healthDecrease, 10)
	]);
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
	_config.value = 16;

	global.items[itemType.consumables][consumableItems.canned_food] = _config;
	global.itemMethods[itemType.consumables][consumableItems.canned_food] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.canned_food] = new ConsumableUsageData(500, snd_eat_canned_food, trashItems.empty_canned_food, [
		otherEffectsData(otherEffectTypes.healthIncrease, 20)
	]);
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
	_config.value = 20;

	global.items[itemType.consumables][consumableItems.canned_fish] = _config;
	global.itemMethods[itemType.consumables][consumableItems.canned_fish] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.canned_fish] = new ConsumableUsageData(400, snd_eat_canned_food, trashItems.empty_canned_fish, [
		otherEffectsData(otherEffectTypes.thirstDecrease, 100)
	]);
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
	_config.value = 20;

	global.items[itemType.consumables][consumableItems.canned_pineapple] = _config;
	global.itemMethods[itemType.consumables][consumableItems.canned_pineapple] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.canned_pineapple] = new ConsumableUsageData(370, snd_eat_canned_food, trashItems.empty_canned_pineapple, [
		otherEffectsData(otherEffectTypes.thirstDecrease, 400)
	]);
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
	_config.value = 18;

	global.items[itemType.consumables][consumableItems.orange_juice] = _config;
	global.itemMethods[itemType.consumables][consumableItems.orange_juice] = [ new ItemMethod("Beber", "drink") ];
	global.consumableUsageData[consumableItems.orange_juice] = new ConsumableUsageData(450, snd_drink_water_bottle);
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
	_config.value = 22;
	
	global.items[itemType.consumables][consumableItems.raw_meat_1] = _config;
	global.itemMethods[itemType.consumables][consumableItems.raw_meat_1] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.raw_meat_1] = new ConsumableUsageData(200, snd_eat_canned_food, undefined, [
		otherEffectsData(otherEffectTypes.healthDecrease, 10)
	]);
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
	_config.value = 35;
	
	global.items[itemType.consumables][consumableItems.cooked_meat_1] = _config;
	global.itemMethods[itemType.consumables][consumableItems.cooked_meat_1] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.cooked_meat_1] = new ConsumableUsageData(700, snd_eat_canned_food, undefined, [
		otherEffectsData(otherEffectTypes.healthIncrease, 30)
	]);
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
	_config.value = 22;
	
	global.items[itemType.consumables][consumableItems.raw_meat_2] = _config;
	global.itemMethods[itemType.consumables][consumableItems.raw_meat_2] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.raw_meat_2] = new ConsumableUsageData(200, snd_eat_canned_food, undefined, [
		otherEffectsData(otherEffectTypes.healthDecrease, 10)
	]);
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
	_config.value = 35;
	
	global.items[itemType.consumables][consumableItems.cooked_meat_2] = _config;
	global.itemMethods[itemType.consumables][consumableItems.cooked_meat_2] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.cooked_meat_2] = new ConsumableUsageData(750, snd_eat_canned_food, undefined, [
		otherEffectsData(otherEffectTypes.healthIncrease, 30)
	]);
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.raw_rat_meat;
	_config.name = "Carne crua de rato";
	_config.description = "Não vai comer isso, né?";
	_config.sprite = spr_raw_rat_meat;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 12;
	_config.value = 8;
	
	global.items[itemType.consumables][consumableItems.raw_rat_meat] = _config;
	global.itemMethods[itemType.consumables][consumableItems.raw_rat_meat] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.raw_rat_meat] = new ConsumableUsageData(50, snd_eat_canned_food, undefined, [
		otherEffectsData(otherEffectTypes.healthDecrease, 15)
	]);
}

{
	var _config = ConsumableConfig();
	_config.itemId = consumableItems.cooked_rat_meat;
	_config.name = "Carne assada de rato";
	_config.description = "Um pouco menos pior do que crua...";
	_config.sprite = spr_cooked_rat_meat;
	_config.consumableType = consumableTypes.food;
	_config.stackable = true;
	_config.limit = 12;
	_config.value = 12;
	
	global.items[itemType.consumables][consumableItems.cooked_rat_meat] = _config;
	global.itemMethods[itemType.consumables][consumableItems.cooked_rat_meat] = [ new ItemMethod("Comer", "eat") ];
	global.consumableUsageData[consumableItems.cooked_rat_meat] = new ConsumableUsageData(120, snd_eat_canned_food, undefined);
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
	_config.value = 15;
	
	global.items[itemType.consumables][consumableItems.bandage] = _config;
	global.itemMethods[itemType.consumables][consumableItems.bandage] = [ new ItemMethod("Usar", "use") ];
	global.consumableUsageData[consumableItems.bandage] = new ConsumableUsageData(10, snd_eat_canned_food, undefined);
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
	_config.value = 60;
	
	global.items[itemType.consumables][consumableItems.medicine] = _config;
	global.itemMethods[itemType.consumables][consumableItems.medicine] = [ new ItemMethod("Usar", "use") ];
	global.consumableUsageData[consumableItems.medicine] = new ConsumableUsageData(70, snd_eat_medicine, undefined);
}