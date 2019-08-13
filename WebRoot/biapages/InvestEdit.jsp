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
	String CodeName="InvestEdit";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='InvestEdit' and GroupID in (" +
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
	<title>�ƻ��ƶ�</title>
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
<script type="text/javascript" src="../bia/bia.js"></script>

<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"InvestEdit", Role:<%=Purview%>};
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
		{item:"����", img:"#59356", action:NewRecordFilter, info:"����һ����¼", Attrib:2, Param:1},
		{item:"�༭", img:"#59357", action:EditRecordFilter, info:"�༭��ǰ��¼", Attrib:2, Param:1},
		{item:"ɾ��", img:"#58996", action:DelRecordFilter, info:"ɾ����ǰ��¼", Attrib:2, Param:1},
		{item:"ˢ��", img:"#58976", action:RefreshFilter, info:"���¼���", Attrib:1, Param:1}
			];
	book.setTool(Tools);
//@@##136:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//��������:Filter
	var o = book.setDocTop("������...", "Filter", "");
	book.Filter = new $.jcom.DBCascade(o, env.fvs + "/asInvestPlan_view.jsp", {}, {}, {title:["�ƻ�"]});
	book.Filter.onclick = ClickFilter;
	book.setPageObj(book.Filter);
	book.Filter.onReady = FilterReady;
	var o = book.setDocBottom("", "paper");
	book.asView = new AsSysInvestView(o, 0, {title:"�����ʾ�����"});

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##129:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function ClickFilter(obj, item)
{
	if (book.Page == undefined)
	{
		var o = book.getDocObj("Page")[0];
		book.Page = new $.jcom.DBForm(o,  env.fvs + "/asInvestPlan_form.jsp", {DataID:item.ID}, 
			{itemstyle:"font:normal normal normal 16px ΢���ź�",valstyle:"width:400px"});
		book.Page.PrepareData = PrepareForm;
		book.Page.onRecordReady = FormPageReady;
	}
	else
		book.Page.getDBRecord(item.ID);
}

function FormPageReady(fields, record)
{
	var field = book.Page.getFields("companys");
	if (field.editor == undefined)
	{
		$("#" + field.EName + "_DIV").css({width:""});
		var cfg = {resizeflag:0};
		var tag = "<h2 align=center>��������ҵ</h2>";
		if (editMode != 0)
		{
			cfg.bodystyle  = 2;
			tag += "&nbsp;&nbsp;<input type=button onclick=InsertCom() value=����>&nbsp;<input type=button onclick=DelCom() value=ɾ��></div>";
		}
		field.editor = new $.jcom.GridView($("#" + field.EName + "_DIV")[0], [{FieldName:"comName", TitleName:"��ҵ����", nWidth:400}],[],{}, cfg);
		field.editor.TitleBar(tag);
	}
	if ((record.companys == undefined) || (record.companys == ""))
	{
		field.editor.reload([]);
		return;
	}
	var ss = record.companys.split(",");
	var ssex = record.companys_ex.split(",");
	var items = [];
	for (var x = 0; x < ss.length; x++)
	{
		items[items.length] = {ID: ss[x], comName: ssex[x]};
	}
	field.editor.reload(items);
}


var comWin, comGrid;
function InsertCom()
{
	if (comWin == undefined)
	{
		comWin = new $.jcom.PopupWin("<div id=ComGridDiv style=width:100%;height:400px;overflow:auto;></div>" +
			"<div style=float:right><input id=InsertFromCom type=button value=ȷ��>&nbsp;&nbsp;</div>", 
				{title:"ѡ����ҵ", width:640, height:480, mask:50,position:"fixed"});
		comGrid = new $.jcom.DBGrid($("#ComGridDiv")[0],  env.fvs + "/company_sel.jsp", {},
			{SeekKey:"", SeekParam:""}, {gridstyle:1, bodystyle:2, footstyle:4, initDepth:4, nowrap:0});
		comWin.close = comWin.hide;
		$("#InsertFromCom").on("click", InsertComRun);
	}
	else
		comWin.show();
}

function InsertComRun()
{
	var sels = comGrid.getsel();
	if (sels.length == 0)
		return alert("����ѡ����ҵ");
	var ids = "";
	var value = book.Page.FieldValue("companys");
	var ss = value.split(",");
	var field = book.Page.getFields("companys");
	var items = field.editor.getData();
	for (var x = 0; x <sels.length; x++)
	{
		var item = comGrid.getItemData($(sels[x]).attr("node"));
		for (var y = 0; y < ss.length; y++)
		{
			if (item.ID == ss[x])
				break;
		}
		if (y >= ss.length)
		{
			if (ids != "")
				ids += ",";
			ids += item.ID;
			items[items.length] = {ID:item.ID, comName:item.comName};
		}
	}
	comWin.hide();
	if (ids != "")
	{
		if (value != "")
			value += ",";
		value += ids;
		book.Page.FieldValue("companys", value);
		field.editor.reload(items); 
	}
}

function DelCom()
{
	var field = book.Page.getFields("companys");
	var sels = field.editor.getsel();
	if (sels.length == 0)
		return alert("���ȹ�ѡ��ҵ");
	for (var x = sels.length - 1; x >= 0; x--)
		field.editor.deleteRow(sels[x]);
	var items = field.editor.getData();
	var ids = "";
	for (var x = 0; x <items.length; x++)
	{
		if (ids != "")
			ids += ",";
		ids += items[x].ID;
	}
	book.Page.FieldValue("companys", ids);
}

function PrepareForm(fields, record, cfg)
{
	if (editMode == 0)
		cfg.formtype = 8;
	else
		cfg.formtype = 4;
	book.asView.reload(record.asSysMainId);
}

function FilterReady(items)
{
	if (items.length == 0)
		NewRecordFilter();
	else
		book.Filter.SkipPage(1, true);
}

function NewRecordFilter(obj, item)	//����
{
//����һ����¼
//	book.Filter.NewItem();
	toggleEditMode();
	book.Page.reset(0, 0, {formtype:4});
	book.Page.getDBRecord(0);
}



function EditRecordFilter(obj, item)	//�༭
{
//�༭��ǰ��¼
//	book.Filter.EditItem();
	toggleEditMode();
	book.Page.reset(0, 0, {formtype:4});
}



function DelRecordFilter(obj, item)	//ɾ��
{
//ɾ����ǰ��¼
	book.Filter.DeleteItem({fun:SubmitResult});
}

function SubmitResult(data)
{
	alert(data);
	location.reload();	
}

var editMode = 0, hostMenuDef;
function toggleEditMode()		//����:��ȫ���༭ģʽ���Ķ�ģʽ֮���л�
{
	var menu = book.getChild("toolObj");
	if (editMode == 0)
	{
		editMode = 1;
		book.toggleEditMode();
		hostMenuDef = menu.getmenu();
		var def = [{item:"����", img:"#59432", action:book.Page.SaveForm},{item:"����",img:"#59470", action:toggleEditMode}];
		menu.reload(def);
	}
	else
	{
		if (window.confirm("�Ƿ�ȷ��Ҫ�˳��༭ģʽ?") == false)
				return;
		editMode = 0;
		book.toggleEditMode();
		menu.reload(hostMenuDef);
	}
}
function RefreshFilter(obj, item)	//ˢ��
{
//���¼���
	location.reload();
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
