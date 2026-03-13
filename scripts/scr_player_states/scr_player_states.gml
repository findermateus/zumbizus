function playerIddleState(){
	handleAngleOffset(false);
	adjustPlayerInteractions(true);
	adjustPlayerSpeed(global.player.walkingSpeed);
	movimentPlayer();
	updateSpriteWithState(sprites.iddle);
	increaseThirst(.03);
	increaseHunger(.02);
	switchBetweenWalkingAndIddle();
	switchToAimState();
}

function walkingState(){
	handleAngleOffset(true, .2, 5);
	adjustPlayerInteractions(true);
	updateSpriteWithState(sprites.walking);
	adjustPlayerSpeed(global.player.walkingSpeed);
	movimentPlayer();
	increaseThirst(.05);
	increaseHunger(.04);
	switchBetweenWalkingAndIddle();
	switchToAimState();
	if (choose(0, 1)) {
		if (velh != 0 || velv != 0) createWalkingParticles(x, y, velh, velv, 1);
	}
}

function runningState() {
	if (global.player.stamina <= 0) {
		currentState = walkingState;
		return;
	}
	handleAngleOffset(true, .4, 5);
	adjustPlayerInteractions(true);
	updateSpriteWithState(sprites.walking);
	adjustPlayerSpeed(global.player.sprintSpeed);
	decreaseStamina(global.player.sprintStaminaDecrease);
	movimentPlayer();
	increaseThirst(.06);
	increaseHunger(.05);
	switchBetweenWalkingAndIddle();
	switchToAimState();
	if (velh != 0 || velv != 0) createWalkingParticles(x, y, velh, velv, 1);
}

function adjustPlayerSpeed(_speed){
	currentSpeed = global.player.stamina <= 0 || global.activeInventory ? _speed * .6 : _speed;
}

function isWalking(){
	if (abs(velv) >= .5 || abs(velh) >= .5) return true;
	return false;
}

function switchBetweenWalkingAndIddle(){
	if(!isWalking()) {
		currentState = playerIddleState;
		return;
	}
	if (keyboard_check(vk_shift) && global.player.stamina > 1) {
		currentState = runningState;
		return;
	}
	currentState = walkingState;
}

function adjustPlayerInteractions(_shouldInteract){
	global.playerStopInteractions = !_shouldInteract;
}

function blockPlayerMenus() {
	global.blockMenus = true;
}

function unBlockPlayerMenus() {
	global.blockMenus = false;
}

function playerAttackState(){
	handleAngleOffset(true, 1, 4, true);
	adjustPlayerInteractions(false);
	movimentPlayer(true);
	increaseThirst(.05);
	increaseHunger(.04);
	updateSpriteWithState(sprites.walking);
	if (obj_weapon.currentState != obj_weapon.weaponAttackingState) {
		currentState = playerIddleState;
	}
}

function switchToAimState(){
	if(global.activeMenu) return;
	if(mouse_check_button(mb_right) && global.activeEquipedItem != global.blankInventorySpace){
		obj_weapon.weaponAim();
		currentState = aimWeaponState;
	}
}

function aimWeaponState(){
	if (!mouse_check_button(mb_right) || global.activeEquipedItem == global.blankInventorySpace || global.activeMenu){
		currentState = playerIddleState;
	}
	adjustPlayerInteractions(false);
	var _isStoped = velh == 0 && velv == 0;
	var _sprite = _isStoped ? sprites.iddle : sprites.walking;
	updateSpriteWithState(_sprite);
	aimWeapon(global.activeEquipedItem);
	increaseThirst(.05);
	increaseHunger(.04);
	if (mouse_check_button(mb_left)){
		if(obj_weapon.currentState == obj_weapon.weaponAttackingState) return;
		if(obj_weapon.attackWithPlayer()){
			currentState = playerAttackState;
		}
	}
	if (!_isStoped && (velh != 0 || velv != 0)) createWalkingParticles(x, y, velh, velv, .5);
}

function aimWeapon(_weapon){
	handleAngleOffset(true, .2, 2);
	adjustPlayerSpeed(global.player.walkingSpeed * .5);
	movimentPlayer(true);
}

function playerReloadingState(){
	if (mouse_check_button_pressed(mb_right)){
		switchToAimState();
	}
	handleAngleOffset(true, .2, 2);
	adjustPlayerInteractions(false);
	var _sprite = velh == 0 && velv == 0 ? sprites.iddle : sprites.walking;
	updateSpriteWithState(_sprite);
	adjustPlayerSpeed(global.player.walkingSpeed * .5);
	movimentPlayer();
}

function playerGetDamagedState() {
	handleAngleOffset(true, .2, 6);
	var _sprite = velh == 0 && velv == 0 ? sprites.iddle : sprites.walking;
	adjustPlayerInteractions(true);
	updateSpriteWithState(_sprite);
	adjustPlayerSpeed(global.player.walkingSpeed * .2);
	movimentPlayer(false);
	switchBetweenWalkingAndIddle();
}

function playerGetGrabbedState() {
    handleAngleOffset(true, .2, 6);
    var _sprite = sprites.iddle;
    adjustPlayerInteractions(false);
    
    velh = 0;
    velv = 0;
    
    updateSpriteWithState(_sprite);
    
    if (!instance_exists(obj_grabbing_controller)) {
        currentState = playerIddleState;
    }
}