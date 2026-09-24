# CLI e tokens

Cada instalação administra seus próprios tokens. A criação e a revogação são feitas pelo terminal da máquina que hospeda o servidor, diretamente ou via SSH. Não existe endpoint HTTP administrativo nem serviço central de autenticação.

## Comandos

| Comando | Função |
| --- | --- |
| `musaranho --help` | Exibir ajuda |
| `musaranho --version` | Exibir versão |
| `musaranho update` | Atualizar a instalação do usuário pela distribuição pública oficial |
| `musaranho serve` | Iniciar servidor em `127.0.0.1:8888` |
| `musaranho serve --model-dir /caminho/musaranho-0.3` | Usar modelo instalado em outro diretório |
| `musaranho chess` | Jogar xadrez contra o Jev com visualizador em http://127.0.0.1:8890 (exige `OPENROUTER_API_KEY`) |
| `musaranho chess --opponent random --engine /caminho/stockfish` | Jogar sem chave, contra lances aleatórios, com avaliação do motor |
| `musaranho serve --detach` | Iniciar em segundo plano, independente do terminal |
| `musaranho serve --bind 127.0.0.1:9000` | Escolher endereço e porta |
| `musaranho token create --name app` | Criar token com validade de 30 dias |
| `musaranho token create --name app --expires-in-days 90` | Escolher validade |
| `musaranho token list` | Listar metadados dos tokens |
| `musaranho token revoke 1` | Revogar token pelo ID |

`--expires-in-days` aceita valores de 1 a 36500. O nome identifica a integração; não precisa ser único. Todos os tokens concedem o mesmo acesso de consumo à API. Não há cotas ou permissões individuais por token nesta etapa.

## Atualizar

```bash
musaranho update
musaranho --version
```

O comando baixa o instalador oficial por HTTPS e atualiza `~/.local/bin/musaranho`, sem `sudo`. Usa as mesmas verificações de integridade da instalação e preserva os tokens. O modelo já instalado é verificado e reutilizado; quando for necessário baixá-lo, uma barra mostra o progresso. Requer Bash, curl e as ferramentas de instalação descritas no [guia](installation.md).

Um servidor que já está em execução continua usando a versão anterior até ser reiniciado. Se o executável antigo ainda não reconhecer `update`, execute uma vez o comando de instalação com curl do guia para obter uma versão que ofereça esse comando.

## Servidor em segundo plano

```bash
musaranho serve --detach
```

O comando retorna após confirmar que o servidor começou a escutar. A saída JSON informa `pid`, `url` e `log`. Você pode fechar o terminal; o servidor continua em execução. `--bind` e `--data-dir` também funcionam nesse modo.

O log fica em `server.log` no diretório de dados, com permissão `600`; por padrão, `~/.local/share/musaranho/server.log`. Use `tail -f` com o caminho retornado para acompanhar. Para encerrar, execute `kill PID`, substituindo `PID` pelo número informado. Não exige `sudo`. Para início automático após reiniciar a máquina, configure o gerenciador de serviços da distribuição.

Se a porta estiver ocupada, o comando falha e indica o log. O processo em primeiro plano iniciado sem `--detach` continua ligado ao terminal e pode ser encerrado com `Ctrl+C`.

## Saída e rotação

A criação imprime JSON com `id`, `name`, `created_at`, `expires_at`, `revoked` e `token`. Datas são segundos Unix em UTC. O token completo aparece somente nessa saída; o servidor não permite recuperá-lo posteriormente.

`token list` retorna os mesmos metadados, sem o segredo. O indicador `revoked` informa revogação explícita; um token também pode estar expirado pela data `expires_at`.

Para trocar uma credencial, crie outro token, atualize a integração e revogue o anterior pelo ID. O servidor reconhece criação, expiração e revogação a cada autenticação. Requisições já autorizadas não são interrompidas.

## Diretório de dados

O padrão é `$XDG_DATA_HOME/musaranho` quando `XDG_DATA_HOME` é absoluto; caso contrário, `~/.local/share/musaranho`. A opção global `--data-dir` permite escolher outro destino:

```bash
musaranho --data-dir /caminho/privado/musaranho token create --name integracao
musaranho --data-dir /caminho/privado/musaranho serve
musaranho --data-dir /caminho/privado/musaranho token list
```

Substitua o caminho e use o mesmo diretório e a mesma conta do sistema para servir e administrar. O banco `tokens.sqlite3` deve ficar em disco local. Faça backup privado desse diretório; não o envie ao Git nem a relatórios de problemas.

O diretório é criado com permissão `700`, e o banco com `600`. O CLI recusa armazenamento acessível a grupo/outros. O banco mantém hashes dos tokens e metadados; o segredo original não é persistido.

## Erros comuns

- **Servidor pede para criar um token:** confira se o primeiro token foi criado com a mesma conta e o mesmo `--data-dir`.
- **Erro de permissões:** use um diretório privado da conta que executa o serviço; não abra as permissões para outros usuários.
- **Token perdido:** crie outro e revogue o antigo pelo ID.
- **Porta ocupada:** escolha outra com `--bind`, ajustando também o proxy se houver.
