getCurrentDialogue = function() {

	if (
		!obj_quest_manager.hasActiveQuest(Quests.BecomeALumberjack)
		&&
		!obj_quest_manager.hasCompletedQuest(Quests.BecomeALumberjack)
	) {
		var _dialogue = new Dialogue(
		[
			new DialogueText("Finalmente conseguimos chegar na base em segurança...", false),
			new DialogueText("Se quisermos sobreviver por aqui...", false),
			new DialogueText("A primeira coisa que precisamos é de um [wave]machado[\wave].", false),
			new DialogueText("Com um machado você consegue cortar árvores...", false),
			new DialogueText("Então o próximo passo é simples: encontre os materiais e faça um machado.", false),
			new DialogueText("Entendi. Vou preparar um machado pra gente.", true),
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

		if (_quest.currentStepIndex == 3) {
			var _dialogue = new Dialogue(
			[
				new DialogueText("Boa... esse machado já vai ajudar bastante.", false),
				new DialogueText("Agora conseguimos cortar madeira de verdade.", false),
				new DialogueText("Mas ainda falta uma coisa importante...", false),
				new DialogueText("Precisamos montar uma fogueira.", false),
				new DialogueText("Sem fogo não vamos durar muitas noites aqui.", false),
				new DialogueText("Vou reunir os materiais.", true)
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