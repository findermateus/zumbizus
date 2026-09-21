containerInitializer = function() {
	obj_waypoint.disabled = true;
	
	var _npc = instance_create_layer(880, 320, "Instances", obj_npc, {
		presetId: "container_survivor"
	});
	
	with (_npc) {
		hasSpoken = false;
		
		greetingOptions = [
			"Eu te sigo..."	
		];
		
		getCurrentDialogue = function() {
			if (hasSpoken) {
				return noone;
			}
		
			var _dialogue = new Dialogue(
				[
					new DialogueText("Fica longe! Dá mais um passo e eu acabo com você!", false),
					new DialogueText("Calma, eu não vou te machucar. Você tá mordida?", true),
					new DialogueText("Você é um deles? Ele te mandou pra terminar o serviço? Onde ele tá... onde tá o desgraçado da jaqueta de couro?!", false),
					new DialogueText("Jaqueta de couro? Do que você tá falando?", true),
					new DialogueText("O cara da jaqueta de couro! Ele fingiu que ia me ajudar, e quando eu virei as costas, ele tentou me matar pra roubar minha mochila. Se não fosse aqueles mortos-vivos invadirem a sala, eu estaria morta. Eu corri até aqui e me tranquei.", false),
					new DialogueText("Hospital... Jaqueta de couro... Ele tava escondido atrás de umas bancadas?", true),
					new DialogueText("Então você sabe, você está com ele?", false),
					new DialogueText("Sim...", true),
					new DialogueText("Ele usou os zumbis que te atacaram como distração. E depois me usou pra limpar o caminho pra ele sair.", true),
					new DialogueText("O nome dele é Hank. Ele me trouxe pra uma base aqui perto e me mandou limpar esse lixão.", true),
					new DialogueText("Ele te mandou pra cá pra morrer. Ou pra limpar a área pra ele vir saquear depois. Ele vai pegar o que é seu.", false),
					new DialogueText("Consegue andar? Vamos voltar pra base. Quero ter uma conversa com ele", true)
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
			
				obj_waypoint.disabled = false;
			
				setDestiny(obj_waypoint.x, obj_waypoint.y, function () {
					currentState = fadeOutState;
				});
			}
		
			return _dialogue;
		}
	}
}

roomId = "container_survivor";