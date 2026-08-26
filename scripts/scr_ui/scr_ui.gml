#macro PRIMARY_COLOR #1f8e00

function createTextInputTutorial(_text, _keys, _requireAll = false) {
    return instance_create_layer(0, 0, "Controllers", obj_input_tutorial, {
        drawType: "text",
        promptText: _text,
        keysToPress: _keys,
        requireAll: _requireAll
    });
}

function createSpriteInputTutorial(_sprite, _keys, _requireAll = false) {
    return instance_create_layer(0, 0, "Controllers", obj_input_tutorial, {
        drawType: "sprite",
        promptSprite: _sprite,
        keysToPress: _keys,
        requireAll: _requireAll
    });
}