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
  <TITLE>������</TITLE>
 </HEAD>
<body leftmargin="0" topmargin="0"> 
<table width="100%" height="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="#83a9dc">
<tbody><tr>
<!-- û��Ȩ�ޡ� -->
<td  valign="middle" style="padding-left:40%"><div style="padding:20"><img src="<%=basePath %>pic/images/error.gif">��������</div>
����ԭ������ǣ�<br>
	1��û�н������ҳ��(<%=request.getAttribute("pagename") %>)��Ȩ�ޡ�<br>
	2���Ƿ��������ҳ��(<%=request.getAttribute("pagename") %>)��<br>
	3��ϵͳ���ִ����������Ա��ϵ
</td></tr>
</tbody></table> 
</body>
</html>
<%jdb.closeDBCon(); %>


