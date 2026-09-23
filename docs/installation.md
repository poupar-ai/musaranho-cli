# Instalação

## Disponibilidade atual

A versão **0.2.0 para Linux x86_64** inclui CLI, autenticação, Swagger e o modelo **musaranho-0.1**, executado localmente em CPU. Não exige Rust, Python ou GPU. O mínimo de glibc está em `cli/release.json`; requer também `libgcc_s.so.1` e bibliotecas padrão do sistema.

O download do modelo tem aproximadamente **1,18 GB**, com **1,30 GB** instalado. Reserve pelo menos **4 GB de disco livre** para baixar e extrair. Para contextos curtos, reserve 4 GB de RAM para a instalação. Para utilizar o limite de 8.192 tokens, recomendamos 24 GB de RAM disponível; o processamento em CPU pode levar minutos por chamada. O consumo depende também do catálogo de opções. Esta versão não oferece aceleração por GPU nem suporte a Windows/macOS.

## Instalar com curl

Instale o CLI diretamente do repositório público:

```bash
MUSARANHO_URL="https://raw.githubusercontent.com/poupar-ai/musaranho-cli/main"
curl -fsSL --proto '=https' --proto-redir '=https' "$MUSARANHO_URL/install.sh" | bash -s -- "$MUSARANHO_URL"
export PATH="$HOME/.local/bin:$PATH"
musaranho --version
```

O instalador baixa o executável de `cli/` e o modelo dos assets da release, verifica os SHA-256 e testa a versão antes de instalar em `~/.local/bin/musaranho`. Os pesos ficam em `~/.local/share/musaranho-cli/models/musaranho-0.1`. Uma falha de download ou integridade preserva o executável instalado. Modelos existentes são verificados e nunca sobrescritos. Os termos e avisos de terceiros ficam em `~/.local/share/musaranho-cli/`. Requer Bash, curl, tar e ferramentas padrão do Linux, incluindo sha256sum. Não usa sudo e não inicia o servidor automaticamente.

O `export` vale para o terminal atual. Adicione `~/.local/bin` ao PATH da configuração do seu shell para uso permanente.

## Instalar pela cópia local

Na raiz da cópia pública, com o pacote e checksum presentes em `cli/`:

```bash
bash install.sh
export PATH="$HOME/.local/bin:$PATH"
musaranho --version
```

A instalação pela cópia local também baixa o modelo pela internet, salvo se `cli/musaranho-0.1.tar.gz` já estiver presente. Para instalação offline, obtenha previamente esse asset da mesma release e copie-o para `cli/`.

Para utilizar um pacote do modelo extraído em outro local, inicie com `musaranho serve --model-dir /caminho/musaranho-0.1`. O servidor verifica a integridade antes de abrir a porta; esse carregamento pode levar alguns segundos.

## Primeiro acesso

```bash
musaranho token create --name minha-aplicacao
musaranho serve
```

Crie o token antes de iniciar o servidor pela primeira vez. O segredo é mostrado apenas na criação; guarde-o em local seguro. Os comandos usam o mesmo diretório de dados da conta atual. Consulte [administração de tokens](cli.md) para escolher outro diretório.

O servidor inicia em primeiro plano, na porta `8888` de localhost. `Ctrl+C` encerra o processo. A rota `/health` permite verificar o servidor com um token; confira `model_ready: true` antes de chamar a inferência.

Se o navegador mostrar conexão recusada, confira se `musaranho serve` está em execução e abra `http://127.0.0.1:8888/docs`. Instalar o CLI não inicia o servidor.

Para iniciar em segundo plano e poder fechar o terminal:

```bash
musaranho serve --detach
```

O comando informa PID, endereço e caminho do log. Consulte [CLI e tokens](cli.md#servidor-em-segundo-plano) para acompanhar e encerrar o processo.

Para acesso pela internet, configure [HTTPS na VPS](deployment.md).
