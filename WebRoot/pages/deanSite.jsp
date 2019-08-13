<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanSite";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanSite' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##535:服务器启动代码(归档用注释,切勿删改)
//
	if (WebChar.RequestInt(request, "SaveMap") == 1)
	{
		String SeatMap = WebChar.requestStr(request, "SeatMap");
		int DataID = WebChar.RequestInt(request, "DataID");
		if (DataID > 0)
			jdb.ExecuteSQL(0, "update Place set SeatMap='" +SeatMap + "' where ID=" + DataID);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}

//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>教学场所</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_268" type="text/css">
body{
background: gray;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanSite", Role:<%=Purview%>};
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
		{item:"新增场所", img:"", action:NewSite, info:"", Attrib:0, Param:0},
		{item:"编辑场所", img:"", action:EditSite, info:"", Attrib:0, Param:0},
		{item:"删除场所", img:"", action:DeleSite, info:"", Attrib:0, Param:0},
		{item:"", img:"", action:null, info:"", Attrib:0, Param:1},
		{item:"座位设置", img:"", action:SetSiteSeat, info:"", Attrib:0, Param:0}
			];
	book.setTool(Tools);
//@@##310:客户端加载时(归档用注释,切勿删改)
//创建对象:Filter
	var o = book.setDocTop("加载中...", "Filter", "");
//	$("#Page").css({padding: "0px 60px 0px 60px"});
	book.Filter = new $.jcom.DBCascade(o, "../fvs/Place_Archive.jsp", {}, {}, {title:["场所"]});
	book.setPageObj(book.Filter);
	book.Filter.onclick = ClickSite;

//	book.Page = new SiteSeatMap(book.getDocObj("Page")[0], [],{});
	book.Page = new SitePage(book.getDocObj("Page")[0]);

//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##311:客户端自定义代码(归档用注释,切勿删改)
//
function ClickSite(obj, item)
{
	book.Page.LoadSite(item);
}

function NewSite(obj, item)	//新增场所
{
//
	book.Filter.NewItem();
}



function EditSite(obj, item)	//编辑场所
{
//
	book.Filter.EditItem();
}



function DeleSite(obj, item)	//删除场所
{
//
	book.Filter.DeleteItem();
}

var seatEditMode = 0;
function SetSiteSeat(obj, item)	//座位设置
{
//
//	book.Page.map.SetMap();
	if (seatEditMode == 0)
	{
		book.toggleEditMode();
		var Menubar = book.getChild("toolObj");
		seatEditMode = 1;
		var def = [{item:"新建", img:"#59356", action:book.Page.map.SetMap},
			{item:"保存", img:"#59432", action:SaveMap},{item:"结束",img:"#59470", action:SetSiteSeat}];
		Menubar.reload(def);
	}
	else
	{
		if (window.confirm("是否确定要退出编辑模式?") == false)
			return;
		seatEditMode = 0;
		book.toggleEditMode();
	}

}

function SaveMap()
{
	book.Page.map.SaveMap(location.pathname + "?SaveMap=1");
//	var item = book.Filter.getselItem();
//	alert(item.SeatMap);
	
}

function SitePage(domobj, cfg)
{
	var self = this;
	var tag = "<div id=SiteTitleDiv align=center style='font-size:18pt;padding-top:20px;'>场所名称</div>" +
		"<div style='font-size:14pt;padding-top:20px;'>场所信息</div><div id=SiteInfoDiv style=min-height:200px></div>" +
		"<div style='font-size:14pt;padding-top:20px;'>座位图</div><div id=SeatMapBox></div>";
	$(domobj).html(tag);
	var box = new $.jcom.SlideBox($("#SeatMapBox")[0], "SeatMapDiv");
	self.map  = new SiteSeatMap($("#SeatMapDiv")[0]);
	
	this.LoadSite = function (item)
	{
		$("#SiteTitleDiv").html(item.item);
		var tag = "<div style=width:90%;height:200px>场所图片未设置</div>";
		if (item.Image > 0)
		var tag = "<img src=../com/down.jsp?AffixID=" + item.Image + " style=width:90%><br>";
		tag += "面积:" + item.Area + ", 座位:" + item.Seats ;
		$("#SiteInfoDiv").html(tag);
		self.map.LoadMap(item);
	};
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
