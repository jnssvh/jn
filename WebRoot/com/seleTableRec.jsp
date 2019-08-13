<%@ page language="java" import="java.util.*,com.jaguar.*,java.sql.*" pageEncoding="GBK"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>
 <%@ include file="init.jsp" %>
<%
//使用样例：
//seleTableRec.jsp?Action=UEnumData_select_list.jsp?EnumTypeCode_-_actionid=abcde=PROFESSION&SelFields=0
//SelFields 为将要选择输出的列，从1开始，当为0时，选择记录的ID，当为多列选择时，用逗号隔开。如'1,2,3,4,5,8'
	int FormType = 1;
	String  DataID = WebChar.requestStr(request , "DataID");
	String SelFields = WebChar.requestStr(request, "SelFields");
	String Action = WebChar.requestStr(request, "Action");
	String dialog = WebChar.requestStr(request, "dialog");
	String callback = WebChar.requestStr(request, "callback");
	Action = WebChar.unescape(WebChar.unescape(Action));
	if (SelFields.equals(""))
		SelFields = "0";
	else
		SelFields = SelFields.replaceAll("join", "&");

	String ColSP = WebChar.requestStr(request, "ColSP");
	if (ColSP.equals(""))
		ColSP = "@:@";
	String RowSP = WebChar.requestStr(request, "RowSP");
	if (RowSP.equals(""))
		RowSP = "@,@";
	//String url = WebChar.requestStr(request, "url");
	String Condition = WebChar.requestStr(request, "Condition");
	if (Condition.length() > 0)
	{
		Condition = Condition.replaceAll("_-_", "&");
		if (Condition.indexOf("?") < 0)
			Action += "?" + Condition;
		else
			Action += "&" + Condition;
	}

	out.println(WebFace.GetHeadBody(TagMethod.getLang(request.getLocale(),"seleTableRec.Tablelist_select"), WebFace.MainBodyColor));
%>
<DIV id=QuoteDiv style=height:520px;overflow:auto;>
<iframe id=TableSeekFrame src="<%=Action%>" width=100% height=100% frameborder=0></iframe></DIV>
<CENTER><input type=Button value="<j:Lang key="psub.Queding"/>" onclick=ConfirmDlg()> &nbsp;
<input type=button value="<j:Lang key="psub.cancel"/>" onclick="window.returnValue='';window.close();"> &nbsp;</CENTER>
<SCRIPT type="text/JavaScript">
function ConfirmDlg(oWin)
{
var x, y, oChecks, value, values;
var SelFields = "<%=SelFields%>";
var ColSP = "<%=ColSP%>";
var RowSP = "<%=RowSP%>";
var obj;
var dialog = "<%=dialog %>";
	nItems = SelFields.split(",");
	if (typeof(oWin) != "object")
		oWin = document.getElementById("TableSeekFrame").contentWindow;
	if (typeof(oWin.UserConfirmWin) == "function")
	{
		result = oWin.UserConfirmWin(SelFields, ColSP, RowSP);
		if (result != "")
		{
			window.returnValue = result;
			window.close();
		}
		return;
	}
	oChecks = oWin.document.getElementsByName("SelectLineTD");
	window.returnValue = "";
	//window.returnValue = oWin.GetSelectNode();
	for (x = 0; x < oChecks.length; x++)
	{
		if (oChecks[x].checked)
		{
			values = "";
			for (y = 0; y < nItems.length; y++)
			{
				obj = oChecks[x].parentNode.parentNode;
				if (obj.getAttribute("node") == undefined)
				{
					obj = oChecks[x].parentNode.parentNode.parentNode;
				}
				if (nItems[y] == 0)
					value = obj.getAttribute("node");
				else			
					value = obj.cells[nItems[y] - 1].innerText;
				if (values == "")
					values = value;
				else
					values += ColSP + value;
			}
			if (window.returnValue == "")
				window.returnValue = values;
			else
				window.returnValue += RowSP + values;
		}
	}
	if (window.returnValue == "")
	{
		if (typeof(oWin.oFocus) == "undefined")
		{	alert("<j:Lang key="seleTableRec.Tablelist_noselect"/>");
			return;
		}
		values = "";
		for (y = 0; y < nItems.length; y++)
		{
			if (nItems[y] == 0)
				value = oWin.oFocus.node;
			else
			{

				if (oWin.oFocus.tagName != "TR")
				{
					if (nItems[y] == 1)
						value = oWin.oFocus.innerText;
					else
					{
						if (typeof(oWin.document.all.SubSeekFrame) == "object")
							return ConfirmDlg(oWin.document.all.SubSeekFrame.contentWindow);
						if (nItems.length <=2)
						{
							returnValue = oWin.oFocus.node + ColSP + oWin.oFocus.innerText;
							return window.close();
						}
						else
							return alert("<j:Lang key="seleTableRec.Select_shitulist"/>");
					}
				}
				else
					value = oWin.oFocus.cells[nItems[y] - 1].innerText;
			}
			if (values == "")
				values = value;
			else
				values += ColSP + value;
		}
		if (window.returnValue == "")
			window.returnValue = values;
		else
			window.returnValue += RowSP + values;
	}
	if (dialog != "NewHref") {
		window.close();
	} else {
		<%
		if (VB.isNotEmpty(callback)) {%>
		try {
		<%="parent." + callback + "(window.returnValue)" %>
		} catch(e) {
			alert(e);
		}
		<%}%>
	}
}
window.onresize=ResizeDlg;
window.onload = function () {
	ResizeDlg();
}
function ResizeDlg()
{
	if (document.body.clientHeight > 40)
		document.all.QuoteDiv.style.height = document.body.clientHeight - 40;
}
</SCRIPT>
<% jdb.closeDBCon();
out.print("</BODY></HTML>");%>