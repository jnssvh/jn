<%@ page language="java" pageEncoding="GBK" isErrorPage="true"%>
 <%@ include file="init.jsp" %>
 <%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>
<html> 
 <HEAD>
 <meta http-equiv="Content-Type" content="text/html; charset=GBK">
<META HTTP-EQUIV='Pragma' CONTENT='no-cache'>
  <TITLE>出错啦</TITLE>
 </HEAD>
<body leftmargin="0" topmargin="0"> 
<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#83a9dc">
<tbody><tr>
<!-- 没有权限。 -->
<td  valign="middle" style="padding-left:40%"><div style="padding:20"><img src="<%=basePath %>pic/images/error.gif">出错啦！</div>
错误原因可能是：<br>
	1：没有进入这个页面(<%=request.getAttribute("pagename") %>)的权限。<br>
	2：非法进入这个页面(<%=request.getAttribute("pagename") %>)。<br>
	3：系统出现错误，请与管理员联系
</td></tr>
</tbody></table> 
</body>
</html>
<%jdb.closeDBCon(); %>


