getCurrentDialogue = function() {	
	if (
		!obj_quest_manager.hasActiveQuest(Quests.BecomeALumberjack)
		&&
		!obj_quest_manager.hasCompletedQuest(Quests.BecomeALumberjack)
	) {
		var _dialogue = new Dialogue(
		[
		    new DialogueText("Finalmente... chegamos.", false),
			new DialogueText("Pelo menos esse lugar parece seguro.", false),
			new DialogueText("Mas ainda não temos muita coisa para trabalhar.", false),
			new DialogueText("Tem alguns gravetos e pedras espalhados por aqui.", false),
			new DialogueText("Podemos usar esses materiais para fazer um machado.", false),
			new DialogueText("Depois, vamos até a floresta buscar madeira.", false),
			new DialogueText("Então primeiro eu procuro os gravetos e as pedras?", true),
			new DialogueText("Isso. Pegue o que encontrar pelo chão e use para fazer um machado.", false),
			new DialogueText("Quando estiver pronto, vá até a floresta e procure madeira.", false),
			new DialogueText("Certo. Vou juntar os materiais, fazer o machado e depois ir para a floresta.", true),
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
			var _quest = getCreateAxeQuest(id);

			obj_quest_manager.addQuest(_quest);
			obj_quest_manager.startQuest(_quest);
		};

		return _dialogue;
	}

	if (obj_quest_manager.hasActiveQuest(Quests.BecomeALumberjack)) {
		var _quest = obj_quest_manager.getQuest(Quests.BecomeALumberjack);
		var _currentStep = _quest.getCurrentStep();
		
		if (_currentStep == undefined) {
			return noone;
		}
		
		if (_currentStep.id == "return_to_survivor") {
			var _dialogue = new Dialogue(
			[
			    new DialogueText("Boa... agora sim estamos começando a nos preparar.", false),
			    new DialogueText("Com isso conseguimos cortar madeira e conseguir alguns recursos.", false),
			    new DialogueText("Mas madeira sozinha não vai nos manter vivos.", false),
			    new DialogueText("Precisamos de um lugar para fazer fogo.", false),
			    new DialogueText("Uma fogueira vai ser uma das primeiras coisas que precisamos construir.", false),
			    new DialogueText("Então vamos começar por aí.", true)
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

			_dialogue.onEnd = method(_quest, function () {
				self.completeCurrentStep();
			});

			return _dialogue;
		}
	}

	if (
		obj_quest_manager.hasCompletedQuest(Quests.CraftACampfire)
		&&
		!obj_quest_manager.hasActiveQuest(Quests.ExploreDump)
		&&
		!obj_quest_manager.hasCompletedQuest(Quests.ExploreDump)
	) {
		var _dialogue = new Dialogue(
			[
				new DialogueText("Enquanto você estava procurando os materiais e montando a fogueira...", false),
				new DialogueText("...eu percebi que tem alguns zumbis bem perto daqui.", false),
				new DialogueText("Talvez não fosse uma má ideia acabar com eles.", false),
				new DialogueText("Assim podemos explorar a região com mais segurança e pegar qualquer coisa útil que encontrarmos.", false),
				new DialogueText("É... matar alguns zumbis e ainda sair de lá com recursos. Parece um bom negócio.", true),
				new DialogueText("Exatamente. Só não se afaste demais.", false),
				new DialogueText("Se encontrar alguma coisa útil, traz pra cá.", false),
				new DialogueText("Pode deixar. Vou dar uma olhada por lá.", true)
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
			var _quest = getExploreDumpQuest();

			obj_quest_manager.addQuest(_quest);
			obj_quest_manager.startQuest(_quest);
		};

		return _dialogue;
	}

	return noone;
};