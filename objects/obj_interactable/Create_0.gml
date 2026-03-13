animationCurveItemDescription = animcurve_get_channel(ac_inventory,"item_description");
playedItemDescription = false;
curveAnimationIndex = 0;
isHovering = false;
textToDraw = "";

drawInterface = function(){
	if(!isHovering) return;
	
	if(curveAnimationIndex>=1){
		curveAnimationIndex = 0;
		playedItemDescription = true;
	}
	
	curveAnimationIndex += (delta_time/1000000);
	
	var _curveLength = 25;
	var _textMarginFromSprite = 20;
	var _positionTransition = !playedItemDescription ? animcurve_channel_evaluate(animationCurveItemDescription, curveAnimationIndex) * _curveLength : 0;
	var _yPosition = (bbox_bottom + _textMarginFromSprite + string_height(textToDraw)) - _positionTransition;
	var _guiXPosition = roomToGuiX(bbox_left + (bbox_right - bbox_left) /2);
	var _guiYPosition = roomToGuiY(_yPosition);
	
	drawActionText(textToDraw, _guiXPosition, _guiYPosition);
}

checkObstacules = function(_player){
	var _x = getMiddlePoint(bbox_left, bbox_right);
	var _y = getMiddlePoint(bbox_top, bbox_bottom);
	if(collision_line(_x, _y, _player.x, _player.y, obj_collision, false, false)) return false;
	return true;
}

checkDistance = function(_player){
	var _distanceBetweenPlayer = point_distance(x, y, _player.x, _player.y);
	if(_distanceBetweenPlayer > global.minimalDistanceToCollect){
		return false;
	}
	return true;
}

verifyConditions = function(){
	var _player = checkPlayerExistence();
	if(!_player) return false;
	if(global.activeInventory) return false;
	if(global.stopInteractions) return false;
	if(global.playerStopInteractions) return false;
	if(!checkObstacules(_player)) return false;
	if(!checkDistance(_player)) return false;
	if(obj_player.closestObjectToCatch != id) return false;
	return true;
}

function handleHover() {
	if(!verifyConditions()) {
		isHovering = false;
		
		return;
	}
	
	if (!isHovering) {
		curveAnimationIndex = 0;
		playHoverSound();
		isHovering = true;
	}	
}