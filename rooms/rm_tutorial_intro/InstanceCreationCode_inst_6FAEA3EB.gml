onFadeOut = function () {
	var _dialogue = createNpcDialogue(
		npc_tutorial,
		[
			"Ei! Você acordou!",
			"Rápido, me ajuda!",
			"Eles vão me pegar!"
		]
	);

	instance_create_layer(0, 0, "Controllers", obj_dialogue, {
		target: npc_tutorial,
		dialogue: _dialogue
	});
}