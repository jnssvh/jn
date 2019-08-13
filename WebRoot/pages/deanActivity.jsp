<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanActivity";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanActivity' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>��ѧ�</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
<style id="css_265" type="text/css">
body{
background: #e9ebee url(../res/skin/p2.jpg) no-repeat fixed;
background-size:100% 100%;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanActivity", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_Activity_list.jsp",{}, {}, {gridstyle:4, resizeflag:0});
	var Tools = [
		{item:"�����", img:"", action:NewActivity, info:"", Attrib:0, Param:1},
		{item:"�༭�", img:"", action:EditActivity, info:"", Attrib:0, Param:1},
		{item:"ɾ���", img:"", action:DelActivity, info:"", Attrib:0, Param:1},
		{item:"ҳ��༭", img:"", action:PageEdit, info:"", Attrib:0, Param:1},
		{item:"��ѯ", img:"", action:Seek, info:"", Attrib:0, Param:1},
		{item:"ɸѡ", img:"", action:Filter, info:"", Attrib:0, Param:1},
		{item:"ˢ��", img:"", action:RefreshPage, info:"", Attrib:0, Param:1}
			];
	book.setTool(Tools);
//@@##83:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##84:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function Seek(obj, item)	//��ѯ
{
//
	book.Page.Seek();
}



function Filter(obj, item)	//ɸѡ
{
//
	book.Page.Filter();
}



function PageEdit(obj, item)	//ά��
{
//
  book.Page.toggleEditMode(book);
}



function NewActivity(obj, item)	//����
{
//����һ����¼
	book.Page.NewItem();

}



function EditActivity(obj, item)	//�༭
{
//�༭��ǰ��¼
	book.Page.EditItem();

}



function DelActivity(obj, item)	//ɾ��
{
//ɾ����ǰ��¼
	book.Page.DeleteItem();

}



function RefreshPage(obj, item)	//ˢ��
{
//���¼���
	book.Page.ReloadGrid();

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
