<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();
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
			response.sendRedirect("com/error.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
%>
<!Doctype html>
<head>
	<title>�û�����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta http-equiv="MSThemeCompatible" content="Yes">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
</head>
<body>Loading...
</body>
<script language=javascript>
var Member = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>"};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, "user", cfg);
	book.initSysStatus(Member.CName + "-" + Member.EName);
	var Tools = [
		{item:"��ѯ", img:"", action:Seek, info:"", Attrib:0},
		{item:"ɸѡ", img:"", action:Filter, info:"", Attrib:0},
		{item:"����", img:"", action:NewRecord, info:"", Attrib:0},
		{item:"�༭", img:"", action:EditRecord, info:"", Attrib:0},
		{item:"ɾ��", img:"", action:DelRecord, info:"", Attrib:0},
		{item:"�������", img:"", action:ClearPass, info:"", Attrib:0}
			];
	book.setRight("ҳ�湤��", "ToolBox", Tools);
	book.setBottom("����˵��", "HelpBox", "<P>&nbsp;</P>");
//@@##113:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
	grid = new $.jcom.DBGrid($("#Page")[0], "../fvs/Member_Edit_Admin.jsp",{}, {}, {gridstyle: 1, resizeflag:0});
	book.setPageObj(grid);
	grid.makeThumb = makeThumb;

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
}
//@@##114:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function makeThumb(line, hint, index)
{
	var data = grid.getData();
	return "<div name=thumbdiv style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;' node=" + index + ">" +
		"<span style='font:normal normal bolder 12pt ΢���ź�;width:120px;display:inline-block;'>" + data[index].CName + "</span>" +
		"<span style='width:60px;display:inline-block;'>" + data[index].EName + "</span>" +
		"<span style='font:normal normal bolder 12pt ����;width:120px;display:inline-block;'>" + data[index].Dept_ex + "</span>" +
		"<span style=width:120px;display:inline-block>" + data[index].Duty + "</span>" +
		"<span style=width:40px;display:inline-block;>" + data[index].Status_ex + "</span>" +
		"</div>";

}

function Seek(obj, item)	//��ѯ
{
//

}



function Filter(obj, item)	//ɸѡ
{
//

}



function NewRecord(obj, item)	//����
{
//

}



function EditRecord(obj, item)	//�༭
{
//

}



function DelRecord(obj, item)	//ɾ��
{
//

}



function ClearPass(obj, item)	//�������
{
//

}


//(�鵵��ע��,����ɾ��)ClientJSCode End##@@
</script>
</HTML>

<%
	jdb.closeDBCon();
%>
