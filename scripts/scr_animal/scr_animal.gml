enum animals {
	rabbit,
	deer,
	rat
}

function animalDrop(_itemType, _itemId, _maxQuantity) {
	return {
		type: _itemType,
		id: _itemId,
		maxQuantity: _maxQuantity
	};
}

function Animal(_id, _name, _drops) constructor {
	id = _id;
	name = _name;
	drop = _drops;
}

function AnimalPassive(_id, _name, _runningSpeed, _iddleSpeed, _drops): Animal(_id, _name, _drops) constructor {
	runningSpeed = _runningSpeed;
	iddleSpeed = _iddleSpeed;
}

global.passiveAnimals = [];

global.passiveAnimals[animals.deer] = new AnimalPassive(animals.deer, "Cervo", 8, 2, [
	animalDrop(itemType.consumables, consumableItems.raw_meat_1, 3)
]);

global.passiveAnimals[animals.rat] = new AnimalPassive(animals.rat, "Rato", 4, 2, [
	animalDrop(itemType.consumables, consumableItems.raw_rat_meat, 1)
]);