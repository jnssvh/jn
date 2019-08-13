<%@ page language="java" import="java.util.*" pageEncoding="GB18030"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.*, java.util.*, java.text.*,com.jaguar.*,org.apache.log4j.Logger"%>
<%@page import="project.*"%>

<%
JDatabase jdb = null;
WebUser user = null;
jdb = new JDatabase();
jdb.InitJDatabase();
user =new SysUser();
user.initWebUser(jdb, request.getCookies());
SysApp sysApp = new SysApp(jdb);
project.SystemLog sysLog = new project.SystemLog(jdb, user, request);
if(request.getProtocol().compareTo("HTTP/1.0")==0)
	response.setHeader("Pragma","no-cache");
if(request.getProtocol().compareTo("HTTP/1.1")==0)
	response.setHeader("Cache-Control","no-cache");
response.setDateHeader("Expires",0);


String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";

String isThumb = "";		//Í¼Æ¬Ê¹ÓÃËõÂÔÍ¼ 
int width = WebChar.RequestInt(request, "width");
int height = WebChar.RequestInt(request, "height");
String AffixID = WebChar.requestStr(request, "AffixID");					//¸½¼þ¿âÖÐµÄ±àºÅ
String type = WebChar.requestStr(request, "type");

if (width > 0 || height > 0) {
	String name = new SysApp(jdb).GetThumbNail(VB.CInt(AffixID), width, width, true);
	if ("name".equals(type)) {
		out.print(name);
	} else {
		ServletContext sc = getServletContext();
		RequestDispatcher rd = sc.getRequestDispatcher("/" + name);
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		return;
	}
}
jdb.closeDBCon();
%>