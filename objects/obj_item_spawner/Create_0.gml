if (!is_numeric(itemId) || !is_numeric(type) || !is_numeric(quantity)) {
	show_debug_message("invalid item configuration itemID: {" + string(itemId) + "} type: {" + string(type) + "} quantity: {" + string(quantity) + "}");
	instance_destroy(id);
}

if (itemId == -1 || type == -1 || quantity < 1) {
	show_debug_message("invalid item configuration itemID: {" + string(itemId) + "} type: {" + string(type) + "} quantity: {" + string(quantity) + "}");
	instance_destroy(id);
}

createDroppedItem(itemId, type, x, y, quantity);

instance_destroy(id);