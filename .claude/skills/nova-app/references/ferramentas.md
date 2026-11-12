<!-- VIEIRINHA121126 -->
# Skills e ferramentas externas

A skill `nova-app` orienta o processo. O trabalho técnico em cada área apoia-se em
skills mantidas por quem faz as ferramentas. Verifica no início da Fase 0 e instala o
que faltar antes da Fase 1. A entrevista e o PRD não dependem de nada disto.

## Verificar o que está instalado

```bash
# Skills instaladas (projeto e globais)
ls .claude/skills ~/.claude/skills 2>/dev/null
# Plugins do Claude Code
claude plugin list 2>/dev/null
# Argent
npx @swmansion/argent@latest --version 2>/dev/null
```

## Superpowers (brainstorming, planos, execução passo a passo)

Repositório: https://github.com/obra/superpowers

Instalação no Claude Code (uma das duas):

```
/plugin install superpowers@claude-plugins-official
```
ou
```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
```

O que usar e quando:
- `brainstorming` na Fase 0: faz a entrevista uma pergunta de cada vez e apresenta o
  desenho por secções curtas para aprovação. Coincide com o que esta skill pede.
- `writing-plans` antes de cada fase: parte o plano em tarefas pequenas com ficheiros,
  código e verificação.
- `executing-plans` ou `subagent-driven-development` durante a fase.
- `test-driven-development` e `requesting-code-review` quando fizer sentido.

Se não estiver instalado, as instruções da `nova-app` cobrem o essencial.

## Supabase (base de dados, Auth, Edge Functions, Storage)

Repositório: https://github.com/supabase/agent-skills

```bash
npx skills add supabase/agent-skills
# ou só uma:
npx skills add supabase/agent-skills --skill supabase
npx skills add supabase/agent-skills --skill supabase-postgres-best-practices
```

Inclui a skill `supabase` (produtos, CLI, client libraries, MCP) e
`supabase-postgres-best-practices` (performance, schema, RLS). Usar na Fase 2 e em
qualquer Edge Function da Fase 3. Se o MCP do Supabase estiver ligado na sessão, serve
para criar o projeto, aplicar migrações e consultar os advisors de segurança.

## Superwall (paywalls e subscrições)

Repositório: https://github.com/superwall/skills

```bash
npx skills add superwall/skills --agent claude-code universal --global --yes
```

Inclui `superwall` (integração do SDK, recursos, analytics), `superwall-editor`
(edição de paywalls e onboarding) e `onboarding-questions` (esboço de onboarding a
partir de uma ficha da App Store). Precisa do CLI `superwall` com `superwall login`
feito uma vez. Usar na Fase 3.

## Argent (testar a app no simulador)

Repositório: https://github.com/software-mansion/argent

```bash
npx @swmansion/argent@latest init
```

Dá ao assistente controlo do simulador iOS: tocar, deslizar, escrever, ler o ecrã,
gravar e repetir percursos, ver logs e tráfego de rede. Depois do `init`, pergunta
"O que consegue o Argent fazer?" para listar as ferramentas disponíveis. Usar antes de
dar qualquer funcionalidade como feita, da Fase 1 em diante.

Requer macOS com Xcode e um simulador instalado. Se a sessão correr num ambiente sem
simulador (cloud, Linux), diz explicitamente que a verificação no simulador fica para
o utilizador fazer localmente, e deixa no `CLAUDE.md` os passos para a fazer.

## Nota sobre ambientes cloud

Numa sessão Claude Code na cloud não há simulador nem Xcode. Nesse caso:
- Fases 0 e a maior parte da 2 (schema, RLS, Edge Functions) funcionam normalmente.
- Fase 1, 3 e 4 precisam de um Mac para compilar e verificar. Prepara o código, os
  comandos e a checklist, e marca no `CLAUDE.md` o que falta verificar localmente.
