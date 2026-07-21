event_inherited();
if (global.timeStopped) exit;

currentState();
if(keyboard_check_released(vk_enter)) currentState = enemyIddleState;
