function meleeWeaponItem(_name, _sprite, _description, _id, _sound, _fitInGrid, _data = {}): Item(_name, _description, _sprite, _id, _sound, _fitInGrid) constructor
{
	actionSound = variable_struct_exists(_data, "actionSound") ? _data.actionSound : undefined;
	bullets = _data.bullets;
	maxAmmo = _data.maxAmmo;
	durability = _data.durability;
	maxDurability = _data.maxDurability;
	durabilityDecrease = _data.durabilityDecrease;
	type = itemType.weapons;
	usableSound = true;
	soundRadius = _data.soundRadius;
}

function weaponContructor(_item = {
	itemId: undefined,
	name: undefined,
	description: undefined,
	sprite: undefined,
	sound: undefined,
	fitInGrid: fitInGridType.verticaly
}){
	return new meleeWeaponItem(_item.name, _item.sprite, _item.description, _item.itemId, _item.sound, _item.fitInGrid, _item);
}