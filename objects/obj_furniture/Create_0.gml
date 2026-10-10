event_inherited();
furnitureInfo = {};
furniture = {};
curveAnimationIndex = 0;
xPosition = x;
yPosition = y;
furnitureCategory = furnitureCategories.storage;
furnitureId = global.furnitureIds.chest;
spriteToDrawShadow = spr_item_default;

xPositionToDrawShadow = xPosition;
yPositionToDrawShadow = yPosition;

currentSpriteFrame = 0;
shadowDirection = 0;

placeSquash = 0;
placeSquashVelocity = 0;

function playPlaceBounce(_force = .3) {
	placeSquash = _force;
	placeSquashVelocity = 0;
}

function updatePlaceBounce() {
	if (placeSquash == 0 && placeSquashVelocity == 0) return;

	placeSquashVelocity += -placeSquash * .3;
	placeSquashVelocity *= .75;
	placeSquash += placeSquashVelocity;

	if (abs(placeSquash) < .002 && abs(placeSquashVelocity) < .002) {
		placeSquash = 0;
		placeSquashVelocity = 0;
	}
}

//IMPORTANTE, toda mobilia produtiva que permite workers deve adaptar esse método
function loadSavedData(_data) {

}

function setShadow(_sprite, _frame, _direction) {
	spriteToDrawShadow = _sprite;
	currentSpriteFrame = _sprite;
	shadowDirection = _direction;
}

function loadFurnitureByDefaultId(){
	var _furniture = undefined;
	for (var i = 0; i < array_length(global.furniture[furnitureCategory]); i ++) {
		var _item = global.furniture[furnitureCategory][i];
		if (_item.furnitureId == furnitureId) {
			_furniture = _item;
		}
	}
	var _furnitureConversor = global.furnitureObjectConversor[? _furniture.furnitureId];
	setFurniture(_furniture, _furnitureConversor.info);
}

function setFurniture(_furniture, _furnitureInfo = {}){
	furnitureInfo = _furnitureInfo;
	furniture = _furniture;
	furnitureId = _furniture[$ "furnitureId"] ?? furnitureId;
	xPosition = x;
	yPosition = y;
	setShadow(_furniture.sprite, 0, 1);
}

function resetPosition(){
	xPosition = x;
	yPosition = y;
}

function innactive(){
	return;
}

currentState = innactive;