function getItemInteractOptions(_type, _id) {
	if (!arrayKeyExists(global.itemMethods, _type)) return [];
	if (!arrayKeyExists(global.itemMethods[_type], _id)) return [];
	
	
	return global.itemMethods[_type][_id];
}