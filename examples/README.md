# Exemplos

- [systemone.request.json](systemone.request.json): lote com três perguntas independentes Choice, Score e Noul. Acrescente IDs em questions para enviar 50 perguntas no mesmo formato.
- [systemone.response.json](systemone.response.json): resposta ilustrativa no contrato comum. Não é resultado de um modelo treinado.
- [Caddyfile](Caddyfile): proxy HTTPS; substitua o domínio antes de usar.

O instalador inclui o modelo musaranho-0.1. A requisição executa inferência real; o arquivo de resposta continua ilustrativo e não promete essas probabilidades.

Com o servidor em execução e a partir da raiz deste repositório, você pode executar a inferência:

```bash
read -r -s -p 'Token: ' MUSARANHO_TOKEN
printf '\n'
printf 'Authorization: Bearer %s\n' "$MUSARANHO_TOKEN" |
  curl --include --header @- \
    --header 'Content-Type: application/json' \
    --data-binary @examples/systemone.request.json \
    http://127.0.0.1:8888/v1/systemone
unset MUSARANHO_TOKEN
```

Resultado esperado nesta prévia: `200` com token válido e modelo instalado; `401 unauthorized` com token inválido. Para chamar uma VPS, use a URL HTTPS da sua instalação.
