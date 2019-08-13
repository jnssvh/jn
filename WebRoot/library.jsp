<%@page language="java" contentType="text/html; charset=GBK" pageEncoding="GBK"%>
<%@page import="com.jaguar.*"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="project.PageSize"%>
<%@page import="project.countDays"%>
<%@page import="java.sql.ResultSet"%>
<%@ include file="init_comm.jsp"%>
<html>
<head>
<title>电子图书馆系统登录</title>
</head>
<%ResultSet rs_term;%>
<body>
<form method="POST" action="http://124.227.9.231/elib3/" target="_blank" v="operator/main_Login.asp">
<div align=center>
<table border="1" width="45%" style="border-collapse: collapse">
	<tr>
		<td colspan="2" align=center height="22">
		<input type="hidden" name="txUserName" value="<%=user.EMemberName%>"/>
		<input type="hidden" name="txUserPasswd" value="admin"/>
		<input name="imglogin2.x" TYPE="hidden" value="30">
		<input name="imglogin2.y" TYPE="hidden" value="30">
		</td>
	</tr>
	<tr>
		<td width="81%" colspan="2" align="center">
		<p align="center">
		<input type="submit" name="login" value="进入系统" name="B1">
		</td>
	</tr>
</table>
</div>
</form>
</body>
</html>