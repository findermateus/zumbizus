disabled = true;	
textToDraw = "Sair";

tag = EXTRACTION_WAYPOINT_TAG;

state = function () {
		var _quest = obj_quest_manager.getQuest(Quests.ExploreDump);
		var _currentStep = _quest.getCurrentStep();
		
		if (_currentStep == undefined) {
			return;
		}
		
		if (_currentStep.id == "return_to_base") { 
			disabled = false;	
		}
}

setOnclickAsTravel(global.maps.playerBase);