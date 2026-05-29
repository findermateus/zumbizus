function getCreateCampfireQuest() {
	var _quest = new Quest(Quests.CraftACampfire, "Descubra o Fogo");
	
	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});

	var _step = new QuestStep("gather_resources", "Colete os itens necesários");

	_step.objectives = [
		{ itemId: trashItems.wood_log, type: itemType.trash, count: 0, target: 6 },
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 12 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 8 },
	];

	_step.onStart = method(_step, function () {
		var _hasAll = true;

		for (var i = 0; i < array_length(self.objectives); i++) {
			var _itemObjective = self.objectives[i];

			var _currentQuantity = getItemQuantityInInventory(
				global.inventory,
				_itemObjective.itemId,
				_itemObjective.type
			);

			self.objectives[i].count = _currentQuantity;

			if (_currentQuantity < _itemObjective.target) {
				_hasAll = false;
			}
		}

		if (_hasAll) {
			self.quest.completeCurrentStep();
		}
	});

	_step.onEvent = method(_step, function(_event, _data) {
		if (_event != QuestEvent.ItemCollected) return;

		for (var i = 0; i < array_length(self.objectives); i++) {
			var obj = self.objectives[i];

			if (_data.itemId == obj.itemId) {
				obj.count += _data.quantity;

				if (obj.count > obj.target) {
					obj.count = obj.target;
				}
			}
		}

		var allDone = true;

		for (var i = 0; i < array_length(self.objectives); i++) {
			if (self.objectives[i].count < self.objectives[i].target) {
				allDone = false;
				break;
			}
		}

		if (allDone) {
			self.quest.completeCurrentStep();
		}
	});

	_quest.addStep(_step);

	var _craftCampfireStep = new QuestStep("craft_campfire", "Construa a fogueira");

	_craftCampfireStep.onEvent = method(_craftCampfireStep, function (_event, _data) {
		if (_event != QuestEvent.FurnitureCrafted) return;

		if (_data.furnitureId == global.furnitureIds.campfire) {
			self.quest.completeCurrentStep();
		}
	});

	_quest.addStep(_craftCampfireStep);

	var _reward = new QuestReward(15);

	array_push(
		_reward.items,
		{
			itemId: consumableItems.watter_bottle,
			itemType: itemType.consumables
		},
		{
			itemId: consumableItems.canned_pineapple,
			itemType: itemType.consumables
		}
	);

	_quest.setReward(_reward);

	return _quest;
}

function getCreateAxeQuest(_npc) {
	var _quest = new Quest(Quests.BecomeALumberjack, "Se torne um Lenhador");

	_quest.onComplete = method(_quest, function () {
		self.applyReward();

		var _nextQuest = getCreateCampfireQuest();

		with(obj_quest_manager) {
			addQuest(_nextQuest);
			startQuest(_nextQuest);
		}
	}); 

	var _step = new QuestStep("gather_resources", "Colete os itens necesários");

	_step.objectives = [
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
	];

	_step.onStart = method(_step, function () {
		var _hasAll = true;
		
		for (var i = 0; i < array_length(self.objectives); i ++) {
			var _itemObjective = self.objectives[i];

			var _currentQuantity = getItemQuantityInInventory(
				global.inventory,
				_itemObjective.itemId,
				_itemObjective.type
			);
			
			self.objectives[i].count = _currentQuantity;
			
			if (_currentQuantity < _itemObjective.target) {
				_hasAll = false;	
			}
		}
		
		if (_hasAll) {
			self.quest.completeCurrentStep();
		}
	});

	_step.onEvent = method(_step, function(_event, _data) {
		if (_event != QuestEvent.ItemCollected) return;

		for (var i = 0; i < array_length(self.objectives); i++) {
			var obj = self.objectives[i];

			if (_data.itemId == obj.itemId && _data.itemType == obj.type) {
				obj.count += _data.quantity;

				if (obj.count > obj.target) {
					obj.count = obj.target;
				}
			}
		}

		var allDone = true;

		for (var i = 0; i < array_length(self.objectives); i++) {
			if (self.objectives[i].count < self.objectives[i].target) {
				allDone = false;
				break;
			}
		}

		if (allDone) {
			self.quest.completeCurrentStep();
		}
	});

	_quest.addStep(_step);

	var _secondStep = new QuestStep("return_to_base", "Volte para a base");

	_secondStep.area = rm_player_base;
	
	_secondStep.onStart = method(_secondStep, function () {
		if (room == self.area) {
			self.quest.completeCurrentStep();
		}
	});

	_secondStep.onEvent = method(_secondStep, function(_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_secondStep);

	var _thirdStep = new QuestStep("craft_axe", "Faça o machado");

	_thirdStep.itemType = itemType.weapons;
	_thirdStep.itemId = weaponItems.axe;
	
	_thirdStep.onEvent = method(_thirdStep, function (_event, _data) {
		if (_event != QuestEvent.ItemCrafted && _event != QuestEvent.ItemCollected) return;
		
		if (_data.itemType == self.itemType && _data.itemId == self.itemId) {
			self.quest.completeCurrentStep();
		}
	});
	
	_quest.addStep(_thirdStep);

	var _talkStep = new QuestStep("return_to_survivor", "Fale com o sobrevivente");

	_talkStep.targetNpc = _npc;

	_talkStep.onEvent = method(_talkStep, function (_event, _data) {
		if (_event != QuestEvent.DialogueEnded) return;

		if (_data.npc != self.targetNpc) return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_talkStep);

	var _reward = new QuestReward(105);

	_quest.setReward(_reward);
	
	return _quest;
}