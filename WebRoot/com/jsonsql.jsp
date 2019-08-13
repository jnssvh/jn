<%@ page language="java" pageEncoding="GBK"%>
<%@ page import="com.jaguar.*,java.sql.*,java.net.URLEncoder,project.*" %>
<%@ include file="init.jsp" %>
<%
	String id = WebChar.requestStr(request, "id");
//	String param = WebChar.requestStr(request, "param");
	String[] param = request.getParameterValues("param");
	int nDB = WebChar.RequestInt(request,"nDB");
	String sql = jdb.getSQLById(id, param);
	if (sql == null)
		return;
	out.print(jdb.getJsonBySql(nDB, sql));
	jdb.closeDBCon();

%>