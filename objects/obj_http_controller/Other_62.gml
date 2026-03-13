if (ds_map_find_value(async_load, "id") == request) {
    if (ds_map_find_value(async_load, "http_status") == 200) {
        var _response = ds_map_find_value(async_load, "result");
        var _data = json_parse(_response);
		loadNpcFromDatabase(_data);
		request = undefined
		var _alert = instance_create_layer(20, 20, "Alert", obj_alert_gui);
		_alert.alertColor = c_lime;
		var _text = "Carregado com sucesso"
		_alert.textAlert = _text;
		_alert.yPosition = 20 + string_height(_text) / 2;
		_alert.xPosition = 20 + string_width(_text) / 2;
    }
}