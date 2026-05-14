enum ammoItems {
	mm9,
	cal12,
	rifle
};

function AmmoItem(_limit, _name, _description, _sprite, _id, _quantity, _sound): Item(_name, _description, _sprite, _id, _sound, true) constructor{
	type = itemType.ammo;
	limit = _limit;
	quantity = _quantity;
}