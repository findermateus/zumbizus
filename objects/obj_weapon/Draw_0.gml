if (global.timeStopped) exit;

drawState(); 

if(global.debug){
	draw_text(father.x, father.y - 50, "State: " + script_get_name(currentState));
	draw_text(father.x, father.y - 20, "Draw: " + script_get_name(drawState));
}