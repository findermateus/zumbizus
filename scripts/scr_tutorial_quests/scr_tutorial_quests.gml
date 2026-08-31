function getCreateCampfireQuest() {
	var _quest = new Quest(Quests.CraftACampfire, "Descubra o Fogo");
	
	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});
	
	var _goToForestStep = new QuestStep("go_to_forest", "Vá até a floresta");
	
	_goToForestStep.area = rm_forest;
	
	_goToForestStep.onStart = method(_goToForestStep, function () {
		if (room == self.area) {
			self.quest.completeCurrentStep();
		}
	});
	
	_goToForestStep.onEvent = method(_goToForestStep, function (_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_goToForestStep);

	var _step = createCollectItemsStep("gather_resources", "Colete os itens necesários", [
		{ itemId: trashItems.wood_log, type: itemType.trash, count: 0, target: 6 },
		{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 12 },
		{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 8 },
	]);

	_quest.addStep(_step);

	_quest.addStep(createReturnToBaseStep());

	var _craftCampfireStep = new QuestStep("craft_campfire", "Construa a fogueira");

	_craftCampfireStep.onStart = method(_craftCampfireStep, function () {
		createTextInputTutorial("[T] Para abrir o menu de criação", [ord("T")])
	});

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
			itemId: consumableItems.raw_meat_1,
			itemType: itemType.consumables
		}
	);

	_quest.setReward(_reward);

	_quest.onComplete = method(_quest, function () {
		self.applyReward();

		var _nextQuest = getCookMeatQuest();

		with (obj_quest_manager) {
			addQuest(_nextQuest);
			startQuest(_nextQuest);
		}
	});

	return _quest;
}

function getCookMeatQuest() {
	var _quest = new Quest(Quests.CookMeat, "Uma Refeição Quente");

	var _cookMeatStep = new QuestStep(
		"cook_meat",
		"Cozinhe a carne"
	);

	_cookMeatStep.onStart = method(_cookMeatStep, function () {
		var _dialogue = new Dialogue(
		[
			new DialogueText("Agora que temos uma fogueira, podemos preparar alguma coisa para comer.", false),
			new DialogueText("Espera... eu encontrei um pedaço de carne antes.", false),
			new DialogueText("Podemos cozinhar ela na fogueira.", false),
			new DialogueText("Toma, fica com ela. Você pode colocar na fogueira.", false),
			new DialogueText("Boa ideia. Vou preparar a carne.", true)
		],
		new DialogueParticipant(
			npc_tutorial_2.name,
			npc_tutorial_2.genderId,
			npc_tutorial_2.skinColor,
			npc_tutorial_2.hairColor,
			npc_tutorial_2.hairOption,
			npc_tutorial_2.eyeId,
			npc_tutorial_2.outfitId,
			npc_tutorial_2.helmetId,
			npc_tutorial_2.bagId
		)
	);

		instance_create_layer(0, 0, "Controllers", obj_dialogue, {
			target: npc_tutorial,
			dialogue: _dialogue
		});
	});

	_cookMeatStep.onEvent = method(_cookMeatStep, function (_event, _data) {
		if (_event != QuestEvent.ItemCrafted) return;

		if (
			_data.itemType != itemType.consumables
			|| _data.itemId != consumableItems.cooked_meat_1
		) return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_cookMeatStep);

	_quest.onComplete = method(_quest, function () {
		self.applyReward();
	});

	var _reward = new QuestReward(15);

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

	var _goToForestStep = new QuestStep("go_to_forest", "Vá até a floresta");
	
	_goToForestStep.area = rm_forest;
	
	_goToForestStep.onStart = method(_goToForestStep, function () {
		if (room == self.area) {
			self.quest.completeCurrentStep();
		}
	});
	
	_goToForestStep.onEvent = method(_goToForestStep, function (_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	});
	
	_quest.addStep(_goToForestStep);

	var _collectMaterialsStep = createCollectItemsStep(
		"collect_axe_materials",
		"Colete os itens necessários",
		[
			{ itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
			{ itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
		]
	);

	_quest.addStep(_collectMaterialsStep);
	
	_quest.addStep(createReturnToBaseStep());

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

	_eatAndDrinkStep.onStart = method(_eatAndDrinkStep, function () {
		createTextInputTutorial("[TAB] Para abrir o inventário", [vk_tab]);
	});

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
	
	_eatAndDrinkStep.onComplete = function () {
		closeInventory();
	}

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
		if (_event != QuestEvent.ItemCollected) return;
		if (_data.itemType != itemType.equipment || _data.itemId != equipmentItems.simpleOutfit) return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_findClothesStep);

	var _wearClothesStep = new QuestStep("wear_clothes", "Vista a roupa encontrada");

	_wearClothesStep.onStart = function () {
		closeInventory();
		createTextInputTutorial("[TAB] Para abrir o inventário", [vk_tab])
	};

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

	_equipWeaponStep.onStart = method(_equipWeaponStep, function () {
		createTextInputTutorial("[TAB] Para abrir o inventário", [vk_tab])
	});

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
	
	_destroyBarricateStep.onStart = method(_destroyBarricateStep, function () {
		createCombatTutorial();
	});

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

	_defeatZombiesStep.onStart = method(_defeatZombiesStep, function () {
		createCombatTutorial();
	});

	_quest.addStep(_defeatZombiesStep);

	var _destroyNpcBarricadeStep = new QuestStep(
		"destroy_npc_barricade",
		"Destrua a bancada que está prendendo o rapaz"
	);
	
	_destroyNpcBarricadeStep.onStart = method(_destroyNpcBarricadeStep, function () {
		createCombatTutorial();
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
				npc_tutorial.eyeId,
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
					destination: rm_tutorial_corridor,
					mapName: "Estrada abandonada"
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

function getExploreDumpQuest() {
	var _quest = new Quest(
		Quests.ExploreDump,
		"Uma Limpeza Necessária"
	);

	_quest.mapId = "junkyard";

	var _exploreDumpStep = new QuestStep(
		"explore_dump",
		"Explore o lixão"
	);

	_exploreDumpStep.area = rm_dump;

	_exploreDumpStep.onStart = method(_exploreDumpStep, function () {
		unlockMap(self.quest.mapId);
	});
	
	_exploreDumpStep.onEvent = method(_exploreDumpStep, function (_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != self.area) return;

		self.quest.completeCurrentStep();
	})

	_quest.addStep(_exploreDumpStep);
	
	var _killTheZombiesStep = new QuestStep("kill_dump_zombies", "Elimine os Zumbis da Área");

	_killTheZombiesStep.enemyQuestTag = "kill_dump_zombies";

	_killTheZombiesStep.onEvent = method(_killTheZombiesStep, function (_event, _data) {
	    if (_event != QuestEvent.EnemyKilled) return;
    
	    var _killedAll = true;
	    var _tagToMatch = enemyQuestTag;
    
	    with(obj_enemy) {
	        if (questTag == _tagToMatch && !defeated) {
	            _killedAll = false;
	            break;
	        }
	    }
    
	    if (_killedAll) {
	        self.quest.completeCurrentStep();
	    }
	});
	
	_quest.addStep(_killTheZombiesStep);
	
	_quest.onComplete = method(_quest, function () {
		lockMap(self.mapId)
	})

	return _quest;
}