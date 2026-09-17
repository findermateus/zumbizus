enum QuestEvent {
	EnemyKilled,
	ItemCollected,
	AreaEntered,
	ItemCrafted,
	FurnitureCrafted,
	DialogueEnded,
	DialogueStarted,
	ItemBought,
	ItemSold,
	ObjectInteracted,
	ItemConsumed,
	ItemEquiped,
	ObjectDestroyed
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
		if (currentStepIndex < 0) return undefined;

		if (currentStepIndex >= array_length(steps)) {
			return undefined;
		}

		return steps[currentStepIndex];
	};
	
	start = function() {
		isActive = true;
		
		onStart();
	
		if (array_length(steps) > 0) {
			steps[0].onStart();
		}
	};
	
	onStart = function() {};
	
	complete = function() {
		isCompleted = true;

		onComplete();

		var _data = self;

		with (obj_quest_manager) {
			completeQuest(_data);
		}
	}
	
	onComplete = function () {};
	
	completeCurrentStep = function() {

		if (isCompleted) return;

		var step = getCurrentStep();

		if (is_undefined(step)) return;

		if (step.isCompleted) return;

		step.isCompleted = true;

		step.onComplete();

		instance_create_layer(0, 0, "Alert", obj_quest_popup, {
			textContent: step.description,
			popupType: QUEST_POPUP_TYPE.STEP_COMPLETED
		});

		currentStepIndex++;

		if (currentStepIndex >= array_length(steps)) {
			complete();
			
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
			
			if (_result != true) {
				createItem(_buildedItem, true);	
			}
			
			createIndicatorForQuestItem(_buildedItem, _quantity);
		}
	};
	
	setReward = function(_reward) {
		reward = _reward;
	}
}

function QuestStep(_id, _description) constructor {
	id = _id;
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
	items = [];
}

enum Quests {
	FindSafePlace,
	BecomeALumberjack,
	CraftACampfire,
	CookMeat,
	ExploreDump
}

enum QUEST_POPUP_TYPE {
    STEP_COMPLETED,
    QUEST_COMPLETED,
    QUEST_ADDED
}

enum POPUP_STATE {
    QUEUED,
    FADE_IN,
    WAIT,
    FADE_OUT
}