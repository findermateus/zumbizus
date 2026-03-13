pauseBlur = 0;
isGamePaused = false;

if (!variable_global_exists("blood_particle_system")) {
    global.blood_particle_system = part_system_create_layer("Instances", false);    
}

if (!variable_global_exists("blood_particle_type")) {
    global.blood_particle_type = part_type_create();
        
    part_type_shape(global.blood_particle_type, pt_shape_pixel);
    
	part_type_size(global.blood_particle_type, 2, 8, -0.05, 0);
	
	part_type_alpha3(global.blood_particle_type, 1, .8, .4);
	
	part_type_color1(global.blood_particle_type, #860000);
    
	part_type_life(global.blood_particle_type, 20, 50);

    part_type_gravity(global.blood_particle_type, 0.05, 270);
        
}

request = "";

inputs = {
	tab: keyboard_check_released(vk_tab)
}
function loadInputs(){
	inputs = {
		tab: keyboard_check_released(vk_tab)
	}
}

function checkInventoryInput(){
	if (global.pause) return;
	
	if(inputs.tab){
		if (!global.activeInventory && !global.blockMenus) {
			openInventory();
			return;
		}
		if(!instance_exists(obj_inventory)) return;
		closeInventory();
	}
}

function getNpcListFromDatabase(){
	var _requestHandler = instance_create_layer(0, 0, layer, obj_http_controller);
	_requestHandler.queryNpcList();
}

function setDefaultCursor() {
	cursor_sprite = noone;
	window_set_cursor(cr_default);
}

function pauseGame() {
	pauseSystems();
	isGamePaused = true;
	
	setDefaultCursor();
	audio_play_sound(snd_swoosh, 0, false);
}

function unPauseGame() {
	unPauseSystems()
	isGamePaused = false;
	layer_destroy("LinearBlur");
	pauseBlur = 0;
}

function drawPause() {
	handleBlurEffect();
	
}

function handleBlurEffect() {
	static _blur = fx_create("_filter_linear_blur");
	
	var _gH = display_get_gui_height();
	var _gW = display_get_gui_width();
	
	var _color = c_black;
	var _alpha = draw_get_alpha();
	draw_set_alpha(.3);
	draw_rectangle_color(0, 0, _gW, _gH, _color, _color, _color, _color, false);
	draw_set_alpha(_alpha);
	
	var _layerId = "LinearBlur";
	var _destinyPauseBlur = 10;
	pauseBlur = lerp(pauseBlur, _destinyPauseBlur, .3);
	if (!layer_exists(_layerId)) {
		layer_create(-20000, _layerId);
		fx_set_parameter(_blur, "g_LinearBlurVector", [pauseBlur, pauseBlur]);
		layer_set_fx(_layerId, _blur);
	}
	
	fx_set_parameter(_blur, "g_LinearBlurVector", [pauseBlur, pauseBlur]);
	layer_set_visible(_layerId, true);
}