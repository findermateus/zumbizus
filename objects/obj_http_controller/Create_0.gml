request = undefined
function queryNpcList(){
	request = http_get("https://survival-game-website.onrender.com/npcs");
}

function loadNpcFromDatabase(_data){
	array_foreach(_data, setNpc);
}

function setNpc(_npcData) {
	global.npcList[_npcData.npcId] = new NPC(
		_npcData.npcName,
		_npcData.npcId,
		_npcData.gender.id,
		_npcData.skinColor.value,
		_npcData.hairColor
	);
	
	var _npc = global.npcList[_npcData.npcId];
	var _mappedAttributes = ds_map_create();
	_mappedAttributes[? "defense"] = baseAttribute.battle;
	_mappedAttributes[? "creation"] = baseAttribute.crafting;
	_mappedAttributes[? "production"] = baseAttribute.production;
	_mappedAttributes[? "supplies"] = baseAttribute.supplies;
	_mappedAttributes[? "commerce"] = baseAttribute.economy;
	_npc.attributes[_mappedAttributes[? _npcData.attribute]].level = 1;
	ds_map_destroy(_mappedAttributes);
}