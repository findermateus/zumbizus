# Sistema de Quests — Contexto Técnico

Este documento descreve o sistema de quests atualmente implementado no projeto **Zumbizus**.

O objetivo deste arquivo é servir como contexto para desenvolvimento futuro e para agentes de IA que precisem entender a arquitetura atual do jogo.

---

## 1. Visão Geral

O sistema de quests do jogo é baseado em **missões sequenciais orientadas a eventos**.

Uma quest é composta por uma lista de steps (`QuestStep`). Cada step representa uma etapa da missão e é concluído quando uma condição específica é atendida.

O sistema não depende de checagens constantes no Step Event. Em vez disso, o jogo dispara eventos relevantes para o `obj_quest_manager`, e o step atual de cada quest ativa decide se deve reagir a esse evento.

Exemplos de eventos:

```gml
QuestEvent.ItemCollected
QuestEvent.ItemCrafted
QuestEvent.EnemyKilled
QuestEvent.AreaEntered
QuestEvent.DialogueEnded
QuestEvent.FurnitureCrafted
```

Fluxo geral:

```text
Evento de gameplay
    ↓
obj_quest_manager.notifyEvent(event, data)
    ↓
Quest ativa recebe evento
    ↓
Step atual avalia evento
    ↓
Step completa
    ↓
Quest avança para o próximo step
    ↓
Quest termina quando não há mais steps
```

---

## 2. Entidades Principais

---

## 2.1 Quest

Representa uma missão completa.

### Responsabilidades

- armazenar steps
- controlar step atual
- iniciar missão
- completar step atual
- concluir quest
- aplicar recompensa
- executar callback de conclusão

### Propriedades principais

```gml
id
name
steps
currentStepIndex
isActive
isCompleted
reward
```

### Callbacks

```gml
onComplete()
```

Executado quando todos os steps da quest foram concluídos.

### Métodos esperados

```gml
addStep(step)
```

Adiciona um step à quest e associa o step à quest.

```gml
getCurrentStep()
```

Retorna o step atual.

Recomendação: deve ser seguro e retornar `undefined` caso `currentStepIndex` esteja fora do array.

```gml
completeCurrentStep()
```

Conclui o step atual, avança para o próximo e, se não houver mais steps, finaliza a quest.

```gml
setReward(reward)
```

Define a recompensa da quest.

```gml
applyReward()
```

Aplica XP e itens configurados em `QuestReward`.

---

## 2.2 QuestStep

Representa uma etapa individual de uma quest.

### Responsabilidades

- descrever um objetivo
- reagir a eventos
- executar lógica ao iniciar
- executar lógica ao completar
- controlar progresso local, quando necessário

### Propriedades principais

```gml
id
description
quest
isCompleted
objectives
```

`id` deve ser uma string simples, por exemplo:

```gml
"collect_axe_materials"
"return_to_base"
"craft_axe"
"return_to_survivor"
```

Evitar depender apenas de `currentStepIndex` para lógica contextual.

### Callbacks

```gml
onStart()
```

Executado quando o step se torna ativo.

Usado, por exemplo, para verificar se o jogador já possui os itens necessários no inventário.

```gml
onEvent(event, data)
```

Executado quando o `obj_quest_manager` encaminha um evento para a quest ativa.

```gml
onComplete()
```

Executado quando o step é concluído.

---

## 2.3 QuestReward

Representa recompensas de uma quest.

### Propriedades principais

```gml
xp
items
```

### Estrutura dos itens

Todo item deve sempre ser representado usando **itemType + itemId**.

Nunca tratar `itemId` sozinho como identificador completo.

Exemplo:

```gml
{
    itemId: consumableItems.watter_bottle,
    itemType: itemType.consumables
}
```

---

## 3. Quest Manager

O `obj_quest_manager` centraliza o controle das quests.

### Estruturas principais

```gml
quests
activeQuests
completedQuests
```

### Observação importante

`completedQuests` armazena ids das quests concluídas, não necessariamente a struct inteira da quest.

---

## 3.1 Métodos principais

```gml
addQuest(quest)
```

Adiciona uma quest ao registro geral.

```gml
startQuest(quest)
```

Inicia a quest, adiciona em `activeQuests` e dispara popup de quest adicionada.

```gml
completeQuest(quest)
```

Marca a quest como concluída, remove de `activeQuests`, adiciona o id em `completedQuests` e dispara popup de quest concluída.

```gml
notifyEvent(event, data)
```

Encaminha o evento para o step atual de cada quest ativa.

Exemplo esperado:

```gml
notifyEvent = function(_event, _data) {
    for (var i = 0; i < array_length(activeQuests); i++) {
        var _quest = activeQuests[i];

        if (!_quest.isActive || _quest.isCompleted) continue;

        var _step = _quest.getCurrentStep();

        if (is_undefined(_step)) continue;

        var _fn = method(_step, _step.onEvent);
        _fn(_event, _data);
    }
};
```

```gml
hasActiveQuest(questId)
```

Verifica se uma quest está ativa.

Recomendação: ignorar quests já marcadas como completas.

```gml
hasCompletedQuest(questId)
```

Verifica se uma quest já foi concluída.

```gml
getQuest(questId)
```

Retorna a quest pelo id.

Recomendação: buscar preferencialmente em `activeQuests` quando o objetivo for manipular uma quest em andamento.

---

## 4. Sistema de Eventos

As quests reagem a eventos disparados pelo jogo.

Exemplo:

```gml
obj_quest_manager.notifyEvent(
    QuestEvent.ItemCollected,
    {
        itemId: trashItems.twig,
        itemType: itemType.trash,
        quantity: 3
    }
);
```

Cada step decide se o evento é relevante.

Exemplo:

```gml
if (_event != QuestEvent.ItemCollected) return;
```

---

## 4.1 Eventos atuais conhecidos

```gml
QuestEvent.ItemCollected
```

Disparado quando o jogador obtém um item do mundo, como loot de chão, container de exploração ou recompensa.

Não deve ser usado para movimentação interna de inventário ou organização em baús da base.

---

```gml
QuestEvent.ItemCrafted
```

Disparado quando um item é craftado.

---

```gml
QuestEvent.EnemyKilled
```

Disparado quando um inimigo é morto.

---

```gml
QuestEvent.AreaEntered
```

Disparado quando o jogador entra em uma área ou room relevante.

---

```gml
QuestEvent.DialogueEnded
```

Disparado quando um diálogo termina.

Deve incluir o NPC alvo:

```gml
{
    npc: target
}
```

---

```gml
QuestEvent.FurnitureCrafted
```

Disparado quando uma mobília/estrutura é construída ou craftada.

Exemplo:

```gml
{
    furnitureId: global.furnitureIds.campfire
}
```

---

## 5. Convenção obrigatória de itens

No projeto, `itemId` e `itemType` andam juntos.

Sempre validar os dois.

Correto:

```gml
if (_data.itemId == obj.itemId && _data.itemType == obj.type) {
    // progresso
}
```

Evitar:

```gml
if (_data.itemId == obj.itemId) {
    // frágil
}
```

Motivo: pode haver ids iguais em tipos diferentes.

---

## 6. Objectives

Steps de coleta podem possuir múltiplos objetivos internos.

Exemplo:

```gml
_step.objectives = [
    { itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
    { itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
];
```

Cada objetivo possui:

```gml
itemId
type
count
target
```

O step é concluído quando todos os objetivos atingem o `target`.

---

## 7. Helper: createCollectItemsStep

Foi criado um helper para encapsular steps de coleta.

Arquivo sugerido:

```text
scr_quest_steps
```

Função:

```gml
createCollectItemsStep(id, description, objectives)
```

Responsabilidades:

- criar um `QuestStep`
- receber lista de objetivos
- sincronizar progresso inicial com inventário no `onStart`
- reagir a `QuestEvent.ItemCollected`
- validar `itemId + itemType`
- somar progresso por quantidade
- limitar progresso ao target
- completar o step quando todos os objetivos forem atingidos

Exemplo de uso:

```gml
var _step = createCollectItemsStep(
    "collect_axe_materials",
    "Colete os itens necessários",
    [
        { itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
        { itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
    ]
);

_quest.addStep(_step);
```

---

## 8. Integração com Diálogo

O sistema de diálogo é integrado ao sistema de quests.

NPCs possuem a função:

```gml
getCurrentDialogue()
```

Essa função retorna dinamicamente o diálogo correto de acordo com o estado do jogo.

Importante: o diálogo não deve depender apenas do evento Create do NPC, porque o estado das quests pode mudar sem o NPC ser recriado.

---

## 8.1 Fluxo de diálogo com quest

Exemplo da progressão inicial:

```text
NPC conversa com player
    ↓
dialogue.onEnd inicia quest do machado
    ↓
player coleta itens
    ↓
player volta para base
    ↓
player crafta machado
    ↓
quest pede para falar com NPC
    ↓
NPC mostra novo diálogo
    ↓
dialogue.onEnd completa último step
    ↓
quest do machado termina
    ↓
quest da fogueira inicia
```

---

## 8.2 DialogueEnded

Ao encerrar diálogo, o `obj_dialogue` deve disparar:

```gml
obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {
    npc: target
});
```

Isso permite steps do tipo “fale com NPC específico”.

---

## 9. NPCs e controle de interação

NPCs usam:

```gml
isInteracting
```

Esse controle impede múltiplas interações simultâneas com o mesmo NPC.

Isso foi necessário para evitar bugs de reentrada, como:

- abrir dois diálogos ao mesmo tempo
- executar `dialogue.onEnd` mais de uma vez
- completar o mesmo step múltiplas vezes
- quebrar quests ao avançar além do último step

Ao abrir diálogo:

```gml
isInteracting = true;
```

Ao finalizar diálogo:

```gml
target.isInteracting = false;
```

---

## 10. Exemplo: Quest do Machado

Quest:

```gml
Quests.BecomeALumberjack
```

Nome:

```text
Se torne um Lenhador
```

Fluxo:

1. Coletar itens necessários
2. Voltar para a base
3. Fazer o machado
4. Falar com o sobrevivente

Ao concluir, aplica recompensa e inicia a quest da fogueira.

### Step de coleta

Criado com:

```gml
createCollectItemsStep(...)
```

Objetivos:

```gml
[
    { itemId: trashItems.twig, type: itemType.trash, count: 0, target: 3 },
    { itemId: trashItems.rock, type: itemType.trash, count: 0, target: 2 }
]
```

### Step de retorno para base

Reage a:

```gml
QuestEvent.AreaEntered
```

Também usa `onStart` para completar automaticamente caso o jogador já esteja na base.

### Step de craftar machado

Reage a:

```gml
QuestEvent.ItemCrafted
```

E valida:

```gml
itemType.weapons
weaponItems.axe
```

### Step de falar com NPC

Reage a:

```gml
QuestEvent.DialogueEnded
```

E valida:

```gml
_data.npc == self.targetNpc
```

---

## 11. Exemplo: Quest da Fogueira

Quest:

```gml
Quests.CraftACampfire
```

Nome:

```text
Descubra o Fogo
```

Fluxo:

1. Coletar itens necessários
2. Construir a fogueira

### Step de coleta

Criado com:

```gml
createCollectItemsStep(...)
```

Objetivos:

```gml
[
    { itemId: trashItems.wood_log, type: itemType.trash, count: 0, target: 6 },
    { itemId: trashItems.twig, type: itemType.trash, count: 0, target: 12 },
    { itemId: trashItems.rock, type: itemType.trash, count: 0, target: 8 }
]
```

### Step de construir fogueira

Reage a:

```gml
QuestEvent.FurnitureCrafted
```

Valida:

```gml
_data.furnitureId == global.furnitureIds.campfire
```

### Recompensas

A quest entrega XP e itens consumíveis.

Exemplo:

```gml
{
    itemId: consumableItems.watter_bottle,
    itemType: itemType.consumables
}
```

```gml
{
    itemId: consumableItems.canned_pineapple,
    itemType: itemType.consumables
}
```

---

## 12. Boas práticas atuais

### Preferir helpers quando houver repetição real

`createCollectItemsStep` foi criado porque o padrão de coleta se repetiu em mais de uma quest.

Não criar helpers genéricos cedo demais.

Exemplo: `createCraftItemStep`, `createTalkToNpcStep` e `createEnterAreaStep` ainda não são obrigatórios se existirem poucas ocorrências.

---

### Evitar overengineering

O sistema ainda está em desenvolvimento.

A prioridade é:

```text
gameplay funcional > arquitetura perfeita
```

Refatorar apenas quando houver repetição real ou dor clara.

---

### Evitar índices mágicos

Evitar depender apenas de:

```gml
quest.currentStepIndex == 3
```

Isso funciona, mas é frágil.

Preferir `step.id` em strings simples:

```gml
"return_to_survivor"
"craft_axe"
"collect_campfire_materials"
```

---

### Proteger sistemas contra reentrada

Sistemas de diálogo, NPC, trade e quest precisam evitar execução duplicada no mesmo frame.

Usar flags como:

```gml
isInteracting
isEnding
isCompleted
```

quando necessário.

---

## 13. Estado atual do sistema

O sistema atualmente suporta:

- quests sequenciais
- múltiplos steps
- recompensas
- XP
- itens como recompensa
- eventos de gameplay
- integração com NPCs
- integração com diálogos
- steps de coleta com múltiplos objetivos
- retorno para NPC
- encadeamento automático de quests
- popup de quest iniciada, step concluído e quest concluída

Esse sistema já é suficiente para construir o tutorial inicial completo do jogo.
