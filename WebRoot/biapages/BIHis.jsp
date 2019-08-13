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
	String CodeName="BIHis";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='BIHis' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##192:服务器启动代码(归档用注释,切勿删改)
	String items;
	if (isAdmin)
		items = jdb.getJsonBySql(0, "select top 300 ID, comName as item from company");
	else
		items = jdb.getJsonBySql(0, "select ID, comName as item from company where official='" + user.CMemberName + "'");


//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>企业历史数据</title>
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"BIHis", Role:<%=Purview%>};
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
//@@##194:客户端加载时(归档用注释,切勿删改)
	if (comItems.length == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>只有企业用户和专管员才可以使用本页面。</div>");
		return;
	}
	var o = book.setDocTop("加载中...", "Filter", "");
	for (var x = 0; x < comItems.length; x++)
		comItems[x].nType = 0;
	if (comItems.length > 1)
		book.Filter = new $.jcom.Cascade(o, comItems, {title:["企业列表","调查计划","计划明细"]});
	else
	{
		book.Filter = new $.jcom.Cascade(o, [], {title:["调查计划","计划明细"]});
		ClickFilter(0, comItems[0]);
	}
	book.Filter.onclick = ClickFilter;
	book.setPageObj(book.Filter);
	book.Filter.SkipPage(1, true);
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##195:客户端自定义代码(归档用注释,切勿删改)
var comItems = <%=items%>;
function ClickFilter(obj, item)
{
	var node = "";
	if (typeof obj == "object")
		node = $(obj).attr("node");
	switch (item.nType)
	{
	case 0:
		$.get(location.pathname, {getPlan:1, comID: item.ID}, function(data)
		{
			var o = $.jcom.eval(data);
			if (typeof o == "string")
				return alert(o);
			for (var x = 0; x < o.Plans.length; x++)
			{
				o.Plans[x].nType = 1;
				o.Plans[x].child = [];
			}
			for (var x = 0; x < o.Details.length; x++)
			{
				o.Details[x].nType = 2;
				for (var y = 0; y < o.Plans.length; y++)
				{
					if (o.Plans[y].ID == o.Details[x].mainId)
						o.Plans[y].child[o.Plans[y].child.length] = o.Details[x];
				}
			}
			book.Filter.loadLegend(o.Plans, node);
			book.Filter.SkipPage(1, true);
		});
		break;
	case 1:
		book.Filter.SkipPage(1, true);
		break;
	case 2:
		var plan = book.Filter.getselItem(1);
		var com = book.Filter.getselItem(0);
		if (book.Page == undefined)
		{
			var o = book.getDocObj("Page")[0];
			book.Page = new AsSysInvestView(o, 0, {mode:2});
		}
		book.Page.loadAskPaper(com, plan, item);
		break;
	}	
}

function LoadPlanOK(data)
{
	book.Filter.alert(data);
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
