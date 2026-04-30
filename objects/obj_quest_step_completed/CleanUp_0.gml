var _idx = array_get_index(global.quest_popup_queue, id);
if (_idx != -1) {
    array_delete(global.quest_popup_queue, _idx, 1);
}

if (global.quest_popup_active == id) {
    global.quest_popup_active = noone;
}