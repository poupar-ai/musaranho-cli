# Segurança

O projeto está em prévia de desenvolvimento. Ainda não há versão de inferência nem compromisso de suporte de longo prazo.

## Reportar uma vulnerabilidade

Não publique tokens, bancos de credenciais, dados de clientes ou detalhes de exploração em Issues públicas. Se o repositório oferecer a opção **Security → Report a vulnerability**, use esse canal privado. Caso ela não esteja disponível, solicite um canal privado ao mantenedor sem incluir detalhes sensíveis no pedido público.

Inclua a versão, o sistema operacional, o comportamento observado e passos de reprodução com dados sintéticos. Nenhum prazo de resposta ou correção é prometido nesta etapa.

## Administrar uma instalação

- Use HTTPS para acessos remotos e mantenha a porta HTTP interna fora da internet.
- Crie um token por integração e revogue credenciais comprometidas ou sem uso.
- Preserve o diretório de tokens com acesso exclusivo da conta do serviço.
- Não registre cabeçalhos `Authorization` em proxies ou ferramentas de diagnóstico.
- Não envie dados reais de produção em relatos de problemas.

Não existe acesso remoto de administração de tokens: utilize o CLI local ou SSH. O administrador da máquina controla a instalação; tokens não protegem os arquivos do modelo contra esse administrador.
