<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="sysDept";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='sysDept' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>���Ź���</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"sysDept", Role:<%=Purview%>};
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
		{item:"��ѯ", img:"", action:SeekDept, info:"", Attrib:1, Param:1},
		{item:"ɸѡ", img:"", action:FilterDept, info:"", Attrib:1, Param:1},
		{item:"��������", img:"", action:NewDept, info:"", Attrib:2, Param:1},
		{item:"�༭����", img:"", action:EditDept, info:"", Attrib:4, Param:1},
		{item:"ɾ������", img:"", action:DelDept, info:"", Attrib:16, Param:1}
			];
	book.setTool(Tools);
//@@##588:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
/*	var o = book.setDocTop("������...", "Filter", "");
 	book.deptFilter = new DeptFilter(o, {ID:0});
	book.deptFilter.onclick = ClickDept;
	book.setPageObj(book.tFilter);
	book.onLink = LinkAddParam;
	book.deptDBFun = new $.jcom.DBFun("../fvs/EditDept.jsp", {title:["��������","�༭����"], width:400, height:260, mask:50, itemstyle:"font:normal normal normal 16px ΢���ź�"});
	book.deptDBFun.onRecordChange = ReloadDept;
*/
ClickDept();
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##589:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function LinkAddParam(item, url)
{
	var id = book.Page.getSelItemKeyValue();
	if (id == undefined)
		return url;
	else
		return url + "?ID=" + id;
}

function ClickDept(obj, item)
{
	if (book.Page == undefined)
	{
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/ManageDept.jsp", {formitemstyle:"font:normal normal normal 16px ΢���ź�", 
			formvalstyle:"width:400px"}, {SeekKey:"", SeekParam:""}, {gridstyle:4, resizeflag:0});
	}
	else
		book.Page.Seek(item.ID, "Dept.ID");	
}
function ReloadDept(nType)
{
	book.deptFilter.refresh();
}

function NewDept(obj, item)
{
//����һ����¼
	book.Page.NewItem();

}

function EditDept(obj, item)	//�༭���
{
//�༭��ǰ��¼
	book.Page.EditItem();

}



function DelDept(obj, item)	//ɾ�����
{
//ɾ����ǰ��¼
	book.Page.DeleteItem();

}


function SeekDept(obj, item)	//��ѯ
{
//
	book.Page.Seek();
}



function FilterDept(obj, item)	//ɸѡ
{
//
	book.Page.Filter();
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
