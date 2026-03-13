enum ammoItems {
	mm9,
	cal12,
	rifle
};

function AmmoItem(_limit, _name, _description, _sprite, _id, _quantity, _sound, _fitInGrid): Item(_name, _description, _sprite, _id, _sound, _fitInGrid, true) constructor{
	type = itemType.ammo;
	limit = _limit;
	quantity = _quantity;
}

function ammoContructor(_item = {
	itemId: undefined,
	name: undefined,
	description: undefined,
	sprite: undefined,
	limit: undefined,
	quantity: 0,
	sound: undefined,
	fitInGrid: fitInGridType.verticaly
}){
	return new AmmoItem(_item.limit, _item.name, _item.description, _item.sprite, _item.itemId, _item.quantity, _item.sound, _item.fitInGrid);
}