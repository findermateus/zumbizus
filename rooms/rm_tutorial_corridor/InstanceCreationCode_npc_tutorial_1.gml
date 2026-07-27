greetingOptions = [
	"Estamos quase lá",
	"Só mais um pouco"
];

hasSpoken = false;

setDestiny(obj_waypoint.x, obj_waypoint.y, function () {
	currentState = iddle;
	
	canTalk = true;

	getCurrentDialogue = function() {
		if (hasSpoken) {
			return noone;
		}
		
		var _dialogue = new Dialogue(
			[
				new DialogueText("Espera um pouco aí, aonde estamos indo?", true),
				new DialogueText("Calma, Você já vai ver...", false),
				new DialogueText("Que?", true),
				new DialogueText("Não, pode ir me falando, eu não estou com a cabeça muito boa e a última coisa que eu preciso agora é cair em uma emboscada", true),
				new DialogueText("Tá, relaxa aí. Enquanto eu explorava essa região achei um pátio abandonado, tinha apenas uma estação de construção, mas me parecia um lugar seguro...", false),
				new DialogueText("E? Depois de chegar lá, o que fazemos?", true),
				new DialogueText("Calma...", false),
				new DialogueText("Chegando lá pensamos nisso", false)
			],
			new DialogueParticipant(
				name,
				genderId,
				skinColor,
				hairColor,
				hairOption,
				eyeId,
				outfitId,
				helmetId,
				bagId
			)
		);
		
		_dialogue.onEnd = function () {
			hasSpoken = true;
		}
		
		return _dialogue;
	}
});