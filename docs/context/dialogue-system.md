# Sistema de Diálogo — Contexto Técnico

Este documento descreve o sistema de diálogo atualmente implementado no projeto **Zumbizus**.

O objetivo deste arquivo é servir como contexto técnico para desenvolvimento futuro e para agentes de IA que precisem entender como o sistema de diálogo funciona e como ele se integra com NPCs e quests.

---

## 1. Visão Geral

O sistema de diálogo permite que NPCs exibam conversas com o jogador, usando uma caixa de diálogo com efeito de digitação, participantes visuais e controle de avanço por input.

O sistema atual suporta:

- diálogos com múltiplas falas
- participantes diferentes
- fala do NPC
- fala do player
- efeito de texto sendo escrito progressivamente
- avanço de página
- skip do texto atual
- encerramento de diálogo
- callbacks ao terminar o diálogo
- integração com o sistema de quests
- câmera focando no NPC durante o diálogo
- bloqueio de menus/player durante o diálogo

---

## 2. Estruturas Principais

---

## 2.1 Dialogue

Representa uma conversa completa.

```gml
function Dialogue(_texts, _participants, _textSpeed = .7) constructor {
    texts = _texts;
    participants = _participants;
    textSpeed = _textSpeed;
}
```

### Propriedades

```gml
texts
participants
textSpeed
onEnd
```

### Descrição

- `texts`: lista de falas do diálogo
- `participants`: participantes da conversa
- `textSpeed`: velocidade do efeito de digitação
- `onEnd`: callback opcional executado quando o diálogo termina

### Exemplo

```gml
var _dialogue = new Dialogue(
[
    new DialogueText("Finalmente conseguimos chegar na base em segurança...", false),
    new DialogueText("A primeira coisa que precisamos é de um machado.", false),
    new DialogueText("Entendi. Vou preparar um machado pra gente.", true),
],
new DialogueParticipant(
    name,
    genderId,
    skinColor,
    hairColor,
    hairOption,
    -1,
    -1
));
```

---

## 2.2 DialogueText

Representa uma fala individual dentro de um diálogo.

```gml
function DialogueText(_text, _participantIndex) constructor {
    text = _text;
    participantIndex = _participantIndex;
}
```

### Propriedades

```gml
text
participantIndex
```

### Observação

O segundo parâmetro indica quem está falando.

Na implementação atual, ele pode ser usado para diferenciar NPC e player.

Exemplo usado no projeto:

```gml
new DialogueText("Fala do NPC", false)
new DialogueText("Fala do player", true)
```

---

## 2.3 DialogueParticipant

Representa os dados visuais de um participante do diálogo.

```gml
function DialogueParticipant(
    _name,
    _gender,
    _skinColor,
    _hairColor,
    _hairId,
    _armor,
    _helmet
) constructor {
    name = _name;
    gender = _gender;
    skinColor = _skinColor;
    hairColor = _hairColor;
    hairId = _hairId;
    armor = _armor;
    helmet = _helmet;
}
```

### Propriedades

```gml
name
gender
skinColor
hairColor
hairId
armor
helmet
```

### Uso

O participante é usado para desenhar o corpo/personagem na interface do diálogo.

Para o player, o sistema usa os dados globais do jogador:

```gml
global.player.name
global.player.gender
global.player.skinColor
global.player.hair
global.equipments
```

---

## 3. obj_dialogue

O `obj_dialogue` é responsável por executar e desenhar o diálogo.

Ele recebe o diálogo através de `instance_create_layer`, geralmente vindo de um NPC.

Exemplo:

```gml
instance_create_layer(0, 0, "Controllers", obj_dialogue, {
    target: id,
    dialogue: _dialogue
});
```

---

## 3.1 Inicialização

Ao ser criado, o `obj_dialogue`:

- abre o menu de diálogo
- bloqueia menus do player
- inicializa página atual
- inicializa índice do texto
- altera o estado do player para estado de diálogo
- ajusta a câmera para focar no NPC alvo

Fluxo:

```gml
openMenu(Menus.Dialogue);
blockPlayerMenus();

currentPage = 0;
textIndex = 0;
animationProgress = 0;

obj_player.currentState = playerDialogueState;

if (instance_exists(target)) {
    obj_camera.setTargetWithZoom(target);
}
```

Caso `dialogue` não seja uma struct válida, o objeto é destruído.

---

## 3.2 endDialogue

Função responsável por encerrar o diálogo.

Responsabilidades:

- fechar menu
- desbloquear menus do player
- executar `dialogue.onEnd`, se existir
- notificar o sistema de quests
- restaurar câmera
- restaurar estado do player
- liberar o NPC de interação
- destruir o `obj_dialogue`

Exemplo conceitual:

```gml
function endDialogue() {
    closeMenu();
    unBlockPlayerMenus();

    if (!is_undefined(dialogue.onEnd)) {
        dialogue.onEnd();
    }

    obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {
        npc: target
    });

    if (instance_exists(target)) {
        target.isInteracting = false;
    }

    obj_camera.setDefaultScale();
    obj_camera.target = obj_player;

    obj_player.currentState = playerIddleState;

    instance_destroy(id);
}
```

### Observação importante

O `DialogueEnded` deve informar o NPC alvo:

```gml
{
    npc: target
}
```

Isso permite que quests validem diálogos com NPCs específicos.

---

## 3.3 Proteção contra múltiplos encerramentos

É recomendado manter uma flag defensiva:

```gml
isEnding = false;
```

E no `endDialogue`:

```gml
if (isEnding) return;
isEnding = true;
```

Isso evita que o diálogo seja encerrado mais de uma vez no mesmo frame, especialmente porque `instance_destroy()` não remove o objeto imediatamente durante a execução do evento atual.

---

## 4. Desenho da caixa de diálogo

A função `drawDialogueBox()` controla:

- animação de entrada da caixa
- posição da caixa na GUI
- cálculo de área de texto
- desenho do box do avatar
- desenho do box de texto
- efeito typewriter
- input para avançar ou completar texto
- desenho do personagem/NPC
- desenho do nome do participante

---

## 4.1 Efeito de digitação

O sistema usa `textIndex` para mostrar apenas parte do texto atual.

```gml
if (textIndex <= _textSize) {
    textIndex += dialogue.textSpeed;
}
```

O texto exibido é:

```gml
var _currentTextPart = string_copy(_text, 1, textIndex);
```

---

## 4.2 Avanço de texto

O input atual usa `vk_space`.

Fluxo:

```gml
if (keyboard_check_pressed(vk_space)) {
    if (textIndex < _textSize) {
        textIndex = _textSize;
    } else if (currentPage < _pageQuantity - 1) {
        currentPage++;
        textIndex = 0;
    } else {
        endDialogue();
    }
}
```

Comportamento:

- se o texto ainda está sendo escrito, espaço completa a fala atual
- se a fala já foi completada, espaço avança para a próxima
- se for a última fala, espaço encerra o diálogo

---

## 4.3 Câmera

Quando o diálogo começa, a câmera foca no NPC alvo:

```gml
obj_camera.setTargetWithZoom(target);
```

Quando o diálogo termina:

```gml
obj_camera.setDefaultScale();
obj_camera.target = obj_player;
```

---

## 5. Integração com NPCs

NPCs possuem uma função:

```gml
getCurrentDialogue()
```

Essa função retorna o diálogo atual do NPC com base no estado do jogo.

Isso substitui a abordagem antiga de definir `dialogue` apenas no Create do NPC.

---

## 5.1 Por que usar getCurrentDialogue

O Create do NPC roda apenas uma vez.

Se o diálogo for definido somente ali, ele não muda quando:

- uma quest começa
- uma quest avança
- uma quest termina
- um novo step fica ativo
- o NPC precisa responder a uma nova situação

Por isso, o NPC deve gerar ou retornar o diálogo no momento da interação.

---

## 5.2 Fluxo de interação com NPC

Fluxo atual:

```text
Player interage com NPC
    ↓
NPC monta lista de opções
    ↓
Player escolhe "Conversar"
    ↓
NPC chama getCurrentDialogue()
    ↓
Se houver diálogo válido, cria obj_dialogue
```

Exemplo:

```gml
case "talk":
    closeInteractOptions();

    var _dialogue = getCurrentDialogue();

    if (is_struct(_dialogue)) {
        isInteracting = true;

        currentDialogue = instance_create_layer(
            0,
            0,
            "Controllers",
            obj_dialogue,
            {
                target: id,
                dialogue: _dialogue
            }
        );
    }
break;
```

---

## 5.3 isInteracting

NPCs usam:

```gml
isInteracting
```

Essa flag impede que o mesmo NPC abra múltiplos diálogos simultaneamente.

Problema resolvido:

- diálogo duplicado
- callbacks executados duas vezes
- `completeCurrentStep()` rodando mais de uma vez
- erro ao tentar avançar uma quest já finalizada
- bugs de frame e reentrada

Ao abrir diálogo:

```gml
isInteracting = true;
```

Ao encerrar diálogo:

```gml
target.isInteracting = false;
```

---

## 6. Integração com Quests

Diálogos podem iniciar, avançar ou concluir quests.

Isso é feito principalmente através de:

```gml
dialogue.onEnd
```

E também via:

```gml
QuestEvent.DialogueEnded
```

---

## 6.1 Iniciando quest ao terminar diálogo

Exemplo:

```gml
_dialogue.onEnd = function () {
    var _quest = obj_quest_manager.getCreateAxeQuest(id);

    obj_quest_manager.addQuest(_quest);
    obj_quest_manager.startQuest(_quest);
};
```

Esse padrão é usado quando o NPC dá uma missão ao jogador após o diálogo inicial.

---

## 6.2 Completando step ao terminar diálogo

Quando uma quest pede para falar com um NPC específico, o diálogo pode completar o step atual.

Exemplo:

```gml
_dialogue.onEnd = method(_quest, function () {
    self.completeCurrentStep();
});
```

Importante: usar `method(_quest, function(){})` mantém `self` apontando para a quest correta.

Não depender de variáveis locais como `_quest` dentro de `function(){}` comum, pois funções anônimas do GML podem não capturar escopo como closures de JavaScript/C#.

---

## 6.3 DialogueEnded como evento

Além do callback, o encerramento do diálogo também dispara evento para o sistema de quests:

```gml
obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {
    npc: target
});
```

Isso permite criar steps que reagem ao diálogo encerrado com um NPC específico.

Exemplo de step:

```gml
_talkStep.targetNpc = _npc;

_talkStep.onEvent = method(_talkStep, function (_event, _data) {
    if (_event != QuestEvent.DialogueEnded) return;

    if (_data.npc != self.targetNpc) return;

    self.quest.completeCurrentStep();
});
```

---

## 7. Exemplo: NPC sobrevivente

O NPC sobrevivente utiliza `getCurrentDialogue()` para mostrar diálogos diferentes dependendo da quest atual.

---

## 7.1 Antes da quest do machado

Se a quest `BecomeALumberjack` não está ativa e não foi concluída:

```gml
!obj_quest_manager.hasActiveQuest(Quests.BecomeALumberjack)
&&
!obj_quest_manager.hasCompletedQuest(Quests.BecomeALumberjack)
```

O NPC mostra o diálogo inicial explicando que o player precisa criar um machado.

Ao terminar:

```gml
var _quest = obj_quest_manager.getCreateAxeQuest(id);

obj_quest_manager.addQuest(_quest);
obj_quest_manager.startQuest(_quest);
```

---

## 7.2 Durante o step de retorno ao NPC

Quando a quest do machado está ativa e no step de retornar ao sobrevivente, o NPC mostra um novo diálogo.

Esse diálogo parabeniza o player pelo machado e introduz a necessidade de construir uma fogueira.

Ao terminar:

```gml
_quest.completeCurrentStep();
```

Isso conclui a quest do machado.

A quest do machado, em seu `onComplete`, inicia a quest da fogueira.

---

## 8. Cuidados técnicos

---

## 8.1 Evitar diálogo fixo no Create

Evitar:

```gml
dialogue = new Dialogue(...);
```

como única fonte de verdade.

Preferir:

```gml
function getCurrentDialogue() {
    // decide o diálogo baseado no estado atual
}
```

Isso evita diálogo desatualizado quando uma quest avança.

---

## 8.2 Evitar múltiplas interações

Sempre proteger NPCs com:

```gml
isInteracting
```

Antes de abrir diálogo:

```gml
if (isInteracting) return;
```

---

## 8.3 Cuidado com callbacks e escopo

Evitar:

```gml
_dialogue.onEnd = function () {
    _quest.completeCurrentStep();
};
```

Quando `_quest` é uma variável local.

Preferir:

```gml
_dialogue.onEnd = method(_quest, function () {
    self.completeCurrentStep();
});
```

ou associar dados diretamente no diálogo.

---

## 8.4 Evitar depender apenas de currentStepIndex

Usar índices como:

```gml
_quest.currentStepIndex == 3
```

funciona, mas pode ser frágil.

Preferir `step.id` com strings simples:

```gml
"return_to_survivor"
"craft_axe"
"collect_materials"
```

Exemplo:

```gml
var _step = _quest.getCurrentStep();

if (!is_undefined(_step) && _step.id == "return_to_survivor") {
    // diálogo contextual
}
```

---

## 9. Estado atual

O sistema de diálogo atualmente suporta:

- diálogo com múltiplas páginas
- efeito de digitação
- skip de texto
- avanço de páginas
- encerramento com callback
- desenho de NPC/player
- foco de câmera
- bloqueio de menus/player
- integração com quests
- diálogo dinâmico por NPC
- proteção contra interação duplicada
- uso de `getCurrentDialogue()` para diálogos contextuais

Esse sistema já é suficiente para o tutorial inicial e para NPCs com diálogo condicionado por progresso de quest.

---

## 10. Possíveis evoluções futuras

Não implementadas ainda, mas compatíveis com a arquitetura atual:

- opções de diálogo
- escolhas do jogador
- branching dialogue
- condições por fala
- ações por fala
- retratos específicos por NPC
- histórico de diálogos
- integração com reputação
- integração com trade
- diálogo que libera loja
- diálogo que entrega item
- diálogo que inicia cutscene
- diálogo carregado de dados externos