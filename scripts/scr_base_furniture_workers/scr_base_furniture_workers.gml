// A atribuição de trabalho vive só no residente (BaseResident.workplace).
// Os workers de uma mobília são derivados dos residentes e ficam em cache até a próxima mudança.

global.furnitureWorkersCache = {};

function invalidateFurnitureWorkersCache() {
	global.furnitureWorkersCache = {};
}

function getFurnitureWorkersCacheKey(_furnitureId, _objectId) {
	return string(_furnitureId) + ":" + string(_objectId);
}

/// @returns {Array} | -1
function getFurnitureWorkers(_furnitureId, _objectId) {
	var _cacheKey = getFurnitureWorkersCacheKey(_furnitureId, _objectId);
	var _cached = global.furnitureWorkersCache[$ _cacheKey];

	if (!is_undefined(_cached)) return _cached;

	var _furniturePreset = global.productiveFurnitures[? _furnitureId];
	var _workerQuantity = is_struct(_furniturePreset) ? _furniturePreset.workerQuantity : 0;
	var _workers = array_create(_workerQuantity, -1);

	var _residents = getBaseResidentList();

	for (var i = 0; i < array_length(_residents); i++) {
		var _workplace = _residents[i].workplace;

		if (!isResidentWorkplace(_workplace, _furnitureId, _objectId)) continue;
		if (_workplace.slot < 0 || _workplace.slot >= _workerQuantity) continue;

		_workers[_workplace.slot] = _residents[i];
	}

	global.furnitureWorkersCache[$ _cacheKey] = _workers;

	return _workers;
}

function isResidentWorkplace(_workplace, _furnitureId, _objectId) {
	return is_struct(_workplace) && _workplace.furnitureId == _furnitureId && _workplace.objectId == _objectId;
}

/// @returns {Struct.BaseResident|Real} | -1
function assignResidentToFurniture(_residentId, _furnitureId, _objectId, _slot) {
	var _resident = getBaseResident(_residentId);

	if (is_undefined(_resident)) return -1;

	var _previousOccupant = getFurnitureWorkers(_furnitureId, _objectId)[_slot];

	if (is_struct(_previousOccupant) && _previousOccupant != _resident) {
		_previousOccupant.workplace = undefined;
	}

	_resident.workplace = {
		furnitureId: _furnitureId,
		objectId: _objectId,
		slot: _slot
	};

	invalidateFurnitureWorkersCache();

	return _previousOccupant == _resident ? -1 : _previousOccupant;
}

function unassignResident(_residentId) {
	var _resident = getBaseResident(_residentId);

	if (is_undefined(_resident)) return;

	_resident.workplace = undefined;

	invalidateFurnitureWorkersCache();
}

function unassignFurnitureWorkers(_furnitureId, _objectId) {
	var _residents = getBaseResidentList();

	for (var i = 0; i < array_length(_residents); i++) {
		if (isResidentWorkplace(_residents[i].workplace, _furnitureId, _objectId)) {
			_residents[i].workplace = undefined;
		}
	}

	invalidateFurnitureWorkersCache();
}

/// @returns {Id.Instance} | noone
function getFurnitureInstance(_furnitureId, _objectId) {
	with (obj_furniture) {
		if (objectId == _objectId && furnitureId == _furnitureId) return id;
	}

	return noone;
}

function canResidentWorkAt(_resident, _furnitureId) {
	var _furniturePreset = global.productiveFurnitures[? _furnitureId];

	if (!is_struct(_furniturePreset)) return false;

	var _requirements = _furniturePreset.workerRequirements;

	for (var i = 0; i < array_length(_requirements); i++) {
		if (!_requirements[i].verifyWorker(_resident)) return false;
	}

	return true;
}
