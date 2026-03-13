function setGuiSize(_guiWidth, _guiHeight){
	camera_set_view_size(view_camera[0], _guiWidth, _guiHeight);
	camera_set_view_border(view_camera[0], _guiWidth, _guiWidth/2)
}

function screenShake(_force){
	if(instance_exists(obj_camera)){
		obj_camera.currentShakeEffect = _force;
	}
}