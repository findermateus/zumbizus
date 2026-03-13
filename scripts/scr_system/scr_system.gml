function initSystem() {
	display_set_gui_size(1920, 1080);
	global.inventoryWidth = 2;
	global.inventoryHeight = 5;
	global.inventory = ds_grid_create(global.inventoryWidth, global.inventoryHeight);
	window_set_cursor(cr_none);
	global.stopInteractions = false;
	global.debug = false;
	ds_grid_clear(global.inventory, global.blankInventorySpace);
	global.activeInventory = false;
	global.activeInventoryAction = global.inventory;
	global.activeMenu = false;
	global.motionPlanningGrid = 0;
	draw_set_font(fnt_gui_default);
	
	global.pause = false;
	global.timeStopped = false;
	
	global.defaultCameraWidth = 2048;
	global.defaultCameraHeight = 1152;
}

initSystem();

function stopTime() {
	global.timeStopped = true;
}

function goTime(){
	global.timeStopped = false;
}

function pauseSystems() {
	stopTime();
	global.pause = true;
}

function unPauseSystems() {
	goTime();
	global.pause = false;
}

function checkPlayerExistence(){
	if(!instance_exists(obj_player)) return false;
	return obj_player;
}


#macro TILESIZE	64

font_enable_effects(fnt_gui_default_outline, true, {
	outlineEnable: true,
	outlineDistance: 3,
	outlineColor: c_black
});

function calculateMotionPlanningGrid(){
	var _widthGrid = ceil(room_width / TILESIZE);
	var _heightGrid = ceil(room_height / TILESIZE);
	global.motionPlanningGrid = mp_grid_create(0, 0, _widthGrid, _heightGrid, TILESIZE, TILESIZE);
	mp_grid_add_instances(global.motionPlanningGrid, obj_collision, false);
}

function calculatePercentual(_percent, _total){
	return (_percent / _total) * 100;
}

function getScale(_newSize, _originalSize){
	return _newSize / _originalSize
}

function mouseIsOnRectangle(_x1, _y1, _x2, _y2){
	var _mouseX = device_mouse_x_to_gui(0);
	var _mouseY = device_mouse_y_to_gui(0);
	return (_mouseX >= _x1 && _mouseX <= _x2) && (_mouseY >= _y1 && _mouseY <= _y2);
}

function getMouseXGui(){
	return device_mouse_x_to_gui(0);
}

function getMouseYGui(){
	return device_mouse_y_to_gui(0);
}

function playFailSound(){
	audio_play_sound(snd_fail, 0, false);
}

function playHoverSound(){
	audio_play_sound(snd_hover, 0, false);
}

function playClickSound() {
	audio_play_sound(snd_click, 0, false);
}

function playSwiiimmmSound(_volume = 1) {
	audio_play_sound(snd_option_menu, 0, false, _volume);
}

function playTickSound() {
	audio_play_sound(snd_tick, 0, false);
}

function openMenu() {
	global.activeMenu = true;
}

function closeMenu() {
	global.activeMenu = false;
}

function getHexFromString(_hexcodeString){
	var _color = int64(ptr(string_replace(_hexcodeString, "#", "")));
	return ((_color & 0xFF0000) >> 16) | (_color & 0x00FF00) | ((_color & 0x0000FF) << 16);
}

function invertDirection(_direction) {
	return (_direction + 180) % 360;
}

function arrayKeyExists(_array, _key) {
	if (array_length(_array) <= _key) return false;
	return _array[_key] != undefined && _array[_key] != 0;
}

function get_animation_increment(_duration_seconds) {
	if (_duration_seconds <= 0) {
		
		return 0;
	}
	
	var _total_microseconds = _duration_seconds * 1000000;
	
	return delta_time / _total_microseconds;
}

function pickRandomItemFromArray(_list) {
    var _arraySize = array_length(_list);
    
    if (_arraySize <= 0) return undefined;
    
    return _list[irandom(_arraySize - 1)];
}

global.collidableObjects = [
	obj_collision,
	obj_furniture_colidable,
	obj_furniture_usable,
	obj_tree
];

global.interactableObjects = [
	obj_interactable,
	obj_npc_resident
];