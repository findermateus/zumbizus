function Dialogue(_texts, _npc, _textSpeed = .7) constructor {
    texts     = _texts;
    textSpeed = _textSpeed;
    onEnd     = function() {};

	if (is_array(_npc)) {
		npcs = _npc;
	} else if (is_struct(_npc)) {
		npcs = [_npc];
	} else {
		npcs = [];
	}

	npc = array_length(npcs) > 0 ? npcs[0] : noone;
}

function DialogueText(_text, _isPlayer, _npcIndex = 0) constructor {
    text     = _text;
    isPlayer = _isPlayer;
	npcIndex = _npcIndex;
}

function DialogueParticipant(_name, _gender, _skinColor, _hairColor, _hairId, _eyeId, _outfitId, _helmetId, _bagId, _instance = noone) constructor {
    name = _name;
    gender = _gender;
    skinColor = _skinColor;
    hairColor = _hairColor;
    hairId = _hairId;
	eyeId = _eyeId;
    outfitId = _outfitId;
    helmetId = _helmetId;
	bagId = _bagId;
	instance = _instance;
}

function createDialogueParticipantFromNpc(_npc) {
	return new DialogueParticipant(
		_npc.name,
		_npc.genderId,
		_npc.skinColor,
		_npc.hairColor,
		_npc.hairOption,
		_npc.eyeId,
		_npc.outfitId,
		_npc.helmetId,
		_npc.bagId,
		_npc.id
	);
}

function createPlayerThoughtDialogue(_texts, _onEnd = undefined, _textSpeed = .7) {
	var _dialogueTexts = [];

	for (var i = 0; i < array_length(_texts); i++) {
		_dialogueTexts[i] = new DialogueText(_texts[i], true);
	}

	var _dialogue = new Dialogue(_dialogueTexts, noone, _textSpeed);

	if (is_callable(_onEnd)) {
		_dialogue.onEnd = _onEnd;
	}

	return _dialogue;
}

function createNpcDialogue(_npc, _texts, _onEnd = undefined) {
	var _dialogueTexts = [];

	for (var i = 0; i < array_length(_texts); i++) {
		array_push(_dialogueTexts, new DialogueText(_texts[i], false));
	}

	var _dialogue = new Dialogue(
		_dialogueTexts,
		createDialogueParticipantFromNpc(_npc)
	);

	_dialogue.onEnd = _onEnd;

	return _dialogue;
}

/// @param {Array} _npcs  instâncias de NPC participantes
/// @param {Array} _lines array de [speaker, texto]; speaker = -1 para o player ou o índice do NPC em _npcs
function createGroupDialogue(_npcs, _lines, _onEnd = undefined, _textSpeed = .7) {
	var _participants = [];

	for (var i = 0; i < array_length(_npcs); i++) {
		array_push(_participants, createDialogueParticipantFromNpc(_npcs[i]));
	}

	var _dialogueTexts = [];

	for (var i = 0; i < array_length(_lines); i++) {
		var _speaker = _lines[i][0];
		var _isPlayer = _speaker < 0;

		array_push(_dialogueTexts, new DialogueText(_lines[i][1], _isPlayer, _isPlayer ? 0 : _speaker));
	}

	var _dialogue = new Dialogue(_dialogueTexts, _participants, _textSpeed);

	if (is_callable(_onEnd)) {
		_dialogue.onEnd = _onEnd;
	}

	return _dialogue;
}
