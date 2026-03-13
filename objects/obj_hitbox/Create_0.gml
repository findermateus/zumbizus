objectsHit = ds_list_create();

function getHitObjects(_obj){
	var _num = instance_place_list(x, y, _obj, objectsHit, true)
	return _num;
}