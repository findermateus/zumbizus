if (saveExists()) {
	loadPlayerData();
	room_goto(rm_player_base);
	
	exit;
}

room_goto(rm_tutorial_intro);