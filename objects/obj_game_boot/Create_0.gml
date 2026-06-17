//room_goto(rm_player_base);
//return;

if (saveExists()) {
	loadPlayerData();
	room_goto(rm_player_base);
} else {
	room_goto(rm_tutorial_intro);
}