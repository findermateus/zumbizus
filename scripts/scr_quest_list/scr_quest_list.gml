function getCreateCampfireQuest() {
	var _quest = new Quest(Quests.CraftACampfire, "Descubra o Fogo");
	
	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});

	var _step = createCollectItemsStep("gather_resources", "Colete os itens necesários", [
		{ itemId: trashItems.wood_log, type: itemType.trash, count: 0, target: 6 },
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 12 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 8 },
	]);

	_quest.addStep(_step);

	var _craftCampfireStep = new QuestStep("craft_campfire", "Construa a fogueira");

	_craftCampfireStep.onEvent = method(_craftCampfireStep, function (_event, _data) {
		if (_event != QuestEvent.FurnitureCrafted) return;

		if (_data.furnitureId == global.furnitureIds.campfire) {
			self.quest.completeCurrentStep();
		}
	});

	_quest.addStep(_craftCampfireStep);

	var _reward = new QuestReward(15);

	array_push(
		_reward.items,
		{
			itemId: consumableItems.watter_bottle,
			itemType: itemType.consumables
		},
		{
			itemId: consumableItems.canned_pineapple,
			itemType: itemType.consumables
		}
	);

	_quest.setReward(_reward);

	return _quest;
}

function getCreateAxeQuest(_npc) {
	var _quest = new Quest(Quests.BecomeALumberjack, "Se torne um Lenhador");

	_quest.onComplete = method(_quest, function () {
		self.applyReward();

		var _nextQuest = getCreateCampfireQuest();

		with(obj_quest_manager) {
			addQuest(_nextQuest);
			startQuest(_nextQuest);
		}
	}); 

	var _step = createCollectItemsStep(
		"collect_axe_materials",
		"Colete os itens necessários",
		[
			{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
			{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
		]
	);

	_quest.addStep(_step);

	var _secondStep = new QuestStep("return_to_base", "Volte para a base");

	_secondStep.area = rm_player_base;
	
	_secondStep.onStart = method(_secondStep, function () {
		if (room == self.area) {
			self.quest.completeCurrentStep();
		}
	});

	_secondStep.onEvent = method(_secondStep, function(_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_secondStep);

	var _thirdStep = new QuestStep("craft_axe", "Faça o machado");

	_thirdStep.itemType = itemType.weapons;
	_thirdStep.itemId = weaponItems.axe;
	
	_thirdStep.onEvent = method(_thirdStep, function (_event, _data) {
		if (_event != QuestEvent.ItemCrafted && _event != QuestEvent.ItemCollected) return;
		
		if (_data.itemType == self.itemType && _data.itemId == self.itemId) {
			self.quest.completeCurrentStep();
		}
	});
	
	_quest.addStep(_thirdStep);

	var _talkStep = new QuestStep("return_to_survivor", "Fale com o sobrevivente");

	_talkStep.targetNpc = _npc;

	_talkStep.onEvent = method(_talkStep, function (_event, _data) {
		if (_event != QuestEvent.DialogueEnded) return;

		if (_data.npc != self.targetNpc) return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_talkStep);

	var _reward = new QuestReward(105);

	_quest.setReward(_reward);
	
	return _quest;
}

function getFindSafePlaceQuest() {
	var _quest = new Quest(Quests.FindSafePlace, "Perdido e Destruído");

	var _inspectTrashStep = new QuestStep(
		"inspect_the_trash",
		"Investigue a lixeira"
	);

	_inspectTrashStep.onEvent = method(_inspectTrashStep, function(_event, _data) {
		if (_event != QuestEvent.ObjectInteracted) return;
		if (_data.tag != "intro_trash") return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_inspectTrashStep);

	var _eatAndDrinkStep = new QuestStep(
		"eat_and_drink",
		"Coma algo e beba água"
	);

	_eatAndDrinkStep.objectives = [
		{
			type: itemType.consumables,
			itemId: consumableItems.watter_bottle,
			count: 0,
			target: 1
		},
		{
			type: itemType.consumables,
			itemId: consumableItems.canned_pineapple,
			count: 0,
			target: 1
		}
	];

	_eatAndDrinkStep.onEvent = method(_eatAndDrinkStep, function(_event, _data) {
		if (_event != QuestEvent.ItemConsumed) return;

		var _quantity = variable_struct_exists(_data, "quantity") ? _data.quantity : 1;

		for (var i = 0; i < array_length(self.objectives); i++) {
			var _objective = self.objectives[i];

			if (
				_data.itemId == _objective.itemId
				&& _data.type == _objective.type
			) {
				_objective.count += _quantity;

				if (_objective.count > _objective.target) {
					_objective.count = _objective.target;
				}
			}
		}

		var _allDone = true;

		for (var i = 0; i < array_length(self.objectives); i++) {
			if (self.objectives[i].count < self.objectives[i].target) {
				_allDone = false;
				break;
			}
		}

		if (_allDone) {
			self.quest.completeCurrentStep();
		}
	});

	_quest.addStep(_eatAndDrinkStep);

	var _clearBlockageStep = new QuestStep(
		"clear_exit_blockage",
		"Remova o bloqueio da porta"
	);

	_clearBlockageStep.onEvent = method(_clearBlockageStep, function(_event, _data) {
		if (_event != QuestEvent.ObjectInteracted) return;
		if (_data.tag != "intro_door_blockage") return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_clearBlockageStep);

	var _findClothesStep = new QuestStep(
		"find_clothes",
		"Procure algo para vestir"
	);

	_findClothesStep.onEvent = method(_findClothesStep, function(_event, _data) {
		if (_event != QuestEvent.ObjectInteracted) return;
		if (_data.tag != "chest") return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_findClothesStep);

	var _wearClothesStep = new QuestStep("wear_clothes", "Vista a roupa encontrada");

	_wearClothesStep.onEvent = method(_wearClothesStep, function (_event, _data) {
		if (_event != QuestEvent.ItemEquiped) return;
		if (_data.type != "armor") return;
		
		self.quest.completeCurrentStep();
	});

	_quest.addStep(_wearClothesStep);

	var _getWeaponStep = new QuestStep(
		"get_weapon",
		"Encontre uma arma"
	);

	_getWeaponStep.onEvent = method(_getWeaponStep, function(_event, _data) {
		if (_event != QuestEvent.ItemCollected) return;
		if (_data.itemType != itemType.weapons) return;
		
		self.quest.completeCurrentStep();
	});

	_quest.addStep(_getWeaponStep);
	
	var _equipWeaponStep = new QuestStep(
		"get_weapon",
		"Equipe a arma"
	);

	_equipWeaponStep.onEvent = method(_equipWeaponStep, function(_event, _data) {
		if (_event != QuestEvent.ItemEquiped) return;
		if (_data.itemType != itemType.weapons) return;
		
		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_equipWeaponStep);
	
	var _destroyBarricateStep = new QuestStep(
		"destroy_barricate",
		"Destrua o bloqueio da porta"
	);

	_destroyBarricateStep.onEvent = method(_destroyBarricateStep, function(_event, _data) {
		if (_event != QuestEvent.ObjectDestroyed) return;
		
		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_destroyBarricateStep);

	var _continueExploringStep = new QuestStep(
		"continue_exploring",
		"Continue Explorando"
	);

	_continueExploringStep.onEvent = method(_continueExploringStep, function(_event, _data) {
		if (_event != QuestEvent.DialogueEnded) return;

		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_continueExploringStep);
	
	var _defeatZombiesStep = createDefeatEnemiesStep(
		"defeat_zombies",
		"Derrote os zumbis",
		obj_enemy,
		2
	);

	_quest.addStep(_defeatZombiesStep);

	var _destroyNpcBarricadeStep = new QuestStep(
		"destroy_npc_barricade",
		"Destrua a bancada que está prendendo o rapaz"
	);

	_destroyNpcBarricadeStep.onStart = method(_destroyNpcBarricadeStep, function () {
		var _alreadyDestroyedBarricate = true;
		
		with (obj_breakable_empty_wooden_shelf) {
			if (destroyed_tag == "npc_barricade") {
				_alreadyDestroyedBarricate = false;
			}
		}
		
		if (_alreadyDestroyedBarricate) {
			self.quest.completeCurrentStep();
			
			return;
		}
		
		var _dialogue = createNpcDialogue(
			npc_tutorial,
			[
				"Ufa... Obrigado! Achei que fosse morrer aqui.",
				"Não sei quem é você, mas me salvou.",
				"Será que pode me dar mais uma ajudinha?",
				"Fiquei preso atrás dessa bancada quando aqueles monstros apareceram.",
				"Se conseguir tirá-la do caminho, vou conseguir sair daqui."
			]
		);

		instance_create_layer(0, 0, "Controllers", obj_dialogue, {
			target: npc_tutorial,
			dialogue: _dialogue
		});
	});

	_destroyNpcBarricadeStep.onEvent = method(_destroyNpcBarricadeStep, function(_event, _data) {
		if (_event != QuestEvent.ObjectDestroyed) return;
		if (_data.tag != "npc_barricade") return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_destroyNpcBarricadeStep);

	var _findSafePlaceStep = new QuestStep(
		"find_safe_place",
		"Encontre um lugar seguro"
	);

	_findSafePlaceStep.onStart = method(_findSafePlaceStep, function () {
		
		var _dialogue = new Dialogue(
			[
				new DialogueText("Espera aí. Quem é você e o que diabos tá acontecendo nesse lugar?", true),
				new DialogueText("Calma, abaixa isso! Eu não sou seu inimigo.", false),
				new DialogueText("Eu vi quando te arrastaram inconsciente aqui pra dentro do hospital e vim conferir se você tava bem.", false),
				new DialogueText("Mas de repente aqueles monstros apareceram e eu tive que me esconder.", false),
				new DialogueText("Me arrastaram? Quem? ...Olha, quer saber? Esquece.", true),
				new DialogueText("Nós dois estamos numa situação de merda. Ficar aqui é suicídio.", true),
				new DialogueText("A gente precisa encontrar um lugar seguro, agora.", true),
				new DialogueText("Concordo com você. Vamos dar o fora daqui.", false)
			],
			new DialogueParticipant(
				npc_tutorial.name,
				npc_tutorial.genderId,
				npc_tutorial.skinColor,
				npc_tutorial.hairColor,
				npc_tutorial.hairOption,
				npc_tutorial.outfitId,
				npc_tutorial.helmetId,
				npc_tutorial.bagId
			)
		);
		
		_dialogue.onEnd = function () {
			obj_waypoint.disabled = false;
			
			obj_waypoint.onClick = method(obj_waypoint, function () {
				if (instance_exists(obj_map_transition)) return;
	
				playClickSound();
	
				instance_create_layer(0, 0, "Controllers", obj_map_transition, {
					destination: rm_player_base,
					mapName: "Base"
				});
			})
			
			with(npc_tutorial) {
				setDestiny(obj_waypoint.x, obj_waypoint.y, function () {
					currentState = fadeOutState;
				});
			}
		}

		instance_create_layer(0, 0, "Controllers", obj_dialogue, {
			target: npc_tutorial,
			dialogue: _dialogue
		});
		
	});

	_findSafePlaceStep.onEvent = method(_findSafePlaceStep, function(_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != rm_player_base) return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_findSafePlaceStep);

	_quest.onComplete = method(_quest, function () {
		saveGame(true, false);
	});
	
	var _reward = new QuestReward(50);
	
	_quest.setReward(_reward);

	return _quest;
}