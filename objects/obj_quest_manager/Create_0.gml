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