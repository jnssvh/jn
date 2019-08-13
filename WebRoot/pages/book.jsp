<%@ page language="java" import="java.sql.*,java.util.*,com.jaguar.*, project.*" pageEncoding="GBK"%>
<%@ page trimDirectiveWhitespaces="true" %> 
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
<!Doctype html><html xmlns=http://www.w3.org/1999/xhtml><head>
<title>BOOK</title>	
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
	var text = "<div id=FilterDiv style='height:200px;border:1px solid gray;background-color:#eeeeee'>筛选区</div><br>" +
		"<div id=TextDiv style='height:800px;border:1px solid gray;'>正文区</div><br>" +
		"<div id=CheckDiv style='height:200px;border:1px solid gray;background-color:#eeeeee'>审核区</div><br>" +
		"<div id=AllowDiv style='height:200px;border:1px solid gray;background-color:#eeeeee'>批准区</div><br>"	
	var book = new $.jcom.BookPage(text, Chapters, "");
	book.initSysStatus(Member.CName + "-" + Member.EName);
//	book.setRight("Right:操作功能的列表");
}
</script>
</HTML>

<%
out.println("</html>"); 
jdb.closeDBCon();
%>
