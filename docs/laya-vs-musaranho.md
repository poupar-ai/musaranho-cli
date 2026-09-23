# Benchmark Laya × Musaranho

Medição de **22 de setembro de 2026**, feita pela equipe do Musaranho. Nas mesmas **704 perguntas**, o candidato Musaranho atingiu **70,45% de acerto global**, contra **57,67% do Laya Typed Decisions**, melhor referência Laya por acerto global e macro nesta amostra. O Router com detecção de tarefa atingiu 56,82%.

**São resultados de desenvolvimento, com limitações e diferenças por tarefa descritas abaixo. O candidato deste estudo é anterior ao modelo distribuído na versão 0.2.0; as latências abaixo não caracterizam a nova distribuição em CPU.** O candidato não foi promovido a produção.

[Dados do benchmark em JSON](../benchmarks/laya-vs-musaranho-2026-09-22.json): métricas e amostras de latência. O [comparativo Jev × Musaranho](jev-vs-musaranho.md) fica em um relatório separado.

## Leitura dos resultados

- **Acerto global:** Musaranho supera o melhor Laya em 12,78 pontos percentuais nesta validação.
- **Scores:** Laya Typed vence, com 70,98% de acerto contra 61,14%; também tem menor erro MAE.
- **Latência:** no cenário longo com 50 perguntas, Musaranho leva 36,59 ms em p50, 9,50× mais rápido que o Laya mais rápido nesse cenário. Com uma pergunta, Laya tem menor p50 nos dois tamanhos de contexto.
- **Limite da conclusão:** os ganhos não são uniformes; o candidato falhou na triagem de regressões e ainda precisa de avaliação independente.

## Qualidade nas mesmas perguntas

**256 casos / 704 perguntas / 247 grupos, sem exclusões**, em português, inglês e espanhol. Todos recebem os mesmos estados, instruções e alternativas.

| Modelo | Global | Macro | Choice | Noul | Score top-1 | Score MAE ↓ |
|---|---:|---:|---:|---:|---:|---:|
| Musaranho experimental | 70,45% | 73,83% | 72,13% | 77,91% | 61,14% | 0,4799 |
| Laya Typed Decisions | 57,67% | 41,37% | 43,39% | 72,39% | 70,98% | 0,3782 |
| Laya Router com detecção de tarefa | 56,82% | 41,37% | 42,82% | 70,55% | 70,47% | 0,3986 |
| Laya Multilingual | 40,91% | 41,09% | 37,36% | 49,08% | 40,41% | 0,7258 |
| Laya Router padrão | 35,37% | 36,56% | 27,87% | 42,94% | 42,49% | 0,6776 |
| Laya English | 35,09% | 35,15% | 26,15% | 44,17% | 43,52% | 0,6406 |

Global pesa cada pergunta igualmente; macro pesa igualmente cada célula fonte/workflow/idioma/tipo. Top-1 compara a alternativa mais provável ao máximo do gabarito; empates seguem a ordem das alternativas solicitadas e qualquer máximo do gabarito conta como acerto. Score MAE compara os valores esperados das distribuições, sem normalizar escalas diferentes para 0–1.

Diferenças globais **novo Musaranho menos referência**, com bootstrap pareado por grupo e 2.000 reamostragens:

- Laya Typed Decisions: **12,78 pp; IC95% [6,33; 19,88]**.
- Laya Router com detecção de tarefa: **13,64 pp; IC95% [7,02; 20,93]**.

Os intervalos descrevem a variação entre os casos avaliados. A seleção do candidato e das referências utilizou a validação; esses intervalos não corrigem o viés de seleção e não sustentam uma alegação de superioridade em dados novos.

### Por fonte

| Fonte | Musaranho | Laya Typed | Router tarefa | Laya Multi | Router padrão | Laya English |
|---|---:|---:|---:|---:|---:|---:|
| clinc150-plus | 79,03% | 29,03% | 24,19% | 62,90% | 24,19% | 24,19% |
| massive-1.1 | 79,03% | 33,06% | 31,45% | 43,55% | 31,45% | 28,23% |
| typed-decisions | 60,66% | 84,92% | 84,92% | 35,74% | 35,41% | 35,41% |
| reasoning-oracles | 79,57% | 35,48% | 36,56% | 36,56% | 36,56% | 38,17% |
| decision-seed | 59,26% | 81,48% | 70,37% | 66,67% | 70,37% | 66,67% |

Typed Decisions contém gabaritos sintéticos suaves, e os oráculos usam templates fixos. A semente interna tem apenas nove casos / 27 perguntas. Concordar com esses gabaritos não equivale a uma auditoria humana de capacidade geral. As fontes públicas podem ter aparecido no treino das referências; não foi possível descartar contaminação externa.

### Regressões que a média pode esconder

A triagem sinaliza quedas maiores que 5 pontos de acerto ou aumento acima de 0,05 no MAE, em recortes com pelo menos 20 perguntas e dez grupos. Não é um teste de significância. Valores negativos de diferença de acerto favorecem a referência; valores positivos de diferença de MAE desfavorecem o Musaranho.

| Referência | Recorte | Diferença de acerto | Diferença de MAE |
|---|---|---:|---:|
| Laya Typed Decisions | source/typed-decisions | -24,26 pp | 0,2956 |
| Laya Typed Decisions | language/en | -3,60 pp | 0,1890 |
| Laya Typed Decisions | kind/score | -9,84 pp | 0,1017 |
| Laya Router com detecção de tarefa | source/typed-decisions | -24,26 pp | 0,2956 |
| Laya Router com detecção de tarefa | language/en | -2,47 pp | 0,1781 |
| Laya Router com detecção de tarefa | kind/score | -9,33 pp | 0,0814 |

## Como o Laya foi testado

SDK **Laya 0.3.5**, três checkpoints locais fixados na revisão do bundle `1c5edc17a7acd8701df6fc341c0d179f1c62c982`. Testamos English, Multilingual, Typed Decisions e o Router oficial em dois modos. A rota padrão selecionou English para 183 casos e Multilingual para 73. Com `auto_task_detection=True`, foram 122 English, 73 Multilingual e 61 Typed Decisions. Essa opção reconhece conjuntos exatos de IDs dos quatro workflows; não é uma classificação geral de domínio. O roteador não recebeu idioma, fonte ou gabarito externos.

**Ajuste de avaliação:** ampliamos `max_len` e `head_max_len` ao contexto máximo do encoder, para preservar as entradas. A auditoria de tokenização encontrou cortes em 125 casos no English e Router padrão, e 124 no Multilingual, Typed e Router especializado, com os limites publicados. Não são pontuações obtidas com o limite padrão de contexto. As inferências comparadas passaram na verificação de conteúdo integral, incluindo todas as alternativas. Qualidade usa logits antes do arredondamento de quatro casas do SDK, com suas temperaturas efetivas; latência usa a resposta nativa.

As alegações da [página oficial do Laya](https://laya.convaiinnovations.com/) usam outros conjuntos e condições. Não importamos seus percentuais como resultados desta avaliação.

## Latência observada

**Milissegundos, p50 / p95**, após três aquecimentos e com 20 medições por cenário. Os modelos foram avaliados sequencialmente em condições equivalentes, sem incluir uma API remota. Os tempos descrevem apenas os cenários deste benchmark e não são uma garantia de desempenho em outras instalações.

| Contexto / perguntas | Musaranho | Laya Typed | Router tarefa | Laya Multi | Router padrão | Laya English |
|---|---:|---:|---:|---:|---:|---:|
| curto/1 | 12,50 / 13,00 | 14,25 / 15,06 | 11,01 / 11,30 | 11,38 / 11,69 | 11,06 / 11,73 | 14,17 / 14,53 |
| curto/4 | 12,73 / 13,20 | 14,71 / 15,58 | 11,37 / 11,83 | 11,21 / 11,99 | 11,18 / 11,46 | 14,63 / 14,82 |
| curto/16 | 14,64 / 15,87 | 31,24 / 32,30 | 13,86 / 15,54 | 14,06 / 15,20 | 13,50 / 13,57 | 31,58 / 31,73 |
| curto/50 | 25,12 / 28,46 | 80,46 / 82,92 | 30,98 / 34,36 | 31,63 / 34,13 | 31,15 / 31,44 | 80,60 / 81,35 |
| longo/1 | 20,94 / 21,73 | 31,05 / 32,23 | 13,23 / 14,14 | 12,31 / 12,63 | 13,47 / 14,13 | 31,33 / 31,94 |
| longo/4 | 23,66 / 25,18 | 108,22 / 112,58 | 37,07 / 42,14 | 36,52 / 37,32 | 37,13 / 37,76 | 109,57 / 113,85 |
| longo/16 | 24,58 / 25,15 | 364,87 / 372,05 | 121,05 / 121,46 | 121,08 / 122,68 | 121,90 / 123,04 | 387,11 / 399,05 |
| longo/50 | 36,59 / 38,47 | 1117,19 / 1157,37 | 347,68 / 365,40 | 347,62 / 348,57 | 350,88 / 352,99 | 1128,20 / 1204,96 |

O estado curto descreve uma capa de celular; o longo repete o texto 40 vezes. Cada lote repete a mesma pergunta de três alternativas com IDs distintos. Inclui tokenização, transferências, inferência e serialização; não mede tráfego heterogêneo ou concorrência de produção. Não há cache de respostas na aplicação.

## Rastreabilidade e limites

- Invariância do novo Musaranho: 775 comparações; maior diferença de probabilidade 0,002465, tolerância 0,003; resultado **passou**.
- Gate de desenvolvimento registrado: **não passou**. Ele combina ganho macro, regressões contra a referência selecionada, latência e invariância; passar ainda não aprova produção.
- Validação usada repetidamente no desenvolvimento; variação entre treinamentos não avaliada. O conjunto de teste final permanece sem avaliação. Ainda falta um teste privado independente com revisão humana.
- Código de treinamento, pesos Musaranho e casos internos selecionados não estão publicados. Agregados permitem conferir as tabelas, mas não tornam o experimento integralmente reproduzível por terceiros.
- Não há afiliação ou validação deste estudo pela ConvAI Innovations, TypeSafe ou OpenRouter. Compatibilidade de formato não implica equivalência de qualidade, comportamento ou disponibilidade.
