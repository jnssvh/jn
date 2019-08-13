<%@ page language="java" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.net.URLEncoder,project.*" %>
 <%@ include file="init.jsp" %>


<%
	WebEnum webenum = new WebEnum(jdb);
//	jdbapp = new JDBApp(jdb, user, webenum);
//	if (!user.GetDataRight(12,1,"",0,""))
//	{
//		out.println("您没有权限执行此操作，请与管理员联系");
//		out.close();
//	}

	String TableName = WebChar.requestStr(request, "TableName");
	String FieldName = WebChar.requestStr(request,"FieldName");
	String CName = WebChar.requestStr(request,"FieldCName");
	String QuoteTable = WebChar.requestStr(request,"QuoteTable");
	String SeekParam = WebChar.requestStr(request,"SeekParam");

	int FieldType = jdb.GetTableFieldType(TableName, 0, FieldName);
	//
	out.println(WebFace.GetHTMLHead("输入查询关键字" + CName + "&nbsp;&nbsp;&nbsp;&nbsp;"));
	String Browse = "BrowseKey()";
	String s[], s1[], TButton, TItem;
	String tag = VB.Left(QuoteTable,1);
	if(tag.equals("@"))
		Browse = "EnumData(this," + VB.Mid(QuoteTable, 2) + ")";
	else if(tag.equals("("))
		Browse = "InlineEnum(this,'" + VB.Mid(QuoteTable, 2, (QuoteTable.length() - 2)) + "')";
	else
	{
		if ((QuoteTable != null && !QuoteTable.equals("")) && !VB.Left(QuoteTable,1).equals("&") && !VB.Left(QuoteTable,1).equals("$"))
		{
			s = QuoteTable.split(",");
			s1 = s[0].split("\\.");
	
			if (s.length == 2)
				Browse = "QuoteTable(this,'" + s1[0] + "','" + s1[1] + "','" + s[1] + "')";
		}
	}
	if (FieldType == 4)
	{
	//       
	//
		TButton = "<input name=TButton type=checkbox onclick=TimeRange(this)>日期范围&nbsp;&nbsp;&nbsp;";
		TItem = "<fieldset id=TItem style=display:none><legend>日期查询: </legend>" +
			"<input type=radio name=SeekDateTime value=1>按年份查询(19xx,20xx)&nbsp;&nbsp;" +
			"<input type=radio name=SeekDateTime value=2>按月份查询(1-12)<BR>" +
			"<input type=radio name=SeekDateTime value=3>按日期查询(1-31)&nbsp;&nbsp;" +
			"<input type=radio name=SeekDateTime value=4>按年月查询(xxxx-xx)<BR>" +
			"<input type=radio name=SeekDateTime value=5 checked>按月日查询(xx-xx)&nbsp;&nbsp;" +
			"<input type=radio name=SeekDateTime value=6>按季度查询(1-4)<BR>" +
			"<input type=radio name=SeekDateTime value=7>按时间段查询。例: 1997-1-1, 2005-12-31" +
			"</fieldset>";
	}
	else{
		TButton = "";
		TItem = "";
	}
	out.println("<script language=javascript src=psub.jsp></script>");
%>
<SCRIPT LANGUAGE=JavaScript>

function ConfirmDlg()
{
	if ((typeof(document.all.TButton) == "object") && (document.all.TButton.checked))
	{
		if (isNaN(parseInt(document.all.SeekKey.value)))
		{
		//输入的关键字不合法
			alert("<tm:Lang key="SeekKey.Buhefa"/>");
			document.all.SeekKey.focus();
			return;
		}
		oRadios = document.getElementsByName("SeekDateTime");
		for (var x = 0; x < oRadios.length; x++)
		{
			if (oRadios[x].checked)
				break;
		}
		returnValue = "@" + oRadios[x].value + "@" + document.all.SeekKey.value;
	}
	else
		returnValue = document.all.SeekKey.value;
	window.close();
}

function PressKey()
{
	if (event.keyCode == 13)
		ConfirmDlg();
}

function BrowseKey()
{
	var value = SelectField(0, "<%=TableName%>", "<%=FieldName%>");
	if (typeof(value) != "undefined")
		document.all.SeekKey.value += value;
}

function TimeRange(obj)
{
	if (obj.checked)
	{
		document.all.HelpField.style.display = "none";
		document.all.TItem.style.display = "inline";
		document.all.SeekKey.rows = 2;
	}
	else
	{
		document.all.HelpField.style.display = "inline";
		document.all.TItem.style.display = "none";
		document.all.SeekKey.rows = 6;
	}
} 

function EnumData(obj, EnumType)
{
	var value = showModalDialog("seleenum.jsp?EnumType=" + EnumType, "", "dialogWidth:400px;scroll:0;help:0;status:0");
	if (typeof(value) == "undefined")
		return;
	var ss = value.split(":");
	document.all.SeekKey.value += ss[0];
}

function InlineEnum(obj, Quote)
{
alert(Quote);
	var value = showModalDialog("seleenum.jsp?Quote=" + Quote, "", "dialogWidth:400px;scroll:0;help:0;status:0");
	if (typeof(value) == "undefined")
		return;
	var ss = value.split(":");
	document.all.SeekKey.value += ss[0];
}

function QuoteTable(obj, TableName, QuoteField, AliasField)
{
	str = showModalDialog("SeleQuoteTable.jsp?TableName=" + TableName + 
		"&QuoteField=" + QuoteField + "&AliasField=" + AliasField, "", 
		"dialogWidth:400px;scroll:0;help:0;status:0;resizable:1");
	if (typeof(str) == "undefined")
		return;
	var s = str.split("|,|");
	document.all.SeekKey.value += s[0];
}
</SCRIPT>
<!-- 输入提示 精确查找请输入完整的关键字名称。例：条件   模糊查找请在关键字前面或后面加上 * 号。例：条件* 或 *条件*

指定范围查找请使用尖括号表示。例： 需要查找多项内容，请使用圆括号表示。例：(条件1,条件2,条件3)
-->
<BODY bgcolor=menu onkeypress=PressKey()>
<%=TItem%>
<fieldset id=HelpField><legend><tm:Lang key="SeekKey.Shuru_tishi"/></legend>
<LI><tm:Lang key="SeekKey.Jienque_select"/>
<LI><tm:Lang key="SeekKey.Mohu_select"/>
<LI><tm:Lang key="SeekKey.Zhiding_fangwei"/>
<LI><tm:Lang key="SeekKey.Manyneirong_select"/></fieldset>
<textarea name=SeekKey rows=6 style=width:100%;><%=SeekParam%></textarea><br>
<BR><CENTER><%=TButton%>
<BUTTON id=Browse onclick=<%=Browse%> title="<tm:Lang key="SeekKey.Guanjizi_select"/>"><tm:Lang key="SeekKey.Lookup"/></BUTTON>&nbsp;&nbsp;
<BUTTON id=Ok onclick=ConfirmDlg()><tm:Lang key="SeekKey.Queding"/></BUTTON>&nbsp;&nbsp;
<BUTTON onclick=window.close()><tm:Lang key="dev_openwin.cancel"/></BUTTON></CENTER>
</BODY>
<% 
jdb.closeDBCon();
%>