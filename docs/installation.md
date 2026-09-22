# Instalação

## Disponibilidade atual

Há um pacote de avaliação **0.1.3 para Linux x86_64**, contendo CLI, servidor, autenticação e Swagger. Ele não inclui modelo treinado. O executável requer a versão mínima de glibc indicada em `cli/release.json` (`glibc_min`), `libgcc_s.so.1` e as bibliotecas padrão do sistema; não exige Rust, Python ou GPU nesta prévia.

O CLI e a autenticação foram testados em Linux x86_64. O suporte a outras plataformas e os requisitos de memória, GPU e runtime do modelo serão informados quando houver uma versão de inferência. Não há suporte anunciado para Windows nesta etapa.

## Instalar com curl

Instale o CLI diretamente do repositório público:

```bash
MUSARANHO_URL="https://raw.githubusercontent.com/poupar-ai/musaranho-cli/main"
curl -fsSL --proto '=https' --proto-redir '=https' "$MUSARANHO_URL/install.sh" | bash -s -- "$MUSARANHO_URL"
export PATH="$HOME/.local/bin:$PATH"
musaranho --version
```

O instalador baixa o pacote de `cli/`, verifica seu SHA-256 e testa a versão do executável antes de instalá-lo em `~/.local/bin/musaranho`. Os termos e avisos de terceiros ficam em `~/.local/share/musaranho-cli/`. Requer Bash, curl, tar e ferramentas padrão do Linux, incluindo sha256sum. Não usa sudo e não inicia o servidor automaticamente.

O `export` vale para o terminal atual. Adicione `~/.local/bin` ao PATH da configuração do seu shell para uso permanente.

## Instalar pela cópia local

Na raiz da cópia pública, com o pacote e checksum presentes em `cli/`:

```bash
bash install.sh
export PATH="$HOME/.local/bin:$PATH"
musaranho --version
```

## Extração manual

O pacote é `cli/musaranho-0.1.3-x86_64-unknown-linux-gnu.tar.gz`, acompanhado de `cli/SHA256SUMS`. Para executar sem instalar:

```bash
(cd cli && sha256sum -c SHA256SUMS)
MUSARANHO_TEST_DIR="$(mktemp -d)"
tar -xzf cli/musaranho-0.1.3-x86_64-unknown-linux-gnu.tar.gz -C "$MUSARANHO_TEST_DIR"
cd "$MUSARANHO_TEST_DIR/musaranho-0.1.3-x86_64-unknown-linux-gnu"
./musaranho --version
```

O CLI compilado não exige acesso ao código-fonte, Cargo ou Python. As dependências do futuro runtime de inferência serão especificadas na release.

## Primeiro acesso

```bash
musaranho token create --name minha-aplicacao
musaranho serve
```

Crie o token antes de iniciar o servidor pela primeira vez. O segredo é mostrado apenas na criação; guarde-o em local seguro. Os comandos usam o mesmo diretório de dados da conta atual. Consulte [administração de tokens](cli.md) para escolher outro diretório.

O servidor inicia em primeiro plano, na porta `8888` de localhost. `Ctrl+C` encerra o processo. A rota `/health` permite verificar o servidor com um token; a rota de inferência ainda retorna `503 model_not_ready`.

Se o navegador mostrar conexão recusada, confira se `musaranho serve` está em execução e abra `http://127.0.0.1:8888/docs`. Instalar o CLI não inicia o servidor.

Para iniciar em segundo plano e poder fechar o terminal:

```bash
musaranho serve --detach
```

O comando informa PID, endereço e caminho do log. Consulte [CLI e tokens](cli.md#servidor-em-segundo-plano) para acompanhar e encerrar o processo.

Para acesso pela internet, configure [HTTPS na VPS](deployment.md).
