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
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
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
	String CodeName="SysUser";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='SysUser' and GroupID in (" +
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
	<title>�û�����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2019-4-28 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"SysUser", Role:<%=Purview%>};
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
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	var Tools = [
		{item:"��ѯ", img:"#59111", action:SeekPage, info:"ȫ�ļ���", Attrib:1, Param:1},
		{item:"ɸѡ", img:"#59188", action:FilterPage, info:"������ɸѡ", Attrib:1, Param:1},
		{item:"����", img:"#59356", action:NewRecordPage, info:"����һ����¼", Attrib:2, Param:1},
		{item:"�༭", img:"#59357", action:EditRecordPage, info:"�༭��ǰ��¼", Attrib:2, Param:1},
		{item:"ɾ��", img:"#58996", action:DelRecordPage, info:"ɾ����ǰ��¼", Attrib:2, Param:1},
		{item:"ҳ��༭", img:"#59341", action:PageEditPage, info:"��ҳ����¼���б༭", Attrib:4, Param:1},
		{item:"ˢ��", img:"#58976", action:RefreshPage, info:"���¼���", Attrib:1, Param:1}
			];
	book.setTool(Tools);
//@@##85:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//��������:Page
	var o = book.getDocObj("Page")[0];
	book.Page = new $.jcom.DBGrid(o,  env.fvs + "/Member_Edit_Admin.jsp", {formitemstyle:"font:normal normal normal 16px ΢���ź�", formvalstyle:"width:400px"}, {SeekKey:"", SeekParam:""}, {gridstyle:4, resizeflag:0});


//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##95:�ͻ����Զ������(�鵵��ע��,����ɾ��)

function SeekPage(obj, item)	//��ѯ
{
//ȫ�ļ���
book.Page.Seek();
}



function FilterPage(obj, item)	//ɸѡ
{
//������ɸѡ
book.Page.Filter();
}



function NewRecordPage(obj, item)	//����
{
//����һ����¼
book.Page.NewItem();
}



function EditRecordPage(obj, item)	//�༭
{
//�༭��ǰ��¼
book.Page.EditItem();
}



function DelRecordPage(obj, item)	//ɾ��
{
//ɾ����ǰ��¼
book.Page.DeleteItem();
}



function PageEditPage(obj, item)	//ҳ��༭
{
//��ҳ����¼���б༭
book.Page.toggleEditMode(book);
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
