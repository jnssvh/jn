<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanEvCourse";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanEvCourse' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##449:服务器启动代码(归档用注释,切勿删改)
//
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));
if (WebChar.RequestInt(request, "GetEvaluate") == 1)
{
	int ClassID = WebChar.RequestInt(request, "ClassID");
	int TermID = WebChar.RequestInt(request, "TermID");
	String Course = "[]", Eva = "[]";
	if (ClassID > 0)
		Course = jdb.getJsonBySql(0, "select Syllabuses_id, CPB_Syllabuses.evaluate_id, CPB_Course.evaluate_id as CourseEvID from CPB_Syllabuses left join CPB_Course on CPB_Syllabuses.Syllabuses_course_id=CPB_Course.Course_id where CPB_Syllabuses.class_id=" + ClassID);
	else
		Course = jdb.getJsonBySql(0, "select Syllabuses_id, CPB_Syllabuses.evaluate_id, CPB_Course.evaluate_id as CourseEvID from CPB_Syllabuses left join CPB_Course on CPB_Syllabuses.Syllabuses_course_id=CPB_Course.Course_id where CPB_Syllabuses.term_id=" + TermID);
//	Eva = jdb.getJsonBySql(0, "select evaluate_id, evaluate_name from CPB_Evaluate where term_id=" + TermID);
	out.print(Course);
	jdb.closeDBCon();
	return;
}
if (WebChar.RequestInt(request, "StopEvaluate") == 1)
{
	int evaluate_id = WebChar.RequestInt(request, "evaluate_id");
	String sql = "update CPB_Evaluate set is_used=0 where evaluate_id=" + evaluate_id;
	jdb.ExecuteSQL(0, sql);
	out.print("OK");
	jdb.closeDBCon();
	return;	
}

if (WebChar.RequestInt(request, "SaveEvaluate") == 1)
{
	int num = WebChar.RequestInt(request, "Num");
	for (int x = 0; x < num; x++)
	{
		int Syllabuses_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_id", x));
		int Course_id = WebChar.ToInt(WebChar.RequestForms(request, "Course_id", x));
		int evaluate_id = WebChar.ToInt(WebChar.RequestForms(request, "evaluate_id", x));
		String sql = "update CPB_Syllabuses set evaluate_id=" + evaluate_id + " where Syllabuses_id=" + Syllabuses_id;
		jdb.ExecuteSQL(0, sql);
		if (Course_id > 0)
		{
			sql = "update CPB_Course set evaluate_id=" + evaluate_id + " where Course_id=" + Course_id;
			jdb.ExecuteSQL(0, sql);
		}
		else if (evaluate_id > 0)
		{
			ResultSet rs = jdb.rsSQL(0, "select * from CPB_Syllabuses where Syllabuses_id=" + Syllabuses_id);
			if (rs.next())
			{
				int subject_id = rs.getInt("Syllabuses_subject_id");
				if (subject_id == 0)
				{
					sql = "select Subject_id from CPB_Subject where Subject_name='" + rs.getString("Syllabuses_course_name") + "' and Teacher_id='" +
							rs.getString("Syllabuses_teacher_id") + "'";
					subject_id = jdb.getIntBySql(0,	sql);
					if (subject_id == 0)
					{
						jdb.ExecuteSQL(0, "insert into CPB_Subject(Subject_name, Teacher_id, Teacher_name, Remark) values('" + rs.getString("Syllabuses_course_name") +
							"','" + rs.getString("Syllabuses_teacher_id") + "','" + rs.getString("Syllabuses_teacher_name") + "','From Evaluate Program:CourseEvaSet.jsp')");
						subject_id = jdb.getIntBySql(0,	sql);
					}
				}
				ResultSet rs1 = jdb.rsSQL(0, "select * from CPB_Course where class_id='" + rs.getInt("class_id") + "' and Subject_id=" + subject_id);
				if (rs1.next())
				{
					Course_id = rs1.getInt("Course_id");
					sql = "update CPB_Course set evaluate_id=" + evaluate_id + " where Course_id=" + Course_id;
					jdb.ExecuteSQL(0, sql);
				}
				else
				{
					sql = "insert into CPB_Course(Subject_id, term_id, Mode_id, Style_id, class_id, Course_name, evaluate_id, Teacher_id, Teacher_name, Course_authorization) values("
							+ subject_id + "," + rs.getInt("term_id") + ",0,0," + rs.getInt("class_id") + ",'" + rs.getString("Syllabuses_course_name") +
							"'," + evaluate_id + ",'" + rs.getString("Syllabuses_teacher_id") + "','" + rs.getString("Syllabuses_teacher_name") + "', 'From Evaluate Program:CourseEvaSet.jsp')";
					jdb.ExecuteSQL(0, sql);
					Course_id = jdb.getIntBySql(0, "select Course_id from CPB_Course where class_id=" + rs.getInt("Class_id") + " and Subject_id=" + subject_id);
				}
				rs1.close();
				sql = "update CPB_Syllabuses set Syllabuses_course_id=" + Course_id + ",Syllabuses_subject_id=" + subject_id + " where Syllabuses_id=" + Syllabuses_id;
				jdb.ExecuteSQL(0, sql);
			}
			rs.close();
		}
	}
	//此段代码来源于deanEvSet.jsp
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
		w1 = " and Term_id=" + Term_id;
		w2 = " and TermID=" + Term_id;
		break;
	case 2:		//班次范围
	default:
		w1 = " and Class_id=" + Class_id;
		w2 = " and ClassIDs='" + Class_id + "'";
		break;
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
	
	out.print("保存成功,更新" + num + "条记录");	
	jdb.closeDBCon();
	return;	
}
String evlist = jdb.getJsonBySql(0, "select evaluate_id, evaluate_name from CPB_Evaluate where (eval_type=1 or eval_type is null)" +
		" and (is_used=1 or is_used is null)");

//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>课程问卷</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_414" type="text/css">
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
<script type="text/javascript" src="../cps/js/courseObj.js"></script>
<script type="text/javascript" src="../cps/js/plancourse.js"></script>

<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanEvCourse", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height,autoWidth:false};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px 微软雅黑'>没有权限使用本页面</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
	var Tools = [
		{item:"导出", img:"", action:null, info:"", Attrib:1, Param:0, child:[
			{item:"导出到EXCEL文件", img:"", action:OutExcel, info:"", Attrib:1, Param:0},
			{item:"导出到WORD文件", img:"", action:OutWord, info:"", Attrib:1, Param:0}]},
		{item:"设置", img:"", action:SetEditMode, info:"", Attrib:2, Param:0}
			];
	book.setTool(Tools);
//@@##451:客户端加载时(归档用注释,切勿删改)
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tcFilter = new TermClassFilter(o,{Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tcFilter.onclickClass = ClickClass;
//	$("#Page").css({padding: "20px 60px 20px 60px"});
	book.setPageObj(book.tcFilter);
	book.onLink = book.tcFilter.LinkAddParam;

	book.Page = new CourseTable($("#Page")[0], []);
	book.Page.PrepareCourseUserData = PrepareCourseUserData;
	var viewhead = book.Page.getChild("viewhead");
	viewhead[viewhead.length] = {FieldName:"evaluate_id", TitleName:"评估问卷", nWidth:100, nShowMode:1};
//	book.Page.reset([], {}, viewhead);	
	EvaEdit = new $.jcom.DynaEditor.List("不能评估", 300, 300);
	EvaEdit.valueChange = EvaChange;
	SetEvaEditData();
	
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##452:客户端自定义代码(归档用注释,切勿删改)
var evList = <%=evlist%>;	//可用问卷列表

function ClickClass(obj, item)
{
	book.Page.LoadCourse(item.Class_id);
}

function SetEvaEditData()
{
	var items = "不能评估";
	for (var x = 0; x < evList.length; x++)
		items += "," + evList[x].evaluate_name;
	EvaEdit.setData(items);
}

function EvaChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	if (index == undefined)
		index = obj.parentNode.parentNode.parentNode.rowIndex;
	var o = book.Page.getChild();
	if (o.courseGrid[index].index >= 0)
	{
		o.courseObj[o.courseGrid[index].index].evaluate_id = getEvaluteID(evList, obj.innerText);
		o.courseObj[o.courseGrid[index].index].EditFlag = 1;
	}
}

function getEvaluteID(evs, name)
{
	for (var x = 0; x < evs.length; x++)
	{
		if (evs[x].evaluate_name == name)
			return evs[x].evaluate_id;
	}
	return 0;
}

function PrepareCourseUserData(courseGrid, viewInfo, viewhead)
{
	function CourseUserDataOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		PrepareEvaluateData(json);
		book.Page.reset(courseGrid, viewInfo, viewhead);	
	}
	
	var o = book.Page.getChild();
	$.get(location.pathname, {GetEvaluate:1, TermID: o.classObj.Term_id, ClassID:o.classObj.Class_id}, CourseUserDataOK);
	return false;
}


function PrepareEvaluateData(Course)
{
var o = book.Page.getChild();
	for (var x = 0; x < o.courseGrid.length; x++)
	{
		if (o.courseGrid[x].index >= 0)
		{
			for (var y = 0; y < Course.length; y++)
			{
				if (o.courseObj[o.courseGrid[x].index].Syllabuses_id == Course[y].Syllabuses_id)
				{
					evid = Course[y].evaluate_id;
//					if (evid == 0)
//						evid = Course[y].CourseEvID;
					o.courseObj[o.courseGrid[x].index].evaluate_id = evid;
					o.courseGrid[x].evaluate_id = getEvaluteName(evList, evid);
				}
			}
			if (typeof o.courseGrid[x].Course == "String")
				o.courseGridp[x].Course = {value:o.courseGrid[x].Course};
			if ((o.courseObj[o.courseGrid[x].index].Syllabuses_activity_id > 0) && (o.courseObj[o.courseGrid[x].index].Syllabuses_subject_id == 0))
				o.courseGrid[x].Course.color = "gray";
			else if ((o.courseObj[o.courseGrid[x].index].Syllabuses_course_id == 0) && (o.courseObj[o.courseGrid[x].index].Syllabuses_subject_id > 0))
				o.courseGrid[x].Course.color = "blue";
			else if ((o.courseObj[o.courseGrid[x].index].Syllabuses_course_id == 0) && (o.courseObj[o.courseGrid[x].index].Syllabuses_subject_id == 0))
				o.courseGrid[x].Course.color = "green";
				
			if ((o.courseObj[o.courseGrid[x].index].Syllabuses_teacher_id == "") || (o.courseObj[o.courseGrid[x].index].Syllabuses_teacher_id == "0"))
				o.courseGrid[x].Teacher = {value:o.courseObj[o.courseGrid[x].index].Syllabuses_teacher_name, color:"gray"};
			o.courseObj[o.courseGrid[x].index].EditFlag = 0;
		}
	}	
}

function getEvaluteName(evs, id)
{
	for (var x = 0; x < evs.length; x++)
	{
		if (evs[x].evaluate_id == id)
			return evs[x].evaluate_name;
	}
	return "不能评估";
}
	
function PrepareTermCourseUserData(grid)
{
	var item = classtree.getTreeItem();
	$.get(location.pathname, {GetEvaluate:1, TermID: item.child[0].Term_id, ClassID:0}, TermCourseUserData);
	view.waiting();
	return false;
}

function TermCourseUserData(data)
{
	var json = $.jcom.eval(data);
	if (typeof json == "string")
		return alert(json);
	PrepareEvaluateData(json);
	var head = [{FieldName:"CourseTime", TitleName:"日期", nWidth:66, nShowMode:1},
	    		{FieldName:"ap", TitleName:"午别", nWidth:36, nShowMode:1},
	    		{FieldName:"Class_Name", TitleName:"班次", nWidth:100, nShowMode:1},
	    	    {FieldName:"Course", TitleName:"内容", nWidth:200, nShowMode:1},
	    	    {FieldName:"Teacher", TitleName:"授课人", nWidth:60, nShowMode:1},
	    	    {FieldName:"ClassRoom", TitleName:"地点", nWidth:80, nShowMode:1},		
	    	    {FieldName:"evaluate_id", TitleName:"评估问卷", nWidth:160, nShowMode:1}];
	courseGrid[2].evaluate_id = "评估问卷";
	view.reset(courseGrid, viewInfo, head);
	view.attachEditor("evaluate_id", EvaEdit, false);
}

function SaveEvaluate()
{
	var item = book.tcFilter.getselItem(1);
	var data = "Class_id=" + item.Class_id;
	if (typeof CouseOptionform == "object")
		option = CourseOptionform.getRecord();
	for (key in option)
		data += "&" + key + "=" + option[key];
	var o = book.Page.getChild();
	var cnt = 0;
	for (var x = 0; x < o.courseObj.length; x++)
	{
//		if (courseObj[x].EditFlag == 1)
		{
			data += "&Syllabuses_id=" + o.courseObj[x].Syllabuses_id + "&Course_id=" + o.courseObj[x].Syllabuses_course_id +
				"&evaluate_id=" + o.courseObj[x].evaluate_id
			cnt ++;
		}
	}
	$.jcom.Ajax(location.pathname + "?SaveEvaluate=1&Num=" + cnt, true, data, SaveEvaluteOK);
}

function SaveEvaluteOK(result)
{
	alert(result);
}

function EvaluateSet()
{
	var size = evList.length + 1;
	if (size > 20)
		size = 20;
	var tag = "<select size=" + size + " id=EvaListSel><option value=0>不能评估</option>";
	for (var x = 0; x < evList.length; x++)
		tag += "<option value=" + evList[x].evaluate_id + ">" + evList[x].evaluate_name + "</option>";
	
	$.jcom.OptionWin(tag + "</select>","问卷设置", [{item:"移除停用", action:RemoveEvaItem},{item:"批量设置", action:BatchEvaSet}], {mask:-1});
}

function RemoveEvaItem()
{
	var o = $("#EvaListSel");
	var index = o[0].selectedIndex;
	if (index <= 0)
		return alert("请先选择问卷");
	
	var flag = window.confirm("您是要永久停用已选择的问卷？还是要暂时移除本次设置不需要使用的问卷？\n【确定】表示停用。【取消】表示移除。\n\n提示：停用表示以后将不会用到这个问卷，移除则会在以后的设置中再次出现这个问卷。");
	if (o[0].options.length == 1)
		return alert("不能全部移除");
	var val = o.val();
	o[0].options.remove(index);
	for (var x = 0; x < evList.length; x++)
	{
		if (evList[x].evaluate_id == val)
		{
			evList.splice(x, 1);
			break;
		}
	}
	SetEvaEditData();
	if (flag)
		$.get(location.pathname, {StopEvaluate:1, evaluate_id: val});		
}

function BatchEvaSet()
{
	var val = $("#EvaListSel").val();
	if (val == null)
		return alert("请先选择问卷");
	if (courseGrid == undefined)
		return alert("请先选择班级或学期打开课表");
	var dest = getViewSelRows();
	flag = false;
	if (dest.length == 0)
	{
		if (window.confirm("您未选择课程，是否需要将当前选择的问卷设置到全部课程？") == false)
			return;
		flag = true;
	} else if (dest.length == 1)
		flag = window.confirm("您是要将当前问卷设置到当前选择课程还是设置到所有课程？\n【确定】设置全部课程。【取消】设置当前课程。");
	var text = getEvaluteName(evList, val);	
	if (flag)
	{
		for (var x = 0; x < courseGrid.length; x++)
			SetOneEVaValue(x, val, text)
	}
	else
	{
		for (var x = 0; x < dest.length; x++)
		{
			var index = dest[x].rowIndex;
			SetOneEVaValue(index, val, text);
		}
	}
}

function SetOneEVaValue(index, val, text)
{
	if (courseGrid[index].index >= 0)
	{
		view.setCell(index, "evaluate_id", text);
		courseObj[courseGrid[index].index].evaluate_id = val;
	}	
}

function OutExcel(obj, item)	//导出到EXCEL文件
{
//

}

function OutWord(obj, item)	//导出到WORD文件
{
//

}

var option = {EVTaskLen:7, bHoliday:1, AttendanceReq:0,ReEditable:1, bAnonymous:1};
var CourseOptionwin, CourseOptionform;
function EvaluateOption()
{
	if (typeof CouseOptionwin == "object")
		return CouseOptionwin.show();
	CourseOptionwin = new $.jcom.PopupWin("<div id=CourseOptionForm style=width:100%;height:100%></div>", 
		{title:"课程评估任务选项", mask:50, width:320, height:240, resize:0,position:"fixed"});
	CourseOptionform = new $.jcom.FormView($("#CourseOptionForm")[0],
		[{CName:"评估任务天数", EName: "EVTaskLen", InputType:1},
		 {CName:"天数跳过节假日", EName: "bHoliday", InputType:2},
		 {CName:"延期处理方式", EName: "DelayMode", InputType:4,Quote:"(1:不允许提交,2:允许提交)"},
		 {CName:"启用考勤关联", EName: "AttendanceReq", InputType:2},
		 {CName:"提交后允许修改", EName: "ReEditable", InputType:2},
		 {CName:"匿名评课", EName: "bAnonymous", InputType:2}
		], {}, {formtype:1});
	CourseOptionwin.close = CourseOptionwin.hide;
	CourseOptionform.setRecord(option);
}

var hostMenuDef, setupMode = 0;
function SetEditMode(obj, item)	//设置问卷
{
//
		var child = book.getChild();
		var menu = child.toolObj;
		if (setupMode == 0)
		{
			setupMode = 1;
			hostMenuDef = menu.getmenu();
			var def = [{item:"批量设置", img:"", action:EvaluateSet},{},{item:"任务选项",action:EvaluateOption},{item:"保存", img:"#59432", action:SaveEvaluate},{},{item:"结束",img:"#59470", action:SetEditMode}];
			menu.reload(def);
			book.Page.attachEditor("evaluate_id", EvaEdit, false);
//			EvaluateSet();
		}
		else
		{
			if (window.confirm("是否确定要退出编辑模式?") == false)
				return;
			setupMode = 0;
			book.Page.detachEditor("evaluate_id");
			menu.reload(hostMenuDef);
		}
		book.toggleEditMode();
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
