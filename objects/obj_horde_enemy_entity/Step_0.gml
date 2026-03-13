event_inherited();
if (global.timeStopped) exit;
enemyColision(obj_collision);

currentState();
if(keyboard_check_released(vk_enter)) currentState = enemyIddleState;
