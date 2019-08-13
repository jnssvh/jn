<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanEvSet";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanEvSet' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##589:服务器启动代码(归档用注释,切勿删改)
//
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

int CreateCourseEvTask = WebChar.RequestInt(request, "CreateCourseEvTask");	
if (CreateCourseEvTask > 0)
{
	int EVTaskLen = WebChar.RequestInt(request, "EVTaskLen");
	int bHoliday = WebChar.RequestInt(request, "bHoliday");
	int AttendanceReq = WebChar.RequestInt(request, "AttendanceReq");
	int DelayMode = WebChar.RequestInt(request, "DelayMode");
	int ReEditable = WebChar.RequestInt(request, "ReEditable");
	int bAnonymous = WebChar.RequestInt(request, "bAnonymous");
	int Target = WebChar.RequestInt(request, "Target");
	String SubmitTime = VB.Now();
	String sql = "select Syllabuses_id, EndTime, Syllabuses_subject_id, Syllabuses_subject_name, Syllabuses_course_name, Syllabuses_teacher_id, Syllabuses_teacher_name, evaluate_id, class_id from CPB_Syllabuses where evaluate_id>0";
	String w1 = "", w2 = "";
	switch (Target)
	{
	case 1:		//学期范围
		w1 = "Term_id=" + Term_id;
		w2 = "TermID=" + Term_id;
		break;
	case 2:		//班次范围
	default:
		w1 = "Class_id=" + Class_id;
		w2 = "ClassIDs='" + Class_id + "'";
		break;
	}
	if (CreateCourseEvTask == 2)
	{
		sql = "update CPB_EvaluateTask set AttendanceReq=" + AttendanceReq + ", DelayMode=" + DelayMode + ", bAnonymous=" + bAnonymous + ", ReEditable=" + ReEditable + ",SubmitMan='" + user.CMemberName +"', SubmitTime='" +SubmitTime + "' where " + w2;		
		jdb.ExecuteSQL(0, sql);		
		out.print("OK");
		jdb.closeDBCon();
		return;
	}
	if (VB.isNotEmpty(w1)) {
		w1 = " AND " + w1;
	}
	ResultSet rs = jdb.rsSQL(0, sql + w1 + " order by BeginTime");
	while (rs.next())
	{
		String EndTime = VB.DateAdd("d", EVTaskLen, rs.getString("EndTime"));
		int ID = WebChar.ToInt(jdb.GetTableValue(0, "CPB_EvaluateTask", "ID", "CourseID", "" + rs.getString("Syllabuses_id")));
		if (ID > 0)
			sql = "update CPB_EvaluateTask set BeginTime='" + rs.getString("EndTime") + "',EndTime='" + EndTime + "', TeacherIDs='" + rs.getString("Syllabuses_teacher_id") + "', EvaluateID=" +
				rs.getInt("evaluate_id") + ", TaskName='" + rs.getString("Syllabuses_subject_name") + "', SubjectID=" + rs.getInt("Syllabuses_subject_id") + ",Teachers='" + rs.getString("Syllabuses_teacher_name") +
				"', AttendanceReq=" + AttendanceReq + ", DelayMode=" + DelayMode + ", bAnonymous=" + bAnonymous + ", ReEditable=" + ReEditable + ",SubmitMan='" + user.CMemberName +"', SubmitTime='" +SubmitTime + "' where ID=" + ID;		
		else
			sql = "insert into CPB_EvaluateTask(TermID, nType, EvaluateID,TaskName,CourseID, SubjectID, TeacherIDs, Teachers, ClassIDs, BeginTime, EndTime,AttendanceReq,DelayMode,bAnonymous,ReEditable, SubmitMan, SubmitTime) values(" +
				Term_id + ",1," + rs.getInt("evaluate_id") + ",'" + rs.getString("Syllabuses_subject_name") + "'," + rs.getInt("Syllabuses_id") + "," + rs.getInt("Syllabuses_subject_id") + ",'" + rs.getString("Syllabuses_teacher_id") +
				 "','" + rs.getString("Syllabuses_teacher_name") + "','" + rs.getInt("class_id") + "','" + rs.getString("EndTime") + "','" + EndTime + "'," + AttendanceReq + "," + DelayMode + "," + bAnonymous + "," + ReEditable + ",'" +
				user.CMemberName + "','" + SubmitTime + "')";
		jdb.ExecuteSQL(0, sql);		
	}
	jdb.ExecuteSQL(0, "delete from CPB_EvaluateTask where nType=1 and (SubmitMan<>'" + user.CMemberName + "' or SubmitTime<>'" + SubmitTime + "')" + w2);
	out.print("OK");
	jdb.closeDBCon();
	return;
}

	
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>评估任务</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_419" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanEvSet", Role:<%=Purview%>};
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
		{item:"创建任务", img:"", action:null, info:"", Attrib:2, Param:1, child:[
			{item:"创建课程评估任务", img:"", action:CreateCourseEvTask, info:"", Attrib:2, Param:1},
			{item:"创建模块评估任务", img:"", action:CreateModeEvTask, info:"", Attrib:2, Param:1},
			{item:"创建其它评估任务", img:"", action:CreateOtherEvTask, info:"", Attrib:2, Param:1}]},
		{item:"批量设置", img:"", action:EvTaskSet, info:"", Attrib:2, Param:1},
		{item:"删除任务", img:"", action:DelEvTask, info:"", Attrib:2, Param:1}
			];
	book.setTool(Tools);
//@@##587:客户端加载时(归档用注释,切勿删改)
//创建对象:Page
	var o = book.getDocObj("Page")[0];
	book.Page = new $.jcom.DBForm(o,  "../fvs/CPB_EvaluateTask_form.jsp",{}, {spaninput:1,itemstyle:"font:normal normal normal 15px 微软雅黑",valstyle:""});

	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tceFilter = new TCEFilter(o,{Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tceFilter.onclickEVTask = onclickEVTask;
	book.setPageObj(book.tcFilter);
	book.onLink = book.tceFilter.LinkAddParam;

//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##588:客户端自定义代码(归档用注释,切勿删改)
function onclickEVTask(obj, item)
{
	book.Page.getDBRecord(item.ID);
}

function CreateCourseEvTask(obj, item)	//创建课程评估任务
{
//
	CreateTaskOption(1);
}

function CreateTaskOption(nType)
{
	var items = book.tceFilter.getNodeItems();
	if ((items == undefined) || (items.length < 1))
			return alert("请先选择学期和班次");
	var CouseOptionwin = new $.jcom.PopupWin("<div id=CourseOptionForm style=width:100%;height:100%></div>", 
		{title:"评估任务选项", mask:50, width:320, height:360, resize:0,position:"fixed"});
	var fields = [{CName:"每条任务天数", EName: "EVTaskLen", InputType:1},
		 {CName:"天数跳过节假日", EName: "bHoliday", InputType:2},
		 {CName:"延期处理方式", EName: "DelayMode", InputType:4,Quote:"(1:不允许提交,2:允许提交)"},
		 {CName:"启用考勤关联", EName: "AttendanceReq", InputType:2},
		 {CName:"提交后允许修改", EName: "ReEditable", InputType:2},
		 {CName:"匿名评课", EName: "bAnonymous", InputType:2},
		 {CName:"班次", EName: "Class_id", InputType:21},
		 {CName:"任务对象", EName: "Target", InputType:3, Quote:"(1:当前学期,2:当前班次)"}
		];
	if (nType == 2)
	{
		fields[0].InputType=21;
		fields[1].InputType=21;
	}
	var form = new $.jcom.FormView($("#CourseOptionForm")[0], fields, {}, {action:location.pathname + "?CreateCourseEvTask=" + nType});
	form.setRecord({EVTaskLen:7, bHoliday:1, AttendanceReq:0,ReEditable:1, bAnonymous:1,Class_id: items[1].Class_id, Target:1});
	form.aftersubmit = function (result)
	{
		alert(result);
		if (result == "OK")
		{
			CouseOptionwin.close();
			location.reload(true);
		}
	};
}



function CreateModeEvTask(obj, item)	//创建模块评估任务
{
//
	alert("==");
}



var OtherTaskwin, otherform;
function CreateOtherEvTask(obj, item)	//创建其它评估任务
{
//
	var items = book.tceFilter.getNodeItems();
	if ((items == undefined) || (items.length < 1))
			return alert("请先选择学期和班次");
	if (typeof OtherTaskwin == "object")
		return OtherTaskwin.show();
	OtherTaskwin = new $.jcom.PopupWin("<div id=OtherTaskForm style=width:100%;height:100%;overflow-y:auto></div>", 
		{title:"创建其它评估任务", mask:50, width:640, height:620, resize:0, position:"fixed"});
	OtherTaskwin.close = OtherTaskwin.hide;
	otherform = new $.jcom.DBForm($("#OtherTaskForm")[0], "../fvs/CPB_EvaluateTask_other.jsp");
	otherform.CreatePredefObj = CreatePredefObj;
	otherform.onCheckForm = CheckClasses;
	otherform.onchange = FieldChange;
	otherform.onready = function (fields, record, t, jsp)
	{
		record.TermID = items[0].Term_id;
		record.TermID_ex = items[0].item;
		otherform.setRecord(record);
	}
	otherform.aftersubmit = function (result)
	{
		alert(result);
		if (result.substr(0, 2) == "OK")
		{
			OtherTaskwin.hide();
			location.reload(true);
		}
	};
	
}

function FieldChange(field, e)
{
if (field == undefined)
	return;
	if (field.EName == "nType")
	{
		var record = otherform.getRecord();
		otherform.FieldValue("TaskName", record.nType.ex);
	}
}

function CheckClasses(fields, record)
{
	var field = otherform.getFields("ClassIDs");
	var items = field.obj.getCheckedItems(0);
	if (items.length == 0)
	{
		alert("未选择班次");
		return false;
	}
	var ids = items[0].Class_id;
	for (var x = 1; x < items.length; x++)
	{
		ids += "," + items[x].Class_id;
	}
	record.ClassIDs = ids;
	otherform.FieldValue("ClassIDs", ids);
	return true;
}

function CreatePredefObj(obj, field)
{
	var items = book.tceFilter.getCasItems(1);
	obj.style.height = "";
	var c = new $.jcom.Cascade(obj, items, {title:["班次"], checkbox:1});
	return c;
}

function EvTaskSet(obj, item)	//批量设置
{
//
	CreateTaskOption(2);

}



function DelEvTask(obj, item)	//删除任务
{
//
	var item = book.tceFilter.getselItem(2);
	book.Page.DeleteRecord(item.ID, "正准备删除评课任务，是否确定?", function(data)
	{
		alert(data)
		location.reload();
	});
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
