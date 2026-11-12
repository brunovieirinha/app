<!-- VIEIRINHA121126 -->
# Stack preferida e regras não negociáveis

## Stack por omissão

Esta é a stack preferida. É uma preferência, não uma imposição: se o projeto beneficiar
de outra escolha (por exemplo, uma app sem contas não precisa de Supabase na Fase 2,
ou uma app com compras únicas pode dispensar o Superwall), diz porquê em uma ou duas
linhas e deixa o utilizador decidir. Não troques por gosto.

| Camada | Escolha | Notas |
|---|---|---|
| App | Expo (React Native) + Expo Router + TypeScript | iOS primeiro. Android fica para depois, mas não escrevas código que o impeça. |
| Base de dados | Supabase Postgres | RLS ativo em todas as tabelas. Migrações em `supabase/migrations/`. |
| Autenticação | Supabase Auth | Sign in with Apple obrigatório. Login anónimo opcional para experimentar antes de criar conta. |
| Lógica com segredos | Supabase Edge Functions (Deno/TypeScript) | Tudo o que precise de service role, chaves de LLM, Resend, webhooks. |
| Ficheiros | Supabase Storage | Buckets privados por omissão, políticas RLS no storage. |
| Pagamentos | Superwall sobre StoreKit (compras da Apple) | Paywall no fim do onboarding. Produtos criados no App Store Connect. |
| Analytics | PostHog | Eventos do funil principal, nomes centralizados num ficheiro. |
| Erros | Sentry (`@sentry/react-native` via `sentry-expo`) | DSN em variável de ambiente. |
| Emails | Resend | Só a partir de Edge Functions. Nunca da app. |
| Testes no simulador | Argent (`@swmansion/argent`) | Abrir a app, tocar nos botões, ler o ecrã, antes de dar algo como feito. |
| Publicação | Xcode/EAS Build → TestFlight → App Store | EAS Update para correções rápidas em JS sem nova review. |

## Variáveis de ambiente

Na app, só variáveis públicas, com o prefixo `EXPO_PUBLIC_`:

```
EXPO_PUBLIC_SUPABASE_URL=
EXPO_PUBLIC_SUPABASE_ANON_KEY=
EXPO_PUBLIC_POSTHOG_KEY=
EXPO_PUBLIC_SENTRY_DSN=
EXPO_PUBLIC_SUPERWALL_KEY=
```

Tudo o resto (service role, `RESEND_API_KEY`, chaves de LLM) vive nos secrets do
Supabase (`supabase secrets set`) e é usado só em Edge Functions. Um `.env.example`
commitado, o `.env` nunca.

## Regras não negociáveis

1. **Chaves secretas nunca dentro da app.** Qualquer chave que não seja pública vai
   para uma Edge Function. Se um pacote pedir uma chave secreta no cliente, é o pacote
   errado.
2. **RLS em todas as tabelas, desde a primeira migração.** Uma tabela sem RLS com a
   chave anónima é uma tabela pública. Políticas por `auth.uid()`; testar com dois
   utilizadores.
3. **Design system desde o início.** Cores, tipografia, espaçamentos e raios num único
   sítio (`src/theme/`). Os ecrãs consomem tokens, nunca valores soltos. É o que
   impede a app de parecer feita por IA: uma paleta curta (1 cor primária, 1 de
   destaque, neutros), uma família tipográfica com 3 ou 4 tamanhos, espaçamentos em
   múltiplos de 4.
4. **CLAUDE.md atualizado a cada fase.** Comandos, arquitetura, decisões, estado.
5. **Commit sempre que algo funcionar.** Um commit por mudança, mensagem clara no
   formato `tipo(âmbito): descrição` (`feat`, `fix`, `chore`, `docs`).
6. **Verificar antes de dizer que está feito.** Com o Argent no simulador. Se o Argent
   não estiver disponível, diz explicitamente que não foi verificado no simulador.
7. **Plano aprovado antes de cada fase.** Sem exceções, mesmo que a fase pareça óbvia.

## O que a Apple exige (checklist de review)

Falhar um destes pontos é rejeição quase certa. Verificar todos antes da Fase 4, e os
marcados com (F2) ou (F3) já nessas fases:

- [ ] **Sign in with Apple** disponível se existir qualquer outro login social (Google,
  Facebook). Se só houver email/password ou anónimo, não é obrigatório, mas é a
  escolha por omissão desta stack. (F2)
- [ ] **Apagar conta dentro da app**, acessível em poucos toques, que apaga de facto os
  dados no servidor. (F2)
- [ ] **Política de privacidade e termos** acessíveis na app e com URL no App Store
  Connect. (F3)
- [ ] **Restaurar compras** visível no paywall e nas definições. (F3)
- [ ] **Paywall claro**: preço, período, renovação automática, e link para termos e
  privacidade. Sem "grátis" quando há trial que converte para pago sem o dizer. (F3)
- [ ] **Nada de "em breve"**, botões desativados ou funcionalidades vazias. O que não
  existe não aparece.
- [ ] **Permissões com justificação clara** nos `NSxxxUsageDescription` do `app.json`
  (`infoPlist`), em linguagem humana, a explicar para que serve. Não pedir permissões
  que a app não usa.
- [ ] **Sem links para comprar fora da app** quando a compra é digital (salvo exceções
  legais da região; na dúvida, não).
- [ ] **A app funciona sem conta** até onde fizer sentido, ou o login tem motivo óbvio.
- [ ] **Estados de erro e vazio** tratados. Uma app que crasha no primeiro ecrã é rejeitada.
- [ ] **Metadados honestos**: screenshots da app real, descrição sem promessas falsas.
- [ ] **Conta de teste** para a review, com instruções no campo "Notes", se houver login.

## Estrutura de pastas sugerida

```
app/                  # rotas do Expo Router
src/
  theme/              # design system: cores, tipografia, espaçamentos
  components/         # componentes reutilizáveis
  features/<nome>/    # ecrãs e lógica por funcionalidade
  lib/supabase.ts     # cliente Supabase (só chaves públicas)
  analytics/eventos.ts
supabase/
  migrations/
  functions/<nome>/index.ts
docs/PRD.md
CLAUDE.md
.env.example
```
