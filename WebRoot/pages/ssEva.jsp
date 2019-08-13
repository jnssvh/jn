<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="ssEva";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='ssEva' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##495:服务器启动代码(归档用注释,切勿删改)
if (WebChar.RequestInt(request, "SaveFlag") == 1)
{
	int instance_id  = WebChar.RequestInt(request, "instance_id");
	int TaskID  = WebChar.RequestInt(request, "TaskID");
	int Syllabuses_id = WebChar.RequestInt(request, "Syllabuses_id");
	int evaluate_id = WebChar.RequestInt(request, "evaluate_id");
	int Total = WebChar.RequestInt(request, "Total");
	String feedback = WebChar.requestStr(request, "feedback");
	String sql;
	if (instance_id > 0)
	{
		sql = "update CPB_Evaluate_instance set score=" + Total + ", feedback='" + feedback + "',submit_time='" + VB.Now() + "' where instance_id=" + instance_id;
		result  = jdb.ExecuteSQL(0, sql);
	}
	else
	{
		instance_id = jdb.getIntBySql(0, "select instance_id from CPB_Evaluate_instance where TaskID=" + TaskID + " and submit_man=" + user.UserID);
		if (instance_id > 0)
			sql = "update CPB_Evaluate_instance set score=" + Total + ", feedback='" + feedback + "',submit_time='" + VB.Now() + "' where instance_id=" + instance_id;			
		else
		 	sql = "insert into CPB_Evaluate_instance (TaskID, Syllabuses_id, evaluate_id, Evaluate_Manner, isAll, score, feedback, submit_man, submit_time) values(" +
	 			TaskID + "," + Syllabuses_id + "," + evaluate_id + ",5,1," + Total + ",'" + feedback + "'," + user.UserID + ",'" + VB.Now() + "')";
		result  = jdb.ExecuteSQL(0, sql);
		instance_id = jdb.getIntBySql(0, "select instance_id from CPB_Evaluate_instance where Syllabuses_id=" + Syllabuses_id + " and submit_man=" + user.UserID);
	}
	
	String tmp[] = request.getParameterValues("Evaluate_item_id");
	int len = 0;
	if (tmp != null)
		len = tmp.length;
	for (int x = 0; x < len; x++)
	{
		int Evaluate_item_id = WebChar.ToInt(WebChar.RequestForms(request, "Evaluate_item_id", x));
		int score = WebChar.ToInt(WebChar.RequestForms(request, "score", x));
		String Evalute_opinion = WebChar.RequestForms(request, "Evalute_opinion", x);
		int inst_detail_id = jdb.getIntBySql(0, "select inst_detail_id from CPB_EvaInstDetail where instance_id=" + instance_id + " and Evaluate_item_id=" + Evaluate_item_id);
		if (inst_detail_id > 0)
			sql = "update CPB_EvaInstDetail set score=" + score + ", Evalute_opinion='" + Evalute_opinion + "' where inst_detail_id=" + inst_detail_id;			
		else
		 	sql = "insert into CPB_EvaInstDetail (instance_id, Evaluate_item_id, score, Evalute_opinion) values(" +
		 			instance_id + "," + Evaluate_item_id + "," + score + ",'" + Evalute_opinion + "')";
		result = jdb.ExecuteSQL(0, sql);		
	}
	
	out.print("OK:提交答卷成功。");
	jdb.closeDBCon();
	return;	
}

if (WebChar.RequestInt(request, "GetStudentAnswer") == 1)
{
//	String sql = "select instance_id, TaskID, Syllabuses_id, score,submit_man, submit_time from CPB_Evaluate_instance where submit_man in (select ID from Member where EName='" + user.EMemberName + "') order by submit_time";
	String sql = "select instance_id, TaskID, Syllabuses_id, score,submit_man, submit_time from CPB_Evaluate_instance where submit_man=" + user.UserID + " order by submit_time";
	String m =jdb.getJsonBySql(0, sql);
//	sql = "select instance_id,Evaluate_item_id, score,Evalute_opinion from CPB_EvaInstDetail where instance_id in (select instance_id from CPB_Evaluate_instance where submit_man in (select ID from Member where EName='" + user.EMemberName + "'))";
	sql = "select instance_id,Evaluate_item_id, score,Evalute_opinion from CPB_EvaInstDetail where instance_id in (select instance_id from CPB_Evaluate_instance where submit_man=" + user.UserID + ")";
	String d =jdb.getJsonBySql(0, sql);
	out.print("{Main:" + m + ", Detail:" + d + "}");
	jdb.closeDBCon();
	return;
}
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>教学评估</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_496" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"ssEva", Role:<%=Purview%>};
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
//@@##491:客户端加载时(归档用注释,切勿删改)
//创建对象:Filter
	var o = book.setDocTop("加载中...", "Filter", "");
//	book.Filter = new $.jcom.DBCascade(o, "../fvs/CPB_EvaluateTask_view.jsp", {URLParam:"?ClassIDs=<%=user.MemberDept%>"}, {}, {title:["任务分类","评估任务"]});
	book.Filter = new $.jcom.Cascade(o, "正在加载...", {title:["任务分类","评估任务"]});
	$.get(location.pathname, {GetStudentAnswer:1}, getAnswerOK);
	book.Filter.onclick = clickEVTask;
	book.setPageObj(book.Filter);
	book.Page = new EvalutionPaper($("#Page")[0], {viewmode:2});


//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##494:客户端自定义代码(归档用注释,切勿删改)
//

var answerRecords = [];
function getAnswerOK(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return alert(json);
	for (var x = 0; x < json.Main.length; x++)
		answerRecords[x] = {Main:json.Main[x], Detail:[]};
	
	for (var x = 0; x < json.Detail.length; x++)
	{
		for (var y = 0; y < answerRecords.length; y++)
		{
			if (answerRecords[y].Main.instance_id == json.Detail[x].instance_id)
				answerRecords[y].Detail[answerRecords[y].Detail.length] = json.Detail[x];	
		}
	}	
	$.get("../fvs/CPB_EvaluateTask_view.jsp", {GetGridData:1, ClassIDs:<%=user.MemberDept%>}, loadEVTask);
}

function loadEVTask(data)
{
	var items = [{item:"待评估任务", nType:1, child:[]},{item:"已评估任务", nType:2, child:[]},{item:"未开始任务", nType:3, child:[]},{item:"全部任务", nType:4}];
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return alert(json);
	var now = new Date();
	for (var x = 0; x < json.Data.length; x++)
	{
		json.Data[x].item = "(" + $.jcom.GetDateTimeString(json.Data[x].BeginTime,1) + "~" + $.jcom.GetDateTimeString(json.Data[x].EndTime, 10) + ") " +
			json.Data[x].TaskName + "(" + json.Data[x].Teachers + ")";
		for (var y = 0; y < answerRecords.length; y++)
		{
			if (parseInt(json.Data[x].ID) == answerRecords[y].Main.TaskID)
			{
				items[1].child[items[1].child.length] = json.Data[x];
				json.Data[x].item += "-已评估";
				json.Data[x].answerIndex = y;
				break;
			}
		}
		if (y == answerRecords.length)
		{
			var starttime = $.jcom.makeDateObj(json.Data[x].BeginTime);
			if (starttime > now)
				items[2].child[items[2].child.length] = json.Data[x];
			else
				items[0].child[items[0].child.length] = json.Data[x];
		}
	}
	items[3].child = json.Data;
	for (var x = 0; x < items.length; x++)
		items[x].item += "(" + items[x].child.length + ")";
	book.Filter.reload(items);
	$.get("ssCheck.jsp", {GetAttendance:1}, GetAttendanceOK);
}

function GetAttendanceOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
	var StatusEnum = ["正常","迟到","早退","迟到早退","事假","病假","缺勤","公假","未考勤","正常"];
	for (var x = 0; x < items.length; x++)
		items[x].Status_ex = StatusEnum[items[x].Status];

	var casitems = book.Filter.getdata();
	var tasks = casitems[3].child;
	for (var x = 0; x < tasks.length; x++)
	{
		for (var y = 0; y < items.length; y++)
		{
			if (items[y].SyllabusesId == tasks[x].CourseID)
				tasks[x].AttendObj = items[y];
		}
	}
	book.Filter.SkipPage(1, true);	
}

function clickEVTask(obj, item)
{
	if (typeof item.child == "object")
	{
		if (item.child.length > 0)
			book.Filter.SkipPage(1, true);
		return;
	}
	var answer;
	if (item.answerIndex != undefined)
		answer = answerRecords[item.answerIndex];
	book.Page.loadEVTaskForm(item, answer, location.pathname + "?SaveFlag=1");
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
