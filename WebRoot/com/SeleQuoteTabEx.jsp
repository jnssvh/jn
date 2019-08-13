<%@ page language="java" import="java.util.*,com.jaguar.*,java.sql.*,project.*" pageEncoding="GBK"%>
 <%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
 <%@ include file="init.jsp" %>
<%
	WebEnum webenum = new WebEnum(jdb);
//	jdbapp = new JDBApp(jdb, user, webenum);
//	if (!user.GetDataRight(12,1,"",0,""))
//	{
//		out.println("您没有权限执行此操作，请与管理员联系");
//		out.close();
//	}
	out.println(WebFace.GetHTMLHead(TagMethod.getLang(request.getLocale(),"SeleQuoteTabEx.Select_yiyong")));
	String TableName = request.getParameter("TableName");
	String QuoteField = request.getParameter("QuoteField");
	String AliasField = request.getParameter("AliasField");
	String Value = request.getParameter("Value");
	String Condition = request.getParameter("Condition");
	String AliasValue = request.getParameter("AliasValue");
	String FrameURL = VB.Mid(Condition, 2) + ".jsp";
	if (Condition.indexOf("?") > 0)
		FrameURL = VB.Mid(Condition, 2);
	String SeleID = WebChar.requestStr(request, "SeleID");
	if (!(SeleID.equals("") || SeleID.equals("0")))
	{
		String keyfield = jdb.getPrimaryKeys(0, TableName);
		int nType =  jdb.GetTableFieldType(TableName,0, keyfield);
		if ((nType != 3) && (nType !=6) && (nType !=7))
				SeleID = "'" + SeleID.replaceAll(",", "','") + "'";
		if ((nType == 11) && (SeleID.length() < 3))
			SeleID = "null";
		
		String sql = "select " + QuoteField + ", " + AliasField + " from " + TableName + " where " + keyfield + " in (" + SeleID + ")";
		ResultSet rs = jdb.rsSQL(0, sql);
		String returnValue = "";
		while (rs.next())
		{
			if (!returnValue.equals(""))
				returnValue += "|;|";
			returnValue += rs.getString(1) + "|,|" + rs.getString(2);
		}
		jdb.rsClose(0, rs);
		out.println("<SCRIPT>if(external.Browser!=null)external.EndDialog('"+returnValue+"');");
		out.println("parent.returnValue='" + returnValue + "';parent.close();</script></body></html>");
		jdb.closeDBCon();
		//out.close();
		//out.clear();
		//out = pageContext.pushBody();
		return;
	}
	
%>
<DIV id=QuoteDiv style=height:520px;overflow:auto;>
<IFRAME id=SeekQuote BORDER=0 width=100% height=100%></IFRAME>
</DIV>
<CENTER><input type=Button value="<j:Lang key="psub.Queding"/>" onclick=ConfirmDlg()> &nbsp;
<input type=Button value="<j:Lang key="SeleQuoteTable.Qingchu"/>" onclick="clearValue()"> &nbsp;
<input type=button value="<j:Lang key="psub.cancel"/>" onclick=(external||window).close()> &nbsp;</CENTER>
<script language=javascript src=psub.jsp></script>
<SCRIPT LANGUAGE="JavaScript">
function clearValue()
{
	try
	{
		var formName = parentWindow.event.srcElement.previousSibling.name;
		parentWindow.document.getElementsByName(formName)[0].value = "";
		formName = formName.replace(/Alias_/, "");
		parentWindow.document.getElementsByName(formName)[0].value = "";
	}
	catch(e)
	{
		window.returnValue = "";
	}
	(external||window).close();
}
function ConfirmDlg()
{
	var w = document.all.SeekQuote.contentWindow;
	var src = "SeleQuoteTabEx.jsp?TableName=<%=TableName%>&QuoteField=<%=QuoteField%>" + 
		"&AliasField=<%=AliasField%>&Value=<%=Value%>&Condition=<%=Condition%>&AliasValue=<%=AliasValue%>";
	
	var nodes = w.GetSelectNode();
	if (nodes != "")
	{
		document.all.SeekQuote.src = src + "&SeleID=" + nodes;
		return;
	}
	if (typeof(w.oFocus) != "object")
		return alert("<j:Lang key="SeleQuoteTabEx.No_select"/>");
	document.all.SeekQuote.src = src + "&SeleID=" + w.oFocus.node;
}


function ResizeDlg()
{
	if (document.body.clientHeight > 40)
		document.all.QuoteDiv.style.height = document.body.clientHeight - 40;
}
var parentWindow;
function window.onload()
{
var fileName = "<%=FrameURL%>";
	parentWindow = window.dialogArguments||external.Argument;
	ResizeDlg();
	window.onresize=ResizeDlg;
	var path = parentWindow.location.href.replace(/(.*\/).*/, "$1");
	document.all.SeekQuote.src = path + fileName;
	//window.open(location.toString())
//	document.all.SeekQuote.src = "../fvs/" + fileName;
}

</SCRIPT>
<%jdb.closeDBCon(); %>

