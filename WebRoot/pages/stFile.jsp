<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="stFile";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='stFile' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##326:服务器启动代码(归档用注释,切勿删改)
	int Class_id = WebChar.RequestInt(request, "Class_id");
	int Term_id  = 0;
	if (Class_id > 0)
		Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>学员名册</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-8-29 -->
<style id="css_283" type="text/css">
body{
background: #e9ebee url(../res/skin/p3.jpg) no-repeat fixed;
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"stFile", Role:<%=Purview%>};
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
		{item:"学员名册", img:"../pic/flow_end.png", action:SetView, info:"", Attrib:1},
		{item:"学籍汇总", img:"", action:SetView, info:"", Attrib:1},
		{item:"考核汇总", img:"", action:SetView, info:"", Attrib:1},
		{item:"学籍考核", img:"", action:SetView, info:"", Attrib:1},
		{item:"", img:"", action:null, info:"", Attrib:1},
		{item:"查询", img:"../pic/c3.png", action:SeekPage, info:"全文检索", Attrib:1},
		{item:"新增", img:"../pic/new_folder.png", action:NewRecordPage, info:"增加一条记录", Attrib:2},
		{item:"编辑", img:"../pic/wendang.png", action:EditRecordPage, info:"编辑当前记录", Attrib:2},
		{item:"删除", img:"../pic/lj.png", action:DelRecordPage, info:"删除当前记录", Attrib:2},
		{item:"刷新", img:"../pic/refur.gif", action:RefreshPage, info:"重新加载", Attrib:1},
		{item:"工具", img:"", action:null, info:"", Attrib:2, child:[
			{item:"按姓氏笔划排序", img:"", action:null, info:"", Attrib:2},
			{item:"自动分组设置", img:"", action:null, info:"", Attrib:2},
			{item:"自动生成学号", img:"", action:null, info:"", Attrib:2},
			{item:"导入学员学号", img:"", action:null, info:"", Attrib:2},
			{item:"手动设置", img:"", action:null, info:"手动设置学号，组号，及职务", Attrib:2},
			{item:"班干部设置", img:"", action:null, info:"", Attrib:2},
			{item:"统一设置考核项", img:"", action:null, info:"", Attrib:2},
			{item:"手动设置考核项", img:"", action:null, info:"", Attrib:2}]}
			];
	book.setTool(Tools);
	var Links = [{item:"教学计划", img:"", Code:"deanPlan", info:"", Attrib:0},
{item:"课程表", img:"", Code:"deanCourse", info:"", Attrib:0}];
	book.setLink(Links);
//@@##325:客户端加载时(归档用注释,切勿删改)
	$("#Page").css({padding: "20px 20px 20px 20px"});
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/SS_Student2.jsp",{}, {}, {gridstyle:3, resizeflag:0});
	book.Page.makeThumb = makeThumb;

	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tcFilter = new TermClassFilter(o, {Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tcFilter.onclickClass = ClickClass;
	book.setPageObj(book.tcFilter);
	book.onLink = book.tcFilter.LinkAddParam;

//(归档用注释,切勿删改)ClientStartCode End##@@
}
//@@##318:客户端自定义代码(归档用注释,切勿删改)
function SeekPage(obj, item)	//查询
{
//全文检索
	book.Page.Seek();

}



function NewRecordPage(obj, item)	//新增
{
//增加一条记录
	book.Page.NewItem();

}



function EditRecordPage(obj, item)	//编辑
{
//编辑当前记录
	book.Page.EditItem();

}



function DelRecordPage(obj, item)	//删除
{
//删除当前记录
	book.Page.DeleteItem();

}



function RefreshPage(obj, item)	//刷新
{
//重新加载
	book.Page.ReloadGrid();

}

function ClickClass(obj, item)
{
	book.Page.config({URLParam:"?ClassID=" + item.Class_id});
	book.Page.ReloadGrid();
}

var listname = "学员名册";
function SetView(obj, item)	//学员名册
{
//
	var o = book.getChild();
	var def = o.toolObj.getmenu();
	def[0].img = "";
	def[1].img = "";
	def[2].img = "";
	def[3].img = "";
	item.img = "../pic/flow_end.png";
	o.toolObj.show();
	listname = item.item;
	book.Page.ReloadGrid();
}

function makeThumb(line, hint, index, item)
{
	if (typeof item.RegID == "undefined")
		return "<div name=thumbdiv style='clear:both;padding:4px;margin:4px;' node=" + index + ">" + item.STdNo.value + "</div>";
	else if (typeof item.RegID == "object")
		return "";

	var img = "<img style='float:left;width:180px;height:180px' src=" + item.Photo + ">";
	var o = book.Page.getChildren();
	var h = o.gridhead;
	switch (listname)
	{
	case "学员名册":
		return "<span name=thumbdiv style='float:left;width:200px;padding:4px;margin:4px;border:1px solid #c0c0c0;background-color:#fcfcfc;' node=" + index +
			"><div align=center style='width:180px;height:180px;overflow:hidden;'>" +img + "</div>" +
			"<div align=center><span style=color:gray>" + item.STdNo + "</span><span style='font:normal normal bolder 12pt 微软雅黑'>" +line + "</span></div>" +
			"<div style=height:45px;text-overflow:ellipsis;overflow:hidden;>" + item.WorkUnit + "</div></span>";
	default:
		var div1 = "", div2 = "", div3 = "", div4 = "", div5 = "", div6 = "";
		div1 = "<div style=float:left;width:180px;padding:4px;><span style=color:gray>学号:" + item.STdNo + "</span><br>" + 
			"<span style=color:gray>姓名:</span><span style='font:normal normal bolder 12pt 微软雅黑'>" + item.StdName + "</span><br>" +
			"<span style=color:gray>性别:" + h.getItemValue(item, "Gender") + "</span><br>" + 
			"<span style=color:gray>民族:" + h.getItemValue(item, "Nation") + "</span><br>" + 
			"<span style=color:gray>出生年月:" + h.getItemValue(item, "Birthday") + "</span><br>" + 
			"<span style=color:gray>手机:" + item.Mobile + "</span><br>" + 
			"<span style=color:gray>单位及职务:" + item.WorkUnit + "</span></div>";
		if (listname != "考核汇总")
		{
			div2 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>出生地:" + h.getItemValue(item, "BirthPlace") + "</span><br>" + 
				"<span style='color:gray'>政治面貌:" + h.getItemValue(item, "PoliticalStatus") + "</span><br>" +
				"<span style=color:gray>参加工作时间:" + h.getItemValue(item, "WorkDate") + "</span><br>" + 
				"<span style=color:gray>学历:" + h.getItemValue(item, "Education") + "</span><br>" + 
				"<span style=color:gray>学位:" + h.getItemValue(item, "Degree") + "</span><br>" + 
				"<span style=color:gray>所学专业:" + h.getItemValue(item, "Specialty") + "</span><br>" + 
				"<span style=color:gray>毕业院校:" + h.getItemValue(item, "GraSchool") + "</span></div>";
			div3 = "<div style=float:left;width:190px;padding:4px;>" +
				"<span style=color:gray>行政级别:" + h.getItemValue(item, "GovLevel") + "</span><br>" + 
				"<span style='color:gray'>职称:" + h.getItemValue(item, "JobTitle") + "</span><br>" +
				"<span style=color:gray>证件号:" + h.getItemValue(item, "IDCard") + "</span><br>" + 
				"<span style=color:gray>邮箱:" + h.getItemValue(item, "EMail") + "</span><br>" + 
				"<span style=color:gray>邮编:" + h.getItemValue(item, "PostCode") + "</span><br>" + 
				"<span style=color:gray>任现职时间:" + h.getItemValue(item, "DutyDate") + "</span><br>" + 
				"<span style=color:gray>通信地址:" + h.getItemValue(item, "WorkPlace") + "</span></div>";
		}
		if (listname != "学籍汇总")
		{
			div4 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>班级职务:" + h.getItemValue(item, "ClassDuty") + "</span><br>" + 
				"<span style='color:gray'>分组号:" + h.getItemValue(item, "GroupNo") + "</span><br>" +
				"<span style=color:gray>请假(天):" + h.getItemValue(item, "Check1") + "</span><br>" + 
				"<span style=color:gray>旷课(天):" + h.getItemValue(item, "Check2") + "</span><br>" + 
				"<span style=color:gray>迟到早退(次):" + h.getItemValue(item, "Check3") + "</span><br>" + 
				"<span style=color:gray>考勤得分:" + h.getItemValue(item, "CheckScore") + "</span><br>" + 
				"<span style=color:gray>遵守规定情况:" + h.getItemValue(item, "RuleNote") + "</span></div>";
			div5 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>考试(考查):" + h.getItemValue(item, "Score1") + "</span><br>" + 
				"<span style='color:gray'>论文(学习心得):" + h.getItemValue(item, "Score2") + "</span><br>" +
				"<span style=color:gray>调研报告:" + h.getItemValue(item, "Score3") + "</span><br>" + 
				"<span style=color:gray>综合学习考核得分:" + h.getItemValue(item, "Score4") + "</span><br>" + 
				"<span style=color:gray>学籍变动情况:" + h.getItemValue(item, "ChangeContent") + "</span><br>" + 
				"<span style=color:gray>奖惩情况:" + h.getItemValue(item, "PanishContent") + "</span></div>";
			div6 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>离校日期:" + h.getItemValue(item, "LeaveDate") + "</span><br>" + 
				"<span style='color:gray'>离校原因:" + h.getItemValue(item, "LeaveInfo") + "</span><br>" +
				"<span style=color:gray>备注:" + h.getItemValue(item, "Note") + "</span></div>";
		}
			
		return "<div name=thumbdiv style='float:left;padding:4px;margin:0px;border-bottom:1px solid gray;background-color:#fcfcfc;' node=" + index + ">" +
			img + div1 + div2 + div3 + div4 + div5 + div6 + "</div>";
	}
	
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
