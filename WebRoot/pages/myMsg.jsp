<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="myMsg";
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	switch (loginType)
	{
	case 2:
		user = new studentUser();
		break;
	default:
		user = new SysUser();
		break;
	}
	int result = user.initWebUser(jdb, cookie);
	if (result != 1)
	{//如果cookie丢失，就从命令行取出账户，重设cookie
		String EName = WebChar.requestStr(request, "UserName");
		Cookie [] ck = new Cookie[2];
		ck[0] = new Cookie("loginname", EName);
		ck[1] = new Cookie("loginpassword", WebChar.requestStr(request, "Password"));
		result = user.initWebUser(jdb, ck);
		if (result != 1)
		{
			jdb.closeDBCon();
			response.sendRedirect("../cps/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='myMsg' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##627:服务器启动代码(归档用注释,切勿删改)
//
	if (WebChar.RequestInt(request, "LoadMsgList") > 0)
	{
		String sql = "select top 200 case when Sender='" + user.CMemberName + "' then Receiver else Sender end item from RealMsg"
			+ " where Sender='" + user.CMemberName + "' or Receiver='" + user.CMemberName + "'"
			+ " group by case when Sender='" + user.CMemberName + "' then Receiver else Sender end order by max(SendDate) desc";
		ResultSet rs = jdb.rsSQL(0, sql);
		StringBuilder str = new StringBuilder();
		str.append("[");
		int cnt = 0;
		while (rs.next())
		{
			if (cnt > 0)
				str.append(",");
			String CName = rs.getString("item");
			int Photo = WebChar.ToInt(jdb.GetTableValue(0, "Member", "Photo", "CName", "'" + CName + "'"));
			str.append("{item:\"" + CName + "\", Photo:" + Photo + "}");
			String list = jdb.getJsonBySql(0, sql);
			cnt ++;
		}
		out.print(str + "]");
		jdb.closeDBCon();
		return;
	}

	if (WebChar.RequestInt(request, "LoadDeptMember") > 0)
	{
		out.print(jdb.getJsonBySql(0, "select EName, CName, Photo from Member where Dept=" + WebChar.RequestInt(request, "DeptNo")));
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "LoadGroupMember") > 0)
	{
		int Dept = WebChar.RequestInt(request, "Dept");
		if (Dept > 0)
			out.print(jdb.getJsonBySql(0, "select EName, CName, Photo from Member where Dept=" + Dept));
		else
			out.print(jdb.getJsonBySql(0, "select ChatRoomUsers.EName, ChatRoomUsers.CName, ChatRoomUsers.NickName, RoomRight, Member.Photo from ChatRoomUsers " +
				"left join Member on ChatRoomUsers.CName=Member.CName where RoomID=" + WebChar.RequestInt(request, "ID")));
		jdb.closeDBCon();
		return;
	}
	
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>我的消息</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2019-4-2 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"myMsg", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	
//@@##628:客户端加载时(归档用注释,切勿删改)
//
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.Filter = new $.jcom.Cascade(o, [{item:"我的消息"},{item:"我的好友"},{item:"我的群"},{item:"组织结构"}], {title:["分类"]});
	book.Filter.onclick = ClickFilter;
	var oo = book.Filter.AddUserLegend("联系人", {TitleID: "UserTitle", divID:"UserTree"});
//	$(o).after("<div id=FilterTree style='border:1px solid gray;width:100%;'></div>");
	book.Tree = new  $.jcom.TreeView(oo[0], []);
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "", {}, {}, {headstyle:3, gridstyle:3, footstyle:4, resizeflag:0, titlebar:"<h2 align=center>对话</h2>"});
	book.groupUsers = new $.jcom.Cascade(0,[], {title:["群成员"]});
	book.setPageObj(book.Filter);
	book.setDocBottom("<textarea id=MsgText placeholder=输入要发送的消息 style='height:100px;border:1px solid gray;width:100%;overflow:visible'></text" + "area>" +
		"<div align=right style=float:right><input id=SubmitButton type=button style='width:100px;font:normal normal normal 16px 微软雅黑' value=发送></div>", "Footbar");
	$("#SubmitButton").on("click", SendMsg);
	book.Page.clickRow = ClickPage;
	book.Tree.click = ClickTree;
	book.Tree.loadnode = LoadDeptMember;
	book.onRealMsg = RealMsg;
	book.Page.makeThumb = MakeThumb;
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##629:客户端自定义代码(归档用注释,切勿删改)
//
var typeItem, userItem;
function MakeThumb(line, hint, index, item)
{
	var tag = "<div style='margin: 0px; padding: 4px;width:100%;overflow:hidden' name=thumbdiv node=" + index + ">"
	if (item.Sender == sys.CName)
		tag += "<div style='float:right;width:40px;'>" + getImg(sys.PhotoID, 40) + "</div><div style='float:right;max-width:90%;padding-right:12px;'>" +
			"<div align=right><span id=Sender>" +item.Sender + "</span><span id=SendDate style=color:gray>" + item.SendDate +
			"</div><div width=40 id=Content style='inline-block;border:1px solid #e0e0e0;padding:8px;background-color:lime;'>" + TranMsg(item.Content) + "</div></div>";
	else
		tag += "<div style='float:left;width:40px;'>" + getImg(userItem.Photo, 40) + "</div><div style='float:left;max-width:90%;padding-left:6px'>" +
			"<div><span id=Sender>" +item.Sender + "</span><span id=SendDate style=color:gray>" + item.SendDate +
			"</div><div width=40 id=Content style='inline-block;border:1px solid #e0e0e0;padding:8px;'>" + TranMsg(item.Content) + "</div></div>";
	return tag + "</div>";
}

function TranMsg(msg)
{
	return msg.replace(/\n/g, "<br>");
}
function RealMsg(cmd, text)
{
		switch (cmd)
		{
		case "ShowMsg":
			var sel1 = book.Tree.getTreeItem();
			if (sel1 == undefined)
				return false;
			var ss = text.split("|");
			if (ss[3] != sel1.item)
				return false;
			var items = book.Page.getData();
			for (var x = items.length - 1; x >= 0; x--)
			{
				if ((items[x].ID == 0) && (items[x].Sender == ss[2]) && (items[x].Receiver == ss[3]) && (items[x].Content == ss[5]))
					return true;
				if (items[x].SendDate < ss[1])
					break;
			}
			book.Page.insertRow({ID:ss[0], Content:ss[5], Sender:ss[2], Receiver:ss[3], Mark:ss[4], SendDate:ss[1]}, -1);
			return true;
		default:
			return false;
		}
}

function SendMsg()
{
	var oSocket = book.getChild("oSocket");
	var sel0 = book.Filter.getsel(0);
	if (sel0 == undefined)
		return;
	var sel1 = book.Tree.getTreeItem();
	if (sel1 == undefined)
		return;
	var msg = $("#MsgText").val();
	if (msg == "")
		return;
	oSocket.send("SendMsg", sel1.item + "|" + msg);
	$("#MsgText").val("");
	book.Page.insertRow({ID:0, Content:msg, Sender:sys.CName, Receiver:sel1.item, Mark:0, SendDate:$.jcom.GetDateTimeString(new Date(), 2) + "*"}, -1);
}

function GetMsgListOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
	for (var x = 0; x < items.length; x++)
		items[x].img = getImg(items[x].Photo, 24);
	book.Tree.setdata(items);
}

function GetMyFriendOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
		TransMyFriendData(items);
	book.Tree.setdata(items);
}

function TransMyFriendData(items)
{
	for (var x = 0; x < items.length; x++)
	{
		if (items[x].Friend == "")
		{
			items[x].item = items[x].GroupName;
			TransMyFriendData(items[x].child);
		}
		else
		{
			items[x].item = items[x].Friend;
			items[x].img = getImg(items[x].Photo, 24);
		}
	}
}

function GetMyGroupOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
	for (var x = 0; x < items.length; x++)
	{
		items[x].item = items[x].RoomName;
		items[x].img = "../pic/forum.gif";
	}
	book.Tree.setdata(items);
}

function GetDeptOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
		TransDeptData(items)
	book.Tree.setdata(items);
}

function TransDeptData(items)
{
	for (var x = 0; x < items.length; x++)
	{
		if ((items[x].child == undefined) || (items[x].child.length == 0))
			items[x].child = null;
		else
			TransDeptData(items[x].child);
		items[x].img = "../pic/stuff.gif";
		items[x].item = items[x].DeptName;
	}
}

function LoadDeptMember(item, odiv)
{
	var fun = function (data)
	{
		item.child = $.jcom.eval(data);
		TransDeptMember(item.child);
		book.Tree.loadnodeok(item, odiv);
		return;
		
	};
	if (item.DeptNo == 0)
	{
		item.child = [];
		loadnodeok(item, div);
		return;
	}
	$.get(location.pathname, {LoadDeptMember:1, DeptNo:item.DeptNo}, fun);
}

function getImg(Photo, height)
{
	if (Photo == 0)
		return "<img src=../pic/366.jpg style=height:" +height + "px>";
	else
		return "<img src=../com/down.jsp?AffixID=" + Photo + " style=height:" + height + "px>";
}

function ClickFilter(obj, item)
{
	typeItem = item;
	switch (item.item)
	{
	case "我的消息":
	 	$.get(location.pathname, {LoadMsgList:1}, GetMsgListOK);
	 	break;
	case "我的好友":
	 	$.get("../fvs/UserFriends_view.jsp", {GetTreeData:1, nFormat:0}, GetMyFriendOK);
		break;
	case "我的群":
	 	$.get("../fvs/ChatRoom_view.jsp", {GetTreeData:1, nFormat:0}, GetMyGroupOK);
		break;
	case "组织结构":
	 	$.get("../fvs/SeekDept.jsp", {GetTreeData:1, nFormat:0}, GetDeptOK);
		break;
	}
	$("#UserTitle").html(item.item);
}

function ClickTree(obj, e)
{

	book.Tree.select(obj);
	userItem = book.Tree.getTreeItem();
	if (typeItem.item == "我的好友")
	{
		if (userItem.Friend == "")
		{
			book.Tree.expand(obj);
			return;
		}
	}
	else if (typeItem.item == "组织结构")
	{
		if (typeof userItem.child == "object")
		{
			book.Tree.expand(obj);
			return;
		}
	}
	else if (typeItem.item == "我的群")
	{
		book.Page.TitleBar("<h2 align=center>群对话：" + obj.innerText + "</h2><div id=GroupUsersList></div>");
		$.get(location.pathname, {LoadGroupMember:1, GroupID:userItem.ID, Dept:userItem.Dept}, LoadGroupMemberOK);
		book.groupUsers.setdomobj($("#GroupUsersList")[0]);
		book.Page.init("../fvs/RealMsg_view.jsp", {TalkMan:obj.innerText});
		return;
	}
	book.groupUsers.setdomobj();
	book.Page.TitleBar("<h2 align=center>对话：" + obj.innerText + "</h2>");
	book.Page.init("../fvs/RealMsg_view.jsp", {TalkMan:obj.innerText});
}

function LoadGroupMemberOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
	TransDeptMember(items);
	book.groupUsers.reload(items);
}

function TransDeptMember(items)
{
	for (var x = 0; x < items.length; x++)
	{
		items[x].item = items[x].CName;
		items[x].img = getImg(items[x].Photo, 24);
	}
}

function ClickPage(td, e)
{
}
//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
