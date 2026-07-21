#macro DEFAULT_CAM_SCALE 1
#macro DEFAULT_CAM_SCALE_SPEED .07
#macro DEFAULT_CAM_SPEED .07

x = 0;
y = 0;

cameraX = x;
cameraY = y;

target = noone;

currentShakeEffect = 0;

setGuiSize(1920, 1080);
window_set_size(1920, 1080)

cameraScaleSpeed = DEFAULT_CAM_SCALE_SPEED;
cameraScale = DEFAULT_CAM_SCALE;

destinyCameraScale = DEFAULT_CAM_SCALE;

cameraHeight = DEFAULT_CAM_H;
cameraWIdth = DEFAULT_CAM_W;
camSpeed = DEFAULT_CAM_SPEED;

followMouse = true;

guiHeight = display_get_gui_height();
guiWidth = display_get_gui_width();

function followPlayer(){
	if(!instance_exists(obj_player)) return;
	target = obj_player;
	followTarget();
}

function setInventoryZoom(){
	destinyCameraScale = .6;
	cameraScaleSpeed = DEFAULT_CAM_SCALE_SPEED;
	followMouse = false;
}

function setCustomValues(_destinyScale, _scaleSpeed, _followsMouse, _currentScale = undefined) {
	destinyCameraScale = _destinyScale;
	cameraScaleSpeed = _scaleSpeed;
	followMouse = _followsMouse;
	
	if (is_numeric(_currentScale)) {
		cameraScale = _currentScale;
	}
}

function setDefaultValues(){
	destinyCameraScale = DEFAULT_CAM_SCALE;
	cameraScaleSpeed = DEFAULT_CAM_SCALE_SPEED;
	camSpeed = DEFAULT_CAM_SPEED;
	followMouse = true;
}

function setCameraScale(){
	cameraScale = lerp(cameraScale, destinyCameraScale, cameraScaleSpeed);
	var _cameraWidth = DEFAULT_CAM_W * cameraScale;
	var _cameraHeight = DEFAULT_CAM_H * cameraScale;
	camera_set_view_size(view_camera[0], _cameraWidth, _cameraHeight);
}

function followTarget(){
	var _viewHeight = camera_get_view_height(view_camera[0]);
	var _viewWidth = camera_get_view_width(view_camera[0]);
	
	if (mouse_check_button(mb_right) && !global.activeInventory && followMouse){
		adjustCameraWithMouse();
	} else {
		var _targetMiddleXPoint = getMiddlePoint(target.bbox_left, target.bbox_right);
		var _targetMiddleYPoint = getMiddlePoint(target.bbox_top, target.bbox_bottom);
		cameraX = lerp(cameraX, _targetMiddleXPoint, camSpeed);	
		cameraY = lerp(cameraY, _targetMiddleYPoint, camSpeed);
	}
	
	x = cameraX;
	y = cameraY
}

function shakeCamera(){
	if(currentShakeEffect == 0) return
	var _x = random_range(-currentShakeEffect, currentShakeEffect); 
	var _y = random_range(-currentShakeEffect, currentShakeEffect);
	view_set_xport(view_current, _x);
	view_set_yport(view_current, _y);
	currentShakeEffect = lerp(currentShakeEffect, 0, .1);
}

function setTargetWithZoom(_id){
	setInventoryZoom();
	target = _id;
	currentState = followTarget;
	currentState();
}


function adjustCameraWithMouse() {
    var _mouseX = mouse_x;
    var _mouseY = mouse_y;

    var _xPositionBetweenMouse = cameraX + (_mouseX - cameraX) / 2;
    var _yPositionBetweenMouse = cameraY + (_mouseY - cameraY) / 2;

    cameraX = lerp(cameraX, _xPositionBetweenMouse, 0.05);
    cameraY = lerp(cameraY, _yPositionBetweenMouse, 0.05);

    var cameraRange = 0.2; // 20% da tela

    var _verticalMax  = target.y + guiHeight * cameraRange;
    var _verticalMin  = target.y - guiHeight * cameraRange;
    cameraY = clamp(cameraY, _verticalMin, _verticalMax);

    var _horizontalMax = target.x + guiWidth * cameraRange;
    var _horizontalMin = target.x - guiWidth * cameraRange;
    cameraX = clamp(cameraX, _horizontalMin, _horizontalMax);
}


currentState = followPlayer;