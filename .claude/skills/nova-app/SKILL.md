---
name: nova-app
description: >-
  Arranque de uma ideia de app nova (mobile, iOS primeiro) do zero até à App Store:
  entrevista o utilizador uma pergunta de cada vez, escreve o PRD em docs/PRD.md,
  monta um roadmap em 4 fases (ação principal no simulador → contas e BD → onboarding,
  paywall e analytics → polimento e submissão) e só executa cada fase depois de um
  plano curto aprovado. Stack por omissão: Expo + Expo Router + TypeScript, Supabase
  (Postgres com RLS, Auth, Edge Functions), Sign in with Apple, Superwall/StoreKit,
  PostHog, Sentry, Resend, Argent, EAS/TestFlight. Usa esta skill SEMPRE que o
  utilizador disser "tenho uma ideia de app", "nova app", "app para iOS", "quero fazer
  uma app que...", "MVP", "PRD", "paywall", "subscrição", "TestFlight", "App Store",
  "Expo", "Supabase", "Superwall", ou pedir para avançar/retomar uma fase de um projeto
  com este roadmap, mesmo sem dizer "skill" ou "prompt de ouro". Não usar para apps web
  internas da PORTOCARGO (Classic ASP/PHC), que têm skill própria.
---

<!-- VIEIRINHA121126 - skill criada a partir do "prompt de ouro" para arranque de apps -->

# Nova app: da ideia à App Store, com uma vitória rápida hoje

Esta skill transforma uma ideia vaga numa app a funcionar, por fases, sem saltar a parte
mais importante: perceber bem o problema e o utilizador **antes** de escrever código.
Responde sempre em português europeu, de forma clara e direta.

## Como saber em que ponto estamos

Antes de fazer seja o que for, olha para a pasta:

| O que existe | Onde estamos | O que fazer |
|---|---|---|
| Pasta vazia ou sem `docs/PRD.md` | Fase 0 (descoberta) | Entrevista → PRD → roadmap |
| `docs/PRD.md` existe, sem `CLAUDE.md` | Fim da Fase 0 | Confirmar PRD, propor plano da Fase 1 |
| `CLAUDE.md` existe | Fase 1 a 4 | Ler o `CLAUDE.md` (secção "Estado atual"), propor plano da fase seguinte |

Se o utilizador disser explicitamente "avança para a Fase N", lê o PRD e o CLAUDE.md,
verifica que a fase anterior está marcada como concluída, e segue para o plano da fase N.

## Fase 0: perceber antes de construir

A ideia chega normalmente numa frase ("uma app para X"). Não é suficiente para construir
nada útil, e a tentação de começar a codificar é o erro mais caro que podemos cometer
hoje. Por isso:

1. **Faz uma pergunta de cada vez.** Uma pergunta por mensagem, curta, e espera pela
   resposta. Várias perguntas de uma vez fazem o utilizador responder mal a todas.
2. **Cobre estes quatro temas, por esta ordem**, adaptando as perguntas às respostas
   anteriores. Normalmente chegam 5 a 8 perguntas no total:
   - **Público**: quem é a pessoa concreta que abre a app? Em que momento do dia? Que
     app usa hoje para isso (ou folha de cálculo, ou nada)?
   - **Problema**: o que lhe dói hoje? O que acontece se não resolver? Como sabe que
     ficou resolvido?
   - **Primeiro dia**: qual é a única ação que a app tem de fazer bem no primeiro dia?
     Se só pudesse existir um ecrã, qual era?
   - **Dinheiro**: porque é que alguém pagaria? Quanto? Subscrição mensal/anual ou compra
     única? O que fica grátis e o que fica atrás do paywall?
3. **Propõe quando o utilizador não souber.** Se responder "não sei", oferece 2 ou 3
   opções concretas com uma recomendação. Não deixes a pergunta em aberto.
4. **Pára quando tiveres o suficiente**, não quando tiveres tudo. O objetivo é um PRD
   suficiente para a Fase 1, não um documento perfeito. Diz "já tenho o que preciso,
   vou escrever o PRD" e escreve-o.

### Escrever o PRD

Escreve `docs/PRD.md` a partir do template em `assets/PRD-template.md`. As secções são
fixas (problema, utilizador-alvo, funcionalidades principais, fora da primeira versão,
fluxo do utilizador do primeiro ecrã até ao paywall, métricas de sucesso). A secção
"Fora da primeira versão" é a mais importante: tudo o que não é a ação principal vai
para lá, com um motivo de uma linha. Isso é o que torna a Fase 1 possível num dia.

Depois do PRD, apresenta o roadmap das 4 fases (ver `references/fases.md`) em meia
dúzia de linhas e pede ao utilizador que confirme o PRD antes de propor o plano da
Fase 1. Faz também o primeiro commit (`docs: adicionar PRD e roadmap`).

## Fases 1 a 4: plano curto, aprovação, execução

Antes de cada fase:

1. Lê `references/fases.md` para o âmbito, a checklist e os critérios de "feito" dessa fase.
2. Escreve um **plano curto** (10 a 20 linhas): o que vai ser construído, os ficheiros
   principais, o que fica de fora, e como se verifica que funciona.
3. **Espera pela aprovação explícita.** Não cries ficheiros, não instales pacotes, não
   faças commits até o utilizador dizer que aprova. Se ele pedir alterações ao plano,
   revê e volta a apresentar.
4. Só depois executa. Durante a execução:
   - Um commit por mudança que funcione, com mensagem clara
     (`feat(auth): sign in with Apple`, `fix(paywall): restaurar compras`).
   - Verifica cada funcionalidade no simulador com o Argent (abrir a app, carregar nos
     botões, ler o ecrã) antes de a dares como feita. "Compila" não é "funciona".
   - Atualiza o `CLAUDE.md` no fim da fase (secção "Estado atual" e "Decisões").
5. No fim, apresenta o que foi feito, o que foi verificado e o que ficou pendente, e
   pergunta se pode avançar para o plano da fase seguinte.

Se for necessário desviar do plano aprovado (uma dependência não funciona, a Apple
exige algo diferente), diz antes de o fazer, numa linha, e continua se for uma mudança
pequena. Mudanças grandes voltam para aprovação.

## Stack e regras

A stack por omissão e as regras não negociáveis estão em `references/stack-e-regras.md`.
Lê esse ficheiro no início da Fase 1 e sempre que escolheres uma dependência nova.
Em resumo:

- **Stack**: Expo + Expo Router + TypeScript; Supabase (Postgres com RLS em todas as
  tabelas, Auth, Edge Functions, Storage); Sign in with Apple; Superwall sobre StoreKit;
  PostHog; Sentry; Resend via Edge Functions; Argent para testes; Xcode → TestFlight →
  App Store, com EAS Update para correções.
- Esta stack é a preferida, não uma imposição. Se vires uma opção melhor para o caso
  concreto, diz porquê, numa linha ou duas, e deixa o utilizador decidir.
- **Chaves secretas nunca na app.** Service role do Supabase, chaves de LLMs, Resend:
  só em Edge Functions. Na app só entram a URL e a chave anónima/publicável do Supabase.
- **O que a Apple exige** para não rejeitar: Sign in with Apple se houver outro login
  social, apagar conta dentro da app, política de privacidade e termos, botão de
  restaurar compras, nada de "em breve", permissões com justificação clara.
- **Design system desde o início**: cores, tipografia e espaçamentos num único ficheiro
  (`src/theme/`), para que a app não pareça feita por IA. Define-o na Fase 1, antes do
  primeiro ecrã.

## CLAUDE.md do projeto

Cria `CLAUDE.md` na raiz no início da Fase 1 a partir de `assets/CLAUDE-template.md`,
e mantém-no atualizado no fim de cada fase. Contém os comandos (correr, testar,
build), a arquitetura (pastas, fluxo de dados), as decisões importantes com o motivo,
o estado atual por fase e as convenções de código. Uma sessão nova deve conseguir
retomar o projeto só com o PRD e o CLAUDE.md.

## Skills e ferramentas externas

O fluxo apoia-se em quatro conjuntos de skills de terceiros. No início da Fase 0,
verifica se estão instaladas (ver `references/ferramentas.md` para os comandos de
verificação e instalação). Se faltarem, propõe instalá-las numa linha e continua: a
entrevista não depende delas. São necessárias a partir da Fase 1:

| Para quê | Skill | Quando usar |
|---|---|---|
| Brainstorming, planos, execução passo a passo | `obra/superpowers` | Planos de cada fase e execução de tarefas |
| Supabase e Postgres | `supabase/agent-skills` | Fase 2 (schema, RLS, Auth, Edge Functions) |
| Paywalls e subscrições | `superwall/skills` | Fase 3 (paywall no fim do onboarding) |
| Abrir e testar a app no simulador | `software-mansion/argent` | Fases 1 a 4, antes de dar algo como feito |
| Auditoria de segurança com correção | `auditoria-seguranca` (esta pasta) | Fase 3, antes do primeiro build para TestFlight |

Quando o Superpowers estiver instalado, usa o `brainstorming` dele para a entrevista e o
`writing-plans` para os planos de fase. Se não estiver, segue as instruções desta skill
diretamente, que cobrem o mesmo.

## Convenções do utilizador

- Responde em português europeu, de forma clara e direta.
- Quando alterares um ficheiro de código, devolve o ficheiro completo, não só o excerto.
- Marca as alterações a código com o comentário `VIEIRINHA` seguido da data em formato
  DDMMAA (exemplo: `// VIEIRINHA121126`), para o utilizador localizar depois o que
  mudou. Em ficheiros novos, uma linha no topo chega.
- Segurança e privacidade por omissão: RLS em todas as tabelas, dados pessoais
  mínimos, nada de segredos no repositório (`.env` no `.gitignore` desde o primeiro
  commit).

## Ficheiros desta skill

- `references/fases.md`: âmbito, checklist e critério de "feito" de cada uma das 4 fases.
- `references/stack-e-regras.md`: stack detalhada, regras da Apple, regras não negociáveis.
- `references/ferramentas.md`: como verificar e instalar as skills externas e o Argent.
- `assets/PRD-template.md`: template do `docs/PRD.md`.
- `assets/CLAUDE-template.md`: template do `CLAUDE.md` do projeto.
