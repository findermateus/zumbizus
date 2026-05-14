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

function MaterialItem(_limit, _name, _description, _sprite, _id, _quantity, _sound): Item(_name, _description, _sprite, _id, _sound, true) constructor{
	type = itemType.trash;
	limit = _limit;
	quantity = _quantity;
}