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
	}));

	instance_create_layer(0, 0, "Controllers", obj_dialogue, {
		target: noone,
		dialogue: _dialogue
	});
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
		if (_data.item.itemId != equipmentItems.tornLabCoat) return;
		
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

	var _findSafePlaceStep = new QuestStep(
		"find_safe_place",
		"Encontre um lugar seguro"
	);

	_findSafePlaceStep.onEvent = method(_findSafePlaceStep, function(_event, _data) {
		if (_event != QuestEvent.AreaEntered) return;
		if (_data.area != rm_player_base) return;

		self.quest.completeCurrentStep();
	});

	_quest.addStep(_findSafePlaceStep);

	_quest.onComplete = method(_quest, function () {
		saveGame(true, false);
	});

	return _quest;
}