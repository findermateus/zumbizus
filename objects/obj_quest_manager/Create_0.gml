hover_anim = 0;
menu_offset_x = 0;

function drawQuests() {
	var _questsCount = array_length(activeQuests);
	if (_questsCount == 0) return;

	var _maxTextWidth = 350;
	var _margin = 30;
	var _padding = 12;
	var _initialY = 50;

	var _totalHeight = drawMainTitle(0, 0, _maxTextWidth, false);
	_totalHeight += 15;
	
	for (var i = 0; i < _questsCount; i++) {
		var q = activeQuests[i];
		_totalHeight += drawQuestTitle(0, 0, _maxTextWidth, q, false);
		
		var step = q.getCurrentStep();
		if (!is_undefined(step)) {
			_totalHeight += drawQuestStep(0, 0, _maxTextWidth, step, q.currentStepIndex, false);
		}
	}

	var _targetOffset = isMenuOpen() ? -(_maxTextWidth + _margin + _padding * 2 + 50) : 0;
	menu_offset_x = lerp(menu_offset_x, _targetOffset, 0.1);

	if (isMenuOpen() && abs(menu_offset_x - _targetOffset) < 2) return;

	var _baseTextX = _margin + menu_offset_x; 
	var _rectX1 = _baseTextX - _padding;
	var _rectY1 = _initialY - _padding;
	var _rectX2 = _baseTextX + _maxTextWidth + _padding;
	var _rectY2 = _initialY + _totalHeight + _padding;

	var _isHovering = mouseIsOnRectangle(_rectX1, _rectY1, _rectX2, _rectY2);
	hover_anim = lerp(hover_anim, _isHovering ? 1 : 0, 0.15);
	var _textX = _baseTextX + (hover_anim * 6);

	var _drawRectX1 = _textX - _padding;
	var _drawRectX2 = _textX + _maxTextWidth + _padding;

	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_sprite_stretched(spr_bar, 0, _drawRectX1, _rectY1, _drawRectX2 - _drawRectX1, _rectY2 - _rectY1);

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_valign(fa_top);
	draw_set_halign(fa_left);

	var _y = _initialY;
	_y += drawMainTitle(_textX, _y, _maxTextWidth, true);
	_y += 15; 
	
	for (var i = 0; i < _questsCount; i++) {
		var q = activeQuests[i];
		_y += drawQuestTitle(_textX, _y, _maxTextWidth, q, true);
		
		var step = q.getCurrentStep();
		if (!is_undefined(step)) {
			_y += drawQuestStep(_textX, _y, _maxTextWidth, step, q.currentStepIndex, true);
		}
	}

	draw_set_font(fnt_gui_default);
}

function drawMainTitle(_x, _y, _maxWidth, _isDraw) {
	draw_set_font(fnt_gui_title);
	var _text = "Missões Ativas [J]";
	var _h = string_height(_text);
	
	if (_isDraw) {
		drawTextExtShadow(_x, _y, _text, -1, _maxWidth, 1, 3, 1);
		draw_text_ext(_x, _y, _text, -1, _maxWidth);
	}
	
	return _h;
}

function drawQuestTitle(_x, _y, _maxWidth, _quest, _isDraw) {
	draw_set_font(fnt_gui_long_text);
	var _h = string_height_ext(_quest.name, -1, _maxWidth);
	
	if (_isDraw) {
		drawTextExtShadow(_x, _y, _quest.name, -1, _maxWidth, 1, 3, 1);
		draw_set_color(#FFB86C);
		draw_text_ext(_x, _y, _quest.name, -1, _maxWidth);
		draw_set_color(c_white);
	}
	
	return _h + 5;
}

function drawQuestStep(_x, _y, _maxWidth, _step, _stepIndex, _isDraw) {
	var _stepScale = 0.7;
	var _scaledMaxWidth = _maxWidth / _stepScale; 
	var _consumedHeight = 0;
	
	var _text = string(_stepIndex + 1) + ") " + _step.description;
	var _h = (string_height_ext(_text, -1, _scaledMaxWidth) * _stepScale);
	
	if (_isDraw) {
		drawTextExtShadow(_x, _y, _text, -1, _scaledMaxWidth, 1, 2, _stepScale);
		draw_set_color(#FFDC64);
		draw_text_ext_transformed(_x, _y, _text, -1, _scaledMaxWidth, _stepScale, _stepScale, 0);
		draw_set_color(c_white);
	}
	_consumedHeight += _h;
	
	_consumedHeight += drawStepObjectives(_x, _y + _consumedHeight, _scaledMaxWidth, _stepScale, _step, _isDraw);
	
	return _consumedHeight + 15;
}

function drawStepObjectives(_x, _y, _scaledMaxWidth, _scale, _step, _isDraw) {
	var _h = 0;
	
	if (array_length(_step.objectives) > 0) {
		for (var i = 0; i < array_length(_step.objectives); i++) {
			var obj = _step.objectives[i];
			var _itemData = global.items[obj.type][obj.itemId];
			
			var _text = "-  " + _itemData.name + " (" + string(obj.count) + "/" + string(obj.target) + ")";
			var _itemH = (string_height_ext(_text, -1, _scaledMaxWidth) * _scale);
			
			if (_isDraw) {
				drawTextExtShadow(_x, _y + _h, _text, -1, _scaledMaxWidth, 1, 2, _scale);
				draw_set_color(#FFDC64);
				draw_text_ext_transformed(_x, _y + _h, _text, -1, _scaledMaxWidth, _scale, _scale, 0);
				draw_set_color(c_white);
			}
			_h += _itemH;
		}
		return _h;
	}

	var _counterText = "";

	if (variable_struct_exists(_step, "killTarget")) {
		_counterText = " (" + string(_step.killCount) + "/" + string(_step.killTarget) + ")";
	} else if (variable_struct_exists(_step, "collectCount")) {
		_counterText = " (" + string(_step.collectCount) + "/" + string(_step.collectTarget) + ")";
	}
	
	if (_counterText != "") {
		var _itemH = (string_height_ext(_counterText, -1, _scaledMaxWidth) * _scale);
		if (_isDraw) {
			drawTextExtShadow(_x, _y + _h, _counterText, -1, _scaledMaxWidth, 1, 2, _scale);
			draw_set_color(#FFDC64);
			draw_text_ext_transformed(_x, _y + _h, _counterText, -1, _scaledMaxWidth, _scale, _scale, 0);
			draw_set_color(c_white);
		}
		_h += _itemH;
	}
	
	return _h;
}

quests = [];
activeQuests = [];
completedQuests = [];

addQuest = function(_quest) {
	array_push(quests, _quest);
};

startQuest = function(_quest) {
	_quest.start();
	array_push(activeQuests, _quest);
};

completeQuest = function(_quest) {
	_quest.isCompleted = true;

	var index = -1;

	for (var i = 0; i < array_length(activeQuests); i++) {
		if (activeQuests[i] == _quest) {
			index = i;
			break;
		}
	}

	if (index != -1) {
		array_delete(activeQuests, index, 1);
	}
	
	instance_create_layer(0, 0, "Alert", obj_quest_step_completed, {
		textContent: _quest.name,
		isStep: false
	});
	
	array_push(completedQuests, _quest.id);
};

notifyEvent = function(_event, _data) {
	for (var i = 0; i < array_length(activeQuests); i++) {
		var _quest = activeQuests[i];
		
		if (!_quest.isActive || _quest.isCompleted) continue;
		
		var _step = _quest.getCurrentStep();
		
		if (is_undefined(_step)) continue;
		
		var _fn = method(_step, _step.onEvent);
		_fn(_event, _data);
	}
};

{
	var _quest = new Quest(Quests.KillingInTheNameOfLove, "Killing in the name of Love");

	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});

	var _step = new QuestStep("Matar 5 Zumbis");
	_step.killCount = 0;
	_step.killTarget = 5;

	_step.onEvent = method(_step, function(_event, _data) {
		if (_event != QuestEvent.EnemyKilled) return;

		self.killCount++;

		if (self.killCount >= self.killTarget) {
			self.quest.completeCurrentStep();
		}
	});

	_quest.addStep(_step);

	addQuest(_quest);
}

function getCreateAxeQuest() {
	var _quest = new Quest(Quests.BecomeALumberjack, "Se torne um Lenhador");

	_quest.onComplete = method(_quest, function () {
		self.applyReward();
		
		with(obj_quest_manager) {
			var _nextQuest = getCreateCampfireQuest();
			addQuest(_nextQuest);
			startQuest(_nextQuest);
		}
	}); 

	var _step = new QuestStep("Colete os itens necesários");

	_step.objectives = [
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
	];

	_step.onStart = method(_step, function () {
		var _hasAll = true;
		
		for (var i = 0; i < array_length(self.objectives); i ++) {
			var _itemObjective = self.objectives[i];
			var _currentQuantity = getItemQuantityInInventory(global.inventory, _itemObjective.itemId, _itemObjective.type);
			
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
	
	var _secondStep = new QuestStep("Volte para a base");
	_secondStep.area = rm_player_base;
	
	_secondStep.onEvent = method(_secondStep, function(_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_secondStep);

	var _thirdStep = new QuestStep("Faça o machado");
	_thirdStep.itemType = itemType.weapons;
	_thirdStep.itemId = weaponItems.axe;
	
	_thirdStep.onEvent = method(_thirdStep, function (_event, _data) {
		if (_event != QuestEvent.ItemCrafted && _event != QuestEvent.ItemCollected) return;
		
		if (_data.itemType == self.itemType && _data.itemId == self.itemId) {
			self.quest.completeCurrentStep();
		}
	});
	
	_quest.addStep(_thirdStep);
	
	var _reward = new QuestReward(105);
	_quest.setReward(_reward);
	
	return _quest;
}

function getCreateCampfireQuest() {
	var _quest = new Quest(Quests.CraftACampfire, "Descubra o Fogo");
	
	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});

	var _step = new QuestStep("Colete os itens necesários");

	_step.objectives = [
		{ itemId: trashItems.wood_log, type: itemType.trash, count: 0, target: 6 },
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 12 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 8 },
	];

	_step.onStart = method(_step, function () {
		var _hasAll = true;
		
		for (var i = 0; i < array_length(self.objectives); i ++) {
			var _itemObjective = self.objectives[i];
			var _currentQuantity = getItemQuantityInInventory(global.inventory, _itemObjective.itemId, _itemObjective.type);
			
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
	
	var _craftCampfireStep = new QuestStep("Construa a fogueira");
	
	_craftCampfireStep.onEvent = method(_craftCampfireStep, function (_event, _data) {
		if (_event != QuestEvent.FurnitureCrafted) return;
		
		if (_data.furnitureId == global.furnitureIds.campfire) {
			self.quest.completeCurrentStep();
		}
	});
	
	_quest.addStep(_craftCampfireStep);
	
	var _reward = new QuestReward(15);
	array_push(_reward.items, { itemId: consumableItems.watter_bottle, itemType: itemType.consumables}, {itemId: consumableItems.canned_pineapple, itemType: itemType.consumables});
	
	_quest.setReward(_reward);
	
	return _quest;
}

function hasActiveQuest(_questId) {
	for (var i = 0; i < array_length(activeQuests); i++) {
		var _quest = activeQuests[i];
		if (_quest.id == _questId) {
			return true;
		}
	}
	
	return false;
}

function hasCompletedQuest(_questId) {
	for (var i = 0; i < array_length(completedQuests); i++) {
		var _quest = completedQuests[i];
		
		if (_questId == _quest) {
			return true;
		}
	}
	
	return false;
}