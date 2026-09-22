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
{"status":"running","model_ready":false}
```

Isso indica que o servidor HTTP está ativo; o modelo ainda não está disponível.

Exemplo em Bash, sem gravar o segredo no histórico ou nos argumentos do curl:

```bash
read -r -s -p 'Token: ' MUSARANHO_TOKEN
printf '\n'
printf 'Authorization: Bearer %s\n' "$MUSARANHO_TOKEN" |
  curl --header @- http://127.0.0.1:8888/health
unset MUSARANHO_TOKEN
```

## Inferência: estado atual

`POST /v1/systemone` está protegido pela autenticação, mas ainda não executa o modelo. Uma chamada autenticada retorna `503`:

```json
{"error":{"code":"model_not_ready","message":"Musaranho inference is not implemented yet"}}
```

O corpo JSON é obrigatório e validado antes de chegar à etapa de inferência. Um lote válido retorna `503 model_not_ready` enquanto o modelo não estiver integrado. A API não gera respostas simuladas.

## Perguntas e respostas em lote

Envie as 50 perguntas em um único `POST /v1/systemone`, dentro de `questions`, usando um ID exclusivo para cada uma. Todas compartilham o mesmo `state`; a resposta prevista contém uma entrada em `answers` para cada ID. O [exemplo JSON](../examples/systemone.request.json) mostra três perguntas dos três tipos; o mesmo formato aceita 50. Não há endpoint separado nem modo assíncrono de jobs.

Cada pergunta é independente: não recebe respostas de outras perguntas como contexto. A ordem dos IDs não define dependência. Perguntas dependentes exigem chamadas sucessivas; `depends_on` não faz parte deste contrato. A validação é do lote inteiro: uma pergunta inválida rejeita a requisição com `422`, sem resultado parcial. IDs duplicados no JSON também são rejeitados.

Use `Content-Type: application/json`. O corpo pode ter até **2 MiB**; não há limite fixo de 50 perguntas. `state` aceita texto, objeto ou array. As instruções são opcionais e aceitam texto, objeto, array ou null. Choice exige um mapa não vazio de alternativas; Score exige uma lista ordenada não vazia; Noul aceita descrições opcionais de `true` e `false`.

**Execução neural planejada:** avaliar perguntas em lotes de tensores com o mesmo modelo carregado, explorando paralelismo da GPU e dividindo lotes conforme a memória disponível. Enviar 50 perguntas não significa carregar 50 modelos nem garante ganho de 50 vezes. O backend ainda não está integrado: esta versão valida entrada e formato de saída, mas não executa inferência em paralelo e não tem latência medida. A velocidade e a independência das previsões deverão ser avaliadas com o modelo real.

## Contrato de decisões

A requisição contém `state`, `model` e `questions`. Cada pergunta tem um ID escolhido pela aplicação, `type` e `instructions`. Choice usa critérios nomeados; Score usa uma lista ordenada; Noul representa uma decisão sim/não. Veja o [exemplo completo](../examples/systemone.request.json).

O identificador `musaranho-format-example` dos exemplos é ilustrativo, não o nome de um modelo disponível. Os identificadores aceitos serão publicados com a versão de inferência.

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
| `200` | — | Health autenticado |
| `400` | `invalid_request` | JSON malformado |
| `401` | `unauthorized` | Token ausente, inválido, expirado ou revogado |
| `413` | `payload_too_large` | Corpo maior que 2 MiB |
| `415` | `unsupported_media_type` | Content-Type incompatível |
| `422` | `invalid_request` | Campos, perguntas, critérios ou IDs inválidos |
| `503` | `authentication_unavailable` | Não foi possível verificar a credencial; acesso bloqueado |
| `503` | `model_not_ready` | Autenticação válida, mas inferência indisponível |

Rotas desconhecidas e métodos não suportados também exigem autenticação antes de retornar `404` ou `405`. Não dependa de um corpo JSON nesses dois casos.
