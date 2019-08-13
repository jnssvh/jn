<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanTermClass2";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanTermClass2' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>ѧ�ڰ��2</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
<style id="css_510" type="text/css">
.pcbody{
background: #e9ebee url(../res/skin/dx1.jpg) no-repeat fixed;
background-size:100% 100%;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanTermClass2", Role:<%=Purview%>};
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
//@@##506:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
	var o = book.setDocTop("������...", "Filter", "");
 	window.tFilter = new TermFilter(o, {Term_id:0});
	tFilter.onclick = ClickTerm;
	book.setPageObj(window.tFilter);
	book.onLink = LinkAddParam;
	book.termDBFun = new $.jcom.DBFun("../fvs/CPB_Term_form.jsp", {title:["����ѧ��","�༭ѧ��"], width:400, height:260, mask:50, itemstyle:"font:normal normal normal 16px ΢���ź�"});
	book.termDBFun.onRecordChange = ReloadTerm;

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##511:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function LinkAddParam(item, url)
{
	var id = book.Page.getSelItemKeyValue();
	if (id == undefined)
		return url;
	else
		return url + "?Class_id=" + id;
}

function ClickTerm(obj, item)
{
	if (book.Page == undefined)
	{
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_Class_list.jsp", {formitemstyle:"font:normal normal normal 16px ΢���ź�", 
			formvalstyle:"width:400px"}, {SeekKey:"CPB_Class.Term_id", SeekParam:item.Term_id}, {gridstyle:4, resizeflag:0});
	}
	else
		book.Page.Seek(item.Term_id, "CPB_Class.Term_id");	
}

function NewClass(obj, item)	//�������
{
//����һ����¼
	book.Page.NewItem();

}



function EditClass(obj, item)	//�༭���
{
//�༭��ǰ��¼
	book.Page.EditItem();

}



function DelClass(obj, item)	//ɾ�����
{
//ɾ����ǰ��¼
	book.Page.DeleteItem();

}

function NewTerm(obj, item)	//����ѧ��
{
//
	book.termDBFun.NewRecord();
}

function EditTerm(obj, item)	//�༭ѧ��
{
//
	var items = window.tFilter.getdata();
	var sel = window.tFilter.getsel();
	var index = parseInt($(sel).attr("node"));
	book.termDBFun.EditRecord(items[index].Term_id);

}

function DeleTerm(obj, item)	//ɾ��ѧ��
{
//
	var items = window.tFilter.getdata();
	var sel = window.tFilter.getsel();
	var index = parseInt($(sel).attr("node"));
	book.termDBFun.DelRecord(items[index].Term_id);
}

function ReloadTerm(nType)
{
	window.tFilter.refresh();
}

function PageEdit(obj, item)	//ҳ��༭
{
//
	book.Page.onEditModeChange = book.toggleEditMode;
	var child = book.getChild();
	book.Page.toggleEditMode(child.toolObj);
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
