function Dialogue(_texts, _participants, _textSpeed = .7) constructor {
	texts = _texts;
	participants = _participants;
	textSpeed = _textSpeed;
}

function DialogueText(_text, _participantIndex) constructor{
	text = _text;
	participantIndex = _participantIndex;
}

function DialogueParticipant(_name, _gender, _skinColor, _hairColor, _hairId, _armor, _helmet) constructor{
	name = _name;
	gender = _gender;
	skinColor = _skinColor;
	hairColor = _hairColor;
	hairId = _hairId;
	armor = _armor;
	helmet = _helmet;
}