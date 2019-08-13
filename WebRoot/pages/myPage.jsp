<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="myPage";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='myPage' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>我的页面</title>
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
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"myPage", Role:<%=Purview%>};
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
//@@##597:客户端加载时(归档用注释,切勿删改)
//
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##598:客户端自定义代码(归档用注释,切勿删改)
//
function test1()
{
	$.jcom.Ajax("../fvs/CPB_Teacher_list.jsp", true, {SeekKey:"中国", SeekParam:"人民"});
}


function test2()
{
	$.jcom.submit("../fvs/CPB_Teacher_list.jsp", {SeekKey:"1中国2", SeekParam:"3人民4"},{method:"get"});
return;

var s = "中国";
alert(s.charCodeAt(0) + "," + s.charCodeAt(1));
alert(s.charCodeAt(0).toString(16) + "," + s.charCodeAt(1).toString(16));
alert("中国:escape=" + escape("中国") + ", encodeURI=" + encodeURI("中国") + ", encodeURIComponent=" + encodeURI("中国"));
}

function test3()
{
//	$.jcom.Ajax("../fvs/CPB_Teacher_list.jsp", true, "SeekKey=%D6%D0%B9%FA&SeekParam=%C8%CB%C3%F1");
	$.jcom.submit("../fvs/CPB_Teacher_list.jsp", {SeekKey:"1中国2", SeekParam:"3人民4"},{method:"post"});


}


//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
<input type=button value=test1 onclick=test1()>
<input type=button value=test2 onclick=test2()>
<input type=button value=test3 onclick=test3()>
<div id=result></div>
</html>
<%
	jdb.closeDBCon();
%>
