<%@ page language="java" import="java.util.*,com.jaguar.*,java.sql.*" pageEncoding="GBK"%>
 <%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
 <%@ include file="init.jsp" %>
<%
//	jdbapp = new JDBApp(jdb, user, webenum);
//	if (!user.GetDataRight(12,1,"",0,""))
//	{
//		out.println("您没有权限执行此操作，请与管理员联系");
//		out.close();
//	}
	String TableName = WebChar.requestStr(request, "TableName");
	String QuoteField = WebChar.requestStr(request, "QuoteField");
	String AliasField = WebChar.requestStr(request, "AliasField");
	// 转到另外按部门选择人员模式 lxt 2017
	if(TableName.toLowerCase().equals("member")&&QuoteField.toUpperCase().equals("ID")&&
			AliasField.toUpperCase().equals("CNAME")){
		request.getRequestDispatcher("SeleQuoteTableMem.jsp").forward(request,response);
		jdb.closeDBCon();
		return;
	}
	String value = WebChar.requestStr(request, "Value");
	String AliasValue = "", sql = "", Condition1 = "";
	if (WebChar.RequestInt(request, "AjaxMode") == 1)
	{
		String result = "";
		int nDB = WebChar.RequestInt(request, "nDB");
		sql = "select " + QuoteField + "," + AliasField + " from " + TableName;

		String Condition = WebChar.requestStr(request,"Condition");
		if  (VB.Left(Condition, 1).equals("="))
			Condition = VB.Mid(Condition, 2);
		if  (VB.Left(Condition, 1).equals("$"))	
			Condition = "";
		if (Condition.equals("!Filter") ||  (Condition.equals("")))
		{
//			AliasValue = WebChar.requestStr(request,"AliasValue");
			Condition = "";
		}
		String SeekKey = WebChar.requestStr(request,"SeekKey");
		if (SeekKey != null && !SeekKey.equals("")) 
			AliasValue = SeekKey;

		if (AliasValue != null && !AliasValue.equals(""))
		{
			if (Condition != null && !Condition.equals(""))
				Condition1 = Condition + " and ";
			sql +=  " where " + Condition1 + AliasField + " like '%" + AliasValue + "%'";
		}
		else
		{
			if (Condition != null && !Condition.equals(""))
				Condition1 = " where " + Condition;
			sql += Condition1;
		}
		ResultSet rs = jdb.rsSQL(nDB, sql);
		while (rs.next())
		{
			if (result.equals(""))
				result = rs.getString(1) + ":" + rs.getString(2);
			else
				result += "," + rs.getString(1) + ":" + rs.getString(2);
		}
			out.print(result);
			return;
	}

	int Multi = WebChar.RequestInt(request, "Multi");
	String mousesel = "";
	if (Multi == 1)
		mousesel = " onmousedown=TableSelectBegin(this)";
	out.println(WebFace.GetHTMLHead(TagMethod.getLang(request.getLocale(),"SeleQuoteTabEx.Select_yiyong")));
	ResultSet rs = null;
%>
<script language=javascript src=psub.jsp></script>
<script language=javascript src=seek.jsp></script>
<SCRIPT LANGUAGE="JavaScript">

function CloseDlg()
{
	window.close();
}

function ConfirmQTDlg(str)
{
	if ((typeof(oFocus) == "object") || (typeof(str) != "undefined"))
	{
		if (typeof(str) == "undefined")
		{
			if (Multi == 1)
				returnValue = GetResultItems();
			else
				returnValue = GetQuoteValue(oFocus);
		}
		else
			returnValue = str;
		if (typeof(g_cbinputObj) == "object")
		{
			ConfirmQuoteTable(returnValue, g_cbinputObj);
			parent.document.body.fireEvent("onmousedown");
			return;
		}
		// Electron lxt 2017.11.8
		if(navigator.userAgent.indexOf("Chrome")>-1){
			window.localStorage["SeleQuoteTableReturnValue"]=returnValue;
		}
		window.close();
	}
	else
		alert("<j:Lang key="SeleQuoteTabEx.No_select"/>");
}

function GetQuoteValue(oTR)
{
	if (oTR.cells.length > 1)
		return oTR.cells[0].innerText + "|,|" + oTR.cells[1].innerText;
	return oTR.cells[0].innerText;
}

function ClearQTDlg()
{
	ConfirmQTDlg("|,|");
}

function MoreData(offset)
{
	var nPage = parseInt(document.all.nPageSpan.innerText) + offset;
	var nPageSize = parseInt(document.all.nPageSizeSpan.innerText);
	document.all.DataFrame.src = location.href + "&CallBack=1&nPage=" + nPage;
	document.all.NextButton.disabled = true;
	document.all.PreviousButton.disabled = true;
	document.all.SeekButton.disabled = true;
	document.all.nPageSpan.innerText = nPage;
}

function SeekData(obj)
{
	if (typeof(g_cbinputObj) == "object")
		g_cbinputObj.value = document.all.SeekInput.value;
	document.all.DataFrame.src = location.href + "&CallBack=1&SeekKey=" + document.all.SeekInput.value;
}

function PageReady()
{
	if (typeof document.all.nPageSpan == "object")
	{
		var nPage = parseInt(document.all.nPageSpan.innerText);
		var nPageSize = parseInt(document.all.nPageSizeSpan.innerText);
		if (nPage >= nPageSize)
			document.all.NextButton.disabled = true;
		else
			document.all.NextButton.disabled = false;
		if (nPage <= 1)
			document.all.PreviousButton.disabled = true;
		else
			document.all.PreviousButton.disabled = false;
	}
	document.all.SeekButton.disabled = false;
	document.all.ListDiv.innerHTML = document.all.DataFrame.contentWindow.document.all.QuoteTable.outerHTML;
	document.all.ListDiv.style.position = "";
	InitComboDoc();
}

var g_cbinputObj;
function InitComboValue(obj)
{
	g_cbinputObj = obj;
	document.all.CancelButton.style.display = "none";
	document.all.OKButton.style.display = "none";
	window.setTimeout(InitComboDoc, 1);
}

function InitComboDoc()
{
	if (typeof(g_cbinputObj) == "object")
	{
		for (var x = 0; x < document.all.QuoteTable.rows.length; x++)
		{
			document.all.QuoteTable.rows[x].onmouseover = function (){SelObject(this);};
			if (document.all.QuoteTable.rows[x].cells[1].innerText == g_cbinputObj.value)
			{
				SelObject(document.all.QuoteTable.rows[x]);
				document.all.QuoteTable.rows[x].scrollIntoView(false); 
			}
		}
	}

}
var ViewMode = 1;
var Multi = <%=Multi%>;
function SelectItem(obj)
{
	if (Multi == 1)
		SelectRow(obj);
	else
		SelObject(obj);
	if (typeof(g_cbinputObj) == "object")
		ConfirmQTDlg();
}

function InsertItems(items)
{
	if (Multi == 0)
		return ConfirmQTDlg();

	if (typeof items != "string")
		items = GetItem();
	if (items == "")
		return;
	var ss = items.split(",");
	for (var x = 0; x < ss.length; x++)
	{
		var ss1 = ss[x].split(":");
		if (IsItemInResult(ss1[0]) == false)
		{
			var oTR = document.all.ResultTable.insertRow(-1); // 这里要强制说明 是-1，w3c是其他默认值 lxt 2014.06.20
			oTR.onclick = function () {SelectRow(this);};
			var oTD = oTR.insertCell(-1); 
			oTD.innerText = ss1[0];
			var oTD = oTR.insertCell(-1); 
			oTD.innerText = ss1[1];
		}
	}
}

function GetItem()
{
var values = "";
	var objs = document.all.QuoteTable.rows;
		for (var x = 0; x < objs.length; x++)
		{
			if (objs[x].selflag == 1)
			{
				if (values != "")
					values += ",";
				values += objs[x].cells[0].innerText + ":" + objs[x].cells[1].innerText;
			}
		}
		return values;
}

function IsItemInResult(item)
{
	for (var x = 1; x < document.all.ResultTable.rows.length; x++)
	{
		if (document.all.ResultTable.rows[x].cells[0].innerText == item)
			return true;
	}
	return false;

}

function DelResult()
{
	for (var x = document.all.ResultTable.rows.length - 1; x >= 1 ; x--)
	{
		if (document.all.ResultTable.rows[x].selflag == 1)
			document.all.ResultTable.rows[x].parentNode.removeChild(document.all.ResultTable.rows[x]);
			//document.all.ResultTable.rows[x].removeNode(true);
	}
}

function GetResultItems()
{
var s1 = "", s2 = "";
	for (var x = 0; x < document.all.ResultTable.rows.length; x++)
	{
		if (s1 != "")
		{
			s1 += ",";
			s2 += ",";
		}
		s1 += document.all.ResultTable.rows[x].cells[0].innerText;
		s2 += document.all.ResultTable.rows[x].cells[1].innerText;
	}
	return s1 + "|,|" + s2;
}

function checkEnter(obj) {
	if (obj.value == "") {
		//return;
	}
	if (event.keyCode == 13) {
		document.getElementsByName("SeekButton")[0].click();
	}
}
</SCRIPT>
<body scroll=no onload="//document.getElementsByName('SeekInput')[0].focus();">
<div id=SelQuoteDiv style=width:100%;height:100%;overflow:hidden;padding-bottom:30px;>
<%
	if (Multi == 1)
	{
%>
<div style="float:right;width:200px;height:100%;">
<div style=width:100%;height:20px;overflow:hidden;>&nbsp;已选择列表:</div>
<div style="width:100%;height:100%;margin-top:-20px;padding-top:20px;overflow:hidden;">
<div id=ResultDiv ondblclick=DelResult() style="border:1px solid gray;width:100%;height:100%;overflow-y:auto;">
<table id=ResultTable onmousedown=TableSelectBegin(this) cellpadding=3 cellspacing=0 width=100% border=0>
<tr><td></td><td></td></tr>
<%
	String result = jdb.GetQuoteResult(TableName, 0, QuoteField, AliasField, value, 2);
	String [] ss2, ss1 = result.split(",");
	if (!result.equals(""))
	{
		for (int x = 0; x < ss1.length; x++)
		{
			if (!ss1[x].equals(""))
			{
				ss2 = ss1[x].split(":");
				if (ss2.length > 1)
					out.println("<tr onclick=SelectRow(this)><td>" + ss2[0] + "</td><td>" + ss2[1] + "</td></tr>");
			}
		}
	}
%>
</table></div>
</div></div>
<div style="float:right;width:80px;height:100%;text-align:center">
<div style=height:50%;margin-top:-80px;padding-top:80px;></div>
<button style=width:70px; onclick=InsertItems()>增加<span style=font-family:webdings>4</span></button><br><br><br>
<button style=width:70px; onclick=DelResult()><span style=font-family:webdings>3</span>删除</button>
</div>
<%
	}
 %>
<div id=LeftDiv style='float:left;height:100%;overflow:hidden'>
<input name=SeekInput style="width:135px;" onkeyup="checkEnter(this)">
<input name=SeekButton type=button onclick=SeekData(this) value=筛选>
<div style="height:100%;padding-bottom:50px;">
<div id=ListDiv style="overflow-y:auto;overflow-x;hidden;border:1px solid gray;height:100%;">
<table id=QuoteTable cellpadding=3 cellspacing=0 width=100% border=0<%=mousesel%>>
<%
	int nPage = WebChar.RequestInt(request, "nPage");
	if (nPage == 0)
		nPage = 1;
	String Condition = WebChar.requestStr(request,"Condition");
	if  (VB.Left(Condition, 1).equals("="))
		Condition = VB.Mid(Condition, 2);
	if  (VB.Left(Condition, 1).equals("$"))	
		Condition = "";
	if (Condition.equals("!Filter") ||  (Condition.equals("")))
	{
//		AliasValue = WebChar.requestStr(request,"AliasValue");
		Condition = "";
	}
	String SeekKey = WebChar.requestStr(request,"SeekKey");
	if (SeekKey != null && !SeekKey.equals("")) 
		AliasValue = SeekKey;
		
	if ((AliasField == null) || AliasField.equals(""))
		sql = "select " + QuoteField + " from " + TableName;
	else
		sql = "select " + QuoteField + ", " + AliasField + " from " + TableName;
	
	if (AliasValue != null && !AliasValue.equals(""))
	{
		if (Condition != null && !Condition.equals(""))
			Condition1 = Condition + " and ";
		sql +=  " where " + Condition1 + AliasField + " like '%" + AliasValue + "%'";
	}
	else
	{
		if (Condition != null && !Condition.equals(""))
			Condition1 = " where " + Condition;
		sql += Condition1;
	}
	rs = jdb.rsSQL(0, sql);
	rs.last();
	int TotalRec = rs.getRow();
	rs.beforeFirst();
	int nPageSize = 20;
	rs.absolute((nPage - 1) * nPageSize + 1);
	//rs.beforeFirst();
	int filecount = rs.getMetaData().getColumnCount();
	if (TotalRec > 0)
	{
		out.println("<tr><td></td><td></td><tr>");
		for (int y = 1; y <= nPageSize; y++)
		{
			out.println("<tr bgcolor=white onclick=SelectItem(this) ondblclick=InsertItems()>");
			for (int x = 1; x <= filecount; x++)
				out.println("<TD>" + rs.getString(x) + "</TD>");
			if (!rs.next())
				break;
		}
	}
	jdb.rsClose(0, rs);
	int CallBack = WebChar.RequestInt(request, "CallBack");
	if (CallBack == 1)
	{
		out.println("</table></div><script language=javascript>parent.PageReady()</script></body></html>");
		return;
	}
	int Pages = (TotalRec + nPageSize - 1) / nPageSize;
	String BrowseButton = "";
	if (Pages > 1)
		BrowseButton = "<div style=float:left;margin-top:-48px;padding-left:4px;>" +
			"<span id=BrowseSpan>页次:<span id=nPageSpan>" + nPage +
			"</span>/<span id=nPageSizeSpan>" + Pages + "</span>&nbsp;" +
			"<input name=PreviousButton type=button onclick=MoreData(-1) disabled value=上页>"+
			"<input name=NextButton type=button onclick=MoreData(1) value=下页></span>" +
			"</div>";
	jdb.closeDBCon();
%>
</table></div></div><%=BrowseButton%></div></div>
<div class=jformtail1 style=margin-top:-30px;width:100%;clear:both>
<div style=float:right>
<input id=ClearButton type=Button value="<j:Lang key="SeleQuoteTable.Qingchu"/>" onclick=ClearQTDlg()>
<input id=OKButton type=Button value="<j:Lang key="psub.Queding"/>" onclick=ConfirmQTDlg()>
<input id=CancelButton type=button value="<j:Lang key="psub.cancel"/>" onclick=CloseDlg()></div></div>
<IFRAME id=DataFrame style=display:none;width:100%;height:200;></IFRAME>
<% out.println("</BODY></HTML>"); %>