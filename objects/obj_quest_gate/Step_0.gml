if (dialogueCooldown > 0) {
	dialogueCooldown--;
}

var _state = getGateState();

if (_state == QuestGateState.Unlocked) {
	if (destroyWhenUnlocked) {
		instance_destroy();
	}

	exit;
}

if (_state == QuestGateState.Waiting) {
	if (blockWhileWaiting) {
		event_inherited();
	}

	exit;
}

event_inherited();

var _isNearGate = isPlayerNearGate();

if (!_isNearGate) {
	wasPlayerNearGate = false;
	exit;
}

if (wasPlayerNearGate) {
	exit;
}

wasPlayerNearGate = true;

showBlockDialogue();