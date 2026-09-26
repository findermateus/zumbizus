onFadeOut = function () {
	var _dialogue = createPlayerThoughtDialogue([
		"Caramba...",
		"Que ventinho",
		"Estou me sentindo meio... [wave]exposto[/wave]",
		"Talvez devesse achar algo para vestir"
	]);
		
	instance_create_layer(0, 0, "Controllers", obj_dialogue, {
		target: noone,
		dialogue: _dialogue
	});
}