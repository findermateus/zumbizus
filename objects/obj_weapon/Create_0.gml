father = noone;

#region SISTEMA DE PARTÍCULAS
{
	explosionParticleSystem = part_system_create();

	faiscaParticleType = part_type_create();
	part_type_shape(faiscaParticleType, pt_shape_pixel);
	part_type_size(faiscaParticleType, 1, 3, 0, 0);
	part_type_color1(faiscaParticleType, c_orange);
	part_type_alpha2(faiscaParticleType, 1, 0);
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

#region
drawAngle = 0;
aimAngleNeedsSnap = true;
weaponKick = 0;
weaponKickVelocity = 0;
weaponPunch = 0;
weaponPunchVelocity = 0;
muzzleFlash = 0;
muzzleSize = 1;
swingTrail = [];
swingLunge = 0;
swingHitBoost = 0;
weaponFlash = 0;
emptyShake = 0;
casings = [];
reloadUI = {
	start: 0,
	duration: 1000,
	flash: 0
};

function getWeaponTipVector(_sprite, _yScale) {
	var _xOffset = sprite_get_xoffset(_sprite);
	var _yOffset = sprite_get_yoffset(_sprite);
	var _width = sprite_get_width(_sprite);
	var _height = sprite_get_height(_sprite);
	var _corners = [
		[-_xOffset, -_yOffset],
		[_width - _xOffset, -_yOffset],
		[-_xOffset, _height - _yOffset],
		[_width - _xOffset, _height - _yOffset]
	];

	var _best = _corners[0];
	var _bestLength = 0;
	for (var i = 0; i < array_length(_corners); i++) {
		var _length = point_distance(0, 0, _corners[i][0], _corners[i][1]);
		if (_length > _bestLength) {
			_bestLength = _length;
			_best = _corners[i];
		}
	}

	return {
		length: _bestLength,
		angleOffset: point_direction(0, 0, _best[0], _best[1] * _yScale)
	};
}

function getWeaponBob() {
	return instance_exists(father) && variable_instance_exists(father, "bodyHop") ? father.bodyHop : 0;
}

function updateWeaponJuice() {
	weaponKickVelocity += -weaponKick * .3;
	weaponKickVelocity *= .65;
	weaponKick += weaponKickVelocity;

	weaponPunchVelocity += -weaponPunch * .3;
	weaponPunchVelocity *= .62;
	weaponPunch += weaponPunchVelocity;

	muzzleFlash = max(0, muzzleFlash - 1);
	swingLunge = lerp(swingLunge, 0, .2);
	swingHitBoost = max(0, swingHitBoost - .05);
	weaponFlash = max(0, weaponFlash - .1);
	emptyShake = lerp(emptyShake, 0, .25);
	reloadUI.flash = max(0, reloadUI.flash - .06);

	for (var i = array_length(casings) - 1; i >= 0; i--) {
		var _casing = casings[i];
		_casing.life--;

		if (!_casing.landed) {
			_casing.x += _casing.hsp;
			_casing.y += _casing.vsp;
			_casing.vsp += .45;
			_casing.angle += _casing.spin;

			if (_casing.y >= _casing.floorY) {
				_casing.y = _casing.floorY;
				if (abs(_casing.vsp) > 1.5) {
					_casing.vsp *= -.4;
					_casing.hsp *= .6;
					_casing.spin *= .5;
				} else {
					_casing.landed = true;
				}
			}
		}

		if (_casing.life <= 0) array_delete(casings, i, 1);
	}
}

function ejectCasing(_isShell) {
	if (array_length(casings) >= 30) array_delete(casings, 0, 1);

	var _backwards = weapon.wDirection + 180 + random_range(-25, 25);
	var _speed = random_range(2, 3.5);
	array_push(casings, {
		x: weapon.xPosition,
		y: weapon.yPosition,
		hsp: lengthdir_x(_speed, _backwards),
		vsp: -random_range(3, 5),
		angle: random(360),
		spin: random_range(-25, 25),
		floorY: father.y + random_range(-6, 6),
		landed: false,
		life: 90,
		isShell: _isShell
	});
}

function drawCasings() {
	for (var i = 0; i < array_length(casings); i++) {
		var _casing = casings[i];
		var _alpha = min(1, _casing.life / 20);
		var _width = _casing.isShell ? 7 : 5;
		var _height = _casing.isShell ? 3.5 : 2.5;
		var _color = _casing.isShell ? #c0392b : #d4a83a;
		draw_sprite_ext(spr_pixel, 0, _casing.x, _casing.y, _width, _height, _casing.angle, _color, _alpha);
	}
}

function drawMuzzleFlash(_x, _y, _direction) {
	if (muzzleFlash <= 0) return;

	var _strength = muzzleFlash / 3;
	var _size = muzzleSize * (.7 + _strength * .5);

	gpu_set_blendmode(bm_add);
	draw_set_alpha(_strength);
	draw_set_color(#ffd27a);

	for (var i = 0; i < 5; i++) {
		var _spikeDirection = _direction + (i - 2) * 32;
		var _length = (i == 2 ? 26 : 13) * _size;
		var _halfWidth = 3.5 * _size;
		draw_triangle(
			_x + lengthdir_x(_halfWidth, _spikeDirection + 90), _y + lengthdir_y(_halfWidth, _spikeDirection + 90),
			_x + lengthdir_x(_halfWidth, _spikeDirection - 90), _y + lengthdir_y(_halfWidth, _spikeDirection - 90),
			_x + lengthdir_x(_length, _spikeDirection), _y + lengthdir_y(_length, _spikeDirection),
			false
		);
	}
	draw_set_color(c_white);
	draw_circle(_x, _y, 5 * _size, false);

	gpu_set_blendmode(bm_normal);
	draw_set_alpha(1);
}

function drawSwingTrail(_sprite, _yScale) {
	var _count = array_length(swingTrail);
	if (_count < 2) return;

	var _tip = getWeaponTipVector(_sprite, _yScale);
	var _innerRadius = _tip.length * .35;
	var _outerRadius = _tip.length;
	var _strength = 1 + swingHitBoost;
	var _color = swingHitBoost > 0 ? #fff1c4 : c_white;

	gpu_set_blendmode(bm_add);
	draw_primitive_begin(pr_trianglestrip);
	for (var i = 0; i < _count; i++) {
		var _entry = swingTrail[i];
		var _age = (i + 1) / _count;
		var _direction = _entry.angle + _tip.angleOffset;
		draw_vertex_color(_entry.x + lengthdir_x(_outerRadius, _direction), _entry.y + lengthdir_y(_outerRadius, _direction), _color, _age * .45 * _strength);
		draw_vertex_color(_entry.x + lengthdir_x(_innerRadius, _direction), _entry.y + lengthdir_y(_innerRadius, _direction), _color, _age * .05);
	}
	draw_primitive_end();
	gpu_set_blendmode(bm_normal);

	for (var i = max(0, _count - 4); i < _count - 1; i++) {
		var _entry = swingTrail[i];
		var _alpha = .12 * (i - (_count - 4) + 1);
		draw_sprite_ext(_sprite, 0, _entry.x, _entry.y, weapon.xScale, _yScale, _entry.angle, c_white, _alpha);
	}
}

function drawReloadProgress() {
	var _isReloading = currentState == reloadingState && weaponAction.item != BLANK_INVENTORY_SPACE;
	if (!_isReloading && reloadUI.flash <= 0) return;
	if (!instance_exists(father)) return;

	var _ratio = 1;
	if (_isReloading) {
		_ratio = weaponAction.item.reloadingType == reloadingTypes.perBullet
			? reloadingAnimation.index / max(1, reloadingAnimation.length)
			: (current_time - reloadUI.start) / max(1, reloadUI.duration);
		_ratio = clamp(_ratio, 0, 1);
	}

	var _cx = weapon.xPosition - 24;
	var _cy = weapon.yPosition + 22;
	var _alpha = _isReloading ? 1 : reloadUI.flash;
	var _radius = 11 + reloadUI.flash * 4;

	draw_set_color(c_black);
	draw_set_alpha(_alpha * .55);
	draw_circle(_cx, _cy, _radius + 2, false);
	drawRadialProgress(_cx, _cy, _radius - 4, _radius, 1, c_black, _alpha * .5);
	drawRadialProgress(_cx, _cy, _radius - 4, _radius, _ratio, _isReloading ? #ffd166 : #5fd35f, _alpha);
	draw_set_color(c_white);
	draw_set_alpha(1);
}
#endregion

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
    aimAngleNeedsSnap = true;
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
		if(mouse_check_button_pressed(mb_left)) {
			audio_play_sound(weaponAction.item.emptyShot, 0, false);
			emptyShake = 4;
		}
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
	reloadUI.flash = 1;
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