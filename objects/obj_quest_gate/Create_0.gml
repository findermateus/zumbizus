event_inherited();

enum QuestGateState {
	Waiting,
	Blocked,
	Unlocked
}

visible = false;

questId = Quests.FindSafePlace;
requiredStepId = "wear_clothes";

dialogueTexts = [
	"Não posso sair assim...",
	"Estou exposto demais.",
	"Preciso encontrar algo para vestir antes de continuar."
];

dialogueCooldown = 0;
dialogueCooldownTime = game_get_speed(gamespeed_fps) * 2;

dialogueIsOpen = false;
wasPlayerNearGate = false;

checkPadding = 2;

destroyWhenUnlocked = true;
blockWhileWaiting = true;

dialogueAlreadyShown = false;
showDialogueOnlyOnce = false;

function getGateState() {
	if (!instance_exists(obj_quest_manager)) {
		return QuestGateState.Waiting;
	}

	var _questManager = instance_find(obj_quest_manager, 0);
	var _quest = _questManager.getQuest(questId);

	if (is_undefined(_quest)) {
		return QuestGateState.Waiting;
	}

	var _step = _questManager.getQuestStepById(_quest, requiredStepId);

	if (is_undefined(_step)) {
		return QuestGateState.Waiting;
	}

	if (_step.isCompleted) {
		return QuestGateState.Unlocked;
	}

	return QuestGateState.Blocked;
}

function shouldBlockPlayer() {
	var _state = getGateState();

	if (_state == QuestGateState.Unlocked) {
		return false;
	}

	if (_state == QuestGateState.Waiting) {
		return blockWhileWaiting;
	}

	return true;
}

function isPlayerNearGate() {
	return collision_rectangle(
		bbox_left - checkPadding,
		bbox_top - checkPadding,
		bbox_right + checkPadding,
		bbox_bottom + checkPadding,
		obj_player,
		false,
		true
	) != noone;
}

function showBlockDialogue() {
	if (dialogueCooldown > 0) return;
	if (dialogueIsOpen) return;
	if (instance_exists(obj_dialogue)) return;

	if (showDialogueOnlyOnce && dialogueAlreadyShown) {
		return;
	}

	dialogueAlreadyShown = true;
	dialogueIsOpen = true;

	var _dialogue = createPlayerThoughtDialogue(
		dialogueTexts,
		method(id, function() {
			dialogueIsOpen = false;
			dialogueCooldown = dialogueCooldownTime;
		})
	);

	instance_create_layer(0, 0, "Controllers", obj_dialogue, {
		target: noone,
		dialogue: _dialogue
	});
}