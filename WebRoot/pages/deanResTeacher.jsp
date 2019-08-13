<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanResTeacher";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanResTeacher' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>师资库</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-8-29 -->
<style id="css_263" type="text/css">
.pcbody{
background: #e9ebee url(../res/skin/dx3.jpg) no-repeat fixed;
background-size:100% 100%;
}
</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanResTeacher", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:2123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	123
	var Tools = [
		{item:"查询", img:"#59111", action:SeekTeacher, info:"123", Attrib:1},
		{item:"筛选", img:"#59188", action:FilterTeacher, info:"多条件筛选", Attrib:1},
		{item:"新增", img:"#59356", action:NewRecordPage, info:"增加一条记录", Attrib:2},
		{item:"编辑", img:"#59357", action:EditRecordPage, info:"编辑当前记录", Attrib:2},
		{item:"删除", img:"#58996", action:DelRecordPage, info:"删除当前记录", Attrib:2},
		{item:"页面编辑", img:"#59341", action:EditTeacher, info:"对页面多记录进行编辑", Attrib:4},
		{item:"刷新", img:"#58976", action:RefreshPage, info:"重新加载", Attrib:1}
			];
	book.setTool(Tools);
//@@##77:客户端加载时(归档用注释,切勿删改)
//client load
	book.Page = new $.jcom.DBGrid($("#Page")[0], "../fvs/CPB_Teacher_list.jsp",{}, {}, {gridstyle: 4, resizeflag:0});
//	book.setPageObj(grid);
//	grid.makeThumb = makeThumb;

//(归档用注释,切勿删改)ClientStartCode End##@@
}
//@@##78:客户端自定义代码(归档用注释,切勿删改)
//user js
function makeThumb(line, hint, index, item)
{
	return "<div name=thumbdiv style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;' node=" + index + ">" +
		"<span style='font:normal normal bolder 12pt 微软雅黑;width:80px;display:inline-block;'>" + item.Teacher_name + "</span>" +
		"<span style='width:40px;display:inline-block;'>" + item.nType_ex + "</span>" +
		"<span style='font:normal normal bolder 12pt 楷体;width:240px;display:inline-block;'>" + item.DeptName + "</span><span>" + item.Duty + "</span>" +
		"<span style=width:80px;display:inline-block;>" + item.PhoneNo + "</span>" +
		"<span style=width:80px;display:inline-block;>" + item.Mobile + "</span>" +
		"<span style=width:80px;display:inline-block;>" + item.EMail + "</span>" +
		"</div>";
}

function SeekTeacher(obj, item)	//查询
{
//
	book.Page.Seek();
}



function FilterTeacher(obj, item)	//筛选
{
//
	book.Page.Filter();
}



function EditTeacher(obj, item)	//维护
{
//
	book.Page.toggleEditMode(book);
}



function NewRecordPage(obj, item)	//新增
{
//增加一条记录
	book.Page.NewItem();

}



function EditRecordPage(obj, item)	//编辑
{
//编辑当前记录
	book.Page.EditItem();

}



function DelRecordPage(obj, item)	//删除
{
//删除当前记录
	book.Page.DeleteItem();

}



function RefreshPage(obj, item)	//刷新
{
//重新加载
	book.Page.ReloadGrid();

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
