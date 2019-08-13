<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanTermClass";
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
	{//如果cookie丢失，就从命令行取出账户，重设cookie
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanTermClass' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##388:服务器启动代码(归档用注释,切勿删改)
//
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>学期班次</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_406" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanTermClass", Role:<%=Purview%>};
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
		{item:"新增学期", img:"", action:NewTerm, info:"", Attrib:2, Param:0},
		{item:"编辑学期", img:"", action:EditTerm, info:"", Attrib:4, Param:0},
		{item:"删除学期", img:"", action:DeleTerm, info:"", Attrib:16, Param:0},
		{item:"", img:"", action:null, info:"", Attrib:0, Param:0},
		{item:"新增班次", img:"#59356", action:NewClass, info:"增加一条记录", Attrib:2, Param:0},
		{item:"编辑班次", img:"#59357", action:EditClass, info:"编辑当前记录", Attrib:4, Param:0},
		{item:"删除班次", img:"#59412", action:DelClass, info:"删除当前记录", Attrib:16, Param:0},
		{item:"页面编辑", img:"#59341", action:PageEdit, info:"", Attrib:2, Param:0}
			];
	book.setTool(Tools);
	var Links = [{item:"教学计划", img:"#57418", Code:"deanPlan", info:"", Attrib:0},
{item:"课程表", img:"#57401", Code:"deanCourse", info:"", Attrib:0},
{item:"课程问卷", img:"#57406", Code:"deanEvCourse", info:"", Attrib:0},
{item:"学籍考核表", img:"#57396", Code:"stDoc", info:"", Attrib:0},
{item:"学员名册", img:"#57378", Code:"stFile", info:"", Attrib:0}];
	book.setLink(Links);
//@@##389:客户端加载时(归档用注释,切勿删改)
//
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tFilter = new TermFilter(o, {Term_id:0});
	book.tFilter.onclick = ClickTerm;
	book.setPageObj(book.tFilter);
	book.onLink = LinkAddParam;
	book.termDBFun = new $.jcom.DBFun("../fvs/CPB_Term_form.jsp", {title:["新增学期","编辑学期"], width:400, height:260, mask:50, itemstyle:"font:normal normal normal 16px 微软雅黑"});
	book.termDBFun.onRecordChange = ReloadTerm;

//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##382:客户端自定义代码(归档用注释,切勿删改)
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
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_Class_list.jsp", {formitemstyle:"font:normal normal normal 16px 微软雅黑", 
			formvalstyle:"width:400px"}, {SeekKey:"CPB_Class.Term_id", SeekParam:item.Term_id}, {gridstyle:4, resizeflag:0});
	}
	else
		book.Page.Seek(item.Term_id, "CPB_Class.Term_id");	
}

function NewClass(obj, item)	//新增班次
{
//增加一条记录
	book.Page.NewItem();

}



function EditClass(obj, item)	//编辑班次
{
//编辑当前记录
	book.Page.EditItem();

}



function DelClass(obj, item)	//删除班次
{
//删除当前记录
	book.Page.DeleteItem();

}

function NewTerm(obj, item)	//新增学期
{
//
	book.termDBFun.NewRecord();
}

function EditTerm(obj, item)	//编辑学期
{
//
	var items = book.tFilter.getdata();
	var sel = book.tFilter.getsel();
	var index = parseInt($(sel).attr("node"));
	book.termDBFun.EditRecord(items[index].Term_id);

}

function DeleTerm(obj, item)	//删除学期
{
//
	var items = book.tFilter.getdata();
	var sel = book.tFilter.getsel();
	var index = parseInt($(sel).attr("node"));
	book.termDBFun.DelRecord(items[index].Term_id);
}

function ReloadTerm(nType)
{
	book.tFilter.refresh();
}

function PageEdit(obj, item)	//页面编辑
{
//
	book.Page.toggleEditMode(book);
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
