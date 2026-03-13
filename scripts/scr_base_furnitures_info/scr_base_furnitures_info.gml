// ============================
// Furniture Data System
// ============================

global.baseProductiveFurnitureData = [];

/// @desc Define um dado específico da mobília
function setFurnitureData(_furnitureId, _objectId, _value) {
    if (!getFurnitureData(_furnitureId, _objectId)) {
		array_push(global.baseProductiveFurnitureData[_furnitureId], _value);
		return;
	}
	
	if (!arrayKeyExists(global.baseProductiveFurnitureData, _furnitureId)) return undefined;
	
	for (var i = 0; i < array_length(global.baseProductiveFurnitureData[_furnitureId]); i++) {
		var _furnitureData = global.baseProductiveFurnitureData[_furnitureId];
		
		if (_furnitureData.objectId == _objectId){
			global.baseProductiveFurnitureData[_furnitureId][i] = _value;
		}
	}
}

/// @desc Retorna um dado específico da mobília
function getFurnitureData(_furnitureId, _objectId) {
	if (!arrayKeyExists(global.baseProductiveFurnitureData, _furnitureId)) {
		global.baseProductiveFurnitureData[_furnitureId] = [];
		return undefined;
	}
	for (var i = 0; i < array_length(global.baseProductiveFurnitureData[_furnitureId]); i++) {
		var _furnitureData = global.baseProductiveFurnitureData[_furnitureId][i];
		
		if (_furnitureData.objectId == _objectId) return _furnitureData;
	}
    
    return undefined;
}
