event_inherited();
furnitureInfo = {};
furniture = {};
furnitureHealth = 1;
curveAnimationIndex = 0;
animationCurveInventoryFull = animcurve_get_channel(ac_inventory,"inventory_full");
xPosition = x;
yPosition = y;
furnitureCategory = furnitureCategories.storage;
furnitureId = furnitureIds.chest;
spriteToDrawShadow = spr_item_default;

xPositionToDrawShadow = xPosition;
yPositionToDrawShadow = yPosition;

currentSpriteFrame = 0;
shadowDirection = 0;

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
	var _furnitureConversor = global.furnitureObjectConversor[_furniture.furnitureId];
	setFurniture(_furniture, _furnitureConversor.info);
}

function setFurniture(_furniture, _furnitureInfo = {}){
	furnitureInfo = _furnitureInfo;
	furnitureHealth = furnitureInfo.furnitureHealth;
	furniture = _furniture;
	xPosition = x;
	yPosition = y;
	setShadow(_furniture.sprite, 0, 1);
}

function resetPosition(){
	xPosition = x;
	yPosition = y;
}

function dropItemsWhenDestroyed(){
	var _items = furniture.requirements;
	for(var i = 0; i < array_length(_items); i++){
		var _item = _items[i];
		var _quantityToCreate = irandom(_item.quantity);
		if (_quantityToCreate > 0){
			var _itemObject = instance_create_layer(x, y, "Items", obj_item);
			_itemObject.defineItem(_item.type, _item.itemId);
			_itemObject.item.quantity = _quantityToCreate;
			_itemObject.createdWithBounce(irandom_range(8, 12), irandom(365));
		}
	}
}

function getHit(_damage = 1){
	furnitureHealth -= _damage;
	curveAnimationIndex = 0;
	xPosition = x;
	yPosition = y;
	currentState = shake;
	if (furnitureHealth <= 0){
		instance_destroy(id, true);
	}
}

function innactive(){
	return;
}

function shake(){
	if(curveAnimationIndex>=1){
		curveAnimationIndex = 0;
		currentState = innactive;
	}
	curveAnimationIndex += (delta_time/1000000);
	xPosition += animcurve_channel_evaluate(animationCurveInventoryFull, curveAnimationIndex) * 2;
	yPosition += animcurve_channel_evaluate(animationCurveInventoryFull, curveAnimationIndex) * 2;
}

currentState = innactive;