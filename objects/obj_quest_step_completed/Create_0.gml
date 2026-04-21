gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

target_y = gui_h * 0.2; 
current_y = target_y + 50; 

alpha = 0;
fade_speed = 0.05;
state = "fade_in";

wait_time = 90;
timer = 0;

wait_time = 120;
timer = 0;

line_progress = 0;      
line_padding = 40;

playSwiiimmmSound();