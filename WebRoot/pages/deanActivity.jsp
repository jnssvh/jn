<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanActivity";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanActivity' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>教学活动</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_265" type="text/css">
body{
background: #e9ebee url(../res/skin/p2.jpg) no-repeat fixed;
background-size:100% 100%;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanActivity", Role:<%=Purview%>};
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
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_Activity_list.jsp",{}, {}, {gridstyle:4, resizeflag:0});
	var Tools = [
		{item:"新增活动", img:"", action:NewActivity, info:"", Attrib:0, Param:1},
		{item:"编辑活动", img:"", action:EditActivity, info:"", Attrib:0, Param:1},
		{item:"删除活动", img:"", action:DelActivity, info:"", Attrib:0, Param:1},
		{item:"页面编辑", img:"", action:PageEdit, info:"", Attrib:0, Param:1},
		{item:"查询", img:"", action:Seek, info:"", Attrib:0, Param:1},
		{item:"筛选", img:"", action:Filter, info:"", Attrib:0, Param:1},
		{item:"刷新", img:"", action:RefreshPage, info:"", Attrib:0, Param:1}
			];
	book.setTool(Tools);
//@@##83:客户端加载时(归档用注释,切勿删改)
//
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##84:客户端自定义代码(归档用注释,切勿删改)
function Seek(obj, item)	//查询
{
//
	book.Page.Seek();
}



function Filter(obj, item)	//筛选
{
//
	book.Page.Filter();
}



function PageEdit(obj, item)	//维护
{
//
  book.Page.toggleEditMode(book);
}



function NewActivity(obj, item)	//新增
{
//增加一条记录
	book.Page.NewItem();

}



function EditActivity(obj, item)	//编辑
{
//编辑当前记录
	book.Page.EditItem();

}



function DelActivity(obj, item)	//删除
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
