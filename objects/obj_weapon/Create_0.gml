father = noone;

#region SISTEMA DE PARTÍCULAS
{
	explosionParticleSystem = part_system_create();

	faiscaParticleType = part_type_create();
	part_type_shape(faiscaParticleType, pt_shape_pixel);
	part_type_size(faiscaParticleType, 1, 3, 0, 0);
	part_type_color1(faiscaParticleType, c_orange);
	part_type_alpha1(faiscaParticleType, 1);
	part_type_speed(faiscaParticleType, 3, 6, 0, 0);
	part_type_direction(faiscaParticleType, 80, 100, 0, 0);
	part_type_gravity(faiscaParticleType, 0.1, 270);
	part_type_life(faiscaParticleType, 10, 20);
	part_type_blend(faiscaParticleType, true);

	smokeParticleType = part_type_create();
	part_type_shape(smokeParticleType, pt_shape_cloud);
	part_type_size(smokeParticleType, 0.3, 0.8, 0, 0);
	part_type_color2(smokeParticleType, c_white, c_gray);
	part_type_alpha3(smokeParticleType, 0.5, 0.3, 0);
	part_type_speed(smokeParticleType, 1, 2, 0, 0);
	part_type_direction(smokeParticleType, 85, 95, 0, 0);
	part_type_gravity(smokeParticleType, 0, 0);
	part_type_life(smokeParticleType, 20, 30);
	part_type_blend(smokeParticleType, true);

	ps_emissor = part_emitter_create(explosionParticleSystem);	
}
#endregion

#region ESTRUTURAS DE DADOS
defaultWeapon = {
	xPosition: 0,
	yPosition: 0,
	wDirection: 0,
	distanceFromPlayer: 50,
	angle: 0,
	angleSwitching: 90,
	yScale: 1,
	xScale: 1
}

reloadingAnimation = {
	speed: 0,
	index: 0,
	length: 0,
	sprite: spr_item_default
}

weapon = defaultWeapon;
recoilAnimationCurve = animcurve_get_channel(ac_weapons, "weaponRecoil");
curveAnimationIndex = 0;

weaponAction = {
	weaponId: noone,
	item: BLANK_INVENTORY_SPACE,
	yScale: -1,
	angle: 0,
	recoilXPosition: 0,
	recoilYPosition: 0,
	destinyAngle: 0,
	animationSpeed: 0,
	animationIndex: 0,
	animationLength: 0,
	animation: spr_baseball_bat,
	info: {}
}
#endregion

// --- ESTADOS LÓGICOS

function drawNothing() {
}

function weaponIdleState(){
	setStateIdle();
	
	weapon.xPosition = father.x;
	weapon.yPosition = father.y;
}

function weaponAimState(){
	updateWeaponActionData();
	
	if (weaponAction.item == BLANK_INVENTORY_SPACE) {
		setStateIdle();
		return;
	}
	
	if(weaponAction.item.type == weaponTypes.shoot){
		obj_cursor_controller.setCursor(CursorType.PreciseAim);
		
		handleStepsForFireWeapon();
	}
	
	if (array_contains([weaponTypes.bladed, weaponTypes.impact, weaponTypes.piercing], weaponAction.item.type)) {
		obj_cursor_controller.setCursor(CursorType.Aim);
	}
}

function weaponAttackingState(){
	// O controle do desenho é feito pelo drawState (handleAttackAnimation)
	// A transição de volta para AimState é feita nos scripts de animação
}

function reloadingState() {
	adjustPlayerInteractions(false);
	if (weaponAction.item.reloadingType == reloadingTypes.magazine) {
		handleMagazineReload();
	} else {
		handleSingeShellReload();
	}
}

function setStateIdle(){
    if (drawState != drawNothing) {
        obj_cursor_controller.setCursor(CursorType.Default);
    }

    currentState = weaponIdleState;
    
    drawState = drawNothing; 
}

function getWeaponBackDrawData(){
	if(global.activeEquipedItem == BLANK_INVENTORY_SPACE) return noone;
	
	var _weaponId = global.activeEquipedItem.itemId;
	var _weapon = global.weapons[_weaponId];
	
	var _side = father.spriteXscale;
	var _jiggle = father.playerAngleOffset; 
	
	var _baseXOffset = -8 * _side;
	var _baseYOffset = -30; 
	
	var _dynamicX = father.x + _baseXOffset + lengthdir_x(_jiggle * 0.5, 90);
	var _dynamicY = father.y + _baseYOffset + lengthdir_y(_jiggle * 0.5, 0);

	var _finalAngle = (45 * _side) + _jiggle;

	return {
		sprite: _weapon.sprite,
		x: _dynamicX,
		y: _dynamicY,
		xscale: 0.8 * _side,
		yscale: 0.8,
		angle: _finalAngle,
		alpha: 1
	};
}

function weaponAim(_comingFromAttack = false){
	obj_camera.setDefaultValues();
	
	if (_comingFromAttack && !mouse_check_button(mb_right)) {
		setStateIdle();
		exit;
	}

	if (is_struct(weaponAction.info) && !checkDurability()){
		resetActiveItem();
		setStateIdle();
		exit;
	}
	
	if (currentState != weaponAttackingState && !_comingFromAttack){
		audio_play_sound(snd_equip_item, 0, false);
	}
	
	if(currentState == weaponAttackingState && !_comingFromAttack) return;
	
	if(_comingFromAttack && weaponAction.item.type != weaponTypes.shoot){
		defineMeeleWeaponPosition(true);
	}
	
	updateWeaponActionData();
	currentState = weaponAimState;
	drawState = drawWeaponAiming;
}

function attackWithPlayer(){
	if (instance_exists(obj_hitbox)) return false;
	if (currentState != weaponAimState) return false;
	if (weaponAction.item == BLANK_INVENTORY_SPACE) return false;
	
	if(weaponAction.item.type == weaponTypes.shoot && !weaponAction.info.bullets){
		if(mouse_check_button_pressed(mb_left)) audio_play_sound(weaponAction.item.emptyShot, 0, false);
		return false;
	}
	
	if(variable_struct_exists(weaponAction.item, "staminaCost") && global.player.stamina <= 0){
		return false;
	}
	
	obj_cursor_controller.triggerRecoil();
	
	handleWeaponAnimation();
	handleWeaponHitBox();
	handleInitialAttackVariables();
	
	currentState = weaponAttackingState;
	drawState = handleAttackAnimation; 
	return true;
}

function updateWeaponActionData() {
	weaponAction.info = global.activeEquipedItem;
	if (global.activeEquipedItem != BLANK_INVENTORY_SPACE && variable_struct_exists(global.activeEquipedItem, "itemId")){
		weaponAction.weaponId = global.activeEquipedItem.itemId;
		weaponAction.item = global.weapons[weaponAction.weaponId];
	} else {
		weaponAction.weaponId = BLANK_INVENTORY_SPACE;
		weaponAction.item = BLANK_INVENTORY_SPACE;
	}
}

function resetActiveItem() {
	global.equipedItems[| global.activeEquipedItemIndex] = BLANK_INVENTORY_SPACE;
	global.activeEquipedItemIndex = BLANK_INVENTORY_SPACE;
	global.activeEquipedItem = BLANK_INVENTORY_SPACE;
	weaponAction.item = BLANK_INVENTORY_SPACE;
	weaponAction.info = BLANK_INVENTORY_SPACE;
}

function finishReloading(){
	adjustPlayerInteractions(true);
	obj_camera.setDefaultValues();
	
	if (mouse_check_button(mb_right) && global.activeEquipedItem != BLANK_INVENTORY_SPACE) {
		weaponAim(true); 
		obj_player.currentState = aimWeaponState;
		
		return;
	}
	
	setStateIdle();
	obj_player.currentState = playerIddleState;
}

currentState = weaponIdleState;
drawState = drawNothing;