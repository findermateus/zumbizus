updateJuice();

switch (fadeState) {
    case STATE_FADE_IN:
        processFadeIn();
        break;
        
    case STATE_WAITING:
        processWaitingInput();
        break;
        
    case STATE_FADE_OUT:
        processFadeOut();
        break;
}