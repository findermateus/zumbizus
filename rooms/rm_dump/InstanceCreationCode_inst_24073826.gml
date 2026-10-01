var _ammoConfig = getItemConfiguration(ammoItems.mm9, itemType.ammo);
var _ammoBuilded = constructItem(itemType.ammo, _ammoConfig);

_ammoBuilded.quantity = 6;

containerData[# 0, 0] = _ammoBuilded;

var _weaponConfig = getItemConfiguration(weaponItems.pistol, itemType.weapons);
var _weaponBuilded = constructItem(itemType.weapons, _weaponConfig);

containerData[# 1, 0] = _weaponBuilded;