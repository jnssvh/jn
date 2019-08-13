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
	{//如果cookie丢失，就从命令行取出账户，重设cookie
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
//@@##98:服务器启动代码(归档用注释,切勿删改)
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

//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>角色权限</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2019-4-28 -->
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
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	var Tools = [
		{item:"新增角色", img:"", action:NewGroup, info:"", Attrib:2, Param:1},
		{item:"修改角色", img:"", action:EditGroup, info:"", Attrib:2, Param:1},
		{item:"删除角色", img:"", action:DelGroup, info:"", Attrib:2, Param:1},
		{item:"新增成员", img:"", action:NewMember, info:"", Attrib:2, Param:1},
		{item:"删除成员", img:"", action:DelMember, info:"", Attrib:2, Param:1},
		{item:"保存设置", img:"", action:SaveRight, info:"", Attrib:2, Param:1}
			];
	book.setTool(Tools);
//@@##99:客户端加载时(归档用注释,切勿删改)
//
	book.Page = new GroupRightPage($("#Page")[0], Chapters);
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##100:客户端自定义代码(归档用注释,切勿删改)
//
function GroupRightPage(domobj, data)
{
	var grid, cascade, dbfun;
	function init()
	{
		var h = [{FieldName:"ID", TitleName:"ID",nWidth:40,nShowMode:6},
		 		{FieldName:"nOrder", TitleName:"顺序号", nWidth:40, nShowMode:6},
		 		{FieldName:"Role", TitleName:"角色", nWidth:80, nShowMode:1, Quote:"(0:无权限,1:读者,2:作者,4:编辑,8:总编,16:管理)"},
		 		{FieldName:"Code", TitleName:"代号", nWidth:80, nShowMode:6},
		 		{FieldName:"item", TitleName:"名称", nWidth:260, nShowMode:9, bTag:1, colstyle:"font:normal normal normal 15px 微软雅黑"},
		 		{FieldName:"img", TitleName:"图示", nWidth:240, nShowMode:6},
		 		{FieldName:"Info", TitleName:"说明", nWidth:280, nShowMode:1},
		 		{FieldName:"ParentNode", TitleName:"父节点", nWidth:180, nShowMode:6},
		 		{FieldName:"nType", TitleName:"类型", nWidth:80, nShowMode:6, Quote:"(1:根系统,2:主系统,3:功能,4:索引,5:次系统)"},
		 		{FieldName:"Status", TitleName:"状态", nWidth:40, nShowMode:6},
		 		{FieldName:"Dir", TitleName:"路径", nWidth:180, nShowMode:6},
		 		{FieldName:"Attrib", TitleName:"属性", nWidth:80, nShowMode:6}];
//		 	PrepareData(Chapters);
		 	grid = new $.jcom.GridView(domobj, h, data,{}, {gridstyle:1, initDepth:5, resizeflag:0});
		 	if (sys.Role > 1)
			 	grid.attachEditor("Role");
//		 	var o = grid.TitleBar("Waiting...");
			var o = book.setDocTop("加载中...", "Filter", "");
		 	cascade = new $.jcom.Cascade(o, [], {title:["权限分组", "分组成员"]});
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
			return alert("请先选择一个分组");
		var node = $(obj).attr("node");
		var ss = node.split(",");
		if (ss.length > 1)
			return alert("请先选择分组");
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
			return alert("请选择分组先");
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

function NewGroup(obj, item)	//新增分组
{
//
	book.Page.NewGroup();
}

function EditGroup(obj, item)	//修改分组
{
//
	book.Page.EditGroup();
}


function DelGroup(obj, item)	//删除分组
{
//
	book.Page.DelGroup();

}



function NewMember(obj, item)	//新增成员
{
//

}



function DelMember(obj, item)	//删除成员
{
//

}



function SaveRight(obj, item)	//保存设置
{
//
	book.Page.SaveRight();
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
