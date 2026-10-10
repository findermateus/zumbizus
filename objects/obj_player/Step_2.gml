x += velh;
y += velv;
x = round(x);
y = round(y);

updateBodyMotion(spriteXscale, currentState == runningState, currentState == playerDialogueState);

event_inherited();
