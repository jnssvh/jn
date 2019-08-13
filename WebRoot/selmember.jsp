<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ include file="com/init.jsp"%>
<%
String type = WebChar.requestStr(request, "type");
String condition = WebChar.requestStr(request, "condition");
//==是否配制成同步挂接系统用户时使用的 lxt 2011.5.17
boolean  isRpcUsed=("linkSystem".equals(type))?true:false;
int selone = WebChar.RequestInt(request, "selone");
int defaultDept = WebChar.RequestInt(request, "DeptId");

out.print(WebFace.GetHTMLHead(isRpcUsed?"选择要同步的部门或分组":"选择员工", "<link rel='stylesheet' type='text/css' href='forum.css'>"));
%>
<style>
body
{
  height: 100%;
  padding:1;
  margin:0;
}
</style>
<body scroll=no style='overflow-x:hidden;height:auto;' alink=#333333 vlink=#333333 link=#333333>
<div id=SelUsers style=width:100%;height:200px;clear:both;overflow:hidden>
<%
	if (selone == 0)
	{
 %>
 <!-- w3c width:200px->190px lxt 2018.1.16 -->
	<div style="float:right;width:190px;height:100%;">
		<div style=width:100%;height:20px;overflow:hidden;>&nbsp;<%=(isRpcUsed)?"已选部门或分组":"已选用户" %>:<span id=CountSpan></span><span id="spanTop" style="margin-left:10px;"></span></div>
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
<%
	}
 %>
	<div id=UsersDiv style=float:left;height:100%>
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
	var memberStr = "";
	var defaultDept = <%=defaultDept%>;
	if (typeof window.dialogArguments == "object") {
		parentWindow = window.dialogArguments;
		if (window.dialogArguments.member != undefined) {
			memberStr = window.dialogArguments.member;
		}
		if (window.dialogArguments.form != undefined) {
			document.getElementById("spanTop").innerHTML = window.dialogArguments.form;
		}
	} else if (typeof window.dialogArguments == "string") {
		memberStr = window.dialogArguments;
	}
	
	// w3c不兼容传参数问题 lxt 2017.6.14
	if(!memberStr&&navigator.userAgent.indexOf("Chrome")>-1&&window.localStorage["W3C_DLG_PARAM"]){
		memberStr=window.localStorage["W3C_DLG_PARAM"];
		window.localStorage["W3C_DLG_PARAM"]=null;
	}
	
	var condition = encodeURIComponent ("<%=condition%>");
	var type = "<%=type%>";
	window.mdiwin = new MDIWindows(document.all.UsersDiv, {});
	ResizeWin();
	switch (type) {
	case "linkSystem":
	case "dept":
	case "SS_CmmSpeechPlayers":// 求是社区 lxt 2012.3.28
	break;
	default:
		var url = "fvs/SeleDeptMember.jsp?DeptId=" + defaultDept + "&type=" + type + "&condition=" + condition;
		mdiwin.Create(url, "组织结构", 0, {dblclick:0});
	break;
	}
	switch (type) {
		case "flow":
			mdiwin.Create("about:blank", "部门", 1, {dblclick:0});
			mdiwin.Create("about:blank", "关联用户", 1, {dblclick:0});
			mdiwin.Create("about:blank", "权限分组", 1, {dblclick:0});
			break;
		case "flowrun":
			mdiwin.Create("about:blank", "用户列表", 1, {dblclick:0});
			mdiwin.Create("about:blank", "组用户", 1, {dblclick:0});
			mdiwin.Create("about:blank", "我的好友", 1, {dblclick:0});
			mdiwin.Create("about:blank", "我的群", 1, {dblclick:0});
			break;		
		case "dept":
			mdiwin.Create("fvs/Dept_select_one_list.jsp?type=flow&condition=" + condition, "部门", 1, {dblclick:0});
			
			break;
		case "app":
			mdiwin.Create("about:blank", "权限分组", 1, {dblclick:0});
			mdiwin.Create("about:blank", "用户列表", 1, {dblclick:0});
			break;
		case "linkSystem":
			mdiwin.Create("fvs/WorkGroup_list_select.jsp", "权限分组", 0, {dblclick:0});
			mdiwin.Create("about:blank", "部门", 1, {dblclick:0});
			break;
		case "right_group":
			mdiwin.Create("about:blank", "用户列表", 1, {dblclick:0});
			mdiwin.Create("about:blank", "我的好友", 1, {dblclick:0});
			mdiwin.Create("about:blank", "权限分组", 1, {dblclick:0});
			break;
		case "SS_CmmSpeechPlayers": // 求是社区
			mdiwin.Create("fvs/SS_CmmSpeechPlayer_ListSel.jsp", "计时赛选手", 0, {dblclick:0});
			break;
		case "inner_mail":
			mdiwin.Create("about:blank", "用户列表", 1, {dblclick:0});
			mdiwin.Create("about:blank", "权限分组", 1, {dblclick:0});
			mdiwin.Create("about:blank", "我的好友", 1, {dblclick:0});
			break;
		default:
			mdiwin.Create("about:blank", "用户列表", 1, {dblclick:0});
			mdiwin.Create("about:blank", "我的好友", 1, {dblclick:0});
			break;
	}
	mdiwin.ActivePage(0);
	mdiwin.onactive = ActivePage;
	window.onresize = ResizeWin;
	
	// IE9+标准模式下空白bug lxt 2017.6.13
	var uDiv=document.getElementById("UsersDiv");
	if(document.documentElement.clientHeight&&document.documentElement.clientHeight>60&&
	navigator.userAgent.indexOf("Trident")>-1&&navigator.userAgent.replace(/.*Trident\/(\d+).*/,"$1")>4){
		uDiv.style.width=(document.documentElement.clientWidth/2)+"px";
		uDiv.style.height=(document.documentElement.clientHeight-60)+"px";
	}
	
	if (typeof document.all.ResultDiv == "object")
	{
		if (IsNetBoxRunning())
			UpdateMember(external.Argument);
		else
		{
			UpdateMember(memberStr);
		}
	}
	if (typeof parent.UserInserMember == "function") {
		parent.UserInsertMember();
	}
}

function ActivePage(item)
{
	var condition = encodeURIComponent ("<%=condition%>");
	var obj = item.data;
	if (typeof obj == "string")
		obj = document.getElementById(item.data);
	if (obj.src != "about:blank")
		return;
	switch (item.item)
	{
	case "组织结构":
		obj.src = "fvs/SeleDeptMember.jsp?condition=" + condition;
		break;
	case "用户列表":
		obj.src = "fvs/SelectActionUser.jsp?condition=" + condition;
		break;
	case "我的好友":
		obj.src = "fvs/UserFriends_select_list.jsp";
		break;
	case "部门":
		obj.src = "fvs/Dept_select_one_list.jsp?type=flow&condition=" + condition;
		break;
	case "关联用户":
		obj.src = "fvs/UEnumData_list_flow.jsp";
		break;
	case "我的群":
		obj.src = "fvs/ChatRoomUsers_list_select.jsp";
		break;
	case "权限分组":
		obj.src = "fvs/WorkGroup_list_select.jsp";
		break;
	case "计时赛选手":// 求是社区
	   	obj.src="fvs/SS_CmmSpeechPlayer_ListSel.jsp";
	   	break;
	case "组用户":
		obj.src = "fvs/FlowSource_list_selectGroup.jsp";
		break;
	default:
	
		break;
	}
}

function ResizeWin()
{
	if (document.body.clientHeight > 43)
		document.all.SelUsers.style.height = document.body.clientHeight - (navigator.userAgent.indexOf("Chrome")>-1?47:43);
}




function ConfirmDlg()
{
	var selectedUser = "";
	if (typeof document.all.ResultDiv != "object")
		selectedUser = GetMember();
	else
	{
		var selectedUser = GetResult();
		if (parentWindow != null && parentWindow.getForm != undefined) {
			selectedUser += "<;>" + parentWindow.getForm(window);
		}
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

function GetMember()
{
var values = "", x, value = "", objs;
	var index = mdiwin.GetActivePage(1);
	var page = mdiwin.GetActivePage(2);
	switch(index)
	{
	case "组织结构":
		objs = page.contentWindow.document.getElementsByTagName("div");
		var isUser = false;
		for (x = 0; x < objs.length; x++)
		{
			if (objs[x].selflag == 1)
			{
				if (page.contentWindow.TestCurrentObj(objs[x]) == 2)
					isUser = false;
				else {
					isUser = true;
					break;
				}
			}
		}
		for (x = 0; x < objs.length; x++)
		{
			if (objs[x].selflag == 1)
			{
				if (page.contentWindow.TestCurrentObj(objs[x]) == 2) {
					if (!isUser) {
						value = GetTreeChildMember(objs[x], page);
					}
				} else
					value = objs[x].innerText;
				if (value != "")
				{
					if (values != "")
						values += ",";
					values += value;
				}
			}
		}
//		page.contentWindow.ClearSelectRow(page.contentWindow.document.all.TableDoc);
		return values;
	case "我的群":
	case "组用户":
		objs = page.contentWindow.document.getElementsByTagName("div");
		
		for (x = 0; x < objs.length; x++)
		{
			
			if (objs[x].selflag == 1)
			{
				if (objs[x].outerHTML.indexOf("BtExTree") >= 0) {
					var divs = objs[x].parentNode.nextSibling.getElementsByTagName("div");
					for (var y = 0; y < divs.length; y++) {
						divs[y].setAttribute("selflag", 1);
					}
					continue;
				}
				value = objs[x].innerText;
				if (value != "")
				{
					if (values != "")
						values += ",";
					values += value;
				}
			}
		}
		objs = null;
//		page.contentWindow.ClearSelectRow(page.contentWindow.document.all.TableDoc);
		return values;
	case "用户列表":
		objs = page.contentWindow.document.all.SeekTable.rows;
		for (var x = 1; x < objs.length; x++)
		{
			if (objs[x].selflag == 1)
			{
				if (values != "")
					values += ",";
				values += objs[x].cells[0].innerText;
			}
		}
//		page.contentWindow.ClearSelectRow(page.contentWindow.document.all.SeekTable);
		return values;
	case "我的好友":
		var objs = page.contentWindow.document.getElementsByTagName("DIV");
		for (var x = 1; x < objs.length; x++)
		{
			if (objs[x].selflag == 1)
			{
				if (page.contentWindow.TestCurrentObj(objs[x]) == 2)
				{
					var oo = objs[x].nextSibling.getElementsByTagName("DIV");
					for (var y = 0; y < oo.length; y++)
					{
						if (oo[y].innerText != "")
						{
							if (values != "")
								values += ",";
							values += oo[y].innerText;
						}
					}
				}
				else
				{
					if (values != "")
						values += ",";
					values += objs[x].innerText;
				}
			}
		}
//		page.contentWindow.ClearSelectRow(page.contentWindow.document.all.TableDoc);
		return values;
	
	case "部门":
		var objs = page.contentWindow.oFocus;
		if (objs == undefined)
			return;
		if (values != "")
			values += ",";
		
		values += <%=(isRpcUsed)?"objs.node+':'+":""%>objs.innerText;
//		page.contentWindow.ClearSelectRow(page.contentWindow.document.all.TableDoc);
		return values;
	case "关联用户":
		objs = page.contentWindow.document.all.SeekTable.rows;
		for (var x = 1; x < objs.length; x++)
		{
			if (objs[x].selflag == 1)
			{
				if (values != "")
					values += ",";
				values += objs[x].cells[0].innerText;
			}
		}
//		page.contentWindow.ClearSelectRow(page.contentWindow.document.all.SeekTable);
		return values;
	case "权限分组":
		var objs = page.contentWindow.oFocus;
		if (objs == undefined)
			return;
		if (values != "")
			values += ",";
		
		values +=<%=(isRpcUsed)?"objs.node+':'+":""%>objs.innerText;
		return values;
	case "计时赛选手":// 求是社区
		var objs = page.contentWindow.oFocus;
		if (objs == undefined||objs.innerHTML.indexOf("BtExTree")>0)
			return;
		if (values != "")
			values += ",";
		
		values +=objs.node+':'+objs.innerText;
		return values;
	}
}

// w3c 获取某子元素 lxt 2017.12.28
// obj.all.BtExTree 这种写法不兼容w3c
function getSubEleById(obj, id){
	var BtExTreeObj;
	var arr=obj.getElementsByTagName("*");
	for(var z=0; z<arr.length; z++)
	if(arr[z].id==id){
		BtExTreeObj=arr[z];
		break;
	}
	return BtExTreeObj;
}
function GetTreeChildMember(obj, page)
{
	// w3c lxt 2017.12.28
	var BtExTreeObj=getSubEleById(obj, "BtExTree");
	var values = "", value, o;
	// obj.all.BtExTree
	if (BtExTreeObj.getAttribute("ready") == "1")
	{
		var childs = obj.nextSibling.childNodes;
		
		for (var x = 0; x < childs.length; x ++)
		{
			if (childs[x].id == "")
				o = childs[x].firstChild;
			else
				o = childs[x];
			
			if (page.contentWindow.TestCurrentObj(o) == 2)
			{
				value = GetTreeChildMember(o, page);
//				x++;
			}
			else
				value = o.innerText;
				
			if (value != "")
			{
				if (values != "")
					values += ",";
				values += value;
			}
		}
	}
	return values;
}

function IsTreeMemberReady()
{
var result = true, x, objs;
	var index = mdiwin.GetActivePage();
	var page = mdiwin.GetActivePage(2);
	if (index != 0)
		return true;
	objs = page.contentWindow.document.getElementsByTagName("div");
	for (x = 0; x < objs.length; x++)
	{
		if (objs[x].selflag == 1)
		{
			if (page.contentWindow.TestCurrentObj(objs[x]) == 2)
			{
				if (IsTreeItemReady(objs[x], page) == false)
					result = false;
			}
		}
	}
	if (result == false)
		window.setTimeout(IsTreeMemberReady, 500);
	else
	{
		if (document.all.InsertButton.disabled == true)
		{
			document.all.InsertButton.disabled = false;
			document.all.InsertButton.click();
		}
	}
	return result;
}

function IsTreeItemReady(obj, page)
{
	// w3c lxt 2017.12.28
	var BtExTreeObj=getSubEleById(obj, "BtExTree");
	// obj.all.BtExTree
	if (BtExTreeObj.getAttribute("ready") == "0")
	{
		page.contentWindow.ExpandTableTree(BtExTreeObj);
		return false;
	}
	if (BtExTreeObj.getAttribute("ready") == "2")
		return false;
	if (obj.nextSibling == null)
		return true;
	var childs = obj.nextSibling.childNodes;
	var value;
	for (var x = 0; x < childs.length; x ++)
	{
		if (page.contentWindow.TestCurrentObj(childs[x]) == 2)
		{
			if (IsTreeItemReady(childs[x], page) == false)
				return false;
		}
	}
	return true;

}

function InsertMember()
{
	if (typeof document.all.ResultDiv != "object")
		return ConfirmDlg();
	var index = mdiwin.GetActivePage();
	if (index != 0)
		return UpdateMember(GetMember());
		
	var page = mdiwin.GetActivePage(2);
	objs = page.contentWindow.document.getElementsByTagName("div");
	var values = "", value;
	for (x = 0; x < objs.length; x++)
	{
		if (objs[x].selflag == 1)
		{
			if (page.contentWindow.TestCurrentObj(objs[x]) != 2)
			{
				value = objs[x].innerText;
				if (value != "")
				{
					if (values != "")
						values += ",";
					values += value;
				}
			}
			else
				getSubEleById(objs[x], "BtExTree").click(); // w3c lxt 2017.12.28
		}
	}
	UpdateMember(values);
}

function AppendMembers()
{
	if (IsTreeMemberReady())
		UpdateMember(GetMember());
	else
		document.all.InsertButton.disabled = true;
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

function DeleMember()
{
	for (var x = document.all.ResultDiv.childNodes.length - 1; x >= 0 ; x--)
	{
		if (document.all.ResultDiv.childNodes[x].selflag == 1)
		{
			//document.all.ResultDiv.childNodes[x].removeNode(true); IE
			document.all.ResultDiv.removeChild(document.all.ResultDiv.childNodes[x]);
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
var ViewMode = 2;
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