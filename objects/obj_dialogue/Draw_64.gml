if (global.pause) exit;

var _guiWidth = display_get_gui_width();
var _guiHeight = display_get_gui_height();

var _participants = dialogue.participants;

for (var i = 0; i < array_length(dialogue.texts); i ++) {
	var _text = dialogue.texts[i];
	var _participantIndex = _text.participantIndex;
	var _pname = _participants[_participantIndex];
	
	draw_text(_guiWidth/2, _guiHeight * .3 + (75 * i), _pname + "- " + _text.text);
}

drawDialogueBox();