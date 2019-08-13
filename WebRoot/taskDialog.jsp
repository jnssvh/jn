<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,project.eut.util.desktop.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
String url = WebChar.requestStr(request, "url");
String dialogStyle = WebChar.requestStr(request, "dialogStyle");
String bottomStyle = "";
if (dialogStyle.matches("[\\s\\S]*bottom\\s*:\\s*none\\s*;")) {
	bottomStyle = "display:none;";
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<META http-equiv='Content-Type' content='text/html; charset=gbk'>
	<META HTTP-EQUIV='Pragma' CONTENT='no-cache'>
	<title>CourseNotEvaluate</title>
	<link rel='stylesheet' type='text/css' href='<%=basePath %>forum.css'>
	<style>
	
		.linkStyle {background:url(<%=basePath %>images/btn_eva.png);
			border:0px;
			width:65px;
			height:25;
			color:white;
			cursor:hand;
			} 
	
	</style>
	
	<script language=javascript src=<%=basePath %>com/psub.jsp></script>
	<script language=javascript src=<%=basePath %>com/common.js></script>
	<script language=javascript src=<%=basePath %>com/seek.jsp></script>
	<script type="text/javascript">
		window.onload = function() {
			var h = document.body.clientHeight;
			if (document.getElementById("dialogBottom").style.display == "none") {
				h = h -60
			} else {
				h = h -100;
			}
			if (h < 100) {
				h = 100;
			}
			document.getElementById("div_case").style.height = h + "px";
		};
	
	</script>
</HEAD>

<body style='background:white' alink=#333333 scroll=no vlink=#333333 link=#333333 topmargin=0 leftmargin=0>
<div style='margin-top:10px;margin-left:10px;'><img src='<%=basePath %>images/423.jpg'/><span id="dialogTitle"></span></div>
<div id='div_case' style='width:100%;overflow-y:auto;overflow-x:hidden; border-top: 1px solid #cbe1eb;'>
<iframe src="<%=url %>" style="width:100%;height:100%;" frameborder="0"></iframe>
</div>
<div id="dialogBottom" style="<%=bottomStyle %>width: 100%; height: 50px; border-top: 1px solid #cbe1eb;">
	<div style="float: left; margin-top: 9px; margin-left: 10px;">
		<input type="checkbox" onclick="clk(this)" />下次不再提醒
	</div>
	<div style="float: right; margin-top: 9px;margin-right: 18px;">
		<input value="以后再说" class=linkStyle type="button" onclick="parent.CloseInlineDlg()" />
	</div>
</div>
</body>
</html>