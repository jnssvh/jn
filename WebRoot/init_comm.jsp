<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@ page language="java" pageEncoding="GBK" import="com.jaguar.*,project.SysApp,project.SysUser"%>
<%
	JDatabase jdb = null;
WebUser user = null;
jdb = new JDatabase();
jdb.InitJDatabase();
user =new SysUser();
String OAvalue = (String) session.getAttribute("OAmemberID");
Cookie[] cookies = null;
if (VB.isNotEmpty(OAvalue)) {
	cookies = new Cookie[6];
	Cookie cookie = new Cookie("memberID", OAvalue+"");
	cookies[0] = cookie;
	OAvalue = (String) session.getAttribute("OAloginname");
	cookie = new Cookie("loginname", OAvalue);
	cookies[1] = cookie;
	OAvalue = (String) session.getAttribute("OArealname");
	cookie = new Cookie("realname", WebChar.escape(OAvalue));
	cookies[2] = cookie;
	OAvalue = (String) session.getAttribute("OAloginpassword");
	cookie = new Cookie("loginpassword", OAvalue);
	cookies[3] = cookie;
	OAvalue = (String) session.getAttribute("OALoginID");
	cookie = new Cookie("LoginID", null);
	cookies[4] = cookie;
	OAvalue = (String) session.getAttribute("OAcheck_passwd");
	cookie = new Cookie("check_passwd", "false");
	cookies[5] = cookie;
	
} else {
	cookies = request.getCookies();
}
if (user.initWebUser(jdb, cookies) != 1)
{
		ServletContext sc = getServletContext();
		request.setAttribute("pagename", SysApp.scriptName(request));
		RequestDispatcher rd = sc.getRequestDispatcher("/com/error.jsp");
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		jdb.closeDBCon();
		return;
}
//if (!WebSafe.checkAccess(request, session, response, jdb)) {
	
//	return;
//}
SysApp sysApp = new SysApp(jdb);
project.SystemLog sysLog = new project.SystemLog(jdb, user, request);
if(request.getProtocol().compareTo("HTTP/1.0")==0)
	response.setHeader("Pragma","no-cache");
if(request.getProtocol().compareTo("HTTP/1.1")==0)
	response.setHeader("Cache-Control","no-cache");
response.setDateHeader("Expires",0);
%>