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

function DialogueParticipant(_name, _gender, _skinColor, _hairColor, _hairId, _armor, _helmet) constructor {
    name      = _name;
    gender    = _gender;
    skinColor = _skinColor;
    hairColor = _hairColor;
    hairId    = _hairId;
    armor     = _armor;
    helmet    = _helmet;
}