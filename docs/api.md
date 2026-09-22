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

O corpo de inferência ainda não é processado ou validado nesta prévia. Os formatos abaixo documentam o contrato pretendido para integração; não anunciam funcionalidade disponível.

## Contrato de decisões

A requisição prevista contém `state`, `model` e `questions`. Cada pergunta tem um ID escolhido pela aplicação, `type` e `instructions`. Choice usa critérios nomeados; Score usa uma lista ordenada; Noul representa uma decisão sim/não. Veja o [exemplo completo](../examples/systemone.request.json).

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
| `401` | `unauthorized` | Token ausente, inválido, expirado ou revogado |
| `503` | `authentication_unavailable` | Não foi possível verificar a credencial; acesso bloqueado |
| `503` | `model_not_ready` | Autenticação válida, mas inferência indisponível |

Rotas desconhecidas e métodos não suportados também exigem autenticação antes de retornar `404` ou `405`. Não dependa de um corpo JSON nesses dois casos.
