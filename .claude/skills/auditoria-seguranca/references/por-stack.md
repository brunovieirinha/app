<!-- VIEIRINHA121126 -->
# Onde procurar e como corrigir, por stack

## Índice
1. Expo / React Native
2. Next.js
3. Vite (React/Vue/Svelte)
4. Node (Express/Fastify/Hono)
5. Supabase
6. Firebase
7. Rate limiting: valores e implementações
8. Teto de gastos em rotas de IA

## 1. Expo / React Native

- **O que vai para o bundle**: tudo o que começa por `EXPO_PUBLIC_` em `.env*`, tudo em
  `app.json`/`app.config.*` (`extra`), e qualquer string no código. `expo-constants`
  expõe o `extra` inteiro.
- **Procurar**: `grep -rn EXPO_PUBLIC_ .`, `app.config.*` secção `extra`, `eas.json`
  (secção `env` de cada profile entra no build).
- **Corrigir**: segredos vão para Edge Functions do Supabase (`supabase/functions/<nome>/`)
  ou para o backend existente. A app chama com `supabase.functions.invoke('<nome>', {body})`,
  que envia o JWT do utilizador automaticamente.
- **Público por desenho**: `EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY`,
  chave do PostHog, DSN do Sentry, chave pública do Superwall/RevenueCat.
- **Armazenamento local**: tokens de sessão em `expo-secure-store`, nunca em
  `AsyncStorage` em claro.

## 2. Next.js

- **O que vai para o cliente**: `NEXT_PUBLIC_*`, tudo em componentes sem `'use server'`
  e fora de `app/api/`. Um ficheiro em `app/` importado por um client component é
  cliente.
- **Procurar**: `grep -rn NEXT_PUBLIC_ .`; imports de `openai`, `stripe`, `resend` em
  ficheiros com `'use client'` ou em `components/`.
- **Corrigir**: mover para `app/api/<rota>/route.ts` ou server actions. Validar com zod
  no topo do handler. Verificar sessão: Supabase (`createServerClient` + `getUser()`),
  Clerk (`auth()`), NextAuth (`getServerSession`).
- **Rate limiting**: `middleware.ts` com `@upstash/ratelimit` (edge) ou por rota.

## 3. Vite (React/Vue/Svelte)

- **O que vai para o cliente**: tudo o que começa por `VITE_`, e todo o código, porque o
  Vite não tem servidor. Qualquer chave num projeto Vite puro é pública.
- **Corrigir**: precisa de um backend. Se não existir, Supabase Edge Functions é o
  caminho mais curto; alternativa: Vercel/Netlify functions. Perguntar ao utilizador
  qual prefere se não houver nenhum.

## 4. Node (Express/Fastify/Hono)

- **Validação**: zod à entrada de cada handler (`schema.parse(req.body)` em try/catch
  → 400). Limitar tamanho do body (`express.json({limit: '100kb'})`).
- **SQL**: `pg` com `$1, $2`, Prisma/Drizzle/Knex com os métodos normais. Procurar
  `query(\`...${`, `.raw(`, `.unsafe(`.
- **Sessão**: middleware que lê `Authorization: Bearer` e valida com o fornecedor
  (`supabase.auth.getUser(token)`, `admin.auth().verifyIdToken`, Clerk
  `clerkMiddleware`). Aplicar a todas as rotas excepto health/webhooks (que validam
  assinatura).
- **Headers**: `helmet()`. CORS com origem explícita, não `*`.
- **Rate limiting**: `express-rate-limit` (memória, chega para uma instância) ou
  `rate-limiter-flexible` com Redis para várias.

## 5. Supabase

### Listar tabelas sem RLS (correr no SQL editor ou via MCP `execute_sql`)
```sql
select schemaname, tablename
from pg_tables
where schemaname = 'public' and rowsecurity = false
order by tablename;
```
### Tabelas com RLS mas sem políticas (RLS ativo sem políticas = ninguém lê, o que
também parte a app)
```sql
select t.tablename
from pg_tables t
left join pg_policies p on p.tablename = t.tablename and p.schemaname = t.schemaname
where t.schemaname = 'public' and t.rowsecurity = true
group by t.tablename having count(p.policyname) = 0;
```
### Ativar RLS e políticas por utilizador (migração)
```sql
alter table public.<tabela> enable row level security;

create policy "<tabela>: ler os próprios" on public.<tabela>
  for select to authenticated using (user_id = (select auth.uid()));
create policy "<tabela>: inserir os próprios" on public.<tabela>
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy "<tabela>: alterar os próprios" on public.<tabela>
  for update to authenticated using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
create policy "<tabela>: apagar os próprios" on public.<tabela>
  for delete to authenticated using (user_id = (select auth.uid()));
```
Se a tabela não tiver `user_id`, é preciso decidir de quem são as linhas: perguntar.
Usar `(select auth.uid())` em vez de `auth.uid()` directo por performance.
Correr também `get_advisors` (MCP) com `type: security` e tratar o que aparecer.

### Storage
Buckets privados por omissão; políticas em `storage.objects` por `auth.uid()` e por
prefixo de pasta (`(storage.foldername(name))[1] = auth.uid()::text`).

### Edge Functions
- Segredos: `supabase secrets set NOME=valor` (nunca em `config.toml` nem no código).
- Verificar utilizador no topo:
```ts
const authHeader = req.headers.get('Authorization') ?? '';
const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
  global: { headers: { Authorization: authHeader } },
});
const { data: { user }, error } = await supabase.auth.getUser();
if (error || !user) return new Response('Unauthorized', { status: 401 });
```
- Service role só quando for mesmo preciso (apagar conta, operações admin), num
  client separado, e nunca devolvido ao cliente.
- Auth do Supabase já tem rate limiting no login/registo/OTP (Dashboard → Auth →
  Rate Limits). Confirmar os valores; não duplicar.

## 6. Firebase

- Regras de segurança em `firestore.rules` e `storage.rules`. Procurar
  `allow read, write: if true` ou `if request.auth != null` sem restringir ao dono.
- Padrão por utilizador:
```
match /users/{uid}/{document=**} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```
- Chaves do Firebase no cliente são públicas por desenho; o que protege são as
  regras e o App Check (ativar).
- Segredos em Cloud Functions via `defineSecret` / Secret Manager.

## 7. Rate limiting: valores e implementações

Valores de partida (ajustar ao tráfego real e dizer no relatório):

| Rota | Por utilizador | Por IP | Janela |
|---|---|---|---|
| Geral (API) | 60 | 120 | 1 min |
| Login | — | 5 | 15 min |
| Registo | — | 3 | 1 h |
| Recuperar password / OTP | — | 3 | 15 min |
| Envio de email | 5 | 10 | 1 h |
| Pagamentos / checkout | 5 | 10 | 10 min |
| IA (chat, geração) | 10 | 20 | 1 min |

Resposta ao ultrapassar: `429` com header `Retry-After: <segundos>` e corpo curto
(`{"error":"Demasiados pedidos. Tenta de novo daqui a pouco."}`).

**Next.js / Edge Functions (sem servidor fixo)**: `@upstash/ratelimit` com Upstash
Redis (gratuito para volumes pequenos). O utilizador tem de criar a conta e pôr
`UPSTASH_REDIS_REST_URL`/`TOKEN` nos segredos: fica na lista "fazer à mão".
Alternativa sem serviço externo, em Supabase: tabela `rate_limits(key text, window_start
timestamptz, count int)` e uma função SQL `check_rate_limit(key, limit, window)` chamada
no topo da Edge Function. Mais lenta, mas sem dependências.

**Express/Fastify**: `express-rate-limit` / `@fastify/rate-limit`, com `keyGenerator`
por `user.id` quando autenticado e por IP caso contrário. Atrás de proxy, definir
`trust proxy` para o IP ser o real.

**Supabase Auth**: já limita login/registo/OTP. Confirmar no dashboard.

## 8. Teto de gastos em rotas de IA

Além do rate limiting por minuto, um limite diário para ninguém esgotar os créditos:

- Tabela `ai_usage(user_id, day date, requests int, tokens int)` com upsert por pedido.
- Limites por utilizador/dia (por exemplo 50 pedidos ou 100k tokens) e global/dia
  (por exemplo 5 000 pedidos). Valores a confirmar com o utilizador no relatório.
- Verificar antes de chamar o modelo; ao atingir, responder 429 com mensagem clara
  ("Atingiste o limite diário") sem expor números internos.
- Definir `max_tokens` em todas as chamadas e limitar o tamanho do prompt do
  utilizador (por exemplo 4 000 caracteres) com zod.
- Opcional: alerta de gasto no painel do fornecedor (OpenAI/Anthropic têm limites de
  gasto mensais): fica na lista "fazer à mão".
