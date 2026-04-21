hover_anim = 0;
menu_offset_x = 0;

function drawQuests() {
	var _questsCount = array_length(activeQuests);

	if (_questsCount == 0) return;

	var _maxTextWidth = 350;
	var _margin = 30;
	var _padding = 12;

	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();

	draw_set_font(fnt_gui_title);
	var _mainTitle = "Missões Ativas [J]";
	var _mainTitleHeight = string_height(_mainTitle);
	
	draw_set_font(fnt_gui_long_text);
	var _totalQuestsHeight = 0;

	for (var i = 0; i < _questsCount; i++) {
		var q = activeQuests[i];
		var step = q.getCurrentStep();
	
		_totalQuestsHeight += string_height_ext(q.name, -1, _maxTextWidth) + 5;
	
		if (!is_undefined(step)) {
			var text = step.description;
			
			text += addCounterText(step); 
		
			var _stepScale = 0.7;
			var _scaledMaxWidth = _maxTextWidth / _stepScale; 
		
			_totalQuestsHeight += (string_height_ext(text, -1, _scaledMaxWidth) * _stepScale) + 15;
		}
	}

	var _totalHeight = _mainTitleHeight + 15 + _totalQuestsHeight;

	// Margem do topo fixada em 15px
	var _initialY = 50;

	// Invertida a direção da animação de sumir (agora vai para a esquerda, usando valor negativo)
	var _targetOffset = global.activeMenu ? -(_maxTextWidth + _margin + _padding * 2 + 50) : 0;
	menu_offset_x = lerp(menu_offset_x, _targetOffset, 0.1);

	if (global.activeMenu && abs(menu_offset_x - _targetOffset) < 2) {
		return;
	}

	var _baseTextX = _margin + menu_offset_x; 

	draw_set_valign(fa_top);
	draw_set_halign(fa_left);

	var _rectX1 = _baseTextX - _padding;
	var _rectY1 = _initialY - _padding;
	var _rectX2 = _baseTextX + _maxTextWidth + _padding;
	var _rectY2 = _initialY + _totalHeight + _padding;

	var _isHovering = mouseIsOnRectangle(_rectX1, _rectY1, _rectX2, _rectY2);
	hover_anim = lerp(hover_anim, _isHovering ? 1 : 0, 0.15);

	// Invertida a animação de hover para ir para a direita (afastando da borda)
	var _textX = _baseTextX + (hover_anim * 6);

	var _drawRectX1 = _textX - _padding;
	var _drawRectX2 = _textX + _maxTextWidth + _padding;

	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_sprite_stretched(spr_bar, 0, _drawRectX1, _rectY1, _drawRectX2 - _drawRectX1, _rectY2 - _rectY1);
	
	draw_set_alpha(1);
	draw_set_color(c_white);

	var _y = _initialY;
	
	draw_set_font(fnt_gui_title);
	drawTextExtShadow(_textX, _y, _mainTitle, -1, _maxTextWidth, 1, 3, 1);
	draw_text_ext(_textX, _y, _mainTitle, -1, _maxTextWidth);
	
	_y += _mainTitleHeight + 15; 

	draw_set_font(fnt_gui_long_text);
	
	for (var i = 0; i < _questsCount; i++) {
		var q = activeQuests[i];
		var step = q.getCurrentStep();
		
		drawTextExtShadow(_textX, _y, q.name, -1, _maxTextWidth, 1, 3, 1);
		draw_set_color(#FFB86C);
		draw_text_ext(_textX, _y, q.name, -1, _maxTextWidth);
		draw_set_color(c_white);
		_y += string_height_ext(q.name, -1, _maxTextWidth) + 5;
		
		if (!is_undefined(step)) {
			var text = step.description;
			
			text += addCounterText(step)
			text = string(q.currentStepIndex + 1) + ") " + text;
			var _stepScale = 0.7;
			var _scaledMaxWidth = _maxTextWidth / _stepScale; 
			
			drawTextExtShadow(_textX, _y, text, -1, _scaledMaxWidth, 1, 2, _stepScale);
			draw_set_color(#FFDC64);
			draw_text_ext_transformed(_textX, _y, text, -1, _scaledMaxWidth, _stepScale, _stepScale, 0);
			draw_set_color(c_white);
			
			_y += (string_height_ext(text, -1, _scaledMaxWidth) * _stepScale) + 15;
		}
	}

	draw_set_font(fnt_gui_default);
}

function addCounterText(step) {
	if (array_length(step.objectives) > 0) {
		var text = "";
		
		for (var i = 0; i < array_length(step.objectives); i++) {
			var obj = step.objectives[i];

			var _itemData = global.items[obj.type][obj.itemId];

			text += "\n-  " + _itemData.name + " (" 
				+ string(obj.count) + "/" + string(obj.target) + ")";
		}

		return text;
	}

	if (variable_struct_exists(step, "killTarget")) {
		return " (" + string(step.killCount) + "/" + string(step.killTarget) + ")";
	}
	
	if (variable_struct_exists(step, "collectCount")) {
		return " (" + string(step.collectCount) + "/" + string(step.collectTarget) + ")";
	}
	
	return "";
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
	
	array_push(completedQuests, _quest);
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
	var _quest = new Quest("test", "Killing in the name of Love");

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
	var _quest = new Quest("craft_axe", "Faça um Machado");

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

{
	var _quest = getCreateAxeQuest();
	addQuest(_quest);
	startQuest(_quest);
}

function getCreateCampfireQuest() {
	var _quest = new Quest("create_campfire", "Crie uma fogueira");
	
	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});

	var _step = new QuestStep("Colete os itens necesários");

	_step.objectives = [
		{ itemId: trashItems.wood_log, type: itemType.trash, count: 0, target: 6 },
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 4 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 3 },
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
	
	var _reward = new QuestReward(15);
	array_push(_reward.items, { itemId: consumableItems.watter_bottle, itemType: itemType.consumables}, {itemId: consumableItems.canned_pineapple, itemType: itemType.consumables});
	
	_quest.setReward(_reward);
	
	return _quest;
}