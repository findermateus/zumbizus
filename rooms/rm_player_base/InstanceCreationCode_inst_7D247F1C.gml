dialogue = new Dialogue(
    [
        new DialogueText("Finalmente conseguimos chegar na base em segurança...", false),
        new DialogueText("Se quisermos sobreviver por aqui...",                  false),
        new DialogueText("E pra isso, a primeira coisa que precisamos é de um [wave]machado[\wave].", false),
        new DialogueText("Com um machado você consegue cortar árvores...",       false),
        new DialogueText("Então o próximo passo é simples: encontre os materiais e faça um machado.", false),
        new DialogueText("Entendi. Vou preparar um machado pra gente.",          true),
    ],
    new DialogueParticipant(name, genderId, skinColor, hairColor, hairOption, -1, -1)
);

dialogue.onEnd = method(dialogue, function () {
	var _quest = obj_quest_manager.getCreateAxeQuest();
	
	obj_quest_manager.addQuest(_quest);
	obj_quest_manager.startQuest(_quest);
});