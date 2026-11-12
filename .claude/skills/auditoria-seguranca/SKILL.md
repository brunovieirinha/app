---
name: auditoria-seguranca
description: >-
  Auditoria de segurança completa a uma app (Expo/React Native, Next, Vite, Node,
  Supabase, Firebase) com correção do que for encontrado, em 4 regras: chaves de API
  fora do frontend (EXPO_PUBLIC_/NEXT_PUBLIC_/VITE_, .env no bundle ou no git),
  validação e sanitização de todos os inputs no servidor (zod, queries parametrizadas,
  escape de HTML, Row Level Security em todas as tabelas), autenticação por plataforma
  estabelecida (Supabase Auth, Firebase Auth, Clerk, Auth0) com sessão verificada no
  servidor, e rate limiting (login, registo, emails, pagamentos, IA, com 429 e teto de
  gastos). Termina com a lista do que mudou e do que o utilizador tem de fazer à mão.
  Usa esta skill SEMPRE que o utilizador pedir "auditoria de segurança", "revê a
  segurança", "a minha app é segura?", "chaves expostas", "RLS", "rate limiting",
  "pentest à app", "antes de publicar", "antes do TestFlight", ou quando encontrares
  segredos no código cliente durante outro trabalho. Nunca muda comportamento visível
  sem perguntar.
---

<!-- VIEIRINHA121126 - skill criada a partir do prompt de auditoria de segurança -->

# Auditoria de segurança com correção

Objetivo: encontrar e corrigir os problemas de segurança mais comuns em apps feitas
depressa, sem alterar o comportamento visível da app, e entregar no fim uma lista
clara do que mudou e do que só o utilizador pode fazer (revogar chaves, configurar
serviços externos). Responde em português europeu, claro e direto.

## Regras de conduta

- **Não mudes comportamento visível.** Um ecrã que funcionava tem de continuar a
  funcionar da mesma forma. Se a correção exigir mudar o que o utilizador vê, ou uma
  decisão de produto (trocar o fornecedor de autenticação, passar uma funcionalidade
  para pago), **pára e pergunta antes**. Faz tudo o resto primeiro e junta as perguntas
  no fim, numa lista, em vez de interromper a cada uma.
- **Não escondas segredos.** Se encontrares uma chave no código ou no histórico do git,
  a correção não é apagá-la do ficheiro: é movê-la para o servidor **e avisar que tem
  de ser revogada e criada uma nova**, porque o que esteve no git continua exposto.
  Nunca reescrevas o histórico do git sem autorização.
- **Marca as alterações** com o comentário `VIEIRINHA` + data DDMMAA e devolve
  ficheiros completos quando mostrares código.
- **Um commit por regra corrigida**, com mensagem `fix(security): ...`, para o
  utilizador poder reverter uma correção sem perder as outras.

## Como trabalhar

1. **Reconhecer a stack.** Lê `package.json`, `app.json`/`app.config.*`, `supabase/`,
   `firebase.json`, `next.config.*`, `vite.config.*`, pastas `api/` ou `server/`. Lê
   `references/por-stack.md` para saber onde procurar e como corrigir em cada stack.
2. **Correr o scan.** `bash scripts/scan.sh <pasta-do-projeto>` faz a parte mecânica:
   segredos no código cliente, variáveis públicas com nomes suspeitos, `.env` fora do
   `.gitignore`, `.env` no histórico do git, `dangerouslySetInnerHTML`/`innerHTML`,
   SQL concatenado, rotas sem verificação de sessão, ausência de rate limiting. O scan
   só lê, não altera nada, e é um ponto de partida, não a auditoria toda: revê os
   resultados com olho crítico e procura o que ele não apanha.
3. **Auditar as 4 regras**, por ordem (abaixo). Para cada achado, decide: corrigir
   agora, ou perguntar (se mexe em comportamento visível ou é decisão do utilizador).
4. **Corrigir**, verificar que a app continua a compilar/arrancar (`tsc --noEmit`,
   testes, `expo start` ou `next build` conforme a stack), e fazer commit por regra.
5. **Relatório final** com o template em `assets/relatorio-template.md`: o que mudou,
   o que o utilizador tem de fazer à mão, e as perguntas pendentes.

## Regra 1: chaves de API fora do frontend

Tudo o que vai para o bundle do cliente é público. Uma app Expo descompila-se, um
site Next/Vite entrega o JS a quem o pedir. Por isso:

- Procura em todo o código cliente (app, web, ficheiros `.env*` incluídos no bundle,
  variáveis `EXPO_PUBLIC_`, `NEXT_PUBLIC_`, `VITE_`) qualquer chave secreta: OpenAI,
  Anthropic, Stripe secret key, service role do Supabase, chaves de Resend, tokens de
  APIs privadas. O scan lista padrões conhecidos (`sk-`, `sk_live_`, `eyJ...` com
  `role: service_role`, etc.); procura também por nome (`SECRET`, `PRIVATE`,
  `SERVICE_ROLE`, `API_KEY` em variável pública).
- Move cada chave para o servidor: Edge Function do Supabase, API route do Next, ou o
  backend que o projeto já use. Cria o endpoint, faz o cliente chamá-lo em vez do
  serviço direto, e verifica a sessão do utilizador nesse endpoint (regra 3).
- Confirma que os ficheiros `.env` com segredos estão no `.gitignore` e que existe um
  `.env.example` sem valores. Se um `.env` já esteve no git (`git log --all -- .env`),
  avisa: a chave está exposta e tem de ser revogada e criada uma nova.
- Chaves que são mesmo públicas (anon key do Supabase, publishable key do Stripe,
  chave do PostHog, DSN do Sentry) podem ficar no cliente. Diz quais ficaram e porquê.

## Regra 2: validação e sanitização de todos os inputs

O cliente pode ser alterado; só a validação no servidor conta.

- Valida no servidor tudo o que vem do utilizador (formulários, pesquisa, nome,
  uploads, parâmetros de URL, corpo de pedidos): tipo, tamanho máximo e formato. Usa
  um schema (zod ou o que o projeto já tiver) à entrada de cada rota, Edge Function ou
  server action. Rejeita com 400 e mensagem genérica, sem ecoar o input.
- Usa sempre queries parametrizadas ou o client da base de dados; nunca concatenes
  input em SQL. Procura `${` e `+` dentro de strings SQL, `.raw(`, `sql\``, `exec(`.
- Escapa o conteúdo antes de o mostrar: sem `dangerouslySetInnerHTML`, `innerHTML` ou
  `eval` com dados do utilizador. Se for mesmo preciso HTML, sanitiza com uma
  biblioteca (DOMPurify) no servidor.
- Uploads: limita tipo (por conteúdo, não só extensão), tamanho, e guarda com nome
  gerado, nunca o nome original.
- **Supabase/Firebase**: ativa Row Level Security (ou regras de segurança) em todas as
  tabelas, com políticas para cada utilizador ler e alterar só os seus dados. O SQL de
  verificação está em `references/por-stack.md`. **Lista as tabelas que estavam sem
  proteção** no relatório. Uma tabela sem RLS com a anon key é pública para toda a
  gente.

## Regra 3: autenticação por plataforma estabelecida

Passwords guardadas à mão, tokens inventados e sessões em memória são onde as apps
caseiras falham. Não vale a pena competir com quem faz isto a tempo inteiro.

- Se a app tem login próprio (tabela de utilizadores com passwords, JWT assinado à mão,
  sessões em cookies feitas à mão), substitui por um serviço estabelecido: Supabase
  Auth, Firebase Auth, Clerk ou Auth0. **Usa o que já estiver no projeto.** Se não
  houver nenhum, a escolha do fornecedor é uma decisão do utilizador: propõe um (o que
  encaixa na stack) e pergunta antes de trocar, porque muda o comportamento visível
  do login e exige migrar utilizadores.
- Garante que todas as rotas e funções do backend verificam a sessão no servidor, e
  não só no cliente: ler o token do header/cookie, validá-lo com o fornecedor
  (`supabase.auth.getUser(token)`, `verifyIdToken`, middleware do Clerk), e só depois
  executar. Esconder um botão no cliente não é autorização.
- Verifica também a **autorização**: o utilizador autenticado só pode mexer nos seus
  próprios recursos (o `id` no URL tem de pertencer a `auth.uid()`). Com RLS ativo e o
  client a usar o token do utilizador, isto vem de graça; com service role no servidor,
  tem de ser verificado à mão.

## Regra 4: rate limiting

Sem limites, uma rota de login é um alvo de força bruta, uma rota de email é spam
pago por ti, e uma rota de IA é uma fatura em aberto.

- Adiciona rate limiting a todas as rotas do backend, sobretudo às de IA, login,
  registo, recuperação de password, envio de emails e pagamentos.
- Limites razoáveis por utilizador e por IP em geral (por exemplo 60 pedidos/minuto),
  mais apertados nas rotas de IA e de login (por exemplo 10/minuto e 5 tentativas de
  login em 15 minutos). Resposta `429 Too Many Requests` com `Retry-After` quando o
  limite for ultrapassado. Os valores concretos e a implementação por stack estão em
  `references/por-stack.md`; adapta ao tráfego real da app e diz no relatório os
  valores escolhidos.
- Nas funcionalidades de IA, põe também um **teto de gastos**: limite de pedidos e de
  tokens por utilizador por dia (contador numa tabela ou no KV), e um limite global
  diário, para ninguém esgotar os créditos. Quando atingido, resposta clara ao
  utilizador, sem expor valores internos.
- Se o fornecedor de auth já tiver rate limiting no login (Supabase Auth tem), não
  dupliques: confirma a configuração e regista no relatório.

## Relatório final

Usa o template em `assets/relatorio-template.md`. Tem três secções fixas, e todas têm
de existir, mesmo que uma esteja vazia:

1. **O que mudei**: por regra, ficheiros alterados e o que faz agora de diferente.
2. **O que tens de fazer à mão**: chaves a revogar e recriar (com o serviço e onde se
   faz), segredos a configurar no servidor (`supabase secrets set ...`, variáveis na
   Vercel), serviços a ativar (Upstash, captcha), e o que verificar depois.
3. **Perguntas antes de avançar**: decisões que não tomei (mudar fornecedor de auth,
   limites que afetam utilizadores reais, comportamento visível).

## Ficheiros desta skill

- `scripts/scan.sh`: scan só de leitura; corre primeiro.
- `references/por-stack.md`: onde procurar e como corrigir em Expo, Next, Vite, Node,
  Supabase e Firebase; SQL para listar tabelas sem RLS; rate limiting por stack.
- `assets/relatorio-template.md`: template do relatório final.
