global.itemMethods[itemType.consumables][consumableItems.canned_food]   = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.watter_bottle] = [ new ItemMethod("Beber", "drink") ];
global.itemMethods[itemType.consumables][consumableItems.canned_fish]   = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.raw_meat_1]    = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.cooked_meat_1] = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.raw_meat_2]    = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.cooked_meat_2] = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.dirt_water]    = [ new ItemMethod("Beber", "drink") ];
global.itemMethods[itemType.consumables][consumableItems.bandage] = [ new ItemMethod("Usar", "use") ];
global.itemMethods[itemType.consumables][consumableItems.medicine]    = [ new ItemMethod("Usar", "use") ];
global.itemMethods[itemType.consumables][consumableItems.canned_pineapple]    = [ new ItemMethod("Comer", "eat") ];
global.itemMethods[itemType.consumables][consumableItems.orange_juice]    = [ new ItemMethod("Beber", "drink") ];

function ConsumableUsageData(_increaseValue, _sound, _itemToDrop = undefined, _otherEffects = []) constructor {
	increaseValue = _increaseValue;
	sound = _sound;
	otherEffects = _otherEffects;
	itemToDrop = _itemToDrop;
}

enum otherEffectTypes {
	healthIncrease,
	thirstDecrease,
	hungerDecrease,
	staminaIncrease,
	healthDecrease
}

function otherEffectsData(_type, _value) {
	return {
		type: _type,
		value: _value
	};
}

global.consumableUsageData = []

global.consumableUsageData[consumableItems.watter_bottle] = new ConsumableUsageData(600, snd_drink_water_bottle, trashItems.empty_watter_bottle, [
	otherEffectsData(otherEffectTypes.staminaIncrease, 40)
]);

global.consumableUsageData[consumableItems.dirt_water] = new ConsumableUsageData(100, snd_drink_water_bottle, trashItems.empty_watter_bottle, [
	otherEffectsData(otherEffectTypes.healthDecrease, 10)	
]);

global.consumableUsageData[consumableItems.canned_food] = new ConsumableUsageData(500, snd_eat_canned_food, trashItems.empty_canned_food, [
	otherEffectsData(otherEffectTypes.healthIncrease, 20), 
]);

global.consumableUsageData[consumableItems.canned_fish] = new ConsumableUsageData(400, snd_eat_canned_food, trashItems.empty_canned_fish, [
	otherEffectsData(otherEffectTypes.thirstDecrease, 100)
]);

global.consumableUsageData[consumableItems.canned_pineapple] = new ConsumableUsageData(370, snd_eat_canned_food, trashItems.empty_canned_pineapple, [
	otherEffectsData(otherEffectTypes.thirstDecrease, 400)
]);

global.consumableUsageData[consumableItems.orange_juice] = new ConsumableUsageData(450, snd_drink_water_bottle);

global.consumableUsageData[consumableItems.raw_meat_1] = new ConsumableUsageData(200, snd_eat_canned_food, undefined, [
	otherEffectsData(otherEffectTypes.healthDecrease, 10)
]);

global.consumableUsageData[consumableItems.cooked_meat_1] = new ConsumableUsageData(700, snd_eat_canned_food, undefined, [
	otherEffectsData(otherEffectTypes.healthIncrease, 30)
]);

global.consumableUsageData[consumableItems.raw_meat_2] = new ConsumableUsageData(200, snd_eat_canned_food, undefined, [
	otherEffectsData(otherEffectTypes.healthDecrease, 10)
]);

global.consumableUsageData[consumableItems.cooked_meat_2] = new ConsumableUsageData(750, snd_eat_canned_food, undefined, [
	otherEffectsData(otherEffectTypes.healthIncrease, 30)
]);

global.consumableUsageData[consumableItems.bandage] = new ConsumableUsageData(10, snd_eat_canned_food, undefined);
global.consumableUsageData[consumableItems.medicine] = new ConsumableUsageData(70, snd_eat_medicine, undefined);