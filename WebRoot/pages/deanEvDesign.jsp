<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanEvDesign";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanEvDesign' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##458:��������������(�鵵��ע��,����ɾ��)
//
	if (WebChar.RequestInt(request, "Repair") == 1)
	{
		String sql = "select * from CPB_Evaluate_Item where Evaluate_id=0 and parent_id>0";
		ResultSet rs = jdb.rsSQL(0, sql);
		while (rs.next())
		{
			int Evaluate_item_id = rs.getInt("Evaluate_item_id");
			int Evaluate_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Evaluate_Item", "Evaluate_id", "Evaluate_item_id", rs.getString("parent_id")));
			sql = "update CPB_Evaluate_Item set Evaluate_id= " + Evaluate_id + " where Evaluate_item_id=" + Evaluate_item_id;
			result = jdb.ExecuteSQL(0, sql);
		}
		jdb.rsClose(0, rs);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}
//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>�ʾ����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
<style id="css_409" type="text/css">
.pcbody{
background: #e9ebee url(../res/skin/dx3.jpg) no-repeat fixed;
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanEvDesign", Role:<%=Purview%>};
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
		{item:"����", img:"#59356", action:null, info:"����һ����¼", Attrib:2, child:[
			{item:"�����ʾ�", img:"", action:NewPaper, info:"", Attrib:0},
			{item:"������Ŀ", img:"", action:NewItem, info:"", Attrib:0}]},
		{item:"�༭", img:"#59357", action:EditRecordPage, info:"�༭��ǰ��¼", Attrib:2},
		{item:"ɾ��", img:"#58996", action:DelRecordPage, info:"ɾ����ǰ��¼", Attrib:2},
		{item:"ˢ��", img:"#58976", action:RefreshPage, info:"���¼���", Attrib:1},
		{item:"�޸�", img:"", action:Repair, info:"�޸��ɰ汾��������Ӧ�°汾", Attrib:16}
			];
	book.setTool(Tools);
//@@##434:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
	book.Page = new EvalutionPaper(book.getDocObj("Page")[0], {viewmode: 1});
	var o = book.setDocTop("������...", "Filter", "");
	book.cascade = new $.jcom.DBCascade(o, "../fvs/CPB_Evaluate_list.jsp", {}, {}, {title:["�ʾ�"]});
	book.setPageObj(book.cascade);
	book.Page.onFormReady = FormReady;
	book.cascade.onclick = ClickPaper;
	

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##435:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function ClickPaper(obj, item)
{
	book.Page.loadPaper(item);
}


function EditRecordPage(obj, item)	//�༭
{
//�༭��ǰ��¼
	var item = book.Page.getTreeItem();
	if (typeof item == "object")
			return book.Page.EditItem({EditAction:"CPB_EvaItem_form"});		
	
	var id = book.cascade.getSelItemKeyValue();
	book.cascade.EditRecord(id, {EditAction:"CPB_Evaluate_form"});
}



function DelRecordPage(obj, item)	//ɾ��
{
//ɾ����ǰ��¼
	var item = book.Page.getTreeItem();
	if (typeof item == "object")
			return book.Page.DeleteItem({EditAction:"CPB_EvaItem_form"});
	var id = book.cascade.getSelItemKeyValue();
	book.cascade.DelRecord(id, {EditAction:"CPB_Evaluate_form"});

}



function RefreshPage(obj, item)	//ˢ��
{
//���¼���
	book.Page.reload();

}



function NewPaper(obj, item)	//�����ʾ�
{
//
	book.cascade.NewRecord({EditAction:"CPB_Evaluate_form"});
}


function NewItem(obj, item)	//������Ŀ
{
//
	var item = book.Page.getTreeItem();
	if (typeof item != "object")
	{
		var id = book.cascade.getSelItemKeyValue();
		if (id == undefined)
			return alert("δѡ���ʾ�����");
	}
	book.Page.NewItem({EditAction:"CPB_EvaItem_form"});		

}

function FormReady(fields, record, title, winform)
{
	var keyid = winform.form.FieldValue("I_DataID");
	if (parseInt(keyid) > 0)
		return;
	var items = book.cascade.getNodeItems()
	if (typeof items != "object")
	{
		winform.win.close();
		return alert("����ѡ��������Ŀ");
	}
	winform.form.FieldValue("Evaluate_id", {value:items[0].evaluate_id, ex:items[0].evaluate_name});
	var item = book.Page.getTreeItem();
	if (typeof item != "object")
	{
		winform.form.FieldValue("parent_id", {value:0, ex:""});
		return;
	}
	if (parseInt(item.parent_id) > 0)
		winform.form.FieldValue("parent_id", {value:item.parent_id, ex:item.parent_id_ex});
	else
		winform.form.FieldValue("parent_id", {value:item.Evaluate_item_id, ex:item.Evaluate_item_name});
}

function Repair(obj, item)	//�޸�
{
//�޸��ɰ汾��������Ӧ�°汾
	$.get(location.pathname, {Repair:1}, function (data) {alert(data);});

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
