# TrackCargo — Tracking de Contentores e Carga Aérea (PORTOCARGO)

App web interna para tracking em tempo real da carga movimentada pela Portocargo:

- **Marítimo** — contentores/BL via API **ShipsGo v1.2** (agregador junto dos armadores),
  com mapa live da posição do navio
- **Aéreo** — AWB via API **ShipsGo v2 Air** (tracking junto das companhias aéreas),
  com rota de aeroportos e voos

## 1. Descrição e estrutura de ficheiros

```
trackcargo/
├── db.asp          ← connection string + helpers (template standard Portocargo)
├── api.asp         ← API REST (VBScript) + integração ShipsGo server-side
├── index.html      ← SPA (HTML + CSS + JS vanilla)
├── logo/           ← (opcional) logo.png|jpg|svg para branding
└── README.md       ← este ficheiro
```

**Fluxo de dados:**

1. O utilizador adiciona um contentor/BL (marítimo) ou um AWB (aéreo) → o IIS chama a
   ShipsGo (**consome 1 crédito** — os créditos ocean e air são contados à parte na
   ShipsGo) e grava o id de tracking no SQL Server (`shipsgo_reqid`).
   - Marítimo: `POST PostContainerInfo` / `PostContainerInfoWithBl` (API v1.2, form-urlencoded)
   - Aéreo: `POST https://api.shipsgo.com/v2/air/shipments` (API v2, JSON, header `X-Shipsgo-User-Token`)
2. Botão ⟳ / "Sincronizar todos" → o IIS consulta o estado atual (grátis, sem créditos),
   devolve o JSON à SPA, que extrai os campos e persiste o snapshot via `action=snapshot`.
3. O detalhe mostra timeline de milestones — marítimo: gate in, load, transbordos,
   chegada, descarga + mapa live do navio (iframe); aéreo: eventos/voos entre aeroportos.

Os **tokens ShipsGo vivem apenas no `api.asp` (server-side)** — nunca são enviados ao browser.

## 2. Pré-requisitos

- Windows Server com IIS e **Classic ASP** ativo
- **SQL Server Native Client / OLEDB** (SQLOLEDB) — já usado pelas restantes apps
- Acesso do servidor IIS à internet por HTTPS para `shipsgo.com` (porta 443)
  — a integração usa `MSXML2.ServerXMLHTTP.6.0`
- Conta ShipsGo com créditos (pay-as-you-go) e o respetivo **authCode**

## 3. Deploy passo a passo

1. Copiar a pasta `trackcargo/` para o site IIS (ex.: `C:\inetpub\wwwroot\trackcargo\`).
2. No IIS, garantir que a app corre num Application Pool com Classic ASP ativo
   e sessões ASP ligadas (Session State).
3. Executar o script SQL da secção 6 na base `PHC_Portocargo` (server `PCPHC`).
4. Confirmar a constante `SHIPSGO_AUTHCODE` no `api.asp` (secção 5).
5. Abrir `https://<servidor>/trackcargo/` e fazer login com as credenciais SQL do utilizador.

## 4. Configuração da connection string (`db.asp`)

O `db.asp` é o template standard Portocargo (server `PCPHC`, base `PHC_Portocargo`,
conta `website` apenas para o endpoint `branding`). Não necessita de alterações.

## 5. Configuração das constantes (`api.asp`)

| Constante | Valor | Notas |
|---|---|---|
| `DB_SERVER` | `PCPHC` | |
| `DB_DATABASE` | `PHC_Portocargo` | |
| `PHC_PERFIL_NO` | `0` | Mudar para N para exigir perfil PHC nº N |
| `SHIPSGO_AUTHCODE` | *(já configurado)* | AuthCode v1.2 (marítimo) — **server-side only** |
| `SHIPSGO_BASE` | `https://shipsgo.com/api/v1.2/ContainerService/` | API v1.2 (marítimo) |
| `SHIPSGO_AIR_TOKEN` | *(= authCode, confirmar)* | API key v2 (aéreo) — ver Dashboard ShipsGo → API. **Pode ser diferente do authCode v1.2**; se o aéreo devolver 401, gerar/copiar a key v2 no dashboard |
| `SHIPSGO_AIR_BASE` | `https://api.shipsgo.com/v2/air/shipments` | API v2 Air |

⚠ **Segurança do authCode**: o ficheiro `api.asp` nunca deve ficar acessível como texto
(o IIS executa-o, não o serve). Se o repositório Git for partilhado fora da equipa,
considerar mover o authCode para um include fora do webroot e **rodar o código na ShipsGo**
(Dashboard → API) se houver suspeita de exposição.

## 6. Permissões SQL necessárias (tabelas + SPs)

Executar em `PHC_Portocargo`:

```sql
------------------------------------------------------------------
-- TABELA
------------------------------------------------------------------
CREATE TABLE dbo.u_trackcargo (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    transport_mode VARCHAR(4)  NOT NULL DEFAULT 'SEA',   -- SEA | AIR
    container_no  VARCHAR(20)  NOT NULL DEFAULT '',
    awb_no        VARCHAR(20)  NOT NULL DEFAULT '',
    bl_no         VARCHAR(40)  NOT NULL DEFAULT '',
    ref_processo  VARCHAR(40)  NOT NULL DEFAULT '',
    shipping_line VARCHAR(20)  NOT NULL DEFAULT 'OTHERS',
    shipsgo_reqid VARCHAR(20)  NOT NULL,
    [status]      VARCHAR(40)  NOT NULL DEFAULT '',
    pol           VARCHAR(80)  NOT NULL DEFAULT '',
    pod           VARCHAR(80)  NOT NULL DEFAULT '',
    vessel        VARCHAR(80)  NOT NULL DEFAULT '',
    vessel_imo    VARCHAR(20)  NOT NULL DEFAULT '',
    voyage        VARCHAR(40)  NOT NULL DEFAULT '',
    etd           DATETIME NULL,
    eta           DATETIME NULL,
    ata           DATETIME NULL,
    last_json     NVARCHAR(MAX) NULL,
    last_sync     DATETIME NULL,
    active        BIT NOT NULL DEFAULT 1,
    created_by    VARCHAR(50) NOT NULL DEFAULT '',
    created_at    DATETIME NOT NULL DEFAULT GETDATE()
);
CREATE INDEX ix_u_trackcargo_reqid ON dbo.u_trackcargo (shipsgo_reqid);
GO

------------------------------------------------------------------
-- SP: LISTA
------------------------------------------------------------------
CREATE PROCEDURE dbo.usp_TrackCargo_Lista
    @filtro VARCHAR(100),
    @estado VARCHAR(40)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, transport_mode, container_no, awb_no, bl_no, ref_processo, shipping_line,
           shipsgo_reqid, [status], pol, pod, vessel, voyage, etd, eta, ata,
           CONVERT(VARCHAR(16), last_sync, 120) AS last_sync, created_by
    FROM dbo.u_trackcargo WITH(NOLOCK)
    WHERE active = 1
      AND (@filtro = '' OR container_no LIKE '%' + @filtro + '%'
                        OR awb_no       LIKE '%' + @filtro + '%'
                        OR bl_no        LIKE '%' + @filtro + '%'
                        OR ref_processo LIKE '%' + @filtro + '%'
                        OR vessel       LIKE '%' + @filtro + '%')
      AND (@estado = '' OR [status] LIKE @estado + '%')
    ORDER BY COALESCE(ata, eta, '2999-12-31'), id DESC;
END
GO

------------------------------------------------------------------
-- SP: DETALHE
------------------------------------------------------------------
CREATE PROCEDURE dbo.usp_TrackCargo_Detalhe
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, transport_mode, container_no, awb_no, bl_no, ref_processo, shipping_line,
           shipsgo_reqid, [status], pol, pod, vessel, vessel_imo, voyage, etd, eta, ata,
           last_json, CONVERT(VARCHAR(16), last_sync, 120) AS last_sync
    FROM dbo.u_trackcargo WITH(NOLOCK)
    WHERE id = @id;
END
GO

------------------------------------------------------------------
-- SP: ADD (devolve o id novo; se o requestId já existir, reativa)
------------------------------------------------------------------
CREATE PROCEDURE dbo.usp_TrackCargo_Add
    @transport_mode VARCHAR(4),
    @container_no  VARCHAR(20),
    @bl_no         VARCHAR(40),
    @awb_no        VARCHAR(20),
    @shipping_line VARCHAR(20),
    @shipsgo_reqid VARCHAR(20),
    @ref_processo  VARCHAR(40),
    @created_by    VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id INT;
    SELECT @id = id FROM dbo.u_trackcargo WITH(NOLOCK)
    WHERE shipsgo_reqid = @shipsgo_reqid AND transport_mode = @transport_mode;
    IF @id IS NOT NULL
    BEGIN
        UPDATE dbo.u_trackcargo
        SET active = 1,
            ref_processo = CASE WHEN @ref_processo <> '' THEN @ref_processo ELSE ref_processo END
        WHERE id = @id;
        SELECT @id AS id;
        RETURN;
    END
    INSERT INTO dbo.u_trackcargo (transport_mode, container_no, bl_no, awb_no, ref_processo, shipping_line, shipsgo_reqid, created_by)
    VALUES (@transport_mode, @container_no, @bl_no, @awb_no, @ref_processo, @shipping_line, @shipsgo_reqid, @created_by);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS id;
END
GO

------------------------------------------------------------------
-- SP: SNAPSHOT (persiste o último estado vindo da ShipsGo)
------------------------------------------------------------------
CREATE PROCEDURE dbo.usp_TrackCargo_Snapshot
    @id           INT,
    @status       VARCHAR(40),
    @pol          VARCHAR(80),
    @pod          VARCHAR(80),
    @vessel       VARCHAR(80),
    @vessel_imo   VARCHAR(20),
    @voyage       VARCHAR(40),
    @container_no VARCHAR(20),
    @etd          VARCHAR(30),
    @eta          VARCHAR(30),
    @ata          VARCHAR(30),
    @last_json    NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.u_trackcargo SET
        [status]     = CASE WHEN @status <> '' THEN @status ELSE [status] END,
        pol          = CASE WHEN @pol    <> '' THEN @pol    ELSE pol END,
        pod          = CASE WHEN @pod    <> '' THEN @pod    ELSE pod END,
        vessel       = CASE WHEN @vessel <> '' THEN @vessel ELSE vessel END,
        vessel_imo   = CASE WHEN @vessel_imo <> '' THEN @vessel_imo ELSE vessel_imo END,
        voyage       = CASE WHEN @voyage <> '' THEN @voyage ELSE voyage END,
        container_no = CASE WHEN @container_no <> '' THEN @container_no ELSE container_no END,
        etd = COALESCE(TRY_CONVERT(DATETIME, @etd, 120), TRY_CONVERT(DATETIME, @etd, 126), etd),
        eta = COALESCE(TRY_CONVERT(DATETIME, @eta, 120), TRY_CONVERT(DATETIME, @eta, 126), eta),
        ata = COALESCE(TRY_CONVERT(DATETIME, @ata, 120), TRY_CONVERT(DATETIME, @ata, 126), ata),
        last_json = @last_json,
        last_sync = GETDATE()
    WHERE id = @id;
END
GO

------------------------------------------------------------------
-- SP: REMOVE (soft delete)
------------------------------------------------------------------
CREATE PROCEDURE dbo.usp_TrackCargo_Remove
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.u_trackcargo SET active = 0 WHERE id = @id;
END
GO

------------------------------------------------------------------
-- PERMISSÕES — dar EXECUTE aos utilizadores/role que usam a app
-- (com ownership chaining não é preciso GRANT direto na tabela)
------------------------------------------------------------------
-- Exemplo, por utilizador ou role:
-- GRANT EXECUTE ON dbo.usp_TrackCargo_Lista    TO [utilizador_ou_role];
-- GRANT EXECUTE ON dbo.usp_TrackCargo_Detalhe  TO [utilizador_ou_role];
-- GRANT EXECUTE ON dbo.usp_TrackCargo_Add      TO [utilizador_ou_role];
-- GRANT EXECUTE ON dbo.usp_TrackCargo_Snapshot TO [utilizador_ou_role];
-- GRANT EXECUTE ON dbo.usp_TrackCargo_Remove   TO [utilizador_ou_role];
```

**Migração (se a versão só-marítimo já estava instalada):**

```sql
ALTER TABLE dbo.u_trackcargo ADD transport_mode VARCHAR(4) NOT NULL DEFAULT 'SEA';
ALTER TABLE dbo.u_trackcargo ADD awb_no VARCHAR(20) NOT NULL DEFAULT '';
GO
-- Recriar as SPs usp_TrackCargo_Lista, usp_TrackCargo_Detalhe e usp_TrackCargo_Add
-- com as definições acima (DROP PROCEDURE + CREATE PROCEDURE).
```

## 7. Como testar

1. **Ligação ShipsGo a partir do servidor** (o ambiente de desenvolvimento desta app não
   tinha saída de rede para `shipsgo.com`, pelo que a API **não foi testada em live** —
   validar no primeiro deploy). Num browser do servidor, ou via PowerShell:
   ```powershell
   Invoke-WebRequest "https://shipsgo.com/api/v1.2/ContainerService/GetContainerInfo/?authCode=<AUTHCODE>&requestId=1"
   ```
   Uma resposta JSON (mesmo de erro "not found") confirma rede + authCode aceite.
2. Login na app com um utilizador SQL válido.
3. "+ Adicionar" com um contentor real em trânsito (ex.: um contentor de um processo
   marítimo atual). Consome 1 crédito. A app faz sync automático após criar.
4. Verificar: linha na grelha com estado/ETA, detalhe com timeline e mapa.
5. "Sincronizar todos" e conferir `last_sync` atualizado.
6. Aéreo: mudar para "Aéreo" na sidebar e adicionar um AWB real (formato `123-12345675`).
   Se devolver HTTP 401, a API key v2 é diferente — ver secção 5 (`SHIPSGO_AIR_TOKEN`).
7. Conferir na base: `SELECT * FROM u_trackcargo`.

**Nota sobre o formato da resposta ShipsGo**: o parsing do JSON (nomes `Status`,
`ArrivalDate`, `TSPorts`, `VesselLatitude`, …) foi escrito de forma defensiva
(aceita datas como string ou objeto `{Date, IsActual}`), mas deve ser validado com
uma resposta real no primeiro teste — ajustar `extractSnapshot()` / `buildTimeline()`
no `index.html` se a conta ShipsGo devolver nomes diferentes.

## 8. Funcionalidades

- **Marítimo e aéreo na mesma app** — navegação Marítimo ⚓ / Aéreo ✈ na sidebar
- Tracking por **nº de contentor** ou por **BL/booking** (1 crédito cobre o BL inteiro)
- Tracking aéreo por **AWB** (companhia detetada pelo prefixo do AWB); timeline de
  eventos/voos entre aeroportos
- Milestones normalizados: gate in, load, partida, transbordos (TSPorts), chegada,
  descarga, gate out, devolução do vazio — timeline com estimado vs. efetivo
- **Mapa live** da posição do navio (embed ShipsGo `marine-traffic`) + lat/lng
- KPIs: ativos, em trânsito, a chegar em ≤7 dias, chegados — clicáveis (filtram)
- Pesquisa (contentor/BL/processo/navio), filtro por estado, ordenação por coluna
- Campo **Ref. processo** para ligar ao dossier PHC (`u_mlistaproc` — ligação
  automática é evolução futura)
- Sincronização individual (⟳) e em massa ("Sincronizar todos") — **não gasta créditos**
- Export **XLSX**
- Dark/Light mode + PT/EN persistidos em `localStorage`
- Autenticação por credenciais SQL do utilizador (padrão Portocargo), com
  suporte opcional a perfil PHC (`PHC_PERFIL_NO`)

## 9. Personalização do logotipo (`logo/`)

Criar a pasta `logo/` dentro de `trackcargo/` e colocar `logo.png` (ou `.jpg`, `.jpeg`,
`.svg`, `.gif`). Aparece automaticamente no login e na sidebar.

## 10. Resolução de problemas

| Sintoma | Causa provável | Solução |
|---|---|---|
| `msxml3.dll` / erro no add ou sync | IIS sem saída HTTPS para shipsgo.com | Abrir firewall/proxy para `shipsgo.com:443` |
| "ShipsGo: … (HTTP 401/403)" | authCode errado ou revogado | Confirmar no dashboard ShipsGo |
| "ShipsGo: …" ao adicionar | Créditos esgotados, contentor inválido ou já existente | Ver mensagem; comprar créditos / verificar nº |
| Estado UNTRACKABLE | Armador não suportado ou nº inexistente | Tentar por BL, ou escolher o armador correto em vez de auto |
| "ShipsGo Air: … (HTTP 401)" | API key v2 diferente do authCode v1.2 | Copiar a key v2 do dashboard para `SHIPSGO_AIR_TOKEN` |
| Aéreo sem eventos/campos vazios | Formato da resposta v2 diferente do esperado | Colar o JSON real e ajustar `extractAirSnapshot()`/`buildAirTimeline()` no index.html |
| "Credenciais inválidas" no login | Login SQL sem acesso a PHC_Portocargo | Criar login SQL + user na BD com EXECUTE nas SPs |
| Grelha vazia após sync | SPs sem GRANT EXECUTE | Correr os GRANTs da secção 6 |
| Datas vazias no snapshot | Formato de data ShipsGo diferente | Ajustar `normDate()` no index.html e os `TRY_CONVERT` na SP Snapshot |
| Mapa não carrega | ShipsGo bloqueia iframe nalguns planos | Usar o link "Abrir mapa em ecrã inteiro" |

## 11. Segurança

- Servir a app **apenas por HTTPS** e idealmente restrita à rede interna / VPN
- Restringir por IP no IIS se exposta externamente
- authCode ShipsGo só server-side (`api.asp`); rodar o código se houver suspeita de fuga
- Todos os endpoints de dados exigem sessão autenticada (401 caso contrário) e usam
  `GetUserConnection()` (credenciais SQL do próprio utilizador)
- Todo o acesso a dados é feito via **Stored Procedures** com parâmetros ADODB
  (sem SQL concatenado)
- Logging: considerar ativar logs do IIS para auditoria de acessos; a tabela guarda
  `created_by` e `created_at` por tracking
