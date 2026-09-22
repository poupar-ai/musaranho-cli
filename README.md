# Musaranho

<p align="center">
  <img src="assets/musaranho.png" alt="Mascote do Musaranho com roupa preta e verde e bandeira do Brasil" width="280">
</p>

Servidor de decisões da Poupar para executar na sua própria máquina ou VPS. Você administra a instalação e os tokens de acesso à API, sem depender de hospedagem da Poupar.

Este repositório reúne documentação pública, exemplos de integração e o pacote de avaliação do servidor. A implementação do produto é privada; a distribuição é por executáveis compilados.

A documentação é gerada a partir do projeto principal. Sugestões de alteração podem ser enviadas pelas Issues.

## Estado do projeto

**Prévia em desenvolvimento. Ainda não há uma versão de inferência disponível.**

| Recurso | Estado |
| --- | --- |
| CLI e servidor HTTP em Rust | Implementados e testados em Linux |
| Criação, expiração e revogação de tokens | Implementadas |
| Swagger embutido e OpenAPI | Disponíveis em `/docs` e `/openapi.json` |
| Contrato JSON `choice`, `score` e `noul` | Validado em testes de formato |
| Modelo treinado e inferência | Ainda não disponíveis |
| Executável de avaliação 0.1.3 | Linux x86_64; mínimo de glibc em `cli/release.json` |

O endpoint de inferência retorna `503 model_not_ready` após autenticar. Os exemplos de respostas são ilustrativos; não são previsões ou resultados de qualidade do modelo.

## Baixar e testar

Instale o CLI diretamente do repositório público:

```bash
MUSARANHO_URL="https://raw.githubusercontent.com/poupar-ai/musaranho-cli/main"
curl -fsSL --proto '=https' --proto-redir '=https' "$MUSARANHO_URL/install.sh" | bash -s -- "$MUSARANHO_URL"
export PATH="$HOME/.local/bin:$PATH"
musaranho token create --name teste
musaranho serve
```

O instalador verifica o SHA-256 do pacote e instala em `~/.local/bin`, sem `sudo`. Para uso permanente, inclua esse diretório no PATH da configuração do seu shell.

**Para testar agora com esta cópia local**, execute na raiz da pasta pública:

```bash
bash install.sh
export PATH="$HOME/.local/bin:$PATH"
musaranho token create --name teste
musaranho serve
```

Abra `http://127.0.0.1:8888/docs`, clique em **Authorize** e cole o token. Execute `GET /health` para testar. Esta prévia não exige Rust, Python ou GPU. Consulte os [termos de avaliação](BINARY-LICENSE.txt).

## Uso do CLI

Após obter e instalar um executável oficial compatível com sua máquina:

```bash
musaranho token create --name minha-aplicacao --expires-in-days 30
musaranho serve
```

Para continuar servindo após fechar o terminal, inicie com `musaranho serve --detach`. O comando retorna PID, URL e caminho do log.

Guarde o token exibido na criação. O servidor escuta em `127.0.0.1:8888`; `/health` e `/v1/systemone` exigem `Authorization: Bearer <token>`. Abra `http://127.0.0.1:8888/docs` e use **Authorize** para testar a API. A documentação é pública, mas as chamadas continuam protegidas. Para consultar e revogar acessos:

```bash
musaranho token list
musaranho token revoke 1
```

O ID deve corresponder ao token desejado. A revogação vale para novas autenticações, sem reiniciar o servidor.

## Documentação

- [Instalação e disponibilidade](docs/installation.md)
- [CLI e administração de tokens](docs/cli.md)
- [API e contrato das respostas](docs/api.md)
- [Especificação OpenAPI](openapi.json)
- [Servidor em VPS e HTTPS](docs/deployment.md)
- [Exemplos JSON](examples/README.md)
- [Segurança](SECURITY.md)
- [Histórico](CHANGELOG.md)
- [Licença e identidade visual](LICENSE)
- [Avisos de terceiros](THIRD_PARTY_NOTICES.md)

Compatibilidade de formato com Jev/Laya não significa equivalência de qualidade, desempenho, pesos ou comportamento. Musaranho é um projeto independente; as referências a esses produtos não indicam afiliação.

## Feedback

Use as Issues do repositório para dúvidas e correções da documentação. Informe a versão do executável e o sistema operacional quando aplicável. Remova tokens, dados pessoais e conteúdo confidencial de qualquer exemplo publicado. Para falhas de segurança, siga [SECURITY.md](SECURITY.md).
