# Jev × Musaranho: comparação experimental

Medição de **22 de setembro de 2026**, realizada pela equipe do Musaranho. **Jev teve maior acerto neste conjunto.** Os candidatos Musaranho responderam com menor latência no processo local, enquanto Jev foi acessado por API remota. Essas topologias diferentes não permitem concluir qual modelo tem menor tempo interno de inferência.

Continuação deste estudo: [comparação com Laya](laya-vs-musaranho.md). Os números abaixo correspondem à avaliação anterior.

**Os candidatos avaliados são privados e experimentais. O pacote público Musaranho 0.1.5 continua sem inferência: `/v1/systemone` retorna `503 model_not_ready`.** Este relatório não anuncia uma versão de modelo disponível para instalação.

Os [resultados agregados em JSON](../benchmarks/jev-vs-musaranho-2026-09-22.json) contêm métricas, amostras de latência e entradas do microbenchmark. Não há afiliação ou validação deste estudo pela TypeSafe ou pelo OpenRouter.

## O que foi comparado

| Item | Jev | Musaranho controle | Musaranho variante |
|---|---|---|---|
| Identificação | `typesafe/jev-1.13-20260917` | Candidato de controle | Candidato alternativo |
| Execução medida | OpenRouter Decisions API | Execução local | Execução local |
| Saída | `choice`, `score`, `noul` | `choice`, `score`, `noul` | `choice`, `score`, `noul` |
| Entradas de qualidade | Os mesmos 256 casos | Os mesmos 256 casos | Os mesmos 256 casos |
| Rede durante a inferência | Incluída na chamada à API | Sem acesso à rede | Sem acesso à rede |
| Disponibilidade nesta avaliação | Serviço externo autenticado | Experimento privado | Experimento privado |

Jev foi solicitado como `typesafe/jev-1.13`, pela [API oficial de decisões do OpenRouter](https://openrouter.ai/docs/api/api-reference/alphadecisions/submit-a-decisions-questions-and-answers-request). Todas as respostas identificaram a mesma revisão acima. As condições do serviço remoto não foram controladas ou verificadas.

## Qualidade nos mesmos casos

**256 casos, 704 perguntas, 247 grupos; nenhuma exclusão ou resposta inválida.** São casos de validação usados no desenvolvimento, em português, inglês e espanhol. Não se trata de um teste final independente.

| Métrica | Jev | Musaranho controle | Musaranho variante |
|---|---:|---:|---:|
| Acerto global por pergunta | **80,54%** | 58,24% | 55,82% |
| Acerto macro por recorte | **87,10%** | 65,16% | 60,10% |
| Choice: alternativa mais provável | **80,75%** | 55,75% | 50,00% |
| Noul: alternativa mais provável | **80,98%** | 77,30% | 76,07% |
| Score: alternativa mais provável | **79,79%** | 46,63% | 49,22% |
| Score: erro absoluto ordinal médio ↓ | **0,2557** | 0,6407 | 0,5881 |

O global dá peso igual a cada pergunta. A macro dá peso igual às células de fonte, workflow, idioma e tipo. O acerto considera a alternativa com maior probabilidade; empates seguem a ordem das opções solicitadas, e qualquer alternativa máxima do gabarito conta como correta. Esse procedimento coincidiu com todas as escolhas nativas `choice` do Jev nesta amostra. Para Score, o erro ordinal compara os valores esperados das distribuições; escalas diferentes não foram normalizadas para 0–1.

Diferença macro **Musaranho menos Jev**, com bootstrap pareado por grupo, 2.000 reamostragens:

- Controle: **−21,94 pontos percentuais**, IC95% **[−26,11; −17,76]**.
- Variante: **−27,00 pontos percentuais**, IC95% **[−32,39; −21,26]**.

Esses intervalos descrevem variação dos casos nesta avaliação; não incluem variação entre treinos, sementes ou revisões do serviço.

### Resultados por fonte

| Fonte | Casos / perguntas | Jev | Controle | Variante |
|---|---:|---:|---:|---:|
| CLINC150 Plus | 62 / 62 | 93,55% | 33,87% | 30,65% |
| MASSIVE 1.1 | 62 / 124 | 75,00% | 56,45% | 50,00% |
| Typed Decisions | 61 / 305 | 68,20% | 52,79% | 53,11% |
| Oráculos sintéticos de matemática/lógica | 62 / 186 | 97,31% | 75,27% | 73,66% |
| Semente sintética interna | 9 / 27 | 100,00% | 66,67% | 48,15% |

A última linha tem amostra pequena e não sustenta uma conclusão ampla. Oráculos usam templates fixos; acertá-los não comprova raciocínio matemático irrestrito. Os dados misturam rótulos categóricos, gabaritos sintéticos e oráculos executáveis. Parte das fontes é pública e pode ter aparecido no treinamento de modelos de referência; não há garantia de ausência de contaminação externa.

## Latência observada

Valores em **ms, p50 / p95**, com 20 medições após três aquecimentos em cada cenário. Uma requisição por vez, pesos locais residentes, incluindo tokenização, transferências, inferência e serialização. A API Jev inclui conexão TLS, rede, roteamento e processamento remoto; o cliente usado não reutiliza conexões HTTP. A medição local do Musaranho não inclui uma camada HTTP.

| Cenário | Jev via API | Musaranho controle local | Musaranho variante local |
|---|---:|---:|---:|
| Contexto curto, 1 pergunta | 502,81 / 653,00 | 11,69 / 12,35 | 12,57 / 13,64 |
| Contexto curto, 4 perguntas | 456,46 / 769,53 | 12,12 / 12,93 | 12,80 / 14,05 |
| Contexto curto, 16 perguntas | 550,94 / 1509,13 | 46,67 / 50,34 | 46,87 / 53,40 |
| Contexto curto, 50 perguntas | 468,17 / 579,07 | 156,14 / 167,59 | 145,59 / 157,66 |
| Contexto longo, 1 pergunta | 654,63 / 1759,58 | 23,26 / 26,04 | 22,19 / 23,18 |
| Contexto longo, 4 perguntas | 560,84 / 1272,70 | 25,63 / 28,39 | 22,97 / 25,22 |
| Contexto longo, 16 perguntas | 635,84 / 993,99 | 63,83 / 70,45 | 56,82 / 63,77 |
| Contexto longo, 50 perguntas | 823,56 / 1494,04 | 184,85 / 227,34 | 156,27 / 163,94 |

O contexto curto descreve uma capa de celular; o longo repete esse texto 40 vezes. Cada lote repete a mesma pergunta de três alternativas com IDs distintos. As entradas exatas estão no JSON. Não há cache de respostas na aplicação; caches internos do fornecedor não foram controlados. As medições locais e remotas ocorreram em momentos diferentes no mesmo dia.

Esses números representam este microbenchmark e este caminho de acesso. Não medem tráfego heterogêneo, concorrência de produção, CPU, outras GPUs ou a velocidade interna do Jev. A latência remota não cresceu monotonicamente com o lote; os dados não isolam os efeitos de rede e carga do serviço. A comparação não justifica uma alegação geral de “Musaranho mais rápido que Jev”.

## Limites da avaliação

- Quinze distribuições de qualidade do Jev exigiram normalização de arredondamento, restrita à revisão observada e ao limite `min(0,02; 0,005 × alternativas)` de erro na soma, para valores com duas casas. Respostas brutas foram preservadas internamente. A normalização não muda a alternativa máxima. NLL/Brier/ECE no JSON são diagnósticos contra esses gabaritos; NLL usa piso `1e-30` e é sensível a zeros arredondados e alvos sintéticos suaves.
- Os pesos, o avaliador completo e os casos internos selecionados não estão publicados. Os dados agregados permitem conferir as tabelas, mas **não tornam o experimento integralmente reproduzível por terceiros**.
- A validação foi reaproveitada no desenvolvimento; variação entre treinamentos não avaliada. Não houve auditoria independente, teste privado humano, comprovação de segurança ou homologação de produção. Formato de resposta compatível não implica equivalência entre os modelos.

Fontes externas: [OpenRouter Decisions API](https://openrouter.ai/docs/api/api-reference/alphadecisions/submit-a-decisions-questions-and-answers-request), [modelo Jev no catálogo](https://openrouter.ai/typesafe/jev-1.13), [MASSIVE](https://huggingface.co/datasets/AmazonScience/massive), [CLINC](https://huggingface.co/datasets/clinc/clinc_oos) e [Typed Decisions](https://huggingface.co/datasets/LocalLLaMA/typed-decisions). As medições deste documento são próprias, não números publicados por esses fornecedores.
