event_inherited();
image_alpha = 0;
onClick = function () {}

getDrawPosition = function () {
    return {
        x: roomToGuiX(getMiddlePoint(bbox_left, bbox_right)),
        y: roomToGuiY(getMiddlePoint(bbox_top, bbox_bottom))
    };
}