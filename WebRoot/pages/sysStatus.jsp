<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="sysStatus";
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	switch (loginType)
	{
	case 2:
		user = new studentUser();
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='sysStatus' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>系统状态</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-8-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"sysStatus", Role:<%=Purview%>};
var book;
window.onload = function()
{
//return;
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
//@@##117:客户端加载时(归档用注释,切勿删改)
//
		var text = navigator.userAgent;
		text += "<br>ScreenWidth=" + screen.availWidth + ", height:" + screen.availHeight;
		text += "<br>windowWidth=" + $(window).width() + ", WindowHeight:"+ $(window).height();
		text += "<br>docwidth=" + cfg.docwidth;
		text += "<br>DeviceDPI=" + screen.deviceXDPI + ", " + screen.deviceYDPI;
		text += "<br>logicalDPI=" + screen.logicalXDPI + ", " + screen.logicalYDPI;
		text += "<br>docWidth=" + $("#" + cfg.docid).outerWidth(); + "<br>"
		var o = $.jcom.getBrowser();
		for (key in o)
			text += key + "=" + o[key] + ", ";
		$("#Page").html(text);

//(归档用注释,切勿删改)ClientStartCode End##@@
}
//@@##118:客户端自定义代码(归档用注释,切勿删改)
//

//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
 <style>
        .layout  div {
            min-height: 10px;
        }
    </style>
</head>
<body>Loading...
<div id=HelpBox style=display:none><P>&nbsp;</P></div>
  <section class="layout float">
        <style>
            .layout.float .left {
                float: left;
                width: 30px;
                background: red;
            }

            .layout.float .right {
                float: right;
                width: 30px;
                background: blue;
            }

            .layout.float .center {
                background: yellow;
            }
        </style>
        <aside>
            <div class="left">L</div>
            <div class="right">R</div>
            <div class="center">
                <h1>浮动解决方案</h1>
                <p>1.这是布局的中间部分</p>
                <p>2.这是布局的中间部分</p>
            </div>
        </aside>
    </section>


</body>
</html>
<%
	jdb.closeDBCon();
%>
