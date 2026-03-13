x = 0;
y = 0;
cameraX = x;
cameraY = y;
target = noone;
currentShakeEffect = 0;
setGuiSize(1920, 1080);
cameraScale = 1;
destinyCameraScale = 1;
cameraScaleVelocity = .01;
defaultCameraWidth = 2048;
defaultCameraHeight = 1152;
cameraHeight = defaultCameraHeight;
cameraWIdth = defaultCameraWidth;
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
	cameraScaleVelocity = .1;
	followMouse = false;
}

function setDefaultScale(){
	destinyCameraScale = 1;
	cameraScaleVelocity = .1;
	followMouse = true;
}

function setCameraScale(){
	cameraScale = lerp(cameraScale, destinyCameraScale, cameraScaleVelocity);
	var _cameraWidth = defaultCameraWidth * cameraScale;
	var _cameraHeight = defaultCameraHeight * cameraScale;
	camera_set_view_size(view_camera[0], _cameraWidth, _cameraHeight);
}

function followTarget(){
	var _viewHeight = camera_get_view_height(view_camera[0]);
	var _viewWidth = camera_get_view_width(view_camera[0]);
	
	var _cameraSpeed = .1;
	
	if (mouse_check_button(mb_right) && !global.activeInventory && followMouse){
		adjustCameraWithMouse();
	} else {
		var _targetMiddleXPoint = getMiddlePoint(target.bbox_left, target.bbox_right);
		var _targetMiddleYPoint = getMiddlePoint(target.bbox_top, target.bbox_bottom);
		cameraX = lerp(cameraX, _targetMiddleXPoint, _cameraSpeed);	
		cameraY = lerp(cameraY, _targetMiddleYPoint, _cameraSpeed);
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