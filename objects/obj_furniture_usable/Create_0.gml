event_inherited();

actionDescription = "";
curveAnimationIndex = 0;
animationCurveItemDescription = animcurve_get_channel(ac_inventory,"item_description");
playedItemDescription = false;
furnitureData = false;

activationMethod = function () {

}

drawInterface = function(){
	if(currentState != active) return;
	if(curveAnimationIndex>=1){
		curveAnimationIndex = 0;
		playedItemDescription = true;
	}
	curveAnimationIndex += (delta_time/1000000);
	var _curveLength = 25;
	var _textMarginFromSprite = 20;
	var _positionTransition = !playedItemDescription ? animcurve_channel_evaluate(animationCurveItemDescription, curveAnimationIndex) * _curveLength : 0;
	var _yPosition = (bbox_bottom + _textMarginFromSprite + string_height(actionDescription)) - _positionTransition;
	var _guiXPosition = roomToGuiX(bbox_left + (bbox_right - bbox_left) /2);
	var _guiYPosition = roomToGuiY(_yPosition);
	drawActionText(actionDescription, _guiXPosition, _guiYPosition);
}

function innactive(){
	if(!verifyConditions()) return;
	curveAnimationIndex = 0;
	playedItemDescription = false;
	playHoverSound();
	currentState = active;
}

function active(){
	if(!verifyConditions()) currentState = innactive;
	if(mouse_check_button_pressed(mb_left)){
		activationMethod();
	}
}

function checkConditionsToClose(){
	if (global.activeBuilding || global.activeInventory || global.currentBaseMenuOption != -1){ 
		return true;
	}
	var _player = checkPlayerExistence();
	if (!_player) return true;
	if(checkObstacules(_player) && checkDistance(_player)) return false;
	
	return true;
}

currentState = innactive;