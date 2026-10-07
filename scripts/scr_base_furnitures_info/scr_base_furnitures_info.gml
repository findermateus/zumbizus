global.baseProductiveFurnitureData = ds_map_create();

function setFurnitureData(_furnitureId, _objectId, _value) {
	if (!ds_map_exists(global.baseProductiveFurnitureData, _furnitureId)) {
		global.baseProductiveFurnitureData[? _furnitureId] = [];
	}

	var _furnitureDataList = global.baseProductiveFurnitureData[? _furnitureId];

	for (var i = 0; i < array_length(_furnitureDataList); i++) {
		if (_furnitureDataList[i].objectId == _objectId) {
			_furnitureDataList[i] = _value;
			return;
		}
	}

	array_push(_furnitureDataList, _value);
}

function getFurnitureData(_furnitureId, _objectId) {
	if (!ds_map_exists(global.baseProductiveFurnitureData, _furnitureId)) return undefined;

	var _furnitureDataList = global.baseProductiveFurnitureData[? _furnitureId];

	for (var i = 0; i < array_length(_furnitureDataList); i++) {
		if (_furnitureDataList[i].objectId == _objectId) return _furnitureDataList[i];
	}

	return undefined;
}
