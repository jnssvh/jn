<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
// ServerChapterPageStartCode
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	user = new SysUser();
	int result = user.initWebUser(jdb, cookie);
	if (result != 1)
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
		String EName = WebChar.requestStr(request, "UserName");
		Cookie [] ck = new Cookie[2];
		ck[0] = new Cookie("loginname", EName);
		ck[1] = new Cookie("loginpassword", WebChar.requestStr(request, "Password"));
		result = user.initWebUser(jdb, ck);
		if (result != 1)
		{
			jdb.closeDBCon();
			response.sendRedirect("../bia/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	String CodeName="myMsg";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='myMsg' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##627:��������������(�鵵��ע��,����ɾ��)
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
				"left join Member on ChatRoomUsers.CName=Member.CName where RoomID=" + WebChar.RequestInt(request, "GroupID")));
		jdb.closeDBCon();
		return;
	}
	



//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>�ҵ���Ϣ</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2019-4-28 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"myMsg", Role:<%=Purview%>};
var env = {com:"../com", proj:"../bia", fvs:"../biafvs", flow:"../biaflow", page:"../biapages"};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	
	var Tools = [
		{item:"��ѯ", img:"", action:SeekMsg, info:"�ҵ���Ϣ.������Ϣ", Attrib:1, Param:1},
		{item:"�½�����", img:"", action:NewMyGrp, info:"�ҵĺ���.�½�����", Attrib:1, Param:1},
		{item:"�༭����", img:"", action:EditMyGrp, info:"�ҵĺ���.�༭����", Attrib:1, Param:1},
		{item:"ɾ������", img:"", action:DelMyGrp, info:"�ҵĺ���.ɾ������", Attrib:1, Param:1},
		{item:"", img:"", action:null, info:"�ҵĺ���.�ָ���", Attrib:1, Param:1},
		{item:"�½�����", img:"", action:NewFriend, info:"�ҵĺ���.�½�����", Attrib:1, Param:1},
		{item:"�༭����", img:"", action:EditFriend, info:"�ҵĺ���.�༭����", Attrib:1, Param:1},
		{item:"ɾ������", img:"", action:DelFriend, info:"�ҵĺ���.ɾ������", Attrib:1, Param:1},
		{item:"�½�Ⱥ", img:"", action:NewGrp, info:"�ҵ�Ⱥ.�½�Ⱥ", Attrib:2, Param:1},
		{item:"�༭Ⱥ", img:"", action:EditGrp, info:"�ҵ�Ⱥ.�༭Ⱥ", Attrib:2, Param:1},
		{item:"ɾ��Ⱥ", img:"", action:DelGrp, info:"�ҵ�Ⱥ.ɾ��Ⱥ", Attrib:2, Param:1},
		{item:"", img:"", action:null, info:"�ҵ�Ⱥ.�ָ���", Attrib:2, Param:1},
		{item:"����Ⱥ��Ա", img:"", action:NewGrpMember, info:"�ҵ�Ⱥ.����Ⱥ��Ա", Attrib:2, Param:1},
		{item:"�༭Ⱥ��Ա", img:"", action:EditGrpMember, info:"�ҵ�Ⱥ.�༭Ⱥ��Ա", Attrib:2, Param:1},
		{item:"ɾ��Ⱥ��Ա", img:"", action:DelGrpMember, info:"�ҵ�Ⱥ.ɾ��Ⱥ��Ա", Attrib:2, Param:1},
		{item:"��������Ⱥ", img:"", action:NewDptGrp, info:"��֯�ṹ.��������Ⱥ", Attrib:2, Param:1},
		{item:"��Ϊ����", img:"", action:AddMyFriend, info:"��֯�ṹ.��Ϊ����", Attrib:1, Param:1}
			];
	book.setTool(Tools);
//@@##628:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
	toolDef = Tools;
	var o = book.setDocTop("������...", "Filter", "");
 	book.Filter = new $.jcom.Cascade(o, [{item:"�ҵ���Ϣ"},{item:"�ҵĺ���"},{item:"�ҵ�Ⱥ"},{item:"��֯�ṹ"}], {title:["����"]});
	book.Filter.onclick = ClickFilter;
	var oo = book.Filter.AddUserLegend("��ϵ��", {TitleID: "UserTitle", divID:"UserTree"});
//	$(o).after("<div id=FilterTree style='border:1px solid gray;width:100%;'></div>");
	book.Tree = new  $.jcom.TreeView(oo[0], []);
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "", {}, {}, {headstyle:3, gridstyle:3, footstyle:4, resizeflag:0, titlebar:"<h2 align=center>�Ի�</h2>"});
	book.groupUsers = new $.jcom.Cascade(0,[], {title:["Ⱥ��Ա"]});
	book.groupUsers.ondblclick = DblClickGroupUser;
	book.Filter.SkipPage(1, true);
	book.setPageObj(book.Filter);
	book.setDocBottom("<textarea id=MsgText placeholder=����Ҫ���͵���Ϣ style='height:100px;border:1px solid gray;width:100%;overflow:visible'></text" + "area>" +
		"<div align=right style=float:right><input id=SubmitButton type=button style='width:100px;font:normal normal normal 16px ΢���ź�' value=����></div>", "Footbar");
	$("#SubmitButton").on("click", SendMsg);
	book.Page.clickRow = ClickPage;
	book.Tree.click = ClickTree;
	book.Tree.loadnode = LoadDeptMember;
	book.onRealMsg = RealMsg;
	book.Page.makeThumb = MakeThumb;


//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##629:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//
var toolDef, typeItem, userItem;
function MakeThumb(line, hint, index, item)
{
	var tag = "<div style='margin: 0px; padding: 4px;width:100%;overflow:hidden' name=thumbdiv node=" + index + ">"
	if (item.Sender == sys.CName)
		tag += "<div style='float:right;width:40px;'>" + $.jcom.RealSocket.prototype.getImg(sys.PhotoID, 40) + "</div><div style='float:right;max-width:90%;padding-right:12px;'>" +
			"<div align=right><span id=Sender>" +item.Sender + "</span><span id=SendDate style=color:gray>" + item.SendDate +
			"</div><div width=40 id=Content style='inline-block;border:1px solid #e0e0e0;padding:8px;background-color:lime;'>" + TranMsg(item.Content) + "</div></div>";
	else
	{
		if (userItem.RoomType == undefined)
			var img = $.jcom.RealSocket.prototype.getImg(userItem.Photo, 40);
		else
			var img = $.jcom.RealSocket.prototype.getImg(item.Photo, 40);
		tag += "<div style='float:left;width:40px;'>" + img + "</div><div style='float:left;max-width:90%;padding-left:6px'>" +
			"<div><span id=Sender>" +item.Sender + "</span><span id=SendDate style=color:gray>" + item.SendDate +
			"</div><div width=40 id=Content style='inline-block;border:1px solid #e0e0e0;padding:8px;'>" + TranMsg(item.Content) + "</div></div>";
	}
	return tag + "</div>";
}

function TranMsg(msg)
{
	return msg.replace(/\n/g, "<br>");
}
function RealMsg(cmd, text)
{
	var oSocket = book.getChild("oSocket");
	var msg = oSocket.getMsgObj(text);
	switch (cmd)
	{
	case "SendMsg":
		var sel1 = book.Tree.getTreeItem();
		if (sel1 == undefined)
			return false;
		if (typeof msg != "object")
			return false;
		if (msg.Receiver != sel1.item)
			return false;
		var items = book.Page.getData();
		for (var x = items.length - 1; x >= 0; x--)
		{
			if ((items[x].ID == 0) && (items[x].Sender == msg.Sender) && (items[x].Receiver == msg.Receiver) && (items[x].Content == msg.Content))
				return false;//true;
			if (items[x].SendDate < msg.SendDate)
				break;
		}
		book.Page.insertRow(msg, -1);
		return true;
	case "RoomMsg":
		break;
	default:
		return false;
	}
}

function SendMsg()
{
	if (userItem == undefined)
		return;
	var msg = $("#MsgText").val();
	if (msg == "")
		return;
	var oSocket = book.getChild("oSocket");
	if (userItem.RoomType == undefined)
		oSocket.send("SendMsg", userItem.item + "|" + msg);
	else
		oSocket.send("RoomMsg", userItem.ID + "|" + msg);
	$("#MsgText").val("");
	book.Page.insertRow({ID:0, Content:msg, Sender:sys.CName, Receiver:userItem.item, Mark:0, SendDate:$.jcom.GetDateTimeString(new Date(), 2) + "*"}, -1);
}

function GetMsgListOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
	for (var x = 0; x < items.length; x++)
		items[x].img = $.jcom.RealSocket.prototype.getImg(items[x].Photo, 24);
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
			items[x].img = $.jcom.RealSocket.prototype.getImg(items[x].Photo, 24);
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
	ToolSwitch(item);
	switch (item.item)
	{
	case "�ҵ���Ϣ":
	 	$.get(location.pathname, {LoadMsgList:1}, GetMsgListOK);
	 	break;
	case "�ҵĺ���":
	 	$.get("../fvs/UserFriends_view.jsp", {GetTreeData:1, nFormat:0}, GetMyFriendOK);
		break;
	case "�ҵ�Ⱥ":
	 	$.get("../fvs/ChatRoom_view.jsp", {GetTreeData:1, nFormat:0}, GetMyGroupOK);
		break;
	case "��֯�ṹ":
	 	$.get("../fvs/SeekDept.jsp", {GetTreeData:1, nFormat:0}, GetDeptOK);
		break;
	}
	$("#UserTitle").html(item.item);
}

function ToolSwitch(item)
{
	var newdef = [];
	for (var x = 0; x < toolDef.length; x++)
	{
		if (toolDef[x].info.indexOf(item.item + ".") >= 0)
		{
			newdef[newdef.length] = toolDef[x];
		}
	}
	var toolObj = book.getChild("toolObj");
	toolObj.reload(newdef);
}

function ClickTree(obj, e)
{

	book.Tree.select(obj);
	var item = book.Tree.getTreeItem();
	if (typeItem.item == "�ҵĺ���")
	{
		if (item.Friend == "")
		{
			book.Tree.expand(obj);
			return;
		}
	}
	if (typeItem.item == "��֯�ṹ")
	{
		if (typeof item.child == "object")
		{
			book.Tree.expand(obj);
			return;
		}
	}
	userItem = item;
	if (typeItem.item == "�ҵ�Ⱥ")
	{
		book.Page.TitleBar("<h2 align=center>Ⱥ�Ի���" + obj.innerText + "</h2><div id=GroupUsersList></div>");
		$.get(location.pathname, {LoadGroupMember:1, GroupID:userItem.ID, Dept:userItem.Dept}, LoadGroupMemberOK);
		book.groupUsers.setdomobj($("#GroupUsersList")[0]);
		book.Page.init("../fvs/ChatRoomHis_view.jsp", {RoomID:userItem.ID});
		return;
	}
	StartDialog(userItem);
}

function StartDialog(item)
{
	book.groupUsers.setdomobj();
	book.Page.TitleBar("<h2 align=center>�Ի���" + item.item + "</h2>");
	book.Page.init("../fvs/RealMsg_view.jsp", {TalkMan:item.item});

}

function LoadGroupMemberOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
	TransDeptMember(items);
	book.groupUsers.reload(items);
}

function DblClickGroupUser(obj, item)
{
	if (item == undefined)
		return;
	userItem = item;
	StartDialog(item);
}

function TransDeptMember(items)
{
	for (var x = 0; x < items.length; x++)
	{
		items[x].item = items[x].CName;
		items[x].img = $.jcom.RealSocket.prototype.getImg(items[x].Photo, 24);
	}
}

function ClickPage(td, e)
{
}


function SeekMsg(obj, item)	//��ѯ
{
//�ҵ���Ϣ.������Ϣ

}



function NewMyGrp(obj, item)	//�½�����
{
//�ҵĺ���.�½�����

}



function EditMyGrp(obj, item)	//�༭����
{
//�ҵĺ���.�༭����

}



function DelMyGrp(obj, item)	//ɾ������
{
//�ҵĺ���.ɾ������

}



function NewFriend(obj, item)	//�½�����
{
//�ҵĺ���.�½�����

}



function EditFriend(obj, item)	//�༭����
{
//�ҵĺ���.�༭����

}



function DelFriend(obj, item)	//ɾ������
{
//�ҵĺ���.ɾ������

}



function NewGrp(obj, item)	//�½�Ⱥ
{
//�ҵ�Ⱥ.�½�Ⱥ

}



function EditGrp(obj, item)	//�༭Ⱥ
{
//�ҵ�Ⱥ.�༭Ⱥ

}



function DelGrp(obj, item)	//ɾ��Ⱥ
{
//�ҵ�Ⱥ.ɾ��Ⱥ

}



function NewGrpMember(obj, item)	//����Ⱥ��Ա
{
//�ҵ�Ⱥ.����Ⱥ��Ա

}



function EditGrpMember(obj, item)	//�༭Ⱥ��Ա
{
//�ҵ�Ⱥ.�༭Ⱥ��Ա

}



function DelGrpMember(obj, item)	//ɾ��Ⱥ��Ա
{
//�ҵ�Ⱥ.ɾ��Ⱥ��Ա

}



function NewDptGrp(obj, item)	//��������Ⱥ
{
//��֯�ṹ.��������Ⱥ

}



function AddMyFriend(obj, item)	//��Ϊ����
{
//��֯�ṹ.��Ϊ����

}




//(�鵵��ע��,����ɾ��)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
