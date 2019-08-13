<%@ page language="java" import="java.sql.* ,com.jaguar.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ include file="init_comm.jsp" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE> 模板 </TITLE>
<META NAME="Generator" CONTENT="EditPlus">
<META NAME="Author" CONTENT="">
<META NAME="Keywords" CONTENT="">
<META NAME="Description" CONTENT="">
<link rel='stylesheet' type='text/css' href='forum.css'>
<script language=javascript src=com/psub.jsp></script>
<script type="text/javascript" src="js/jaguar.js"></script>
<SCRIPT LANGUAGE="JavaScript">
function smt(obj)
{
	switch (obj.value)
	{
	case "确定":
		var chks = document.getElementsByName("columns");
		var slt = [];
		for (var i = 0; i < chks.length; i++)
		{
			if (chks[i].checked)
				slt.push(chks[i].value);
		}
		if (slt.length == 0)
		{
			alert("导出数据时，至少选择一个字段。");
			return;
		}
		document.getElementsByName("columns")[0].value = escape(escape(slt.join(",")));
		document.forms[0].submit();
		slt = null;
	case "取消":
		parent.document.all.InDlgDiv.removeNode(true);
		break;
	default:
	
		break;
	}
}


window.onload = function(){
	var pnt = parent;
	if (parent == self)
	{
		pnt = window.opener;
	}
	var rename = "<%=WebChar.requestStr(request, "rename")%>";
	if (rename != "")
	{
		document.getElementsByName("rename")[0].value = rename;
	}
	if (typeof pnt.initExportForm == "function")
	{
		pnt.initExportForm(window);
	}
	var table = null;
	try {
		table = pnt.document.getElementsByName("SubSeekFrame")[0].contentWindow.document.getElementById("SeekTable");
	} catch (e) {
		table = pnt.document.getElementById("SeekTable");
	}
	var slt = [];
	var key = "", val = "";
	var lineCount = 2;
	slt.push("<table border=\"0\" width=\"100%\" cellspacing=\"0\" cellpadding=\"5\" id=\"listtable\">");
	var count = 0;
	for (var i = 0; i < table.rows[0].cells.length; i++)
	{
		key = table.rows[0].cells[i].node;
		if (key == undefined)
		{
			continue;
		}
		if (count % lineCount == 0)
		{
			slt.push("<tr>");
		}
		val = table.rows[0].cells[i].innerText.replace(/^[^\w[\u4e00-\u9fa5]]+|[^\w[\u4e00-\u9fa5]]+$/g, "");
		slt.push("<td><input type=\"checkbox\" name=\"columns\" value=\"" + key + " [" + val + "]\" checked>" + val + "</td>");
		if (count % lineCount == lineCount - 1)
		{
			slt.push("</tr>");
		}
		else if (i == table.rows[0].cells.length - 1)
		{
			for (var j = count + 1; j < table.rows[0].cells.length; j++)
			{
				slt.push("<td>&nbsp;</td></tr>");
			}
		}
		count ++;
	}
	slt.push("</table>");
	document.getElementById("divcolumn").innerHTML = slt.join("");
	slt = null;
};
</script>
</HEAD>

<BODY topmargin="0">
<FORM method="post" action="AjaxFunction" target="frmhidden">
<input type="hidden" name="type" value="ExportData">
<input type="hidden" name="sub_type" value="<%=WebChar.requestStr(request, "sub_type") %>">
<input type="hidden" name="columns" value="">
<input type="hidden" name="datas" value="">
<input type="hidden" name="rename" value="">
<input type="hidden" name="method" value="form">
<table border="0" width="100%" cellspacing="0" cellpadding="0" height="100%" id="table1">
	<tr>
		<td><div>请选择导出的列：</div>
		<div id="divcolumn">
		
		</div>
		<div><input type="button" name="b1" value="确定" onclick="smt(this)"><input type="button" name="b2" value="取消" onclick="smt(this)"></div>
		</td>
	</tr>
</table>
</FORM>
<iframe id="frmhidden" name="frmhidden" style="display:none;" frameborder="0" src=""></iframe>
</body>
</html>
<% jdb.closeDBCon();%>

