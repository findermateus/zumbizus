function Dialogue(_texts, _npc, _textSpeed = .7) constructor {
    texts     = _texts;
    npc       = _npc;
    textSpeed = _textSpeed;
    onEnd     = function() {};
}

function DialogueText(_text, _isPlayer) constructor {
    text     = _text;
    isPlayer = _isPlayer;
}

function DialogueParticipant(_name, _gender, _skinColor, _hairColor, _hairId, _outfitId, _helmetId, _bagId) constructor {
    name = _name;
    gender = _gender;
    skinColor = _skinColor;
    hairColor = _hairColor;
    hairId = _hairId;
    outfitId = _outfitId;
    helmetId = _helmetId;
	bagId = _bagId
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
	
	var _participant = new DialogueParticipant(
		_npc.name,
		_npc.genderId,
		_npc.skinColor,
		_npc.hairColor,
		_npc.hairOption,
		_npc.outfitId,
		_npc.helmetId,
		_npc.bagId
	);

	var _dialogue = new Dialogue(
		_dialogueTexts,
		_participant
	);

	_dialogue.onEnd = _onEnd;

	return _dialogue;
}