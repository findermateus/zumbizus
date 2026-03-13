if (global.pause) exit;

event_inherited();

workerList = getFurnitureWorkers(furnitureId, objectId);

audio_emitter_position(audioEmitter, getMiddlePoint(bbox_left, bbox_right), bbox_bottom, 0);
if (isUsing && checkConditionsToClose()) {
	hideModal();
}

loadModalValues();
handleSlots();

yPositionToDrawShadow = getMiddlePoint(bbox_top, bbox_bottom);