function getItemValue(_item) {
	if (!is_struct(_item)) return 0;
	if (!variable_struct_exists(_item, "value")) return 0;

	return _item.value;
}

function getItemTotalValue(_item) {
	if (!is_struct(_item)) return 0;

	var _quantity = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;

	return getItemValue(_item) * _quantity;
}

function playerHasMoney(_amount) {
	return global.player.money >= _amount;
}

function addPlayerMoney(_amount) {
	global.player.money += _amount;
}

function removePlayerMoney(_amount) {
	if (!playerHasMoney(_amount)) return false;

	global.player.money -= _amount;
	return true;
}