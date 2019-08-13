<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ include file="com/init.jsp"%>
<%
	int StepID = WebChar.RequestInt(request, "StepID");
	int ActionID = WebChar.RequestInt(request, "ActionID");
	String UsersRuler = jdb.GetTableValue(0, "FlowNode", "UsersRuler", "", "ID=" + ActionID);
	String ActionUser = "", tag = "";
	try {
			ActionUser = FlowFun.GetFlowUser(UsersRuler, jdb, user, StepID);
		} catch (Exception e) {
		}
	String [] ss = ActionUser.split(",");
	
	for (int x = 0; x < ss.length; x++)
		tag += "<div style=width:100%;height:20px;padding-left:8px;>" + ss[x] + "</div>";

out.print(WebFace.GetHTMLHead("选择流程执行人", "<link rel='stylesheet' type='text/css' href='forum.css'>"));
%>
<style>
body
{
  height: 100%;
  padding:1;
  margin:0;
}
</style>
<body scroll=no style='overflow-x:hidden;' alink=#333333 vlink=#333333 link=#333333>
<div id=SelUsers style="width:100%;height:200px;clear:both;overflow:hidden">
	<div style="float:right;width:200px;height:100%;">
		<div style=width:100%;height:20px;overflow:hidden;>&nbsp;已选用户:<span id=CountSpan></span><span id="spanTop" style="margin-left:10px;"></span></div>
		<div style="width:100%;height:100%;margin-top:-20px;padding-top:20px;overflow:hidden;">
		<div id=ResultDiv onclick=SelResult(this) ondblclick=DeleMember() onmousedown=TreeSelectBegin(this) style="border:1px solid gray;width:100%;height:100%;overflow-y:auto;"></div>		
		</div>
	</div>
	<div style="float:right;width:80px;height:100%;text-align:center">
		<div style=height:50%;margin-top:-80px;padding-top:80px;></div>
		<button id=InsertButton style=width:70px; onclick=AppendMembers()>增加<span style=font-family:webdings>4</span></button><br><br><br>
		<button style=width:70px; onclick=DeleMember()><span style=font-family:webdings>3</span>删除</button><br><br><br>
		<button style=width:70px; onclick=DeleAllMember()><span style=font-family:webdings></span>清空</button>
		<div id="divForm" style="margin-top:10px;"></div>
	</div>
	<div id=UsersDiv style="border:1px solid gray;float:left;height:100px;overflow:auto;" onclick=SeleUser(this) ondblclick=AppendMembers()><%=tag%>
	</div>
</div>
<CENTER class=jformtail1 style=margin-top:10px;><input type=Button value=确定 onclick=ConfirmDlg()> &nbsp;
	<input type=button value=取消 onclick=CloseWin()> &nbsp;</CENTER>
</BODY>
<script language=javascript src=com/seek.jsp></script>
<script language=javascript src=com/psub.jsp></script>
<script language=javascript src=com/common.js></script>
<script language=javascript>
var nSelCount = 0;
var parentWindow = null;
window.onload=function()
{
	UpdateMember(window.dialogArguments);
	ResizeWin();
	window.onresize = ResizeWin;
	
	
}

function ResizeWin()
{
	var div=document.getElementById("UsersDiv");
	if (document.body.clientHeight > 43)
		div.style.height = document.body.clientHeight - 43;
	div.style.width=(document.documentElement.clientWidth-300)+"px";
	document.getElementById("SelUsers").style.height=(document.documentElement.clientHeight-100)+"px";
}

function SeleUser(obj)
{
	if (event.srcElement != obj)
		SelObject(event.srcElement);
}

function AppendMembers()
{
	if (typeof oFocus == "object")
		UpdateMember(oFocus.innerText);
}

function UpdateMember(members)
{
	if ((members == "") || (typeof members != "string"))
		return;
	var ss = members.split(",");
	ss = ss.sort(Compare);
	var users = new Array();
	for (var x = 0; x < ss.length; x++)
	{
		if (IsMemberInResult(ss[x]) == false)
		{
			users.push("<div style=width:100%;height:20px;padding-left:8px;>" + ss[x] + "</div>");
			nSelCount ++;
		}
	}
	document.all.ResultDiv.insertAdjacentHTML("beforeEnd", users.join(""));
	document.all.CountSpan.innerText = nSelCount;
}

function Compare(a,b) 
{ 
	return a.localeCompare(b); 
}

function IsMemberInResult(member)
{
	for (var x = document.all.ResultDiv.childNodes.length - 1; x >= 0 ; x--)
	{
		if (document.all.ResultDiv.childNodes[x].innerText == member)
			return true;
	}
	return false;

}

function GetResult()
{
	var value = "";
	for (var x = document.all.ResultDiv.childNodes.length - 1; x >= 0 ; x--)
	{
		if (value != "")
			value += ",";
		value += document.all.ResultDiv.childNodes[x].innerText;
	}
	return value;
}

function ConfirmDlg()
{
	var selectedUser = "";
	var selectedUser = GetResult();
	if (parentWindow != null && parentWindow.getForm != undefined) 
	{
		selectedUser += "<;>" + parentWindow.getForm(window);
	}
	window.returnValue = selectedUser;
	// Chrome浏览器不能弹模态对话框处理（兼容Electron) lxt 2017.5.28
	if(window.navigator.userAgent.indexOf("Chrome")>-1){
		window.localStorage["diglogReturnValue"]= selectedUser;
	}
	if (IsNetBoxRunning() && (typeof window.dialogHeight == "undefined"))
		external.EndDialog(window.returnValue);
	else
		window.close();
	parentWindow = null;
}


function DeleMember()
{
	for (var x = document.all.ResultDiv.childNodes.length - 1; x >= 0 ; x--)
	{
		if (document.all.ResultDiv.childNodes[x].selflag == 1)
		{
			document.all.ResultDiv.childNodes[x].removeNode(true);
			nSelCount --;
		}
	}
	document.all.CountSpan.innerText = nSelCount;
}

function DeleAllMember()
{
	if (window.confirm("将清空所有已选用户,是否确定?"))
	{
		document.all.ResultDiv.innerHTML = "";
		nSelCount = 0;
	}
	document.all.CountSpan.innerText = "";
}

function SelResult(obj)
{
	if (obj == event.srcElement)
		return;
	if (event.srcElement.tagName == "DIV")
		SelectRow(event.srcElement);
}

</script>
<%
out.println("</HTML>");
jdb.closeDBCon();
 %>