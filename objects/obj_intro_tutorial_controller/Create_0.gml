introState = "fade_from_black";

fadeAlpha = 1;
fadeTimer = 0;
fadeDuration = game_get_speed(gamespeed_fps) * 4;

dialogueStarted = false;

obj_player.currentState = playerDialogueState;

openMenu(Menus.Cutscene);

function startIntroPlayerDialogue() {
	var _dialogue = createPlayerThoughtDialogue([
		"Minha cabeça...",
		"Onde... onde eu estou?",
		"Eu não lembro de nada.",
		"Preciso encontrar um lugar seguro...",
		"Mas antes!",
		"Que fome e sede...",
		"Vou ver se tem algo naquela lixeira..."
	], method(id, function () {
		var _quest = getFindSafePlaceQuest();

		with (obj_quest_manager) {
			addQuest(_quest);
			startQuest(_quest);
		}

		introState = "running";
		
		global.player.currentHunger = global.player.defaultTotalHunger * .2;
		global.player.currentThirst = global.player.defaultTotalThirst * .2;
		
		obj_camera.setDefaultValues();
		
		createTextInputTutorial("Use WASD para andar", [ord("W"), ord("A"), ord("S"), ord("D")]);
	}));

	instance_create_layer(0, 0, "Controllers", obj_dialogue, {
		target: noone,
		dialogue: _dialogue
	});
}