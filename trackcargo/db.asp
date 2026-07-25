<%
Const DB_CONNECTION_STRING = "Provider=SQLOLEDB;Server=PCPHC;Database=PHC_Portocargo;Uid=website;Pwd=infopcargo;"

Function GetConnection()
    Dim conn
    Set conn = Server.CreateObject("ADODB.Connection")
    conn.CommandTimeout = 180
    conn.Open DB_CONNECTION_STRING
    Set GetConnection = conn
End Function

Function GetConnectionString()
    GetConnectionString = DB_CONNECTION_STRING
End Function

Function JsonEscape(ByVal s)
    If IsNull(s) Then JsonEscape = "" : Exit Function
    s = CStr(s)
    s = Replace(s, "\", "\\")
    s = Replace(s, Chr(34), "\" & Chr(34))
    s = Replace(s, "/", "\/")
    s = Replace(s, vbCrLf, "\n")
    s = Replace(s, vbCr, "\n")
    s = Replace(s, vbLf, "\n")
    s = Replace(s, vbTab, "\t")
    JsonEscape = s
End Function

Function IsoDate(ByVal v)
    If IsNull(v) Or v = "" Then
        IsoDate = ""
    Else
        IsoDate = Year(v) & "-" & Right("0" & Month(v), 2) & "-" & Right("0" & Day(v), 2)
    End If
End Function

Function Nz(ByVal v)
    If IsNull(v) Then Nz = "" Else Nz = CStr(v)
End Function

Function NzNum(ByVal v)
    If IsNull(v) Or Trim(CStr(v)) = "" Then NzNum = "0" Else NzNum = CStr(v)
End Function

Sub WriteJsonError(ByVal msg)
    Response.Status = "500 Internal Server Error"
    Response.ContentType = "application/json"
    Response.Charset = "utf-8"
    Response.Write "{""error"":""" & JsonEscape(msg) & """}"
End Sub
%>
