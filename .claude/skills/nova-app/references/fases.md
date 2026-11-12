<!-- VIEIRINHA121126 -->
# Roadmap em 4 fases

O princípio é ter algo a funcionar hoje e crescer depois, em complexidade e em
funcionalidades. Cada fase tem um âmbito fechado, uma checklist e um critério de
"feito". Antes de cada fase: plano curto, aprovação do utilizador, só depois execução.

## Fase 1: a ação principal a funcionar no simulador

**Objetivo**: o utilizador abre a app no simulador do iPhone e consegue fazer a ação
principal do PRD de uma ponta à outra, mesmo que os dados fiquem só no telemóvel.

**Âmbito**
- Projeto Expo com Expo Router e TypeScript (`npx create-expo-app@latest -t tabs` ou
  `blank-typescript`, consoante o PRD). iOS primeiro.
- Design system em `src/theme/` (cores, tipografia, espaçamentos, raios) antes do
  primeiro ecrã. Todos os ecrãs usam só tokens do tema.
- Os ecrãs estritamente necessários para a ação principal. Normalmente 1 a 3.
- Dados locais: estado em memória ou AsyncStorage/SQLite. Nada de backend ainda.
- `CLAUDE.md` criado a partir do template.
- `.gitignore` com `.env*`, `node_modules`, `ios/`, `android/` (se não forem versionados).

**Fica de fora**: login, sincronização, paywall, analytics, onboarding, definições,
qualquer ecrã que não esteja no caminho da ação principal.

**Feito quando**
- `npx expo run:ios` (ou `npx expo start` + simulador) abre a app sem erros.
- Com o Argent, a ação principal foi executada no simulador e o resultado lido no ecrã.
- Commit feito e `CLAUDE.md` com "Fase 1: concluída" e as decisões tomadas.

## Fase 2: contas, base de dados e sincronização

**Objetivo**: os dados da ação principal passam a viver no Supabase, por utilizador, e
sobrevivem a reinstalar a app.

**Âmbito**
- Projeto Supabase (criar com a CLI ou MCP; o utilizador confirma a organização/região).
- Schema Postgres mínimo para a ação principal. Migrações versionadas em
  `supabase/migrations/`.
- **RLS ativo em todas as tabelas**, com políticas por `auth.uid()`. Sem exceções.
- Auth com Sign in with Apple (e anónimo, se o PRD permitir experimentar antes de criar
  conta).
- Cliente Supabase na app só com URL e chave anónima/publicável, lidas de variáveis
  `EXPO_PUBLIC_*`.
- Apagar conta dentro da app (Edge Function com service role que apaga o utilizador e os
  dados). A Apple exige isto; fazê-lo agora evita refazer ecrãs na Fase 4.
- Sincronização: a app escreve/lê no Supabase; se o PRD exigir offline, fila local com
  reenvio. Caso contrário, online simples.
- Storage apenas se a ação principal precisar de ficheiros.

**Fica de fora**: paywall, analytics, emails, onboarding bonito.

**Feito quando**
- Novo utilizador faz login com Apple no simulador, executa a ação principal, os dados
  aparecem na tabela do Supabase, e um segundo utilizador não os vê (teste de RLS feito
  com dois utilizadores ou com `supabase test`).
- Apagar conta remove o utilizador e os seus dados.
- `supabase db diff` limpo, migrações commitadas, `CLAUDE.md` atualizado.

## Fase 3: onboarding, paywall e analytics (pronta para TestFlight)

**Objetivo**: o funil completo existe e é medido: abrir a app → onboarding → paywall →
subscrever → ação principal.

**Âmbito**
- Onboarding curto (2 a 4 ecrãs) que explica o valor e pede as permissões necessárias
  com justificação clara. Nada de pedir permissões que a app não usa.
- Superwall configurado sobre StoreKit, com os produtos criados no App Store Connect
  (o utilizador cria os produtos; a skill prepara os IDs e a configuração). Paywall
  aparece no fim do onboarding. Botão de restaurar compras visível.
- Gating: o que fica grátis e o que fica atrás do paywall, conforme o PRD.
- PostHog com os eventos do funil: `app_aberta`, `onboarding_concluido`,
  `paywall_visto`, `subscreveu`, `acao_principal`. Nomes em `src/analytics/eventos.ts`
  para não haver strings soltas.
- Sentry para erros, com DSN em variável de ambiente.
- Resend via Edge Function para o email transacional mínimo (boas-vindas ou recibo),
  só se o PRD o pedir.
- Política de privacidade e termos acessíveis dentro da app (links ou ecrã).
- Build com EAS (`eas build --platform ios --profile preview`) e envio para TestFlight.

**Feito quando**
- Com o Argent: onboarding completo no simulador, paywall aparece, compra sandbox
  funciona, restaurar compras funciona, ação principal desbloqueada.
- Os 5 eventos aparecem no PostHog. Um erro forçado aparece no Sentry.
- Build no TestFlight instalável num iPhone real. `CLAUDE.md` atualizado.

## Fase 4: polimento e submissão na App Store

**Objetivo**: passar a review da Apple à primeira.

**Âmbito**
- Rever a checklist da Apple em `stack-e-regras.md` ponto a ponto.
- Ícone, splash, nome, screenshots (6.7" e 6.1" no mínimo), descrição, palavras-chave,
  categoria, classificação etária, URL de privacidade e de suporte.
- Estados vazios, de erro e de carregamento em todos os ecrãs. Textos revistos.
- Performance: arranque rápido, listas com `FlatList`, imagens com tamanhos corretos.
- Acessibilidade mínima: labels nos botões, contraste, Dynamic Type não parte layouts.
- `eas build --profile production` e submissão (`eas submit`) ou via Xcode/Transporter.
- EAS Update configurado para correções rápidas sem nova review.

**Feito quando**
- Submissão feita no App Store Connect com estado "Waiting for Review" ou superior.
- `CLAUDE.md` com "Fase 4: submetida em DD/MM/AAAA" e os próximos passos pós-lançamento.

## Depois do lançamento

Não faz parte do roadmap inicial, mas deixa no `CLAUDE.md` três linhas: o que medir na
primeira semana (os eventos do funil), o que fazer se a review for rejeitada (ler o
motivo, corrigir, resubmeter, nunca discutir), e a primeira funcionalidade da secção
"Fora da primeira versão" que vale a pena fazer a seguir.
