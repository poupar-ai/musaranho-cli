# Musaranho

<p align="center">
  <img src="assets/musaranho.png" alt="Mascote do Musaranho com roupa preta e verde e bandeira do Brasil" width="280">
</p>

Motor de decisões tipadas **System 1**, em desenvolvimento, projetado para inferência multilíngue não autoregressiva e perguntas independentes em lote. O objetivo é produzir decisões `choice`, `score` e `noul` diretamente, sem gerar texto livre.

Execute o CLI Rust e a API na sua própria máquina ou VPS, com tokens locais e Swagger embutido. A versão 0.2.3 inclui o modelo musaranho-0.2 e inferência local em CPU para até 50 perguntas por chamada.

Este repositório reúne documentação pública, exemplos de integração e o pacote de avaliação do servidor e do modelo. A implementação do produto é privada; a distribuição é por executáveis compilados.

A documentação é gerada a partir do projeto principal. Sugestões de alteração podem ser enviadas pelas Issues.

## Estado do projeto

**Versão inicial instalável, com inferência local. Uso experimental.**

| Recurso | Estado |
| --- | --- |
| CLI e servidor HTTP em Rust | Implementados e testados em Linux |
| Criação, expiração e revogação de tokens | Implementadas |
| Swagger embutido e OpenAPI | Disponíveis em `/docs` e `/openapi.json` |
| Lotes de perguntas independentes | Inferência de 1 a 50 perguntas na mesma chamada |
| Contrato JSON `choice`, `score` e `noul` | Compatível nos campos comuns com Jev/Laya |
| Modelo treinado e inferência | musaranho-0.2 disponível no instalador |
| Executável de avaliação 0.2.3 | Linux x86_64; mínimo de glibc em `cli/release.json` |

O instalador baixa e verifica o executável e o modelo (download do modelo: aproximadamente 1,18 GB; pesos instalados: 1,30 GB). Não exige Python, Rust ou GPU. O processamento ocorre na sua máquina.

O checkpoint desta versão atingiu **75,85% de acerto em 704 perguntas** na validação reutilizada durante o desenvolvimento. Esse resultado não garante acerto em dados novos. Há limitações em consultas a registros e textos longos; o limite técnico de 8.192 tokens não garante compreensão adequada nesse comprimento.

## Benchmark histórico Laya × Musaranho

Medição de um candidato anterior, diferente do modelo instalado nesta versão: **256 casos e 704 perguntas**, em português, inglês e espanhol. Comparação do Musaranho experimental com três variantes e dois modos do roteador oficial do Laya 0.3.5.

| Modelo | Acerto global |
| --- | ---: |
| Musaranho experimental | **70,45%** |
| Laya Typed Decisions | 57,67% |
| Laya Router com detecção de tarefa | 56,82% |
| Laya Multilingual | 40,91% |
| Laya Router padrão | 35,37% |
| Laya English | 35,09% |

Musaranho ganha **12,78 pontos percentuais** sobre o melhor Laya nesta amostra. No cenário de contexto longo com 50 perguntas, seu p50 foi **36,59 ms**, 9,50× mais rápido que o Laya mais rápido nesse cenário. **Laya Typed vence em Score (70,98% contra 61,14%) e nos workflows de Typed Decisions (84,92% contra 60,66%). Laya também tem menor latência com uma pergunta.**

São resultados de validação reutilizada durante o desenvolvimento, com os limites de contexto do Laya ampliados para preservar as entradas. Não demonstram superioridade geral em dados novos. O candidato não passou na triagem de regressões e não é o checkpoint distribuído nesta versão. Ainda é necessária uma avaliação independente.

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

O instalador verifica o SHA-256 dos pacotes e instala em `~/.local/bin`, sem `sudo`. O download do modelo exibe uma barra de progresso. Para uso permanente, inclua esse diretório no PATH da configuração do seu shell.

**Para testar agora com esta cópia local**, execute na raiz da pasta pública:

```bash
bash install.sh
export PATH="$HOME/.local/bin:$PATH"
musaranho token create --name teste
musaranho serve
```

Abra `http://127.0.0.1:8888/docs`, clique em **Authorize** e cole o token. Execute `GET /health` e confira `model_ready: true`. Depois execute `POST /v1/systemone` com o exemplo do Swagger. Esta prévia não exige Rust, Python ou GPU. Consulte os [termos de avaliação](BINARY-LICENSE.txt).

## Atualizar

Para atualizar uma instalação existente:

```bash
musaranho update
musaranho --version
```

Depois, reinicie o servidor. Os tokens são preservados e o modelo existente é reutilizado após verificação.

Se a versão antiga não reconhecer `update`, repita uma vez o comando de instalação com curl da seção acima.

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
