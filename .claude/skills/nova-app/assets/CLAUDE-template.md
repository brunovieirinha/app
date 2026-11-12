# [Nome da app]

<!-- VIEIRINHA121126 -->
[Uma frase: o que a app faz e para quem. Ver `docs/PRD.md` para o detalhe.]

## Comandos

```bash
npm install                      # dependências
npx expo start                   # dev server (i para abrir o simulador iOS)
npx expo run:ios                 # build nativo e abrir no simulador
npx tsc --noEmit                 # verificação de tipos
npm test                         # testes (se existirem)
supabase start                   # Supabase local (Fase 2+)
supabase db diff -f <nome>       # nova migração a partir de alterações locais
supabase db push                 # aplicar migrações ao projeto remoto
supabase functions serve         # Edge Functions locais
eas build --platform ios --profile preview   # build para TestFlight (Fase 3+)
eas update --branch production --message "..." # correção rápida em JS (Fase 4+)
```

## Arquitetura

- `app/`: rotas do Expo Router. Um ficheiro por ecrã.
- `src/theme/`: design system (cores, tipografia, espaçamentos). Os ecrãs só usam tokens.
- `src/features/<nome>/`: ecrãs e lógica por funcionalidade.
- `src/lib/supabase.ts`: cliente Supabase com chaves públicas (`EXPO_PUBLIC_*`).
- `src/analytics/eventos.ts`: nomes dos eventos PostHog.
- `supabase/migrations/`: schema versionado. RLS em todas as tabelas.
- `supabase/functions/`: Edge Functions (tudo o que precise de segredos).

**Fluxo de dados**: [ecrã] → [hook/serviço] → Supabase (ou local na Fase 1).

## Stack

Expo + Expo Router + TypeScript · Supabase (Postgres/RLS, Auth, Edge Functions,
Storage) · Sign in with Apple · Superwall/StoreKit · PostHog · Sentry · Resend ·
Argent para testes · EAS/TestFlight.

## Regras

- Chaves secretas só em Edge Functions. Na app, só `EXPO_PUBLIC_*`.
- RLS em todas as tabelas. Políticas por `auth.uid()`.
- Um commit por mudança que funcione: `tipo(âmbito): descrição`.
- Verificar no simulador (Argent) antes de dar como feito.
- Plano curto e aprovação antes de cada fase.
- Alterações a código marcadas com `// VIEIRINHA` + data DDMMAA.
- Respostas em português europeu, claras e diretas; devolver ficheiros completos.

## Decisões

| Data | Decisão | Motivo |
|---|---|---|
| [data] | [ex.: dados locais com AsyncStorage na Fase 1] | [ex.: ação principal não precisa de backend para ser validada] |

## Estado atual

- **Fase 0 (PRD)**: concluída em [data]
- **Fase 1 (ação principal no simulador)**: [por iniciar / em curso / concluída em data]
- **Fase 2 (contas, BD, sync)**: por iniciar
- **Fase 3 (onboarding, paywall, analytics)**: por iniciar
- **Fase 4 (polimento, App Store)**: por iniciar

**Falta verificar localmente** (se a sessão correu sem simulador): [lista ou "nada"]

**Próximo passo**: [uma linha]
