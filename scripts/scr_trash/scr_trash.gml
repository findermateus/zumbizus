enum trashItems {
	nail,
	empty_watter_bottle,
	empty_canned_food,
	wood_board,
	empty_canned_fish,
	duct_tape,
	twig,
	rock,
	wood_log,
	rope,
	plant_fiber,
	empty_canned_pineapple
}

function MaterialItem(_limit, _name, _description, _sprite, _id, _quantity, _sound, _fitInGrid): Item(_name, _description, _sprite, _id, _sound, _fitInGrid, true) constructor{
	type = itemType.trash;
	limit = _limit;
	quantity = _quantity;
}

function trashConstructor(_item = {
	itemId: undefined,
	name: undefined,
	description: undefined,
	sprite: undefined,
	limit: undefined,
	quantity: 0,
	sound: undefined,
	fitInGrid: fitInGridType.verticaly
}){
	return new MaterialItem(_item.limit, _item.name, _item.description, _item.sprite, _item.itemId, _item.quantity, _item.sound, _item.fitInGrid);
}