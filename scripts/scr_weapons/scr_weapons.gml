function WeaponItem(_name, _sprite, _description, _id, _sound, _data = {}): Item(_name, _description, _sprite, _id, _sound) constructor
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