# Servidor em VPS

Você administra a máquina ou VPS, o domínio, os certificados e os custos da sua instalação. A autenticação não depende de conta ou servidor da Poupar.

## Executar

Com o executável instalado, use uma conta de serviço sem privilégios de administrador e um diretório privado de dados. Crie os tokens com a mesma conta e o mesmo diretório usados pelo servidor:

```bash
musaranho token create --name minha-aplicacao
musaranho serve --bind 127.0.0.1:8888
```

O comando permanece em primeiro plano. Para operação contínua, configure o gerenciador de serviços da sua distribuição com esse comando, a conta escolhida e um diretório de dados persistente. O servidor aceita encerramento por `SIGINT` e `SIGTERM`.

## HTTPS

Mantenha o Musaranho em localhost e coloque um proxy HTTPS na mesma máquina. Exemplo com Caddy, também disponível em [examples/Caddyfile](../examples/Caddyfile):

```caddyfile
musaranho.seu-dominio.com {
    reverse_proxy 127.0.0.1:8888
}
```

Substitua o domínio por um que você controla e aponte o DNS para a VPS. Instale e configure o Caddy conforme a [documentação oficial](https://caddyserver.com/docs/quick-starts/reverse-proxy). As portas 80/443 precisam chegar ao proxy para emissão automática do certificado. A porta 8888 deve permanecer fora do acesso público.

Aplicações remotas passam a usar `https://musaranho.seu-dominio.com`, mantendo o cabeçalho Bearer. O proxy deve encaminhar `Authorization`, sem registrar seu conteúdo. Não envie tokens por HTTP através da internet.

`--bind 0.0.0.0:8888` permite escutar em outras interfaces, mas não configura TLS. Use-o somente quando a rede e o proxy exigirem, com firewall impedindo acesso HTTP direto. Autenticação por token não substitui criptografia de transporte.

## Operação

Mantenha backup privado do diretório de tokens e mantenha o executável atualizado. Configure limites de tráfego no proxy de acordo com a capacidade da máquina; esta prévia não inclui quotas por token ou limitação de requisições.

O endpoint `/health` exige token e informa separadamente se o modelo está pronto. Nesta etapa, `model_ready` é `false` e a inferência retorna `503`; a prévia serve para validar instalação e autenticação.

Tokens protegem a API contra chamadas não autorizadas. Eles não impedem o administrador da máquina de acessar arquivos locais, incluindo futuros pesos distribuídos para inferência.
