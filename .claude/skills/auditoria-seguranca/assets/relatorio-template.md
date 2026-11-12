# Auditoria de segurança: [nome da app], [data]

<!-- VIEIRINHA121126 -->

## 1. O que mudei

### Regra 1: chaves fora do frontend
- [ficheiro]: [o que estava, o que está agora]
- Chaves que ficaram no cliente por serem públicas: [lista com motivo]

### Regra 2: validação e sanitização
- [rota/função]: schema zod com [campos e limites]
- Tabelas que estavam sem RLS: [lista]. Agora com políticas por `auth.uid()`.
- [outros]

### Regra 3: autenticação
- [rotas que passaram a verificar sessão no servidor]

### Regra 4: rate limiting
- [rotas e limites aplicados, por utilizador e por IP]
- Teto de gastos de IA: [valores]

Commits: [lista `fix(security): ...`]

## 2. O que tens de fazer à mão

- [ ] Revogar e criar nova: [serviço, chave, onde se faz]. Motivo: esteve em [ficheiro/commit].
- [ ] Configurar segredos no servidor: `supabase secrets set ...` / variáveis na Vercel
- [ ] Criar conta/serviço: [Upstash, captcha, ...]
- [ ] Confirmar no dashboard: [Supabase Auth rate limits, advisors de segurança]
- [ ] Testar: [login, ação principal, rota de IA] para confirmar que nada visível mudou

## 3. Perguntas antes de avançar

- [decisão pendente e opções, com recomendação]
