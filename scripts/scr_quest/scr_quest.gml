enum QuestEvent {
	EnemyKilled,
	ItemCollected,
	AreaEntered,
	ItemCrafted,
	FurnitureCrafted,
	DialogueEnded,
	DialogueStarted
}

function Quest(_id, _name) constructor {
	id = _id;
	name = _name;
	steps = [];
	reward = undefined;
	
	currentStepIndex = 0;
	isCompleted = false;
	isActive = false;
	
	addStep = function(_step) {
		_step.quest = self;
		array_push(steps, _step);
	};
	
	getCurrentStep = function() {
		return steps[currentStepIndex];
	};
	
	start = function() {
		isActive = true;
	
		if (array_length(steps) > 0) {
			steps[0].onStart();
		}
	};
	
	onComplete = function () {};
	
	completeCurrentStep = function() {
		var step = getCurrentStep();
	
		if (step.isCompleted) return;

		step.isCompleted = true;
		step.onComplete();

		instance_create_layer(0, 0, "Alert", obj_quest_step_completed, {
			textContent: step.description,
			isStep: true
		});

		currentStepIndex++;

		if (currentStepIndex >= array_length(steps)) {
			isCompleted = true;
			onComplete();

			var _data = self;

			with (obj_quest_manager) {
				completeQuest(_data);
			}
			
			return;
		}
	
		getCurrentStep().onStart();
	};
	
	applyReward = function() {
		if (is_undefined(reward)) return;

		var r = reward;

		if (r.xp > 0) {
			xpAdd(r.xp);
		}

		for (var i = 0; i < array_length(r.items); i++) {
			var item = r.items[i];
			var _itemConfig = global.items[item.itemType][item.itemId];
			var _buildedItem = constructItem(item.itemType, _itemConfig);
			
			var _quantity = variable_struct_exists(item, "quantity") ? item.quantity : 1;
			
			_buildedItem.quantity = _quantity;
			
			var _result = addItemToGrid(global.inventory, _buildedItem);
			
			if (_result == true) {
				createIndicatorForQuestItem(_buildedItem, _quantity);
				
				continue;
			}
			
			show_message("não connseguiu por tudo no inventory: " + _itemConfig.name);
		}
	};
	
	setReward = function(_reward) {
		reward = _reward;
	}
}

function QuestStep(_description) constructor {
	quest = undefined;
	description = _description;
	isCompleted = false;
	onStart = function () {};
	onComplete = function () {};
	onEvent = function(_event, _data) {};
	objectives = [];
}

function QuestReward(_xp) constructor {
	xp = _xp;
	items = []; // {itemId, itemType, quantity}
}