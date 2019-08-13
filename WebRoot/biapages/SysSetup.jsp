<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
// ServerChapterPageStartCode
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	user = new SysUser();
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
			response.sendRedirect("../bia/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	String CodeName="SysSetup";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='SysSetup' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
%>
<!DOCTYPE html>
<html>
<head>
	<title>系统设置</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2019-4-28 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"SysSetup", Role:<%=Purview%>};
var env = {com:"../com", proj:"../bia", fvs:"../biafvs", flow:"../biaflow", page:"../biapages"};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	
//@@##55:客户端加载时(归档用注释,切勿删改)
//
	var fields = [
					{CName:"系统名称", EName: "SysName", nRequired:1},
					{CName:"机构名称", EName: "OrgName", nRequired:1},
					{CName:"机构图标", EName: "OrgIcon", nRequired:1},
					{CName:"机构位置", EName: "OrgPos", nRequired:1},
					{CName:"机构地址", EName: "OrgAddress", nRequired:1},
					{CName:"机构负责人", EName: "OrgLeader", nRequired:1},
					{CName:"机构联系电话", EName: "OrgPhone", nRequired:1},
					{CName:"机构联系人", EName: "OrgLinker", nRequired:1},
					{CName:"机构级别", EName: "UserName", nRequired:1},
					{CName:"省(直辖市)", EName: "OrgProvince", nRequired:1},
					{CName:"市(州)", EName: "OrgCity", nRequired:1},
					{CName:"区(县)", EName: "OrgConty", nRequired:1},
					{CName:"上级机构名称", EName: "ParentOrg", nRequired:1},
					{CName:"下级机构", EName: "ChilOrg", nRequired:1}
				];
	book.form = new $.jcom.FormView($("#Page")[0], fields, {}, 
		{action:location.pathname, requireTag:"", itemstyle:"font:normal normal normal 16px 微软雅黑", valstyle:"width:300px"});
	book.form.onchange = FormChange;
	book.form.aftersubmit = FormSaveOK;

//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##56:客户端自定义代码(归档用注释,切勿删改)
//
function FormChange()
{
}

function FormSaveOK()
{
}
//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
