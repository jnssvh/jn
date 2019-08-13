<%@ page language="java" import="java.util.*" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.text.*,net.sf.json.JSONArray, net.sf.json.JSONObject,project.*"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@page import="java.util.Date"%> 
<%!


%>
<%
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	switch (loginType)
	{
	case 2:
//		user = new studentUser();
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
	SysApp sysApp = new SysApp(jdb);

	if (WebChar.RequestInt(request, "SaveMyPhoto") == 1)
	{
		int photoid = WebChar.RequestInt(request, "photoid");
		switch (loginType)
		{
		case 2:
			break;
		default:
			String sql = "update Member set Photo=" + photoid + " where ID=" + user.UserID;
			jdb.ExecuteSQL(0, sql);
			out.print("OK");
			jdb.closeDBCon();
			return;
		}		
	}

%>