var _medicineConfig = global.items[itemType.consumables][consumableItems.medicine];
var _medicine = constructItem(itemType.consumables, _medicineConfig);

var _bandageConfig = global.items[itemType.consumables][consumableItems.bandage];
var _bandage = constructItem(itemType.consumables, _bandageConfig);

containerData[# 0, 0] = _medicine;
containerData[# 0, 1] = _bandage;