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
	String CodeName="SysRight";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='SysRight' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##98:��������������(�鵵��ע��,����ɾ��)
//
		if (WebChar.RequestInt(request, "SaveRight") == 1)
		{
			int cnt = 0;
			int GroupID = WebChar.RequestInt(request, "GroupID");
			String tmp[] = request.getParameterValues("ObjID");
			if (tmp != null)
				cnt = tmp.length;
			for (int x = 0; x < cnt; x++)
			{
				int ObjID = WebChar.ToInt(WebChar.RequestForms(request, "ObjID", x));
				int Role = WebChar.ToInt(WebChar.RequestForms(request, "Role", x));
				String Code = WebChar.RequestForms(request, "Code", x);

				int ID = WebChar.ToInt(jdb.GetTableValue(0, "ObjRight", "ID", "GroupID", GroupID + " and ObjType=10 and ObjID=" + ObjID));
				if (ID > 0)
				{
					String sql = "update ObjRight set Purview=" + Role + ", ObjParam='" + Code + "', SubmitMan='" + user.CMemberName + "', SubmitTime='" + VB.Now() + "' where ID=" + ID;
					jdb.ExecuteSQL(0, sql);
				}
				else if (Role > 0)
				{
				 	String sql = "insert into ObjRight (ObjType, ObjParam, ObjID, GroupID, Purview, SubmitMan, SubmitTime) values(10,'" + Code + "'," + ObjID + "," + 
							GroupID + "," + Role + ",'" + user.CMemberName + "','" + VB.Now() + "')";
					jdb.ExecuteSQL(0, sql);
					
				}
			}

			out.print("OK");
			jdb.closeDBCon();
			return;
		}

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>��ɫȨ��</title>
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"SysRight", Role:<%=Purview%>};
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
		{item:"������ɫ", img:"", action:NewGroup, info:"", Attrib:2, Param:1},
		{item:"�޸Ľ�ɫ", img:"", action:EditGroup, info:"", Attrib:2, Param:1},
		{item:"ɾ����ɫ", img:"", action:DelGroup, info:"", Attrib:2, Param:1},
		{item:"������Ա", img:"", action:NewMember, info:"", Attrib:2, Param:1},
		{item:"ɾ����Ա", img:"", action:DelMember, info:"", Attrib:2, Param:1},
		{item:"��������", img:"", action:SaveRight, info:"", Attrib:2, Param:1}
			];
	book.setTool(Tools);
//@@##99:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
	book.Page = new GroupRightPage($("#Page")[0], Chapters);
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##100:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//
function GroupRightPage(domobj, data)
{
	var grid, cascade, dbfun;
	function init()
	{
		var h = [{FieldName:"ID", TitleName:"ID",nWidth:40,nShowMode:6},
		 		{FieldName:"nOrder", TitleName:"˳���", nWidth:40, nShowMode:6},
		 		{FieldName:"Role", TitleName:"��ɫ", nWidth:80, nShowMode:1, Quote:"(0:��Ȩ��,1:����,2:����,4:�༭,8:�ܱ�,16:����)"},
		 		{FieldName:"Code", TitleName:"����", nWidth:80, nShowMode:6},
		 		{FieldName:"item", TitleName:"����", nWidth:260, nShowMode:9, bTag:1, colstyle:"font:normal normal normal 15px ΢���ź�"},
		 		{FieldName:"img", TitleName:"ͼʾ", nWidth:240, nShowMode:6},
		 		{FieldName:"Info", TitleName:"˵��", nWidth:280, nShowMode:1},
		 		{FieldName:"ParentNode", TitleName:"���ڵ�", nWidth:180, nShowMode:6},
		 		{FieldName:"nType", TitleName:"����", nWidth:80, nShowMode:6, Quote:"(1:��ϵͳ,2:��ϵͳ,3:����,4:����,5:��ϵͳ)"},
		 		{FieldName:"Status", TitleName:"״̬", nWidth:40, nShowMode:6},
		 		{FieldName:"Dir", TitleName:"·��", nWidth:180, nShowMode:6},
		 		{FieldName:"Attrib", TitleName:"����", nWidth:80, nShowMode:6}];
//		 	PrepareData(Chapters);
		 	grid = new $.jcom.GridView(domobj, h, data,{}, {gridstyle:1, initDepth:5, resizeflag:0});
		 	if (sys.Role > 1)
			 	grid.attachEditor("Role");
//		 	var o = grid.TitleBar("Waiting...");
			var o = book.setDocTop("������...", "Filter", "");
		 	cascade = new $.jcom.Cascade(o, [], {title:["Ȩ�޷���", "�����Ա"]});
		 	cascade.onclick = ClickGroup;
		 	var jsp =env.fvs + "/WorkGroup_list_select.jsp"; 
		 	$.get(jsp, {GetTreeData:1, nFormat: 0}, GetGroupOK);
			dbfun = new $.jcom.DBFun(jsp);
	}

	function GetGroupOK(data)
	{
		var json = $.jcom.eval(data);
		for (var x = 0; x < json.length; x++)
		{
			var ss = json[x].Members.split(",");
			json[x].child = [];
			for (var y = 0; y < ss.length; y++)
				json[x].child[y] = {item:ss[y]};
			json[x].item = json[x].GroupName;
		}
		cascade.reload(json);
	}

	function ClickGroup(obj, item)
	{
		if (item.ID != undefined)
		 	$.get(env.fvs + "/ObjRight_view.jsp", {GetGridData:1, ObjType:10, GroupID: item.ID}, GroupRightOK);
	}
	
	function GroupRightOK(result)
	{
		var json = $.jcom.eval(result);
		PrepareData(data, json.Data);
		grid.reload();
	}
	
	function PrepareData(items, grs)
	{
		for (var x = 0; x < items.length; x++)
		{
			items[x].Role = 0;
			for (var y = 0; y < grs.length; y ++)
			{
				if (items[x].ID == grs[y].ObjID)
				{
					items[x].Role = grs[y].Purview;
					break;
				}
			}
			if (typeof items[x].child == "object")
				PrepareData(items[x].child, grs);
		}
	}
	
	this.NewGroup = function()
	{
		dbfun.NewRecord({EditAction:"WorkGroup_form"});
	};
	
	this.EditGroup = function ()
	{
		var id = getGroupid();
		if (id != undefined)
			dbfun.EditRecord(id, {EditAction:"WorkGroup_form"});
	};
	
	function getGroupid()
	{
		var obj = cascade.getsel();
		if (obj == undefined)
			return alert("����ѡ��һ������");
		var node = $(obj).attr("node");
		var ss = node.split(",");
		if (ss.length > 1)
			return alert("����ѡ�����");
		var items = cascade.getdata();
		return items[parseInt(node)].ID;
	}
	
	function GetPostData(data)
	{
		
		if (data == undefined)
			var data = grid.getData();
		var text = "";
		for (var x = 0; x < data.length; x++)
		{
			text += "&ObjID=" + data[x].ID + "&Code=" + data[x].Code + "&Role=" + data[x].Role;
			if ((typeof data[x].child == "object") && (data[x].child != null))
				text += GetPostData(data[x].child);
		}
		
		return text;
	}
	
	this.SaveRight = function ()
	{
		var id = getGroupid();
		if (id == undefined)
			return alert("��ѡ�������");
		var data = GetPostData();
		$.jcom.Ajax(location.pathname + "?SaveRight=1&GroupID=" + id, true, data, SaveRightOK);
	};
	
	function SaveRightOK(data)
	{
		alert(data);
	}
	
	this.DelGroup = function ()
	{
		var id = getGroupid();
		if (id != undefined)
			dbfun.DelRecord(id, {EditAction:"WorkGroup_form"});
	};
	
	init();
}

function NewGroup(obj, item)	//��������
{
//
	book.Page.NewGroup();
}

function EditGroup(obj, item)	//�޸ķ���
{
//
	book.Page.EditGroup();
}


function DelGroup(obj, item)	//ɾ������
{
//
	book.Page.DelGroup();

}



function NewMember(obj, item)	//������Ա
{
//

}



function DelMember(obj, item)	//ɾ����Ա
{
//

}



function SaveRight(obj, item)	//��������
{
//
	book.Page.SaveRight();
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
