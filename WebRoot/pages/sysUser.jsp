<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="sysUser";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='sysUser' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>�û�����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"sysUser", Role:<%=Purview%>};
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
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/Member_Edit_Admin.jsp",{}, {}, {gridstyle:4, resizeflag:0});
	var Tools = [
		{item:"��ѯ", img:"../pic/c3.png", action:Seek, info:"", Attrib:1},
		{item:"ɸѡ", img:"../pic/knowledge_search.png", action:Filter, info:"", Attrib:1},
		{item:"����", img:"../pic/new_folder.png", action:NewRecord, info:"", Attrib:2},
		{item:"�༭", img:"../pic/wendang.png", action:EditRecord, info:"", Attrib:2},
		{item:"ɾ��", img:"../pic/lj.png", action:DelRecord, info:"", Attrib:3},
		{item:"�������", img:"../pic/gn_4.png", action:ClearPass, info:"", Attrib:3}
			];
	book.setTool(Tools);
}
//@@##114:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function makeThumb(line, hint, index, item)
{
	return "<div name=thumbdiv style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;' node=" + index + ">" +
	"<span style='font:normal normal bolder 12pt ΢���ź�;width:120px;display:inline-block;'>" + item.CName + "</span>" +
	"<span style='width:60px;display:inline-block;'>" + item.EName + "</span>" +
	"<span style='font:normal normal bolder 12pt ����;width:120px;display:inline-block;'>" + item.Dept_ex + "</span>" +
	"<span style=width:120px;display:inline-block>" + item.Duty + "</span>" +
	"<span style=width:40px;display:inline-block;>" + item.Status_ex + "</span>" +
	"</div>";
}

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



function NewRecord(obj, item)	//����
{
//
	book.Page.NewItem({EditAction:"../fvs/EditMember_Form.jsp", itemstyle:"font-size:16px", width:320, height:240});
}



function EditRecord(obj, item)	//�༭
{
//
	book.Page.EditItem({EditAction:"../fvs/EditMember_Form.jsp", itemstyle:"font-size:16px", width:320, height:240});

}



function DelRecord(obj, item)	//ɾ��
{
//
	book.Page.DeleteItem();
}



function ClearPass(obj, item)	//�������
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
