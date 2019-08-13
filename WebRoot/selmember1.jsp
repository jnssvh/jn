<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ include file="com/init.jsp"%>
<%
out.print(WebFace.GetHTMLHead("选择员工", "<link rel='stylesheet' type='text/css' href='com/forum.css'>"));
%>
<body style='background:menu;overflow-x:hidden;' alink=#333333 vlink=#333333 link=#333333 topmargin=1 leftmargin=0>
<div nowrap id=JNetPropTag style='height:20px;width:380px;'>
<span id=PageSpan class=page onclick=SelectPage(this) node=1>组织结构</span>
<span id=PageSpan class=page onclick=SelectPage(this) node=2>员工列表</span>
<span id=PageSpan class=page onclick=SelectPage(this) node=3>我的好友</span>
</div><div id=pageline class=pagediv style=width:100%;height:1px;></div>
<iframe id=WorkFrame SCROLLING=no FRAMEBORDER=0 style="width:100%;height:200;"></iframe>
<CENTER><input type=Button value=确定 onclick=ConfirmDlg()> &nbsp;
	<input type=button value=取消 onclick=window.close()> &nbsp;</CENTER>
</BODY>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript>
function window.onload()
{
	var objs = document.getElementsByName("PageSpan");
	objs[0].click();
	window.onresize = ResizeWin;
	ResizeWin();
}

function ResizeWin()
{
	document.all.WorkFrame.style.height = document.body.clientHeight - 46;
}

var oSelectedPage;
function SelectPage(obj)
{
	if (typeof(oSelectedPage) == "object")
		oSelectedPage.className = "page";
	oSelectedPage = obj;

	oSelectedPage.className = "page selected";
	switch(obj.node)
	{
	case "1":
		document.all.WorkFrame.src = "fvs/Member_select_one_list.jsp";
		break;
	case "2":
		document.all.WorkFrame.src = "fvs/Member_select_flow_one_list.jsp";
		break;
	case "3":
		document.all.WorkFrame.src = "fvs/UserFriends_select_one_list.jsp";
		break;
	}
}

function ConfirmDlg()
{
var values, oChecks;
	values = "";
	
	var oChecks = document.all.WorkFrame.contentWindow.oFocus;
	
	if (oChecks != undefined)
	{
		switch(oSelectedPage.node)
		{
		case "1":
				values = oChecks.innerText;
			break;
		case "2":
				values = oChecks.cells[0].innerText;
			break;
		case "3":
				values = oChecks.innerText;
			break;
		}
	
	}
	
	window.returnValue = values;
	window.close();
}
</script>
<%="</HTML>" %>