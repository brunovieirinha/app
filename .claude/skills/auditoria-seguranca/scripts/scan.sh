#!/usr/bin/env bash
# VIEIRINHA121126 - scan de segurança só de leitura. Não altera nada.
# Uso: bash scan.sh <pasta-do-projeto>
set -u
ROOT="${1:-.}"
cd "$ROOT" || { echo "Pasta não encontrada: $ROOT"; exit 1; }

EXCL='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=.expo --exclude-dir=ios --exclude-dir=android --exclude-dir=coverage'
CLIENT_GLOB='--include=.env* --include=*.ts --include=*.tsx --include=*.js --include=*.jsx --include=*.mjs --include=*.vue --include=*.svelte --include=*.html --include=*.json'

sec() { printf '\n==== %s ====\n' "$1"; }
hit() { printf '  [!] %s\n' "$1"; }
ok()  { printf '  [ok] %s\n' "$1"; }

sec "Stack detetada"
[ -f package.json ] && grep -oE '"(expo|next|vite|react-native|express|fastify|hono|@supabase/supabase-js|firebase|@clerk/[a-z-]+|@auth0/[a-z-]+|zod|express-rate-limit|@upstash/ratelimit|dompurify|openai|@anthropic-ai/sdk|stripe|resend)"' package.json | sort -u | sed 's/^/  /'
[ -d supabase ] && echo "  supabase/ presente"
[ -f firebase.json ] && echo "  firebase.json presente"

sec "1. Segredos no código cliente (padrões conhecidos)"
grep -rnE $EXCL $CLIENT_GLOB \
  -e 'sk-[A-Za-z0-9_-]{20,}' \
  -e 'sk-ant-[A-Za-z0-9_-]{20,}' \
  -e 'sk_(live|test)_[A-Za-z0-9]{10,}' \
  -e 'rk_(live|test)_[A-Za-z0-9]{10,}' \
  -e 'whsec_[A-Za-z0-9]{10,}' \
  -e 're_[A-Za-z0-9]{20,}' \
  -e 'AIza[0-9A-Za-z_-]{30,}' \
  -e 'ghp_[A-Za-z0-9]{30,}' \
  -e 'xox[baprs]-[A-Za-z0-9-]{10,}' \
  -e 'AKIA[0-9A-Z]{16}' \
  -e '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----' \
  . 2>/dev/null | sed 's/^/  [!] /' || true
# JWT do Supabase com role service_role (payload em base64 contém "service_role")
grep -rnoE $EXCL $CLIENT_GLOB 'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' . 2>/dev/null | while IFS=: read -r f l tok; do
  payload=$(echo "$tok" | cut -d. -f2 | tr '_-' '/+' | base64 -d 2>/dev/null || true)
  echo "$payload" | grep -q service_role && hit "service_role JWT em $f:$l"
done
ok "fim dos padrões conhecidos (ausência de linhas [!] acima = nada encontrado por padrão)"

sec "1b. Variáveis públicas com nomes suspeitos (EXPO_PUBLIC_/NEXT_PUBLIC_/VITE_)"
grep -rnE $EXCL --include=*.env* --include=*.ts --include=*.tsx --include=*.js --include=*.jsx --include=*.json --include=*.yml --include=*.yaml \
  '(EXPO_PUBLIC|NEXT_PUBLIC|VITE)_[A-Z0-9_]*(SECRET|PRIVATE|SERVICE_ROLE|SERVICE_KEY|API_KEY|APIKEY|TOKEN|PASSWORD|OPENAI|ANTHROPIC|STRIPE|RESEND)' . 2>/dev/null | sed 's/^/  [!] /' || true
echo "  (nota: *_ANON_KEY, *_PUBLISHABLE_KEY, *_POSTHOG_KEY, *_SENTRY_DSN são públicas por desenho)"

sec "1c. Ficheiros .env e .gitignore"
for f in $(find . -maxdepth 3 -name '.env*' -not -name '*.example' -not -path '*/node_modules/*' 2>/dev/null); do
  if [ -f .gitignore ] && git check-ignore -q "$f" 2>/dev/null; then ok "$f ignorado"; else hit "$f NÃO está no .gitignore"; fi
done
[ -f .env.example ] && ok ".env.example existe" || hit "não existe .env.example"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  hist=$(git log --all --diff-filter=A --name-only --pretty=format: -- '.env' '.env.*' '*/.env' 2>/dev/null | grep -v '\.example$' | sort -u)
  [ -n "$hist" ] && { hit "ficheiros .env no HISTÓRICO do git (chaves expostas, revogar):"; echo "$hist" | sed 's/^/      /'; } || ok "nenhum .env no histórico do git"
fi

sec "2a. HTML não escapado / eval"
grep -rnE $EXCL $CLIENT_GLOB 'dangerouslySetInnerHTML|\.innerHTML\s*=|insertAdjacentHTML|v-html=|\{@html|new Function\(|\beval\(' . 2>/dev/null | sed 's/^/  [!] /' || true

sec "2b. SQL concatenado"
grep -rnE $EXCL $CLIENT_GLOB "(SELECT|INSERT|UPDATE|DELETE|WHERE)[^\n]*(\\$\\{|\" *\\+ *[a-zA-Z_]|' *\\+ *[a-zA-Z_])" . 2>/dev/null | grep -viE 'migrations/|\.sql$' | sed 's/^/  [!] /' || true
grep -rnE $EXCL $CLIENT_GLOB '\.raw\(|\.unsafe\(|rpc\(.*\$\{' . 2>/dev/null | sed 's/^/  [?] rever: /' || true

sec "2c. Validação de input (zod/yup/valibot) nas rotas"
routes=$(find . -type f \( -path '*/api/*' -o -path '*/functions/*' -o -path '*/server/*' -o -path '*/routes/*' -o -name 'route.ts' -o -name 'route.js' \) -not -path '*/node_modules/*' -not -path '*/.next/*' 2>/dev/null)
if [ -n "$routes" ]; then
  for r in $routes; do
    grep -qE 'zod|yup|valibot|\.parse\(|\.safeParse\(|Joi\.' "$r" 2>/dev/null || hit "sem schema de validação: $r"
  done
else echo "  (sem pastas api/functions/server/routes encontradas)"; fi

sec "2d. Supabase: RLS nas migrações"
if [ -d supabase/migrations ]; then
  for t in $(grep -rhoiE 'create table (if not exists )?(public\.)?"?[a-z_]+"?' supabase/migrations 2>/dev/null | awk '{print $NF}' | tr -d '"' | sed 's/^public\.//' | sort -u); do
    grep -rqiE "alter table (public\.)?\"?$t\"? enable row level security" supabase/migrations 2>/dev/null && ok "RLS em $t" || hit "tabela $t SEM 'enable row level security' nas migrações"
  done
  echo "  (confirma no projeto remoto com o SQL em references/por-stack.md)"
else echo "  (sem supabase/migrations; verificar RLS via MCP/SQL)"; fi

sec "3. Autenticação"
grep -rnE $EXCL $CLIENT_GLOB 'bcrypt|argon2|scrypt|pbkdf2|jwt\.sign\(|jsonwebtoken|password_hash|passwordHash|createHmac\(' . 2>/dev/null | grep -v supabase/functions | sed 's/^/  [?] auth feita à mão?: /' || true
if [ -n "${routes:-}" ]; then
  for r in $routes; do
    grep -qE 'getUser\(|getSession\(|verifyIdToken|auth\(\)|currentUser|getAuth\(|requireAuth|withAuth|authenticate|Authorization' "$r" 2>/dev/null || hit "rota sem verificação de sessão visível: $r"
  done
fi

sec "4. Rate limiting"
grep -rlE $EXCL $CLIENT_GLOB 'express-rate-limit|@upstash/ratelimit|rate-limiter-flexible|rateLimit\(|ratelimit|RateLimit|429' . 2>/dev/null | sed 's/^/  encontrado em: /' || hit "nenhuma referência a rate limiting no código"
grep -rlE $EXCL $CLIENT_GLOB 'openai|anthropic|@ai-sdk|generateText|chat\.completions|messages\.create' . 2>/dev/null | sed 's|^|  rota ou ficheiro de IA (precisa de limite + teto de gastos): |' || true

printf '\nScan terminado. Isto é um ponto de partida: revê manualmente o que o scan não apanha.\n'
