var _pistolConfiguration = getItemConfiguration(weaponItems.pistol, itemType.weapons);

containerData[# 0, 0] = constructItem(itemType.weapons, _pistolConfiguration);

var _ammoConfiguration = getItemConfiguration(ammoItems.mm9, itemType.ammo);

_ammoConfiguration.quantity = 6;

containerData[# 1, 0] = constructItem(itemType.ammo, _ammoConfiguration);