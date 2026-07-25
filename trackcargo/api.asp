<%@ Language=VBScript CodePage=65001 %>
<%
Response.CodePage = 65001
Response.CharSet = "utf-8"
Response.Buffer = True
Session.CodePage = 65001
%>
<!-- #include file="db.asp" -->
<%
'================================================================
' TRACKCARGO — Tracking de Contentores (ShipsGo) — API Backend
' VIEIRINHA250726
'================================================================

Const DB_SERVER   = "PCPHC"
Const DB_DATABASE = "PHC_Portocargo"
Const PHC_PERFIL_NO = 0   ' 0 = sem restrição; N = exige perfil PHC nº N

'----------------------------------------------------------------
' ShipsGo — tokens SERVER-SIDE, nunca enviados ao browser.
' Marítimo: API v1.2 (authCode) · Aéreo: API v2 (API key no header)
' NOTA: confirmar no dashboard ShipsGo se a API key v2 (aéreo) é a
' mesma do authCode v1.2 — se não for, atualizar SHIPSGO_AIR_TOKEN.
'----------------------------------------------------------------
Const SHIPSGO_AUTHCODE = "668e9266-0d35-4054-a3d3-f09b8a68fab5"
Const SHIPSGO_BASE     = "https://shipsgo.com/api/v1.2/ContainerService/"
Const SHIPSGO_AIR_TOKEN = "668e9266-0d35-4054-a3d3-f09b8a68fab5"
Const SHIPSGO_AIR_BASE  = "https://api.shipsgo.com/v2/air/shipments"

Dim sAction
sAction = LCase(Trim(Request.QueryString("action")))

Select Case sAction
    Case "check"    : DoCheck
    Case "login"    : DoLogin
    Case "logout"   : DoLogout
    Case "branding" : DoBranding
    Case "lista"    : DoListaSafe
    Case "detalhe"  : DoDetalheSafe
    Case "add"      : DoAddSafe
    Case "sync"     : DoSyncSafe
    Case "snapshot" : DoSnapshotSafe
    Case "remove"   : DoRemoveSafe
    Case Else
        Response.ContentType = "application/json"
        Response.Write "{""error"":""Accao desconhecida""}"
End Select

'================================================================
' AUTENTICAÇÃO
'================================================================
Function IsLoggedIn()
    IsLoggedIn = (Session("sql_user") <> "")
End Function

Function GetUserConnection()
    Dim conn, sCS
    sCS = "Provider=SQLOLEDB;Server=" & DB_SERVER & _
          ";Database=" & DB_DATABASE & _
          ";Uid=" & Session("sql_user") & _
          ";Pwd=" & Session("sql_pass") & ";"
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.CommandTimeout = 180
    conn.Open sCS
    Set GetUserConnection = conn
End Function

Sub DoCheck()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If IsLoggedIn() Then
        Response.Write "{""loggedIn"":true,""username"":""" & JsonEscape(Session("sql_user")) & """}"
    Else
        Response.Write "{""loggedIn"":false}"
    End If
End Sub

Sub DoLogin()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    Dim sUser, sPass
    sUser = Trim(Request.Form("username"))
    sPass = Request.Form("password")
    If sUser = "" Or sPass = "" Then
        Response.Write "{""error"":""Credenciais em falta""}"
        Exit Sub
    End If
    Dim conn, sCS
    sCS = "Provider=SQLOLEDB;Server=" & DB_SERVER & _
          ";Database=" & DB_DATABASE & _
          ";Uid=" & sUser & ";Pwd=" & sPass & ";"
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.CommandTimeout = 30
    On Error Resume Next
    conn.Open sCS
    If Err.Number <> 0 Then
        On Error GoTo 0
        conn.Close : Set conn = Nothing
        Response.Write "{""error"":""Credenciais inválidas""}"
        Exit Sub
    End If
    On Error GoTo 0
    If PHC_PERFIL_NO > 0 Then
        If Not CheckPhcPerfil(conn, sUser, PHC_PERFIL_NO) Then
            conn.Close : Set conn = Nothing
            Response.Write "{""error"":""Sem permissão para aceder a esta aplicação""}"
            Exit Sub
        End If
    End If
    conn.Close : Set conn = Nothing
    Session("sql_user") = sUser
    Session("sql_pass") = sPass
    Response.Write "{""ok"":true,""username"":""" & JsonEscape(sUser) & """}"
End Sub

Sub DoLogout()
    Session.Abandon
    Response.ContentType = "application/json"
    Response.Write "{""ok"":true}"
End Sub

Sub DoBranding()
    ' Usa GetConnection() (conta website) — sem dados sensíveis
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    Dim sLogoUrl : sLogoUrl = ""
    Dim aExt : aExt = Array("png","jpg","jpeg","svg","gif")
    Dim i
    For i = 0 To UBound(aExt)
        Dim sPath : sPath = Server.MapPath("logo/logo." & aExt(i))
        If CreateObject("Scripting.FileSystemObject").FileExists(sPath) Then
            sLogoUrl = "logo/logo." & aExt(i)
            Exit For
        End If
    Next
    Response.Write "{""logoUrl"":""" & sLogoUrl & """}"
End Sub

Function CheckPhcPerfil(conn, sUser, nPerfil)
    CheckPhcPerfil = False
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "SELECT COUNT(*) FROM pf WITH(NOLOCK)" & _
                      " INNER JOIN pfu WITH(NOLOCK) ON pfu.pfstamp = pf.pfstamp" & _
                      " INNER JOIN us WITH(NOLOCK) ON us.usstamp = pfu.usstamp" & _
                      " WHERE pf.pfno = ? AND UPPER(RTRIM(us.usercode)) = UPPER(RTRIM(?))"
    cmd.Parameters.Append cmd.CreateParameter("pfno",  3, 1, , nPerfil)
    cmd.Parameters.Append cmd.CreateParameter("user",  200, 1, 50, sUser)
    On Error Resume Next
    Set rs = cmd.Execute
    If Err.Number = 0 And Not rs.EOF Then
        CheckPhcPerfil = (rs(0) > 0)
    End If
    On Error GoTo 0
    If Not rs Is Nothing Then rs.Close : Set rs = Nothing
    Set cmd = Nothing
End Function

'================================================================
' HELPER HTTP — chamadas server-side à API ShipsGo
'================================================================
Function ShipsGoHttp(ByVal sMethod, ByVal sUrl, ByVal sBody)
    Dim http
    Set http = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")
    http.setTimeouts 15000, 15000, 30000, 60000
    http.Open sMethod, sUrl, False
    http.setRequestHeader "Accept", "application/json"
    If UCase(sMethod) = "POST" Then
        http.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
        http.Send sBody
    Else
        http.Send
    End If
    Dim oRes
    Set oRes = Server.CreateObject("Scripting.Dictionary")
    oRes.Add "status", http.Status
    oRes.Add "body", http.responseText
    Set http = Nothing
    Set ShipsGoHttp = oRes
End Function

' Chamadas à API v2 (aéreo) — JSON + API key no header
Function ShipsGoAirHttp(ByVal sMethod, ByVal sUrl, ByVal sJsonBody)
    Dim http
    Set http = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")
    http.setTimeouts 15000, 15000, 30000, 60000
    http.Open sMethod, sUrl, False
    http.setRequestHeader "Accept", "application/json"
    http.setRequestHeader "X-Shipsgo-User-Token", SHIPSGO_AIR_TOKEN
    If UCase(sMethod) = "POST" Then
        http.setRequestHeader "Content-Type", "application/json"
        http.Send sJsonBody
    Else
        http.Send
    End If
    Dim oRes
    Set oRes = Server.CreateObject("Scripting.Dictionary")
    oRes.Add "status", http.Status
    oRes.Add "body", http.responseText
    Set http = Nothing
    Set ShipsGoAirHttp = oRes
End Function

' Extrai o primeiro "id": numérico de uma resposta JSON (sem parser completo)
Function ExtractJsonId(ByVal sBody)
    ExtractJsonId = ""
    Dim p, c, sNum
    p = InStr(1, sBody, """id"":", vbTextCompare)
    If p = 0 Then Exit Function
    p = p + Len("""id"":")
    sNum = ""
    Do While p <= Len(sBody)
        c = Mid(sBody, p, 1)
        If c >= "0" And c <= "9" Then
            sNum = sNum & c
        ElseIf c = " " Or c = """" Then
            If sNum <> "" Then Exit Do
        Else
            Exit Do
        End If
        p = p + 1
    Loop
    ExtractJsonId = sNum
End Function

' Extrai "message" de uma resposta JSON de erro da ShipsGo (sem parser completo)
Function ShipsGoErrMsg(ByVal sBody)
    Dim p1, p2
    p1 = InStr(1, sBody, """message"":""", vbTextCompare)
    If p1 > 0 Then
        p1 = p1 + Len("""message"":""")
        p2 = InStr(p1, sBody, """")
        If p2 > p1 Then
            ShipsGoErrMsg = Mid(sBody, p1, p2 - p1)
            Exit Function
        End If
    End If
    ShipsGoErrMsg = Left(sBody, 300)
End Function

'================================================================
' LISTA — grelha principal (sem last_json, para ser leve)
'================================================================
Sub DoListaSafe()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If Not IsLoggedIn() Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Nao autenticado""}"
        Exit Sub
    End If
    On Error Resume Next
    DoLista
    If Err.Number <> 0 Then
        Dim sErr : sErr = "Err=" & Err.Number & " | " & Err.Description
        On Error GoTo 0
        Response.Clear
        Response.Write "{""error"":""" & JsonEscape(sErr) & """}"
    End If
End Sub

Sub DoLista()
    Dim conn : Set conn = GetUserConnection()
    Dim sFiltro : sFiltro = Trim(Request.QueryString("filtro"))
    Dim sEstado : sEstado = Trim(Request.QueryString("estado"))

    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "usp_TrackCargo_Lista"
    cmd.CommandType = 4
    cmd.Parameters.Append cmd.CreateParameter("@filtro", 200, 1, 100, sFiltro)
    cmd.Parameters.Append cmd.CreateParameter("@estado", 200, 1, 40, sEstado)
    Set rs = cmd.Execute

    Dim sJson : sJson = "["
    Dim bFirst : bFirst = True
    Do While Not rs.EOF
        If Not bFirst Then sJson = sJson & ","
        sJson = sJson & "{" & _
            """id"":" & NzNum(rs("id")) & "," & _
            """mode"":""" & JsonEscape(Nz(rs("transport_mode"))) & """," & _
            """container"":""" & JsonEscape(Nz(rs("container_no"))) & """," & _
            """awb"":""" & JsonEscape(Nz(rs("awb_no"))) & """," & _
            """bl"":""" & JsonEscape(Nz(rs("bl_no"))) & """," & _
            """processo"":""" & JsonEscape(Nz(rs("ref_processo"))) & """," & _
            """line"":""" & JsonEscape(Nz(rs("shipping_line"))) & """," & _
            """reqid"":""" & JsonEscape(Nz(rs("shipsgo_reqid"))) & """," & _
            """status"":""" & JsonEscape(Nz(rs("status"))) & """," & _
            """pol"":""" & JsonEscape(Nz(rs("pol"))) & """," & _
            """pod"":""" & JsonEscape(Nz(rs("pod"))) & """," & _
            """vessel"":""" & JsonEscape(Nz(rs("vessel"))) & """," & _
            """voyage"":""" & JsonEscape(Nz(rs("voyage"))) & """," & _
            """etd"":""" & IsoDate(rs("etd")) & """," & _
            """eta"":""" & IsoDate(rs("eta")) & """," & _
            """ata"":""" & IsoDate(rs("ata")) & """," & _
            """lastSync"":""" & JsonEscape(Nz(rs("last_sync"))) & """," & _
            """createdBy"":""" & JsonEscape(Nz(rs("created_by"))) & """}"
        bFirst = False
        rs.MoveNext
    Loop
    sJson = sJson & "]"
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing
    Response.Write sJson
End Sub

'================================================================
' DETALHE — registo + último snapshot JSON da ShipsGo
'================================================================
Sub DoDetalheSafe()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If Not IsLoggedIn() Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Nao autenticado""}"
        Exit Sub
    End If
    On Error Resume Next
    DoDetalhe
    If Err.Number <> 0 Then
        Dim sErr : sErr = "Err=" & Err.Number & " | " & Err.Description
        On Error GoTo 0
        Response.Clear
        Response.Write "{""error"":""" & JsonEscape(sErr) & """}"
    End If
End Sub

Sub DoDetalhe()
    Dim nId : nId = CLng(Request.QueryString("id"))
    Dim conn : Set conn = GetUserConnection()
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "usp_TrackCargo_Detalhe"
    cmd.CommandType = 4
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , nId)
    Set rs = cmd.Execute

    If rs.EOF Then
        rs.Close : conn.Close
        Response.Write "{""error"":""Registo não encontrado""}"
        Exit Sub
    End If

    Dim sRaw : sRaw = Nz(rs("last_json"))
    If Trim(sRaw) = "" Then sRaw = "null"

    Dim sJson
    sJson = "{" & _
        """id"":" & NzNum(rs("id")) & "," & _
        """mode"":""" & JsonEscape(Nz(rs("transport_mode"))) & """," & _
        """container"":""" & JsonEscape(Nz(rs("container_no"))) & """," & _
        """awb"":""" & JsonEscape(Nz(rs("awb_no"))) & """," & _
        """bl"":""" & JsonEscape(Nz(rs("bl_no"))) & """," & _
        """processo"":""" & JsonEscape(Nz(rs("ref_processo"))) & """," & _
        """line"":""" & JsonEscape(Nz(rs("shipping_line"))) & """," & _
        """reqid"":""" & JsonEscape(Nz(rs("shipsgo_reqid"))) & """," & _
        """status"":""" & JsonEscape(Nz(rs("status"))) & """," & _
        """pol"":""" & JsonEscape(Nz(rs("pol"))) & """," & _
        """pod"":""" & JsonEscape(Nz(rs("pod"))) & """," & _
        """vessel"":""" & JsonEscape(Nz(rs("vessel"))) & """," & _
        """vesselImo"":""" & JsonEscape(Nz(rs("vessel_imo"))) & """," & _
        """voyage"":""" & JsonEscape(Nz(rs("voyage"))) & """," & _
        """etd"":""" & IsoDate(rs("etd")) & """," & _
        """eta"":""" & IsoDate(rs("eta")) & """," & _
        """ata"":""" & IsoDate(rs("ata")) & """," & _
        """lastSync"":""" & JsonEscape(Nz(rs("last_sync"))) & """," & _
        """raw"":" & sRaw & "}"
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing
    Response.Write sJson
End Sub

'================================================================
' ADD — cria tracking na ShipsGo (gasta 1 crédito) e grava registo
'================================================================
Sub DoAddSafe()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If Not IsLoggedIn() Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Nao autenticado""}"
        Exit Sub
    End If
    On Error Resume Next
    DoAdd
    If Err.Number <> 0 Then
        Dim sErr : sErr = "Err=" & Err.Number & " | " & Err.Description
        On Error GoTo 0
        Response.Clear
        Response.Write "{""error"":""" & JsonEscape(sErr) & """}"
    End If
End Sub

Sub DoAdd()
    Dim sMode, sContainer, sBl, sAwb, sLine, sProcesso
    sMode      = UCase(Trim(Request.Form("mode")))
    If sMode <> "AIR" Then sMode = "SEA"
    sContainer = UCase(Trim(Request.Form("container")))
    sBl        = Trim(Request.Form("bl"))
    sAwb       = Trim(Request.Form("awb"))
    sLine      = Trim(Request.Form("line"))
    sProcesso  = Trim(Request.Form("processo"))
    If sLine = "" Then sLine = "OTHERS"

    If sMode = "AIR" And sAwb = "" Then
        Response.Write "{""error"":""Indicar o nº do AWB""}"
        Exit Sub
    End If
    If sMode = "SEA" And sContainer = "" And sBl = "" Then
        Response.Write "{""error"":""Indicar nº de contentor ou BL""}"
        Exit Sub
    End If

    ' --- 1) Criar o tracking na ShipsGo
    Dim sUrl, sBody, oRes, sReqId
    If sMode = "AIR" Then
        ' API v2 aéreo: POST JSON com o AWB (a companhia é detetada pelo prefixo)
        sBody = "{""awb_number"":""" & JsonEscape(sAwb) & """,""follow"":true}"
        Set oRes = ShipsGoAirHttp("POST", SHIPSGO_AIR_BASE, sBody)
        sReqId = ExtractJsonId(oRes("body"))
        If Not (oRes("status") >= 200 And oRes("status") < 300 And sReqId <> "") Then
            Response.Write "{""error"":""ShipsGo Air: " & JsonEscape(ShipsGoErrMsg(oRes("body"))) & " (HTTP " & oRes("status") & ")""}"
            Exit Sub
        End If
        sLine = ""   ' companhia aérea vem no primeiro sync
    Else
        If sContainer <> "" Then
            sUrl  = SHIPSGO_BASE & "PostContainerInfo"
            sBody = "authCode=" & SHIPSGO_AUTHCODE & _
                    "&containerNumber=" & Server.URLEncode(sContainer) & _
                    "&shippingLine=" & Server.URLEncode(sLine)
        Else
            sUrl  = SHIPSGO_BASE & "PostContainerInfoWithBl"
            sBody = "authCode=" & SHIPSGO_AUTHCODE & _
                    "&blContainersRef=" & Server.URLEncode(sBl) & _
                    "&shippingLine=" & Server.URLEncode(sLine)
        End If

        Set oRes = ShipsGoHttp("POST", sUrl, sBody)

        sReqId = Trim(Replace(Replace(CStr(oRes("body")), """", ""), vbCrLf, ""))
        If Not (oRes("status") >= 200 And oRes("status") < 300 And IsNumeric(sReqId)) Then
            Response.Write "{""error"":""ShipsGo: " & JsonEscape(ShipsGoErrMsg(oRes("body"))) & " (HTTP " & oRes("status") & ")""}"
            Exit Sub
        End If
    End If

    ' --- 2) Gravar o registo local
    Dim conn : Set conn = GetUserConnection()
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "usp_TrackCargo_Add"
    cmd.CommandType = 4
    cmd.Parameters.Append cmd.CreateParameter("@transport_mode", 200, 1, 4,  sMode)
    cmd.Parameters.Append cmd.CreateParameter("@container_no",  200, 1, 20,  sContainer)
    cmd.Parameters.Append cmd.CreateParameter("@bl_no",         200, 1, 40,  sBl)
    cmd.Parameters.Append cmd.CreateParameter("@awb_no",        200, 1, 20,  sAwb)
    cmd.Parameters.Append cmd.CreateParameter("@shipping_line", 200, 1, 20,  sLine)
    cmd.Parameters.Append cmd.CreateParameter("@shipsgo_reqid", 200, 1, 20,  sReqId)
    cmd.Parameters.Append cmd.CreateParameter("@ref_processo",  200, 1, 40,  sProcesso)
    cmd.Parameters.Append cmd.CreateParameter("@created_by",    200, 1, 50,  Session("sql_user"))
    Set rs = cmd.Execute
    Dim nNewId : nNewId = 0
    If Not rs.EOF Then nNewId = rs(0)
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing

    Response.Write "{""ok"":true,""id"":" & nNewId & ",""requestId"":""" & JsonEscape(sReqId) & """}"
End Sub

'================================================================
' SYNC — vai buscar o estado atual à ShipsGo (não gasta créditos)
'         Devolve o JSON bruto; o frontend extrai os campos e
'         chama depois action=snapshot para persistir.
'================================================================
Sub DoSyncSafe()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If Not IsLoggedIn() Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Nao autenticado""}"
        Exit Sub
    End If
    On Error Resume Next
    DoSync
    If Err.Number <> 0 Then
        Dim sErr : sErr = "Err=" & Err.Number & " | " & Err.Description
        On Error GoTo 0
        Response.Clear
        Response.Write "{""error"":""" & JsonEscape(sErr) & """}"
    End If
End Sub

Sub DoSync()
    Dim nId : nId = CLng(Request.QueryString("id"))

    ' Obter o requestId ShipsGo do registo
    Dim conn : Set conn = GetUserConnection()
    Dim cmd, rs
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "usp_TrackCargo_Detalhe"
    cmd.CommandType = 4
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , nId)
    Set rs = cmd.Execute
    If rs.EOF Then
        rs.Close : conn.Close
        Response.Write "{""error"":""Registo não encontrado""}"
        Exit Sub
    End If
    Dim sReqId : sReqId = Nz(rs("shipsgo_reqid"))
    Dim sMode : sMode = UCase(Nz(rs("transport_mode")))
    If sMode <> "AIR" Then sMode = "SEA"
    rs.Close : Set rs = Nothing
    conn.Close : Set conn = Nothing

    Dim sUrl, oRes
    If sMode = "AIR" Then
        sUrl = SHIPSGO_AIR_BASE & "/" & Server.URLEncode(sReqId)
        Set oRes = ShipsGoAirHttp("GET", sUrl, "")
    Else
        sUrl = SHIPSGO_BASE & "GetContainerInfo/?authCode=" & SHIPSGO_AUTHCODE & _
               "&requestId=" & Server.URLEncode(sReqId) & "&mapPoint=true"
        Set oRes = ShipsGoHttp("GET", sUrl, "")
    End If

    Dim sBody : sBody = Trim(CStr(oRes("body")))
    If oRes("status") >= 200 And oRes("status") < 300 And (Left(sBody, 1) = "[" Or Left(sBody, 1) = "{") Then
        Response.Write "{""id"":" & nId & ",""mode"":""" & sMode & """,""raw"":" & sBody & "}"
    Else
        Response.Write "{""error"":""ShipsGo: " & JsonEscape(ShipsGoErrMsg(sBody)) & " (HTTP " & oRes("status") & ")""}"
    End If
End Sub

'================================================================
' SNAPSHOT — persiste os campos extraídos pelo frontend + JSON bruto
'================================================================
Sub DoSnapshotSafe()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If Not IsLoggedIn() Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Nao autenticado""}"
        Exit Sub
    End If
    On Error Resume Next
    DoSnapshot
    If Err.Number <> 0 Then
        Dim sErr : sErr = "Err=" & Err.Number & " | " & Err.Description
        On Error GoTo 0
        Response.Clear
        Response.Write "{""error"":""" & JsonEscape(sErr) & """}"
    End If
End Sub

Sub DoSnapshot()
    Dim nId : nId = CLng(Request.Form("id"))
    Dim sRaw : sRaw = Request.Form("raw")
    If Len(sRaw) = 0 Then sRaw = ""

    Dim conn : Set conn = GetUserConnection()
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "usp_TrackCargo_Snapshot"
    cmd.CommandType = 4
    cmd.Parameters.Append cmd.CreateParameter("@id",         3,   1, ,   nId)
    cmd.Parameters.Append cmd.CreateParameter("@status",     200, 1, 40,  Left(Trim(Request.Form("status")), 40))
    cmd.Parameters.Append cmd.CreateParameter("@pol",        200, 1, 80,  Left(Trim(Request.Form("pol")), 80))
    cmd.Parameters.Append cmd.CreateParameter("@pod",        200, 1, 80,  Left(Trim(Request.Form("pod")), 80))
    cmd.Parameters.Append cmd.CreateParameter("@vessel",     200, 1, 80,  Left(Trim(Request.Form("vessel")), 80))
    cmd.Parameters.Append cmd.CreateParameter("@vessel_imo", 200, 1, 20,  Left(Trim(Request.Form("vessel_imo")), 20))
    cmd.Parameters.Append cmd.CreateParameter("@voyage",     200, 1, 40,  Left(Trim(Request.Form("voyage")), 40))
    cmd.Parameters.Append cmd.CreateParameter("@container_no", 200, 1, 20, Left(UCase(Trim(Request.Form("container"))), 20))
    cmd.Parameters.Append cmd.CreateParameter("@etd",        200, 1, 30,  Left(Trim(Request.Form("etd")), 30))
    cmd.Parameters.Append cmd.CreateParameter("@eta",        200, 1, 30,  Left(Trim(Request.Form("eta")), 30))
    cmd.Parameters.Append cmd.CreateParameter("@ata",        200, 1, 30,  Left(Trim(Request.Form("ata")), 30))
    Dim nLenRaw : nLenRaw = Len(sRaw)
    If nLenRaw < 1 Then nLenRaw = 1
    cmd.Parameters.Append cmd.CreateParameter("@last_json",  203, 1, nLenRaw, sRaw)  ' 203 = adLongVarWChar
    cmd.Execute , , 128  ' adExecuteNoRecords
    Set cmd = Nothing
    conn.Close : Set conn = Nothing

    Response.Write "{""ok"":true}"
End Sub

'================================================================
' REMOVE — desativa o tracking localmente (active = 0)
'================================================================
Sub DoRemoveSafe()
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    If Not IsLoggedIn() Then
        Response.Status = "401 Unauthorized"
        Response.Write "{""error"":""Nao autenticado""}"
        Exit Sub
    End If
    On Error Resume Next
    DoRemove
    If Err.Number <> 0 Then
        Dim sErr : sErr = "Err=" & Err.Number & " | " & Err.Description
        On Error GoTo 0
        Response.Clear
        Response.Write "{""error"":""" & JsonEscape(sErr) & """}"
    End If
End Sub

Sub DoRemove()
    Dim nId : nId = CLng(Request.Form("id"))
    Dim conn : Set conn = GetUserConnection()
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command")
    Set cmd.ActiveConnection = conn
    cmd.CommandText = "usp_TrackCargo_Remove"
    cmd.CommandType = 4
    cmd.Parameters.Append cmd.CreateParameter("@id", 3, 1, , nId)
    cmd.Execute , , 128
    Set cmd = Nothing
    conn.Close : Set conn = Nothing
    Response.Write "{""ok"":true}"
End Sub
%>
