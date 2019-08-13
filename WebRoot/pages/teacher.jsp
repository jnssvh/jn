<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="teacher";
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
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='teacher' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>ʦ�ʿ�</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
<style id="css_263" type="text/css">
body{
background: #e9ebee url(../res/skin/m1.jpg) no-repeat fixed;
background-size:100% 100%;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"teacher", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:2123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	var Tools = [
		{item:"��ѯ", img:"", action:SeekTeacher, info:"123", Attrib:0},
		{item:"ɸѡ", img:"", action:FilterTeacher, info:"ddfdf", Attrib:0},
		{item:"ά��", img:"", action:EditTeacher, info:"", Attrib:0}
			];
	book.setTool(Tools);
//@@##77:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//client load
	book.Page = new $.jcom.DBGrid($("#Page")[0], "../fvs/CPB_Teacher_list.jsp",{}, {}, {gridstyle: 4, resizeflag:0});
//	book.setPageObj(grid);
//	grid.makeThumb = makeThumb;

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
}
//@@##78:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//user js
function makeThumb(line, hint, index, item)
{
	return "<div name=thumbdiv style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;' node=" + index + ">" +
		"<span style='font:normal normal bolder 12pt ΢���ź�;width:80px;display:inline-block;'>" + item.Teacher_name + "</span>" +
		"<span style='width:40px;display:inline-block;'>" + item.nType_ex + "</span>" +
		"<span style='font:normal normal bolder 12pt ����;width:240px;display:inline-block;'>" + item.DeptName + "</span><span>" + item.Duty + "</span>" +
		"<span style=width:80px;display:inline-block;>" + item.PhoneNo + "</span>" +
		"<span style=width:80px;display:inline-block;>" + item.Mobile + "</span>" +
		"<span style=width:80px;display:inline-block;>" + item.EMail + "</span>" +
		"</div>";
}

function SeekTeacher(obj, item)	//��ѯ
{
//
	book.Page.Seek();
}



function FilterTeacher(obj, item)	//ɸѡ
{
//
	book.Page.Filter();
}



function EditTeacher(obj, item)	//ά��
{
//

}


//(�鵵��ע��,����ɾ��)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
