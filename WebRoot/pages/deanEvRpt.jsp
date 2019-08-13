<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanEvRpt";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanEvRpt' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##447:服务器启动代码(归档用注释,切勿删改)
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));
if (WebChar.RequestInt(request, "GetEVTaskAnswer") == 1)
{
	int TaskID = WebChar.RequestInt(request, "TaskID");
//	String sql = "select ename,cname from CPB_Evaluate_instance S left join member M on M.id=S.submit_man where S.Syllabuses_Id = " + Syllabuses_id;
//	jdb.ExecuteSQL(0, "update CPB_Evaluate_instance set TaskID=" + TaskID + " where Syllabuses_id in (select CourseID from CPB_EvaluateTask where ID=" + TaskID + ")");//为以前数据设置评估任务号，临时代码
	String sql = "select instance_id, score,feedback, submit_man, submit_time from CPB_Evaluate_instance where TaskID = " + TaskID + " order by submit_time";
	String m =jdb.getJsonBySql(0, sql);
	sql = "select Evaluate_item_id, instance_id, score,Evalute_opinion from CPB_EvaInstDetail where instance_id in (select instance_id from CPB_Evaluate_instance where TaskID = " + TaskID + ")";
	String d =jdb.getJsonBySql(0, sql);
//	sql = "select RegID, StdName, STdNo, Member.ID as MemberID from SS_Student left join Member on Member.EName=SS_Student.STdNo where ClassID=" + Class_id;
	sql = "select RegID, StdName, STdNo from SS_Student where ClassID=" + Class_id;
	String s =jdb.getJsonBySql(0, sql);
	out.print("{Main:" + m + ", Detail:" + d + ", Users:" + s + "}");
	jdb.closeDBCon();
	return;
}
if (WebChar.RequestInt(request, "DataTrans") == 1)
{
	String sql = "select * from CPB_Evaluate_instance order by submit_time";
	ResultSet rs = jdb.rsSQL(0, sql);
	while (rs.next())
	{
		if (rs.getString("scanfile") == null)
		{
			int regid = jdb.getIntBySql(0, "select RegID from SS_Student where STdNo in (select EName from Member where ID=" + rs.getInt("submit_man") + ")");
			if (regid > 0)
			{
				sql = "update CPB_Evaluate_instance set submit_man=" + regid + ",scanfile='" + rs.getInt("submit_man") + "' where instance_id=" + rs.getInt("instance_id");
				jdb.ExecuteSQL(0, sql);
			}
		}
		if (rs.getInt("TaskID") == 0)
		{
			int courseid = rs.getInt("Syllabuses_id");
			if (courseid > 0)
			{
				int TaskID = jdb.getIntBySql(0, "select ID from CPB_EvaluateTask where CourseID=" + courseid);
				if (TaskID == 0)
				{
					ResultSet rs1 = jdb.rsSQL(0, "select * from CPB_Syllabuses where Syllabuses_id=" + courseid);
					if (rs1.next())
					{
						sql = "insert into CPB_EvaluateTask(TermID, nType, EvaluateID,TaskName,CourseID, SubjectID, TeacherIDs, Teachers, ClassIDs, BeginTime, EndTime,AttendanceReq,DelayMode,bAnonymous,ReEditable, SubmitMan, SubmitTime) values(" +
							rs1.getInt("term_id") + ",1," + rs.getInt("evaluate_id") + ",'" + rs1.getString("Syllabuses_subject_name") + "'," + courseid + "," + rs1.getInt("Syllabuses_subject_id") + ",'" + rs1.getString("Syllabuses_teacher_id") +
							 "','" + rs1.getString("Syllabuses_teacher_name") + "','" + rs1.getInt("class_id") + "','" + rs1.getString("EndTime") + "','" + VB.Now() + "',0,1,1,1,'" +
							user.CMemberName + "','" + VB.Now() + "')";
						jdb.ExecuteSQL(0, sql);
						TaskID = jdb.getIntBySql(0, "select ID from CPB_EvaluateTask where CourseID=" + courseid);
					}
					rs1.close();
				}
				sql = "update CPB_Evaluate_instance set TaskID=" + TaskID + " where instance_id=" + rs.getInt("instance_id");
				jdb.ExecuteSQL(0, sql);
			}
			else
			{
				int classid = jdb.getIntBySql(0, "select ClassID from SS_Student where STdNo in (select EName from Member where ID=" + rs.getInt("submit_man") + ")");
				int termid = jdb.getIntBySql(0, "select TermID from SS_Student where STdNo in (select EName from Member where ID=" + rs.getInt("submit_man") + ")");
				int TaskID = jdb.getIntBySql(0, "select ID from CPB_EvaluateTask where EvaluateID=" + rs.getInt("evaluate_id") + " and " + jdb.getSubSQLfromMutiValue("ClassIDs", "" + classid));
				if (TaskID == 0)
				{
					sql = "insert into CPB_EvaluateTask(TermID, nType, EvaluateID,TaskName, ClassIDs, BeginTime, EndTime,AttendanceReq,DelayMode,bAnonymous,ReEditable, SubmitMan, SubmitTime) values(" +
						termid + ",6," + rs.getInt("evaluate_id") + ",'综合评估任务','" + classid + "','" + rs.getString("submit_time") + "','" + VB.Now() + "',0,1,1,1,'" +
						user.CMemberName + "','" + VB.Now() + "')";
					jdb.ExecuteSQL(0, sql);
					TaskID = jdb.getIntBySql(0, "select ID from CPB_EvaluateTask where EvaluateID=" + rs.getInt("evaluate_id") + " and " + jdb.getSubSQLfromMutiValue("ClassIDs", "" + classid));
				}
				sql = "update CPB_Evaluate_instance set TaskID=" + TaskID + " where instance_id=" + rs.getInt("instance_id");
				jdb.ExecuteSQL(0, sql);
			}
		}
	}
	rs.close();
	out.print("OK");
	jdb.closeDBCon();
	return;
}

//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>评估结果</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_424" type="text/css">
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
<script type="text/javascript" src="../js/ECharts/dist/echarts.min.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanEvRpt", Role:<%=Purview%>};
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
		{item:"答卷汇总", img:"#8730", action:AnswerTotal, info:"", Attrib:1, Param:0},
		{item:"答卷清单", img:"", action:AnswerList, info:"", Attrib:1, Param:0},
		{item:"数据转换", img:"", action:DataTrans, info:"转换旧数据为新结构", Attrib:16, Param:1}
			];
	book.setTool(Tools);
//@@##445:客户端加载时(归档用注释,切勿删改)
//
	book.Page = new EvalutionPaper(book.getDocObj("Page")[0], {viewmode: 4});
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tceFilter = new TCEFilter(o,{Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tceFilter.onclickEVTask= ClickEVTask;
	book.tceFilter.onclickLegend4 = ClickAnswer;
	book.setPageObj(book.tceFilter);
	book.onLink = book.tceFilter.LinkAddParam;


//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##446:客户端自定义代码(归档用注释,切勿删改)
var answerItems = {};
function ClickEVTask(obj, item)
{
	var fun = function(data)
	{
		answerItems = $.jcom.eval(data);
		if (typeof answerItems == "string")
			alert(answerItems);
		for (var x = 0; x < answerItems.Main.length; x++)
			answerItems.Main[x].item = answerItems.Main[x].score + "分" + "(" + $.jcom.GetDateTimeString(answerItems.Main[x].submit_time, 9) + ")";
		if (viewmode == 4)
			book.Page.loadEVTaskRpt(item, answerItems);
		else
			book.tceFilter.loadLegend(answerItems.Main, $(obj).attr("node"));
	};
	var classitem = book.tceFilter.getselItem(1);
	$.get(location.pathname, {GetEVTaskAnswer:1, TaskID: item.ID, Class_id: classitem.Class_id}, fun);
	book.Page.waiting();
}

function ClickAnswer(obj, item)
{
	var answer = {Main:item, Detail:[]};
	for (var x = 0; x < answerItems.Detail.length; x++)
	{
		if (answerItems.Detail[x].instance_id == item.instance_id)
			answer.Detail[answer.Detail.length] = answerItems.Detail[x];
	}
	var items = book.tceFilter.getNodeItems();
	book.Page.loadEvTaskAnswer(items[2], answer);
}

var viewmode = 4;
function AnswerTotal(obj, item)	//答卷汇总
{
//
	if (viewmode == 4)
		return;
	viewmode = 4;
	item.img = "#8730";
	var tool = book.getChild("toolObj");
	def = tool.getmenu();
	def[1].img = "";
	tool.reload(def);
	book.tceFilter.RemoveLegend();
}

function AnswerList(obj, item)	//答卷清单
{
//
	if (viewmode == 3)
		return;
	viewmode = 3;
	item.img = "#8730";
	var tool = book.getChild("toolObj");
	def = tool.getmenu();
	def[0].img = "";
	tool.reload(def);
	book.tceFilter.AddLegend("答卷", answerItems.Main, "#9856");	
}


function DataTrans(obj, item)	//数据转换
{
//转换旧数据为新结构
$.get(location.pathname, {DataTrans:1}, function (data) {alert(data);});

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
