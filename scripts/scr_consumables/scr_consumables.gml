enum consumableItems {
	watter_bottle,
	canned_food,
	canned_fish,
	raw_meat_1,
	cooked_meat_1,
	raw_meat_2,
	cooked_meat_2,
	dirt_water,
	bandage,
	medicine,
	canned_pineapple,
	orange_juice
}

enum consumableTypes {
	drink,
	food,
	beer,
	health
}

function ConsumableItem(_name, _description, _sprite, _id, _sound, _fitInGrid, _data): Item(_name, _description, _sprite, _id, _sound, _fitInGrid) constructor{
	type = itemType.consumables;
	stackable = _data.stackable;
	limit = _data.limit;
	consumableType = _data.consumableType;
	quantity = variable_struct_exists(_data, "quantity") ? _data.quantity : 1;
}

function consumableConstructor(_item = {
	itemId: 0,
	name: undefined,
	description: undefined,
	sprite: undefined,
	sound: undefined,
	fitInGrid: fitInGridType.verticaly
}){
	return new ConsumableItem(_item.name, _item.description, _item.sprite, _item.itemId, _item.sound, _item.fitInGrid, _item);
}