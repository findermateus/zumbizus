event_inherited();

textToDraw = "Remover";

questTag = "intro_door_blockage";

isRemoving = false;
removeAlpha = 1;
removeSpeed = 0.03;

function canRemoveBlockage() {
	var _quest = obj_quest_manager.getQuest(Quests.FindSafePlace);

	if (is_undefined(_quest)) return false;
	if (!_quest.isActive) return false;

	var _step = _quest.getCurrentStep();

	if (is_undefined(_step)) return false;

	return _step.id == "clear_exit_blockage";
}

function showWeakDialogue() {
	var _dialogue = createPlayerThoughtDialogue([
		"Está bloqueado...",
		"Eu ainda estou fraco demais para tirar isso daqui.",
		"Preciso comer e beber alguma coisa antes."
	]);

	instance_create_layer(0, 0, "Controllers", obj_dialogue, {
		target: noone,
		dialogue: _dialogue
	});
}

function removeBlockage() {
	if (isRemoving) return;

	isRemoving = true;

	audio_play_sound(snd_hit_tree1, 0, false);

	obj_quest_manager.notifyEvent(QuestEvent.ObjectInteracted, {
		tag: questTag,
		object: id
	});
}