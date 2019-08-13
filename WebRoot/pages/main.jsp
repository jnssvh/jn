<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
//@@##50:服务器用户自定义声明代码(归档用注释,切勿删改)
//defined

//(归档用注释,切勿删改)服务器用户自定义声明代码 End##@@

%>
<%
	String CodeName="main";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='main' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##51:服务器启动代码(归档用注释,切勿删改)
//server on load

//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>党校管理系统</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2019-4-24 -->
<style id="css_147" type="text/css">
.pcbody{
background: #e9ebee url(../res/skin/dx2.jpg) no-repeat fixed;
background-size:100% 100%;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"main", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:"1122"};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
//@@##53:客户端加载时(归档用注释,切勿删改)
//on load after
//var tree = new $.jcom.TreeView($("#Page")[0], Chapters, {initDepth:5});
//test test test
	book.Page = new $.jcom.ChapterTree($("#Page")[0],  book.getItem().child);


//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##54:客户端自定义代码(归档用注释,切勿删改)
//test



////sdfsdfsdfsd

//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
<div id=HelpBox style=display:none><P>1、本系统所有的页面均以文档的形式呈现，页眉处是本页面的主标题和副标题，点击或按下主标题或副标题，会出现其它章节的列表，选择某一项，就可以跳转到相应的页面。</P>
<P>2、通过鼠标滑轮或手指滑动到文档底部时，会出现下一页的提示，此时继续滑动，会自动跳转到下一页，停止滑动，则留在本页。</P></div></body>
</html>
<%
	jdb.closeDBCon();
%>
