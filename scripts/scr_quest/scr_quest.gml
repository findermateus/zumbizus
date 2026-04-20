enum QuestEvent {
	EnemyKilled,
	ItemCollected,
	AreaEntered,
	ItemCrafted
}

function Quest(_id, _name) constructor {
	id = _id;
	name = _name;
	steps = [];
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
}

function QuestStep(_description) constructor {
	quest = undefined;
	description = _description;
	isCompleted = false;
	onStart = function () {};
	onComplete = function () {};
	onEvent = function(_event, _data) {};
}