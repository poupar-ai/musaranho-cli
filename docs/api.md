# API

URL local padrão: `http://127.0.0.1:8888`. Para acesso remoto, utilize a URL HTTPS configurada pelo administrador da instalação.

## Autenticação

As rotas operacionais `/health` e `/v1/systemone` exigem um único cabeçalho:

```http
Authorization: Bearer <token>
```

Crie o token pelo [CLI](cli.md). Tokens na URL não são aceitos. Não existe autenticação por cookie nem endpoint público de administração.

## Swagger embutido

Abra `/docs` no endereço da sua instalação, por exemplo `http://127.0.0.1:8888/docs`. A interface, seus arquivos estáticos e `/openapi.json` são públicos para permitir carregar a documentação no navegador. Eles não dão acesso à inferência ou à administração.

Clique em **Authorize**, cole somente o token criado pelo CLI e confirme. Depois use **Try it out** e **Execute**. O Swagger envia o cabeçalho Bearer nas chamadas. A credencial não é persistida entre recarregamentos da página; não use um navegador compartilhado com um token ativo.

Os assets estão embutidos no executável: não é necessário instalar Swagger separadamente, acessar CDN ou enviar o contrato a um validador externo. A [especificação exportada](../openapi.json) é a mesma incorporada ao servidor daquela versão.

## Verificar o servidor

`GET /health` retorna `200` quando autenticado:

```json
{"status":"running","model_ready":true}
```

Isso indica que o servidor e o modelo estão prontos. Sem os pesos instalados, `model_ready` será `false`.

Exemplo em Bash, sem gravar o segredo no histórico ou nos argumentos do curl:

```bash
read -r -s -p 'Token: ' MUSARANHO_TOKEN
printf '\n'
printf 'Authorization: Bearer %s\n' "$MUSARANHO_TOKEN" |
  curl --header @- http://127.0.0.1:8888/health
unset MUSARANHO_TOKEN
```

## Inferência local

`POST /v1/systemone` executa o modelo instalado e retorna `200` com decisões reais. Use `model: "musaranho"` ou `model: "musaranho-0.3"`; a resposta identifica a versão efetivamente executada.

Um lote é processado por vez para limitar o uso de memória. Chamadas simultâneas recebem `503 model_busy` com `Retry-After: 1`. Sem modelo instalado, retorna `503 model_not_ready`. As entradas não são enviadas a serviços externos.

## Perguntas e respostas em lote

Envie as 50 perguntas em um único `POST /v1/systemone`, dentro de `questions`, usando um ID exclusivo para cada uma. Todas compartilham o mesmo `state`; a resposta contém uma entrada em `answers` para cada ID. O [exemplo JSON](../examples/systemone.request.json) mostra três perguntas dos três tipos; o mesmo formato aceita 50. Não há endpoint separado nem modo assíncrono de jobs.

Cada pergunta é independente: não recebe respostas de outras perguntas como contexto. A ordem dos IDs não define dependência. Perguntas dependentes exigem chamadas sucessivas; `depends_on` não faz parte deste contrato. A validação é do lote inteiro: uma pergunta inválida rejeita a requisição com `422`, sem resultado parcial. IDs duplicados no JSON também são rejeitados.

Use `Content-Type: application/json`. O corpo pode ter até **2 MiB**, com **1 a 50 perguntas**. `state` aceita texto, objeto ou array. Cada pergunta exige `instructions` como texto não vazio. Choice exige um mapa não vazio de alternativas; Score exige uma lista ordenada não vazia; Noul aceita critérios opcionais, contendo ambos `true` e `false` quando fornecidos.

O limite é de **8.192 tokens para o estado** e, separadamente, **8.192 tokens para cada pergunta com seu catálogo de opções**. Entradas maiores são rejeitadas com `422`; não há truncamento silencioso. O limite técnico não é uma garantia de qualidade em textos longos.

## Contrato de decisões

A requisição contém `state`, `model` e `questions`. Cada pergunta tem um ID escolhido pela aplicação, `type` e `instructions`. Choice usa critérios nomeados; Score usa uma lista ordenada; Noul representa uma decisão sim/não. Veja o [exemplo completo](../examples/systemone.request.json).

O alias `musaranho` seleciona o modelo `musaranho-0.3` nesta versão.

| Local | Campos da resposta |
| --- | --- |
| Resposta | `model`, `answers`, `usage` |
| Choice | `type`, `choice`, `probabilities`, `confidence` |
| Score | `type`, `score`, `legend`, `probabilities`, `confidence` |
| Noul | `type`, `noul` |
| Usage | `input_tokens`, `output_tokens` |

Os IDs em `answers` correspondem aos IDs em `questions`. Choice retorna a alternativa selecionada e as probabilidades por rótulo. Score retorna a média ponderada dos índices da escala, com índices como strings nas probabilidades e na legenda. Noul retorna uma probabilidade entre zero e um, não um booleano.

`confidence` resume a concentração da distribuição; não é garantia de acerto. O contrato atual usa entropia normalizada. Não transfira limiares de confiança entre modelos sem avaliação. O formato prevê `output_tokens` igual a zero e `input_tokens` medido pela execução real.

Veja a [resposta ilustrativa](../examples/systemone.response.json). Os números e o uso de tokens desse arquivo são exemplos, não métricas de inferência.

## Compatibilidade

O contrato compartilha os campos principais com [Jev/TypeSafe](https://docs.typesafe.ai/api) e [Laya](https://github.com/NandhaKishorM/laya). A formatação foi testada com o SDK TypeSafe e comparada com respostas Laya. Isso não garante compatibilidade completa entre servidores ou SDKs, nem equivalência de previsões.

Os extras `action` e `noul.confidence` do Laya não integram o contrato comum. Integrações que dependam deles precisam de adaptação. Não há suporte anunciado ao carregamento de pesos Jev/Laya.

## Códigos atuais

| HTTP | Código | Significado |
| --- | --- | --- |
| `200` | — | Health ou inferência concluída |
| `400` | `invalid_request` | JSON malformado |
| `401` | `unauthorized` | Token ausente, inválido, expirado ou revogado |
| `413` | `payload_too_large` | Corpo maior que 2 MiB |
| `415` | `unsupported_media_type` | Content-Type incompatível |
| `422` | `invalid_request` | Campos, perguntas, critérios ou IDs inválidos |
| `503` | `authentication_unavailable` | Não foi possível verificar a credencial; acesso bloqueado |
| `503` | `model_not_ready` | Modelo não instalado |
| `503` | `model_busy` | Lote em execução; tente novamente após o intervalo informado |
| `500` | `inference_failed` | Falha ao executar o modelo |

Rotas desconhecidas e métodos não suportados também exigem autenticação antes de retornar `404` ou `405`. Não dependa de um corpo JSON nesses dois casos.
