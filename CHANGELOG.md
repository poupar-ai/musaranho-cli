# Histórico

## 0.2.0 — versão inicial com inferência

- Modelo musaranho-0.1 instalado automaticamente com verificação de integridade.
- Inferência local em CPU para Choice, Score e Noul, sem Python ou GPU.
- Lotes de até 50 perguntas, limite de 8.192 tokens sem truncamento silencioso e controle de concorrência.
- Checkpoint com 75,85% na validação de desenvolvimento; uso experimental e limitações de generalização.

## 0.1.5 — prévia de avaliação

- Resumo do benchmark Laya × Musaranho no README, com acerto, latência e limitações por tarefa.
- Relatórios Laya × Musaranho e Jev × Musaranho acompanhados dos resultados agregados em JSON.
- Pacote de avaliação atualizado; o modelo experimental continua fora do CLI e a inferência retorna `503 model_not_ready`.

## 0.1.4 — prévia de avaliação

- Validação de lotes independentes em `POST /v1/systemone`, com testes de 50 perguntas.
- JSON inválido, campos e critérios incorretos, IDs duplicados e payloads acima de 2 MiB retornam erros estruturados.
- Swagger descreve entrada em lote e contrato futuro de saída; sem respostas simuladas ou inferência paralela nesta prévia.
- Apresentação do projeto centrada no motor de decisões tipadas System 1.

## 0.1.3 — prévia de avaliação

- `musaranho serve --detach` mantém o servidor ativo após fechar o terminal.
- Confirmação de inicialização com PID, URL e log privado; falhas de bind são reportadas ao iniciar.

## 0.1.2 — prévia de avaliação

- Porta padrão do servidor alterada para `8888`.
- Instruções de instalação, Swagger e proxy atualizadas para a nova porta.

## 0.1.1 — prévia de avaliação

- Publicação automática no repositório público a partir de tags `v*` do privado.
- CLI, instalador, OpenAPI e documentação sincronizados na versão 0.1.1.

## 0.1.0 — prévia de avaliação

- Documentação pública de instalação, CLI, API e execução em VPS.
- CLI e servidor com autenticação por tokens, expiração e revogação locais.
- Swagger embutido em `/docs`, com autorização Bearer e OpenAPI em `/openapi.json`.
- Contrato de respostas Choice, Score e Noul documentado com exemplos ilustrativos.
- Mascote do Musaranho.
- Pacote Linux x86_64 com executável, documentação, termos de avaliação, licenças de terceiros e checksum SHA-256.

Pacote preparado para distribuição e testes; isso não indica publicação em um serviço de hospedagem. Ainda sem modelo de inferência: a rota retorna `503 model_not_ready`.
