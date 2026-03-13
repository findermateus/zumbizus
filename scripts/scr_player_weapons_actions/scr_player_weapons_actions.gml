function handleWeaponAnimation(){
	if (global.activeEquipedItem == global.blankInventorySpace) return;
	if(variable_struct_exists(weaponAction.item, "animation")){
		handleAnimatedWeaponAttack();
		return;
	}
	if(weaponAction.item.attackType == weaponAttackType.swing){
		return;
	}
}

function handleAttackAnimation(){
	if (global.activeEquipedItem == global.blankInventorySpace) return;
	if (weaponAction.item == global.blankInventorySpace) return;
	if(variable_struct_exists(weaponAction.item, "animation")){
		drawWeaponAttackingWithAnimation();
		return;
	}
	if(weaponAction.item.attackType == weaponAttackType.swing){
		drawWeaponAttackingSwing();
		return;
	}
	
	if(weaponAction.item.type == weaponTypes.shoot){
		drawWeaponShooting(weaponAction.item.recoilForce, weaponAction.item.delayToShoot);
	}
}
function playAttackSound(){
	if (global.activeEquipedItem == global.blankInventorySpace) return;
	if (variable_struct_exists(weaponAction.item, "attackingSound")){
		var _soundsCount = array_length(weaponAction.item.attackingSound);
		if (_soundsCount){
			var _soundIndex = irandom(_soundsCount - 1);
			audio_play_sound(weaponAction.item.attackingSound[_soundIndex], 0, false);
			var _x = getMiddlePoint(father.bbox_left, father.bbox_right);
			var _y = getMiddlePoint(father.bbox_top, father.bbox_bottom);
			obj_player_sound_controller.addSound(weaponAction.info.soundRadius, _x, _y, soundIntensity.standard, id);
		}
	}
}

function handleWeaponHitBox(){
	if (weaponAction.item.attackType == weaponAttackType.swing){
		playAttackSound();
		weaponAction.angle = weapon.angle;
		var _angle = variable_struct_exists(weaponAction.item, "angleToSwitch") ? weaponAction.item.angleToSwitch : 180
		var _angleToChange = (_angle * sign(weapon.yScale)) * -1;
		weaponAction.destinyAngle = weaponAction.angle + _angleToChange;
		handleSwingWeaponAttack();
	}
	if(weaponAction.item.type == weaponTypes.shoot){
		playAttackSound();
		handleFireWeaponAttack();
	}
}

function handleAnimatedWeaponAttack(){
	var _weaponAnimation = weaponAction.item.animation;
	weaponAction.animation = _weaponAnimation;
	weaponAction.animationIndex = 0;
	weaponAction.animationSpeed = sprite_get_speed(_weaponAnimation) / 60;
	weaponAction.animationLength = sprite_get_number(_weaponAnimation);
}

function handleInitialAttackVariables(){
	if (variable_struct_exists(weaponAction.item,  "staminaCost")){
		obj_player.decreaseStamina(weaponAction.item.staminaCost);
	}
	if(weaponAction.item.attackType == weaponAttackType.swing){
		weaponAction.yScale = weapon.yScale;
		weaponAction.angle = weapon.angle;
		weapon.angleSwitching *= -1;
		weapon.yScale *= -1;
	}
	if(weaponAction.item.type == weaponTypes.shoot){
		weaponAction.yScale = weapon.yScale;
		weaponAction.angle = weapon.angle;
	}
}
function defineMeeleWeaponPosition(_transition = false){
	
	weapon.yScale = sign(weapon.angleSwitching);
	weaponAction.yScale = -weapon.yScale;
	
	
	if(currentState == weaponAimState || _transition){
		weapon.wDirection = point_direction(father.x, father.y, mouse_x, mouse_y);
		weapon.angle = weapon.wDirection + weapon.angleSwitching;
	}
	var _centralizedYPosition = father.y - sprite_get_height(spr_human_male_iddle) / 2;
	if (!_transition){
		weapon.xPosition = lerp(weapon.xPosition, father.x + lengthdir_x(weapon.distanceFromPlayer, weapon.wDirection), .3)
		weapon.yPosition = lerp(weapon.yPosition , _centralizedYPosition + lengthdir_y(weapon.distanceFromPlayer, weapon.wDirection), .3);
		return;
	}
	weapon.xPosition = father.x + lengthdir_x(weapon.distanceFromPlayer, weapon.wDirection)
	weapon.yPosition = _centralizedYPosition + lengthdir_y(weapon.distanceFromPlayer, weapon.wDirection);
}

function defineFireWeaponPosition(){
	//weaponAction.yPosition
	if(currentState == weaponAimState || currentState == weaponAttackingState){
		weapon.wDirection = point_direction(father.x, father.y, mouse_x, mouse_y);
		weapon.angle = weapon.wDirection;
		weapon.yScale = sign(mouse_x - weapon.xPosition);	
	}
	var _centralizedYPosition = father.y - sprite_get_height(spr_human_male_iddle) / 2;
	weapon.xPosition = lerp(weapon.xPosition, father.x, .3);
	weapon.yPosition = lerp(weapon.yPosition, _centralizedYPosition + 15, .3);
}

function handleStepsForFireWeapon(){
	var _bullets = weaponAction.info.bullets;
	if (keyboard_check_pressed(ord("R"))){
		if (weaponAction.info.bullets >= weaponAction.info.maxAmmo) return;
		var _allowedAmmo = weaponAction.item.allowedAmmo;
		var _bulletItem = findItemInInventoryByIdNoBullshit(global.inventory, _allowedAmmo, itemType.ammo);
		if(_bulletItem == false) return;
		setUpReloading();
	}
}

function setUpReloading(){
	cursor_sprite = noone;
	window_set_cursor(cr_appstart);
	if (weaponAction.item.reloadingSprite != spr_item_default) {
		setUpReloadingAnimation();
	}
	if (weaponAction.item.reloadingType == reloadingTypes.magazine){
		playReloadingSound();
	}
	obj_camera.setTargetWithZoom(obj_player);
	obj_player.currentState = playerReloadingState;
	currentState = reloadingState;
}

function setUpReloadingAnimation(){
	var _sprite = weaponAction.item.reloadingSprite;
	reloadingAnimation.index = 0;
	reloadingAnimation.sprite = weaponAction.item.reloadingSprite;
	reloadingAnimation.length = sprite_get_number(reloadingAnimation.sprite);
	var _reloadTime = weaponAction.item.reloadTime;
	reloadingAnimation.speed = reloadingAnimation.length / _reloadTime;
}

function handleMagazineReload(){
	if (audio_is_playing(weaponAction.item.reloadSound) && weaponAction.item.reloadingSprite == spr_item_default) {
		return;
	}
	if (weaponAction.item.reloadingSprite != spr_item_default) {
		if (reloadingAnimation.index < reloadingAnimation.length) {
			calculateReloadAnimation();
			return;
		}
		reloadingAnimation.index = 0;
	}
	var _allowedAmmo = weaponAction.item.allowedAmmo;
	var _bulletSpace = weaponAction.info.maxAmmo - weaponAction.info.bullets;
	var _itemQuantityInInventory = getItemQuantityInInventory(global.inventory, _allowedAmmo, itemType.ammo);
	var _bulletsToInsert = _itemQuantityInInventory < _bulletSpace ? _itemQuantityInInventory : _bulletSpace;
	insertAmmo(_allowedAmmo, _bulletsToInsert);
	finishReloading();
}

function calculateReloadAnimation(){
	reloadingAnimation.index += reloadingAnimation.speed;
}

function handleSingeShellReload(){
	var _allowedAmmo = weaponAction.item.allowedAmmo;
	var _bulletSpace = weaponAction.info.maxAmmo - weaponAction.info.bullets;
	var _itemQuantityInInventory = getItemQuantityInInventory(global.inventory, _allowedAmmo, itemType.ammo);
	if (!_itemQuantityInInventory || !_bulletSpace){
		finishReloading();
		return;
	}
	if (reloadingAnimation.index < reloadingAnimation.length) {
		calculateReloadAnimation();
		return;
	}
	playReloadingSound();
	insertAmmo(_allowedAmmo, 1);
	reloadingAnimation.index = 0;
}

function playReloadingSound(){
	audio_play_sound(weaponAction.item.reloadSound, 0, false);
}

function insertAmmo(_ammoType, _quantity){
	decreaseItemQuantityInInventory(global.inventory, _ammoType, itemType.ammo, _quantity);
	weaponAction.info.bullets += _quantity;
}

function handleSwingWeaponAttack(){
	var _hitBox = createHitBox(weaponAction.item);
	hitEnemies(_hitBox, weaponAction.item);
}

function handleFireWeaponAttack(){
	if(instance_exists(obj_camera)){
		obj_camera.currentShakeEffect = 2;
	}
	weaponAction.info.bullets --;
	var _directionToGo = weapon.wDirection;
	var _sprite = weaponAction.item.sprite;
	var _xOffset = sprite_get_xoffset(_sprite);
	var _spriteWidth = sprite_get_width(_sprite);
	var _xdistanceFromPoint = _spriteWidth - _xOffset;

	var _xPosition = weapon.xPosition + lengthdir_x(_xdistanceFromPoint, _directionToGo);

	var _yPosition = weapon.yPosition + lengthdir_y(_xdistanceFromPoint, _directionToGo);
	var _dir = point_direction(_xPosition, _yPosition, mouse_x, mouse_y);
	createShotLight(_xPosition, _yPosition, weaponAction.item.lightSpread)
	if (weaponAction.item.attackType == weaponAttackType.tripleBullets) {
		createBulletShot(_dir + 5, _xPosition, _yPosition);
		createBulletShot(_dir - 5, _xPosition, _yPosition);
	}
	createBulletShot(_dir, _xPosition, _yPosition);
	createBulletExplosion(_xPosition, _yPosition, weaponAction.item.damage, weapon.wDirection);
}

function createShotLight(_x, _y, _lightRange){
	instance_create_layer(_x, _y, "Particles", obj_fire_weapon_light, {
		range: _lightRange
	});
}

function createBulletShot(_dir, _xPosition, _yPosition) {
	var _thickness = variable_struct_exists(weaponAction.item, "thickness") ? weaponAction.item.thickness : 1;
	var _bullet = instance_create_layer(_xPosition, _yPosition, "Bullets", obj_bullet);
	_bullet.image_angle = weapon.angle;
	_bullet.defineValues(_dir, 5, weaponAction.item.damage, weaponAction.item.bulletDistance , _thickness);
}

function createMeleeImpact(_x, _y, _intensity) {
    part_system_depth(explosionParticleSystem, -10000);
	var _faiscaCount = clamp(round(15 * _intensity), 5, 50);
	var _smokeCount = clamp(round(5 * _intensity), 2, 15);
	part_type_direction(faiscaParticleType, 0, 359, 0, 0);
	part_type_direction(smokeParticleType, 0, 359, 0, 0);
	part_emitter_region(explosionParticleSystem, ps_emissor, _x, _x, _y, _y, ps_shape_ellipse, ps_distr_linear);
	part_emitter_burst(explosionParticleSystem, ps_emissor, faiscaParticleType, _faiscaCount);
	part_emitter_burst(explosionParticleSystem, ps_emissor, smokeParticleType, _smokeCount);
}


function createBulletExplosion(_xPosition, _yPosition, _damage, _direction) {
    part_system_depth(explosionParticleSystem, getClosestDepth());
    var _faiscaCount = clamp(round(_damage * 1.5), 5, 40);
    part_type_direction(faiscaParticleType, _direction - 30, _direction + 30, 0, 0);
    part_emitter_region(explosionParticleSystem, ps_emissor, _xPosition, _xPosition, _yPosition, _yPosition, ps_shape_diamond, ps_distr_linear);
    part_emitter_burst(explosionParticleSystem, ps_emissor, faiscaParticleType, _faiscaCount);
    part_emitter_burst(explosionParticleSystem, ps_emissor, smokeParticleType, 5);
}


function createHitBox(_weapon){
	var _hitBox = instance_create_layer(weapon.xPosition, weapon.yPosition, "Particles", obj_hitbox);
	_hitBox.image_angle = weapon.angle - weapon.angleSwitching;
	_hitBox.sprite_index = _weapon.hitBox;
	return _hitBox;
}

function hitEnemies(_hitBox, _weapon){
	var _num = _hitBox.getHitObjects(obj_hittable);
	var _hitEnemies = _hitBox.objectsHit;
	var _sprite = weaponAction.item.sprite;
	var _xPosition = weapon.xPosition + lengthdir_x(sprite_get_width(_sprite), weapon.wDirection);
	var _yPosition = weapon.yPosition + lengthdir_y(sprite_get_height(_sprite), weapon.wDirection);
	var _damage = random_range(_weapon.damage - 3, _weapon.damage + 3);
	if (_num > 0){
		for(var _i = 0; _i < ds_list_size(_hitEnemies); _i ++){
			_hitEnemies[| _i].getHit(_damage, weapon.wDirection, _weapon.pushForce, _weapon.type, weaponAction.weaponId);
		}
		createHitBoxImpact(_xPosition, _yPosition, 10, 20);
		weaponAction.info.durability -= weaponAction.info.durabilityDecrease;
	}
	_num = _hitBox.getHitObjects(obj_furniture);
	var _hitFurniture = _hitBox.objectsHit;
	if (_num > 0){
		for(var _i = 0; _i < ds_list_size(_hitFurniture); _i ++){
			_hitFurniture[| _i].getHit(_damage);
		}
		createHitBoxImpact(_xPosition, _yPosition, 10, 20);
		weaponAction.info.durability -= weaponAction.info.durabilityDecrease;
	}
	instance_destroy(_hitBox);
}

function createHitBoxImpact(_xPosition, _yPosition, _range1, _range2){
	createMeleeImpact(_xPosition, _yPosition, _range2);
	screenShake(_range1);
}

#region visuals
function setXScaleAccordingToMouse(){
	if (mouse_x < weapon.xPosition) {
		weapon.xScale = -1;
	} else {
		weapon.xScale = 1;
	}
}

function drawWeaponAttackingWithAnimation(){
	draw_sprite_ext(weaponAction.animation, weaponAction.animationIndex, weapon.xPosition, weapon.yPosition, 1, weaponAction.yScale, weapon.wDirection, c_white, 1);
	weaponAction.animationIndex += weaponAction.animationSpeed;
	if (weaponAction.animationIndex >= weaponAction.animationLength){
		weaponAim(true);
	}
}

function drawWeaponAttackingSwing(){
	draw_sprite_ext(weaponAction.item.sprite, 0, weapon.xPosition, weapon.yPosition, weapon.xScale, weaponAction.yScale, weaponAction.angle, c_white, 1);
	weaponAction.angle = lerp(weaponAction.angle, weaponAction.destinyAngle, weaponAction.item.attackSpeed);
	var _differenceBetweenAngles = abs(weaponAction.angle - weaponAction.destinyAngle);
	if (_differenceBetweenAngles < 1){
		weaponAim(true);
		return;
	}
}
function checkDurability(){
	if (!itemHasDurability(weaponAction.info)) return true;
	return weaponAction.info.durability > 0;
}

function drawWeaponShooting(_recoilForce, _delay){
	curveAnimationIndex += (delta_time/1000000) * _delay;
	var _curveLength = _recoilForce;
	var _positionTransition = animcurve_channel_evaluate(recoilAnimationCurve, curveAnimationIndex) * _curveLength;
	weapon.xPosition += lengthdir_x(_positionTransition, weapon.wDirection);
	weapon.yPosition += lengthdir_y(_positionTransition, weapon.wDirection);
	weapon.yPosition += lengthdir_y(_positionTransition, weapon.wDirection);
	weapon.wDirection = point_direction(father.x, father.y, mouse_x, mouse_y);
	weapon.angle = weapon.wDirection;
	weapon.yScale = sign(mouse_x - weapon.xPosition);
	draw_sprite_ext(weaponAction.item.sprite, 0, weapon.xPosition, weapon.yPosition, weapon.xScale, weapon.yScale, weapon.angle, c_white, 1);
	if (curveAnimationIndex >= 1){
		curveAnimationIndex = 0;
		weaponAim(true);
	}
}
#endregion