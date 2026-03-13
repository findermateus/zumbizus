father = noone;


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
	item: global.blankInventorySpace,
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


function nothing(){
	if (drawState != drawNothing) {
		obj_controller.setDefaultCursor();
	}
	weapon.xPosition = father.x;
	weapon.yPosition = father.y;
	drawState = drawNothing;	
}

function setAimingCursor() {
	cursor_sprite = spr_cursor_aiming;
	window_set_cursor(cr_none);
}

function weaponAimState(){
	if(father.currentState != aimWeaponState) currentState = nothing;
	
	weaponAction.info = global.activeEquipedItem;
	if (global.activeEquipedItem != global.blankInventorySpace && variable_struct_exists(global.activeEquipedItem, "itemId")){
		weaponAction.weaponId = global.activeEquipedItem.itemId;
		weaponAction.item = global.weapons[weaponAction.weaponId];
	} else {
		weaponAction.weaponId = global.blankInventorySpace
		weaponAction.item = global.blankInventorySpace;
		return;
	}
	
	setAimingCursor();
	
	if(weaponAction.item.type == weaponTypes.shoot){
		handleStepsForFireWeapon();
	}
}

currentState = nothing;


function weaponAim(_comingFromAttack = false){
	obj_camera.setDefaultScale();
	if (is_struct(weaponAction.info) && !checkDurability()){
		global.equipedItems[| global.activeEquipedItemIndex] = global.blankInventorySpace;
		global.activeEquipedItemIndex = global.blankInventorySpace;
		global.activeEquipedItem = global.blankInventorySpace;
		drawState = drawNothing;
		weaponAction.item = global.blankInventorySpace;
		weaponAction.info = global.blankInventorySpace;
		currentState = nothing;
		exit;
	}
	if (currentState != weaponAttackingState){
		audio_play_sound(snd_equip_item, 0, false);
	}
	if(currentState == weaponAttackingState && !_comingFromAttack) return;
	if(_comingFromAttack && weaponAction.item.type != weaponTypes.shoot){
		defineMeeleWeaponPosition(true);
	}
	obj_player.currentState = aimWeaponState;
	currentState = weaponAimState;
	drawState = drawWeaponAiming;
}

function defineWeaponPosition(){
	if (weaponAction.item == global.blankInventorySpace) return;
	if (!variable_struct_exists(weaponAction.item, "type")) return;
	if (weaponAction.item.type == weaponTypes.shoot){
		defineFireWeaponPosition();
		return;
	}
	defineMeeleWeaponPosition();
}

function drawWeaponAiming(){
	if(global.activeEquipedItem == global.blankInventorySpace) return;
	if (weaponAction.weaponId != global.activeEquipedItem.itemId){
		weapon.yScale = 1;
		weapon.angle = 0;
		weapon.angleSwitching = 90;
		weaponAction.weaponId = global.activeEquipedItem.itemId;	
		weaponAction.item = global.weapons[weaponAction.weaponId];
	}
	if(currentState != weaponAimState && currentState != reloadingState){
		//drawState = drawNothing;
		return;
	}
	if (currentState == reloadingState && weaponAction.item.reloadingSprite != spr_item_default){
		drawReloadAnimation();
		return;
	}
	var _weaponId = global.activeEquipedItem.itemId;
	var _weapon = global.weapons[_weaponId];
	draw_sprite_ext(_weapon.sprite, 0, weapon.xPosition, weapon.yPosition, weapon.xScale, weapon.yScale, weapon.angle, c_white, 1);
}

function drawReloadAnimation(){
	draw_sprite_ext(
		reloadingAnimation.sprite,
		reloadingAnimation.index,
		weapon.xPosition,
		weapon.yPosition,
		weapon.xScale,
		weapon.yScale,
		weapon.angle,
		c_white,
		1
	);
}

function drawNothing(){
	return;
}

drawState = drawNothing;	

function weaponAttackingState(){
	drawState = handleAttackAnimation;
	//currentState = weaponAimState;
}

function attackWithPlayer(){
	if (instance_exists(obj_hitbox)) return;
	if (currentState != weaponAimState) return;
	if (weaponAction.item == global.blankInventorySpace) return false;
	if(weaponAction.item.type == weaponTypes.shoot && !weaponAction.info.bullets){
		if(mouse_check_button_pressed(mb_left)) audio_play_sound(weaponAction.item.emptyShot, 0, false);
		return false;
	}
	if(variable_struct_exists(weaponAction.item, "staminaCost") && global.player.stamina <= 0){
		return false;
	}
	handleWeaponAnimation();
	handleWeaponHitBox();
	handleInitialAttackVariables();
	currentState = weaponAttackingState;
	return true;
}

function reloadingState() {
	adjustPlayerInteractions(false);
	if (weaponAction.item.reloadingType == reloadingTypes.magazine) {
		handleMagazineReload();
		return
	}
	handleSingeShellReload();
}

function finishReloading(){
	adjustPlayerInteractions(true);
	obj_camera.setDefaultScale();
	weaponAim(false);
}