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
	{//如果cookie丢失，就从命令行取出账户，重设cookie
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
	<title>计划制定</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2019-4-28 -->
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
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	var Tools = [
		{item:"新增", img:"#59356", action:NewRecordFilter, info:"增加一条记录", Attrib:2, Param:1},
		{item:"编辑", img:"#59357", action:EditRecordFilter, info:"编辑当前记录", Attrib:2, Param:1},
		{item:"删除", img:"#58996", action:DelRecordFilter, info:"删除当前记录", Attrib:2, Param:1},
		{item:"刷新", img:"#58976", action:RefreshFilter, info:"重新加载", Attrib:1, Param:1}
			];
	book.setTool(Tools);
//@@##136:客户端加载时(归档用注释,切勿删改)
//创建对象:Filter
	var o = book.setDocTop("加载中...", "Filter", "");
	book.Filter = new $.jcom.DBCascade(o, env.fvs + "/asInvestPlan_view.jsp", {}, {}, {title:["计划"]});
	book.Filter.onclick = ClickFilter;
	book.setPageObj(book.Filter);
	book.Filter.onReady = FilterReady;
	var o = book.setDocBottom("", "paper");
	book.asView = new AsSysInvestView(o, 0, {title:"调查问卷样本"});

//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##129:客户端自定义代码(归档用注释,切勿删改)
function ClickFilter(obj, item)
{
	if (book.Page == undefined)
	{
		var o = book.getDocObj("Page")[0];
		book.Page = new $.jcom.DBForm(o,  env.fvs + "/asInvestPlan_form.jsp", {DataID:item.ID}, 
			{itemstyle:"font:normal normal normal 16px 微软雅黑",valstyle:"width:400px"});
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
		var tag = "<h2 align=center>被调查企业</h2>";
		if (editMode != 0)
		{
			cfg.bodystyle  = 2;
			tag += "&nbsp;&nbsp;<input type=button onclick=InsertCom() value=增加>&nbsp;<input type=button onclick=DelCom() value=删除></div>";
		}
		field.editor = new $.jcom.GridView($("#" + field.EName + "_DIV")[0], [{FieldName:"comName", TitleName:"企业名称", nWidth:400}],[],{}, cfg);
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
			"<div style=float:right><input id=InsertFromCom type=button value=确定>&nbsp;&nbsp;</div>", 
				{title:"选择企业", width:640, height:480, mask:50,position:"fixed"});
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
		return alert("请先选择企业");
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
		return alert("请先勾选企业");
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

function NewRecordFilter(obj, item)	//新增
{
//增加一条记录
//	book.Filter.NewItem();
	toggleEditMode();
	book.Page.reset(0, 0, {formtype:4});
	book.Page.getDBRecord(0);
}



function EditRecordFilter(obj, item)	//编辑
{
//编辑当前记录
//	book.Filter.EditItem();
	toggleEditMode();
	book.Page.reset(0, 0, {formtype:4});
}



function DelRecordFilter(obj, item)	//删除
{
//删除当前记录
	book.Filter.DeleteItem({fun:SubmitResult});
}

function SubmitResult(data)
{
	alert(data);
	location.reload();	
}

var editMode = 0, hostMenuDef;
function toggleEditMode()		//方法:在全屏编辑模式和阅读模式之间切换
{
	var menu = book.getChild("toolObj");
	if (editMode == 0)
	{
		editMode = 1;
		book.toggleEditMode();
		hostMenuDef = menu.getmenu();
		var def = [{item:"保存", img:"#59432", action:book.Page.SaveForm},{item:"结束",img:"#59470", action:toggleEditMode}];
		menu.reload(def);
	}
	else
	{
		if (window.confirm("是否确定要退出编辑模式?") == false)
				return;
		editMode = 0;
		book.toggleEditMode();
		menu.reload(hostMenuDef);
	}
}
function RefreshFilter(obj, item)	//刷新
{
//重新加载
	location.reload();
}

//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
