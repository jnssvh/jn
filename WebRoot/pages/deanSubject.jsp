<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanSubject";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanSubject' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>ר���</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
<style id="css_264" type="text/css">
body{
background: #e9ebee url(../res/skin/p1.jpg) no-repeat fixed;
background-size:100% 100%;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanSubject", Role:<%=Purview%>};
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
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_Subject_list.jsp",{}, {}, {gridstyle:4, resizeflag:0});
	var Tools = [
		{item:"ȫ�ļ���", img:"", action:SeekSubject, info:"", Attrib:1},
		{item:"����ר��", img:"", action:NewSubject, info:"", Attrib:2},
		{item:"�༭ר��", img:"", action:EditSubject, info:"", Attrib:2},
		{item:"ɾ��ר��", img:"", action:DelSubject, info:"", Attrib:2},
		{item:"�ϲ�ר��", img:"", action:MergeSubject, info:"", Attrib:2},
		{item:"����ר��", img:"", action:ImportSubject, info:"", Attrib:2}
			];
	book.setTool(Tools);
//@@##309:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
			var o = book.setDocTop("������...", "Filter", "");
		 	book.cascade = new $.jcom.Cascade(o, [], {title:["ר�����", "�ӷ���"]});
		 	book.cascade.onclick = ClickSbjClass;
		 	var jsp ="../fvs/CPB_Subject_Class_tree.jsp"; 
		 	$.get(jsp, {GetTreeData:1, nFormat: 0}, GetSbjClassOK);

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
}
//@@##239:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function GetSbjClassOK(data)
{
	var json = $.jcom.eval(data);
	for (var x = 0; x < json.length; x++)
	{
		json[x].item = json[x].Subject_Class_name;
		for (var y = 0; y < json[x].child.length; y++)
			json[x].child[y].item = json[x].child[y].Subject_Class_name;
	}
	book.cascade.reload(json);
}

function ClickSbjClass(obj, item)
{
	alert(item);
}

function SeekSubject(obj, item)	//ȫ�ļ���
{
//
	book.Page.Seek();
}



function NewSubject(obj, item)	//����ר��
{
//
	book.Page.NewItem();
}



function EditSubject(obj, item)	//�༭ר��
{
//
	book.Page.EditItem();
}



function DelSubject(obj, item)	//ɾ��ר��
{
//
	book.Page.DeleteItem();
}



function MergeSubject(obj, item)	//�ϲ�ר��
{
//

}



function ImportSubject(obj, item)	//����ר��
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
