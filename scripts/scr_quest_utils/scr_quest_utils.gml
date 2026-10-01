function createCollectItemsStep(_id, _description, _objectives) {
	var _step = new QuestStep(_id, _description);

	_step.objectives = _objectives;

	_step.onStart = method(_step, function () {
		var _hasAll = true;

		for (var i = 0; i < array_length(self.objectives); i++) {
			var _objective = self.objectives[i];

			var _currentQuantity = getItemQuantityInInventory(
				global.inventory,
				_objective.itemId,
				_objective.type
			);

			self.objectives[i].count = _currentQuantity;

			if (_currentQuantity < _objective.target) {
				_hasAll = false;
			}
		}

		if (_hasAll) {
			self.quest.completeCurrentStep();
		}
	});

	_step.onEvent = method(_step, function (_event, _data) {
		if (_event != QuestEvent.ItemCollected) return;

		for (var i = 0; i < array_length(self.objectives); i++) {
			var _objective = self.objectives[i];

			if (
				_data.itemId == _objective.itemId
				&& _data.itemType == _objective.type
			) {
				_objective.count += _data.quantity;

				if (_objective.count > _objective.target) {
					_objective.count = _objective.target;
				}
			}
		}

		var _allDone = true;

		for (var i = 0; i < array_length(self.objectives); i++) {
			if (self.objectives[i].count < self.objectives[i].target) {
				_allDone = false;
				break;
			}
		}

		if (_allDone) {
			self.quest.completeCurrentStep();
		}
	});

	return _step;
}

function createDefeatEnemiesStep(_id, _description, _enemyType, _killTarget) {
	var _step = new QuestStep(_id, _description);

	_step.enemyType = _enemyType;
	_step.killTarget = _killTarget;
	_step.killCount = 0;

	_step.onEvent = method(_step, function (_event, _data) {
		if (_event != QuestEvent.EnemyKilled) return;
		if (
			_data.enemyType == self.enemyType 
			|| object_is_ancestor(_data.enemyType, self.enemyType)
		) {
			self.killCount += 1;

			if (self.killCount >= self.killTarget) {
				self.killCount = self.killTarget;
				self.quest.completeCurrentStep();
			}
		}
	});

	return _step;
}

function createReturnToBaseStep() {
	var _step = new QuestStep("return_to_base", "Volte para a base");

	_step.area = rm_player_base;
	
	_step.onStart = method(_step, function () {
		if (room == self.area) {
			self.quest.completeCurrentStep();
		}
	});

	_step.onEvent = method(_step, function(_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	});
	
	return _step;
}

function spawnMissingQuestItems(_objectives, _margin = 64) {
	for (var i = 0; i < array_length(_objectives); i++) {
		var _objective = _objectives[i];

		var _missing = _objective.target - getItemQuantityInInventory(
			global.inventory,
			_objective.itemId,
			_objective.type
		);

		with (obj_item) {
			if (is_undefined(item)) continue;
			if (item.type != _objective.type || item.itemId != _objective.itemId) continue;

			_missing -= item.quantity;
		}

		if (_missing <= 0) continue;

		var _itemRef = global.items[_objective.type][_objective.itemId];

		repeat (_missing) {
			var _xx = irandom_range(_margin, room_width - _margin);
			var _yy = irandom_range(_margin, room_height - _margin);

			var _inst = instance_create_layer(_xx, _yy, "Items", obj_item);
			_inst.item = constructItem(_objective.type, _itemRef);
		}
	}
}
