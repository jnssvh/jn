<%@ page language="java" pageEncoding="GBK" import="com.jaguar.*,project.SysApp,project.SysUser"%>
<%
JDatabase jdb = null;
WebUser user = null;
SysApp sysApp = null;
project.SystemLog sysLog = null;

String userLoginName = WebChar.getCookie(request, "loginname");
if (userLoginName.isEmpty()) {
	response.addCookie(new Cookie("loginname", "guest"));
	response.addCookie(new Cookie("loginpassword", "123456"));
}
jdb = new JDatabase();
jdb.InitJDatabase();
user =new SysUser();
user.initWebUser( jdb, request.getCookies() );
sysApp = new SysApp(jdb);
sysLog = new project.SystemLog( jdb, user, request );

if( request.getProtocol().compareTo("HTTP/1.0") == 0 )
	response.setHeader("Pragma", "no-cache");
if( request.getProtocol().compareTo("HTTP/1.1") == 0 )
	response.setHeader( "Cache-Control", "no-cache" );
response.setDateHeader( "Expires", 0 );
%>