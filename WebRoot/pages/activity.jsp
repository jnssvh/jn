<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();
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
			response.sendRedirect("com/error.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
%>
<!Doctype html>
<head>
	<title>教学活动</title>
	<META http-equiv='Content-Type' content='text/html; charset=GBK'>
	<meta http-equiv='MSThemeCompatible' content='Yes'>
	<link rel='stylesheet' type='text/css' href='../forum.css'>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
</head>
<body>Loading...
</body>
<script language=javascript>
var Member = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>"};
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	var book = new $.jcom.BookPage(aFace, Chapters, "activity", cfg);
	book.initSysStatus(Member.CName + "-" + Member.EName);
	book.setBottom("辅助说明", "HelpBox", "<P>&nbsp;</P>");
//@@##83:客户端加载时(归档用注释,切勿删改)
//
	$("#Page").css({overflowX: "hidden", overflowY: "visible", border:"1px solid red"});
alert("OK");
	var grid = new $.jcom.DBGrid($("#Page")[0], "../fvs/CPB_Activity_list.jsp");
//	view = new $.jcom.DBGrid($("#bottom")[0], "../fvs/CPB_Activity_list.jsp", {Menubar:menubar});
//(归档用注释,切勿删改)ClientStartCode End##@@
}
//@@##84:客户端自定义代码(归档用注释,切勿删改)
//
//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</HTML>

<%
	jdb.closeDBCon();
%>
