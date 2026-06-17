switch (introState) {
	case "fade_from_black":
		fadeTimer++;

		fadeAlpha = 1 - clamp(fadeTimer / fadeDuration, 0, 1);

		if (fadeTimer >= fadeDuration) {
			fadeAlpha = 0;
			introState = "player_thought";
		}
	break;

	case "player_thought":
		if (!dialogueStarted) {
			dialogueStarted = true;
			startIntroPlayerDialogue();
		}
	break;

	case "running":
	break;
}