# Musaranho

<p align="center">
  <img src="assets/musaranho.png" alt="Mascote do Musaranho com roupa preta e verde e bandeira do Brasil" width="280">
</p>

Motor de decisões tipadas **System 1**, em desenvolvimento, projetado para inferência multilíngue não autoregressiva e perguntas independentes em lote. O objetivo é produzir decisões `choice`, `score` e `noul` diretamente, sem gerar texto livre.

Execute o CLI Rust e a API na sua própria máquina ou VPS, com tokens locais e Swagger embutido. A camada HTTP já valida lotes de perguntas; o modelo e o processamento neural em paralelo ainda estão em desenvolvimento.

Este repositório reúne documentação pública, exemplos de integração e o pacote de avaliação do servidor. A implementação do produto é privada; a distribuição é por executáveis compilados.

A documentação é gerada a partir do projeto principal. Sugestões de alteração podem ser enviadas pelas Issues.

## Estado do projeto

**Prévia em desenvolvimento. Ainda não há uma versão de inferência disponível.**

| Recurso | Estado |
| --- | --- |
| CLI e servidor HTTP em Rust | Implementados e testados em Linux |
| Criação, expiração e revogação de tokens | Implementadas |
| Swagger embutido e OpenAPI | Disponíveis em `/docs` e `/openapi.json` |
| Lotes de perguntas independentes | Entrada validada na API; formato de saída testado com 50 perguntas |
| Contrato JSON `choice`, `score` e `noul` | Compatível nos campos comuns com Jev/Laya |
| Modelo treinado e inferência | Candidatos privados em avaliação; indisponíveis no pacote público |
| Executável de avaliação 0.1.5 | Linux x86_64; mínimo de glibc em `cli/release.json` |

O endpoint de inferência retorna `503 model_not_ready` após autenticar. Os exemplos de respostas são ilustrativos; não são previsões ou resultados de qualidade do modelo.

## Benchmark Laya × Musaranho

Medição de 22/09/2026: **256 casos e 704 perguntas**, em português, inglês e espanhol. Comparação do Musaranho experimental com três variantes e dois modos do roteador oficial do Laya 0.3.5.

| Modelo | Acerto global |
| --- | ---: |
| Musaranho experimental | **70,45%** |
| Laya Typed Decisions | 57,67% |
| Laya Router com detecção de tarefa | 56,82% |
| Laya Multilingual | 40,91% |
| Laya Router padrão | 35,37% |
| Laya English | 35,09% |

Musaranho ganha **12,78 pontos percentuais** sobre o melhor Laya nesta amostra. No cenário de contexto longo com 50 perguntas, seu p50 foi **36,59 ms**, 9,50× mais rápido que o Laya mais rápido nesse cenário. **Laya Typed vence em Score (70,98% contra 61,14%) e nos workflows de Typed Decisions (84,92% contra 60,66%). Laya também tem menor latência com uma pergunta.**

São resultados de validação reutilizada durante o desenvolvimento, com os limites de contexto do Laya ampliados para preservar as entradas. Não demonstram superioridade geral em dados novos. O candidato não passou na triagem de regressões e ainda não está disponível no CLI público. Ainda é necessária uma avaliação independente.

Consulte o [benchmark completo, metodologia e limitações](docs/laya-vs-musaranho.md) e os [dados em JSON](benchmarks/laya-vs-musaranho-2026-09-22.json). O [comparativo Jev × Musaranho](docs/jev-vs-musaranho.md) documenta separadamente uma avaliação anterior.

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
- [Comparativo experimental Jev × Musaranho](docs/jev-vs-musaranho.md)
- [Benchmark Laya × Musaranho](docs/laya-vs-musaranho.md)
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
