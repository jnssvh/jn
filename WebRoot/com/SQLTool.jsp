<%@ page language="java" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*, java.util.*, java.net.URLEncoder,project.*" %>
<%@ include file="init.jsp" %>
<%
	user = new SysUser();
	user.initWebUser(jdb, request.getCookies());
	if (!user.isAdmin())
	{
		out.print("没有权限");
		return;
	}
	String SQLText = WebChar.requestStr(request, "SQLText");

	if (!SQLText.equals(""))
	{
		long t = System.currentTimeMillis();
		ResultSet rs = jdb.rsSQL(0, SQLText);
		t = System.currentTimeMillis() - t;
		StringBuffer result = new StringBuffer();
		result.append("<table bgcolor=#999999 cellpadding=3 cellspacing=1  border=0><tr>");
		ResultSetMetaData rsmt = rs.getMetaData();
		int columnCount = rsmt.getColumnCount();
		for (int x = 0; x < columnCount; x++)
			result.append("<td nowrap bgcolor=#eeeeee>" + rsmt.getColumnName(x + 1) + "</td>");
		result.append("</tr>");
		int cnt = 0;
		while (rs.next())
		{
			result.append("<tr bgcolor=white onclick=SelectObj(this)>");
			for (int x = 0; x < columnCount; x++)
				result.append("<td nowrap>" + rs.getString(x + 1) + "</td>");
			result.append("</tr>");
			cnt ++;
		}
		result.append("</table>");
		result.append("<div><p>返回记录数:" + cnt + "条， SQL执行时间:" + t + "毫秒&nbsp;<span style=color:gray; onclick=DelResult(this)>删除结果</span></p></div>");
		rs.close();
		
		out.print(result);
		return;
	}
	out.print(WebFace.GetHTMLHead("SQL工具", "<link rel='stylesheet' type='text/css' href='com/forum.css'>"));
%>
<div id=panel></div><textarea style=width:100%;height=50px; id=SQLText wrap=VIRTUAL><%=SQLText%></textarea>
<input type=button value=上一条 onclick=SkipSQL(1) id=PreviousButton>
<input type=button value=下一条 onclick=SkipSQL(-1) id=NextButton>
<input type=button value=删除 onclick=ClearSQL() id=NextButton>
<input type=button value=粘贴 onclick=PasteSQL() id=NextButton>
<input type=button value=清除 onclick=ClearResult() id=NextButton>
<input type=button value=刷新 onclick=location.reload(true) id=NextButton>
<input type=button value=历史 onclick=LoadHis()>
<input type=button value=载入 style=display:none>
<input type=button value=保存 style=display:none>
<input type=button value=执行 onclick=RunSQL() id=RunButton>
</div>
<script language=javascript src=jquery.js></script>
<script language=javascript src=jcom.js></script>
<script language=javascript>
function RunSQL()
{
	SQLHis.push(document.all.SQLText.innerText);
	$.jcom.Ajax(location.pathname, true,"SQLText=" + escape(document.all.SQLText.innerText), SQLResult);
	document.all.RunButton.disabled = true;
}

function DelResult(obj)
{
	obj.parentNode.parentNode.removeNode(true);
}

function CopySQL(obj)
{
	document.all.SQLText.innerText = obj.parentNode.all.SQLSpan.innerText;
	document.all.SQLText.focus();
}

function LoadSQL(obj)
{
	var tag = "<select onchange=SelCommSQL(this)>";
	for (var x = 0; x < preSQLs.length; x++)
		tag += "<option value=" + x + ">" + preSQLs[x].name + "</option>";
	obj.outerHTML = tag + "</select>";
}

function SelCommSQL(obj)
{
	document.all.SQLText.innerText = preSQLs[obj.value].sql;
}

var SQLHis = [];
var nOffset = 0;
function SkipSQL(nStep)
{
	if (SQLHis.length == 0)
		return;
	nOffset += nStep;
	if (nOffset >= SQLHis.length)
		nOffset = SQLHis.length - 1;
	if (nOffset < 0)
		nOffset = 0;
	document.all.SQLText.innerText = SQLHis[SQLHis.length - 1 - nOffset];
}

function ClearSQL()
{
	document.all.SQLText.innerText = "";
}

function ClearResult()
{
	var objs = document.getElementsByName("SQLDiv");
	for (var x = objs.length - 1; x >= 0; x --)
		objs[x].removeNode(true);
}

function PasteSQL()
{
	document.all.SQLText.innerText = window.clipboardData.getData("Text");
}

function RerunSQL(obj)
{
	CopySQL(obj);
	RunSQL();
}

function SQLResult(data)
{
	$("#panel").before("<div id=SQLDiv><br><div>SQL:" +
		"<span id=SQLSpan style='font-size:16px;padding-left:20px;padding-right:20px'>" + $("#SQLText").text() +	
		"</span><input type=button value=复制 onclick=CopySQL(this)><input type=button value=删除 onclick=DelResult(this)><input type=button value=运行 onclick=RerunSQL(this)></div>" +
		data + "</div>");
	document.all.SQLText.innerText = "";
	document.all.RunButton.disabled = false;
	nOffset = -1;
}

function LoadHis()
{
}
</script>
</body></html>