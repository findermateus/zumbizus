enum consumableTypes {
	drink,
	food,
	beer,
	health
}

function ConsumableItem(_name, _description, _sprite, _id, _sound, _data): Item(_name, _description, _sprite, _id, _sound) constructor{
	type = itemType.consumables;
	stackable = _data.stackable;
	limit = _data.limit;
	consumableType = _data.consumableType;
	quantity = variable_struct_exists(_data, "quantity") ? _data.quantity : 1;
}