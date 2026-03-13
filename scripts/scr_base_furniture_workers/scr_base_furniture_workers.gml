
function setWorkerData(_objectId, _furnitureId, _workerId, _slot) {
	var _worker = getWorkerData(_workerId);
	if (_worker == false) {
		global.workingNpcs[_workerId] = {
			furnitureId: _furnitureId,
			objectId: _objectId,
			slot: _slot
		};
	}
}

function cleanWorkerData(_workerId) {
	var _worker = getWorkerData(_workerId);
	if (_worker == false) return;
	
	var _furnitureData = getFurnitureData(_worker.furnitureId, _worker.objectId);
	if (_furnitureData != undefined && is_array(_furnitureData.workers)) {
		_furnitureData.workers[_worker.slot] = -1;
	}
	
	global.workingNpcs[_workerId] = false;
}

function getWorkerData(_workerId) {
	if (array_length(global.workingNpcs) <= _workerId) {
		return false;
	}
	
	var _worker = global.workingNpcs[_workerId];
	
	return is_struct(_worker) ? _worker : false;
}

function getFurnitureWorkers(_furnitureId, _objectId) {
	var _furniturePreset = global.productiveFurnitures[_furnitureId];
	var _return = [];
	
	for (var i = 0; i < _furniturePreset.workerQuantity; i++) {
		_return[i] = -1;
	}
	
	var _furnitureData = getFurnitureData(_furnitureId, _objectId);
	if (_furnitureData == undefined) return _return;
	
	var _alreadySetWorkersLength = array_length(_furnitureData.workers);
	var _returnLength = array_length(_return);
	
	if (_returnLength == _alreadySetWorkersLength) {
		return _furnitureData.workers;
	}
	
	for (var i = 0; i < _returnLength; i++) {
		if (!arrayKeyExists(_furnitureData.workers, i)) {
			_furnitureData.workers[i] = _return[i];
		}
	}
	
	return _furnitureData.workers;
}

function removeWorkerFromFurnitureBySlot(_furnitureId, _objectId, _workerSlot) {
	var _furnitureData = getFurnitureData(_furnitureId, _objectId);
	if (_furnitureData == undefined) return -1;
	
	cleanFurnitureWorkersData(_furnitureId, _objectId);
	
	var _worker = _furnitureData.workers[_workerSlot];
	_furnitureData.workers[_workerSlot] = -1;
	
	if (_worker != -1) {
		cleanWorkerData(_worker.id);
	}
	
	return _worker;
}

function addWorkerToFurniture(_furnitureId, _objectId, _workerSlot, _workerId, _workerLevel = undefined) {
	var _furniturePreset = global.productiveFurnitures[_furnitureId];
	var _furnitureData = getFurnitureData(_furnitureId, _objectId);
	if (_furnitureData == undefined) return -1;
	
	if (_workerLevel == undefined) {
		var _npc = global.npcList[_workerId];
		var _furnitureAttribute = _furniturePreset.attribute;
		_workerLevel = _npc.attributes[_furnitureAttribute].level;
	}
	
	var _worker = new Worker(_workerId);
	
	cleanFurnitureWorkersData(_furnitureId, _objectId);
	
	// remove o worker de onde ele já estava
	cleanWorkerData(_workerId);
	
	var _oldSlotWorker = _furnitureData.workers[_workerSlot];
	if (_oldSlotWorker != -1) {
		cleanWorkerData(_oldSlotWorker.id);
	}
	
	_furnitureData.workers[_workerSlot] = _worker;
	setWorkerData(_objectId, _furnitureId, _workerId, _workerSlot);
	
	return _oldSlotWorker;
}

/// @method cleanFurnitureWorkersData(id da mobilia, id do objeto) serve para carregar os arrays impedindo erros
function cleanFurnitureWorkersData(_furnitureId, _objectId) {
	var _furniturePreset = global.productiveFurnitures[_furnitureId];
	var _furnitureData = getFurnitureData(_furnitureId, _objectId);
	
	if (_furnitureData == undefined) return;
	
	if (!is_array(_furnitureData.workers)) {
		_furnitureData.workers = [];
	}
	
	for (var i = 0; i < _furniturePreset.workerQuantity; i++) {
		if (!arrayKeyExists(_furnitureData.workers, i)) {
			_furnitureData.workers[i] = -1;
		}
	}
}