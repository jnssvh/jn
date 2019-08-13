<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="ssManual";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='ssManual' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>学员手册 </title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-8-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"ssManual", Role:<%=Purview%>};
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
		{item:"新增", img:"#59356", action:NewRecordPage, info:"增加一条记录", Attrib:2},
		{item:"编辑", img:"#59357", action:EditRecordPage, info:"编辑当前记录", Attrib:2},
		{item:"删除", img:"#58996", action:DelRecordPage, info:"删除当前记录", Attrib:2},
		{item:"刷新", img:"#58976", action:RefreshPage, info:"重新加载", Attrib:2}
			];
	book.setTool(Tools);
//@@##469:客户端加载时(归档用注释,切勿删改)
//创建对象:Filter
	var o = book.setDocTop("加载中...", "Filter", "");
	book.Filter = new $.jcom.DBCascade(o, "../fvs/UserDatas_viewManual.jsp", {}, {}, {title:["目录"]});
	book.setPageObj(book.Filter);
	book.Filter.onclick = clickFile;

//创建对象:Page
	var o = book.getDocObj("Page")[0];
	book.Page = new $.jcom.DBTree(o,  "../fvs/UserDatas_viewManual.jsp",{}, {itemstyle:"font:normal normal normal 15px 微软雅黑",rollbkcolor:false,selbkcolor:false});

	$("#Page").css({padding: "20px 20px 20px 20px"});
	book.Page.PrepareData = PrepareData;

//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##470:客户端自定义代码(归档用注释,切勿删改)
//
function clickFile(obj, item)
{
	var obj = book.Page.getNodeObj(0, $(obj).attr("node"));
	obj.scrollIntoView();
}

function PrepareData(items)
{
	for (var x = 0; x < items.length; x++)
	{
		items[x].item = "<h1>" + items[x].CName + "</h1><div>" + items[x]. Content + "</div>";
	}
	return items;
}

function NewRecordPage(obj, item)	//新增
{
//增加一条记录
book.Filter.NewItem();
}



function EditRecordPage(obj, item)	//编辑
{
//编辑当前记录
book.Filter.EditItem();
}



function DelRecordPage(obj, item)	//删除
{
//删除当前记录
book.Filter.DeleteItem();
}



function RefreshPage(obj, item)	//刷新
{
//重新加载
book.Page.reload();
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
