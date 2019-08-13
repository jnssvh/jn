<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanEvStat3";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanEvStat3' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>教师课程统计</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanEvStat3", Role:<%=Purview%>};
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
//@@##643:客户端加载时(归档用注释,切勿删改)
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.Filter = new DeptTeacherFilter(o, {Dept_id:0});
	//book.Filter.onclickClass = ClickEVTask;
	book.setPageObj(book.Filter);
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##640:客户端自定义代码(归档用注释,切勿删改)
function DeptFilter(domobj, cfg)	//部门级联选择类
{
	var self = this;
	cfg = $.jcom.initObjVal( {title:["部门"], itemimg:["#9726"], prep:"", ID:0}, cfg);
	var data = [];
	$.jcom.DBCascade.call(this, domobj, "../fvs/SS_Dept_list_teacher.jsp", {}, {OrderField:"DeptNo", bDesc:1}, cfg);
	
	this.PrepareData = function (items, head)
	{
		for (var x = 0; x < items.length; x++)
		{
			items[x].item = items[x].DeptName;
			items[x].child = null;
		}
		return items;
	};

	this.onReady = function (items)
	{
		if (cfg.Term_id > 0)
		{
			for (var x = 0; x < items.length; x++)
			{
				if (items[x].ID == cfg.ID)
				{
					self.select(x);
					return;
				}
			}
		}
		else if (items.length > 0)
			self.SkipPage(1, true);
	};
}


function DeptTeacherFilter(domobj, cfg)	 //部门-教师 级联选择类
{
	var self = this;
	cfg = $.jcom.initObjVal( {title:["部门", "教师"], itemimg:["#57371", "#57434"], prep:"", ID:0, TeacherId: 0}, cfg);
	var data = [];
	DeptFilter.call(this, domobj, cfg);
		
	this.loadnode = function (item, node)
	{
		var fun = function(result)
		{
			var json = $.jcom.eval(result);
			if (typeof json == "string")
				return alert(json);
			var sub = -1;
			for (var x = 0; x < json.length; x++)
			{
				json[x].item = json[x].CName;
				if (json[x].ID == cfg.ID)
					sub = x;					
			}
			item.child = json;
			self.loadnodeok(item, node);
			if (sub >= 0)
			{
				self.select(node + "," + sub);
				var obj = self.getsel(1);
//				var obj = $("span[node='" + node + "," + sub + "']")[0];
				self.onclick(obj, item.child[sub]);
				return;
			}
			else if (json.length > 0)
				self.SkipPage(1, true);
		};
		
		var ss = node.split(",");
		if (ss.length == 1)
			$.get("../fvs/SS_Member_list_teacher.jsp"
			, {URLParam:"?dept_id=" + item.ID + "&dept_no=" + item.DeptNo, GetTreeData:1, nFormat:0}, fun);
		else
			self.loadNextNode(item, node);
	};
	
	this.loadNextNode = function(item, node)
	{
	};
	
	this.onclick = function(obj, item)
	{
		var node = $(obj).attr("node");
		if (node == undefined)
			return;
		var ss = node.split(",");
		switch (ss.length)
		{
		case 1:		//Dept
			if ((item.child != null) && (item.child.length > 0) && (cfg.title.length > 1))
				self.SkipPage(1, true);
			self.onclickDept(obj, item);
			break;
		case 2:		//Teacher
			self.onclickTeacher(obj, item);
			break;
		default:
			self.onclickOther(obj, item);
			break;
		}
	};

	this.onclickDept = function(obj, item)
	{
		
	};
	
	this.onclickTeacher = function(obj, item)
	{
	if (book.Page == undefined)
	{
		book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/CPB_EvaluateTask_deanEvStat3.jsp"
			, {formitemstyle:"font:normal normal normal 16px 微软雅黑", 
			formvalstyle:"width:400px"}, {URLParam:"?teacher_id=" +item.ID + "&dept_no=" + item.Dept}
			, {gridstyle:4, resizeflag:0});
	}
	else {
		book.Page.config({URLParam:"?teacher_id=" +item.ID + "&dept_no=" + item.Dept});
		book.Page.ReloadGrid();
	}

	};
	
	this.onclickOther = function (obj, item)
	{
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
