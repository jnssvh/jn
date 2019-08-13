<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="sysDept";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='sysDept' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>部门管理</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"sysDept", Role:<%=Purview%>};
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
		{item:"查询", img:"", action:SeekDept, info:"", Attrib:1, Param:1},
		{item:"筛选", img:"", action:FilterDept, info:"", Attrib:1, Param:1},
		{item:"新增部门", img:"", action:NewDept, info:"", Attrib:2, Param:1},
		{item:"编辑部门", img:"", action:EditDept, info:"", Attrib:4, Param:1},
		{item:"删除部门", img:"", action:DelDept, info:"", Attrib:16, Param:1}
			];
	book.setTool(Tools);
//@@##588:客户端加载时(归档用注释,切勿删改)
/*	var o = book.setDocTop("加载中...", "Filter", "");
 	book.deptFilter = new DeptFilter(o, {ID:0});
	book.deptFilter.onclick = ClickDept;
	book.setPageObj(book.tFilter);
	book.onLink = LinkAddParam;
	book.deptDBFun = new $.jcom.DBFun("../fvs/EditDept.jsp", {title:["新增部门","编辑部门"], width:400, height:260, mask:50, itemstyle:"font:normal normal normal 16px 微软雅黑"});
	book.deptDBFun.onRecordChange = ReloadDept;
*/
ClickDept();
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##589:客户端自定义代码(归档用注释,切勿删改)
function LinkAddParam(item, url)
{
	var id = book.Page.getSelItemKeyValue();
	if (id == undefined)
		return url;
	else
		return url + "?ID=" + id;
}

function ClickDept(obj, item)
{
	if (book.Page == undefined)
	{
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/ManageDept.jsp", {formitemstyle:"font:normal normal normal 16px 微软雅黑", 
			formvalstyle:"width:400px"}, {SeekKey:"", SeekParam:""}, {gridstyle:4, resizeflag:0});
	}
	else
		book.Page.Seek(item.ID, "Dept.ID");	
}
function ReloadDept(nType)
{
	book.deptFilter.refresh();
}

function NewDept(obj, item)
{
//增加一条记录
	book.Page.NewItem();

}

function EditDept(obj, item)	//编辑班次
{
//编辑当前记录
	book.Page.EditItem();

}



function DelDept(obj, item)	//删除班次
{
//删除当前记录
	book.Page.DeleteItem();

}


function SeekDept(obj, item)	//查询
{
//
	book.Page.Seek();
}



function FilterDept(obj, item)	//筛选
{
//
	book.Page.Filter();
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
