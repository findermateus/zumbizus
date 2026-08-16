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
		    new DialogueText("Tem uma floresta não muito longe daqui.", false),
		    new DialogueText("Se quisermos começar a construir alguma coisa, vamos precisar buscar madeira lá.", false),
		    new DialogueText("E vamos precisar de um machado para isso.", false),
		    new DialogueText("Então eu vou até a floresta?", true),
		    new DialogueText("Isso. Procure alguns materiais e faça um machado.", false),
		    new DialogueText("Depois podemos começar a preparar esse lugar.", false),
		    new DialogueText("Certo. Vou até lá buscar o que precisamos.", true)
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

	return noone;
};

canTrade = true;

tradeItems = [
	new TradeItem(consumableItems.canned_food, itemType.consumables, 1),
	new TradeItem(consumableItems.canned_fish, itemType.consumables, 1),
	new TradeItem(consumableItems.watter_bottle, itemType.consumables, 1),
	new TradeItem(consumableItems.dirt_water, itemType.consumables, 1),
	new TradeItem(consumableItems.bandage, itemType.consumables, 1),
];