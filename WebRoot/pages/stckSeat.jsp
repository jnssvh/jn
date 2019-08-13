<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="stckSeat";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='stckSeat' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##556:服务器启动代码(归档用注释,切勿删改)
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));
	
	if (WebChar.RequestInt(request, "SaveCourseSeat") > 0)
	{
		int Syllabuses_id = WebChar.RequestInt(request, "courseID");
		String BeginTime = WebChar.requestStr(request, "BeginTime");
		String EndTime = WebChar.requestStr(request, "EndTime");
		int bAttendance = WebChar.RequestInt(request, "bAttendance");
		String ClassRoom = WebChar.requestStr(request, "ClassRoom");
		int ClassRoomID = WebChar.RequestInt(request, "ClassRoomID");
		String sql = "update CPB_Syllabuses set BeginTime='" + BeginTime + "', EndTime='" + EndTime + "', bAttendance=" + bAttendance + ",Syllabuses_ClassRoom='" +
			ClassRoom + "', Syllabuses_ClassRoom_id=" + ClassRoomID + " where Syllabuses_id=" + Syllabuses_id;
		jdb.ExecuteSQL(0, sql);
		
		String SeatMap = WebChar.requestStr(request, "SeatMap");
		int	AtdID = WebChar.ToInt(jdb.GetTableValue(0, "SS_Attendance_Main", "AtdID", "ClassID", Class_id + " and SLBID=" + Syllabuses_id + " and RoomID=" + ClassRoomID));
		if (AtdID == 0)
			sql = "insert into SS_Attendance_Main(ClassID, SLBID, RoomID, SeatMap, SubmitMan) values (" + Class_id + "," + Syllabuses_id +
				"," + ClassRoomID + ",'" + SeatMap + "','" + user.CMemberName + "')";
		else
			sql = "update SS_Attendance_Main set SeatMap='" + SeatMap + "' where AtdID=" + AtdID;
		jdb.ExecuteSQL(0, sql);
		out.print("OK");			
		jdb.closeDBCon();
		return;
	}
	
	if (WebChar.RequestInt(request, "GetCourseMap") > 0)
	{
		int Syllabuses_id = WebChar.RequestInt(request, "courseID");
		int ClassRoomID = WebChar.RequestInt(request, "ClassRoomID");
		String SeatMap = jdb.GetTableValue(0, "SS_Attendance_Main", "SeatMap", "ClassID", Class_id + " and SLBID=" + Syllabuses_id + " and RoomID=" + ClassRoomID);
		if (SeatMap.equals(""))
			SeatMap = jdb.GetTableValue(0, "SS_Attendance_Main", "SeatMap", "ClassID", Class_id + " and RoomID=" + ClassRoomID);
		if (SeatMap.equals(""))
			SeatMap = jdb.GetTableValue(0, "Place", "SeatMap", "ID", "" + ClassRoomID);
		out.print(SeatMap);
		jdb.closeDBCon();
		return;
	}
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>座位设置</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_557" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"stckSeat", Role:<%=Purview%>};
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
		{item:"导出", img:"", action:null, info:"", Attrib:1, Param:1, child:[
			{item:"导出到WORD文件", img:"", action:OutWord, info:"", Attrib:1, Param:1},
			{item:"导出到EXCEL文件", img:"", action:OutExcel, info:"", Attrib:1, Param:1}]},
		{item:"设置", img:"", action:SetEditMode, info:"", Attrib:2, Param:1}
			];
	book.setTool(Tools);
//@@##559:客户端加载时(归档用注释,切勿删改)
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tccFilter = new TCCFilter(o,{mode:2, Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tccFilter.onclickCourse = ClickCourse;
	$("#Page").css({padding: "20px 60px 20px 60px"});
	book.setPageObj(book.tccFilter);
	book.onLink = book.tccFilter.LinkAddParam;
	book.Page = new CourseCheckPage(book.getDocObj("Page")[0]);


//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##560:客户端自定义代码(归档用注释,切勿删改)
function ClickCourse(obj, item)
{
	book.Page.LoadCourse(item);
}

function CourseCheckPage(domobj, cfg)
{
	var self = this;
	var timeEdit, roomtree, roomEdit, courseItem, studentItem;
	var editmode = 0;
	var tag = "<div id=SiteTitleDiv align=center>课程信息</div>" +
		"<div style='font-size:14pt;padding-top:20px;'>上课时间:&nbsp;<span class=spantext id=BeginTime style=width:60px></span>" +
		"下课时间:&nbsp;<span class=spantext id=EndTime style=width:60px></span>是否考勤:&nbsp;<input id=bAttendance disabled type=checkbox></div>" +
		"<div id=ClassRoom align=center style='font-size:14pt;padding-top:20px;'>教学场所</div>" +
		"<div style='font-size:14pt;padding-top:20px;'>座位安排图</div><div id=SeatMapBox></div><div id=StudentDiv></div>" +
		"<div id=HintDiv style=display:none;font-size:12pt;><br><input id=Saveoption type=checkbox>将座位安排保存到本班相同场所的其它课程<hr>提示：双击座位即可将当前选择学员安排到相应的座位</div>";
	$(domobj).html(tag);
	var box = new $.jcom.SlideBox($("#SeatMapBox")[0], "SeatMapDiv");
	self.map = new SiteSeatMap($("#SeatMapDiv")[0]);
	self.oStudent = new $.jcom.Cascade($("#StudentDiv")[0], [],{title:["未排座学员"]});
	self.map.loadCourseMapReady = MapReady;
	
	self.map.dblclickRow = function(td)
	{
		if (editmode == 0)
			return;
		var o = self.map.getSelSeat();
		var seat = o.items[o.row][o.field];
		if (typeof seat.stdItem == "object")
			self.oStudent.addItem(seat.stdItem);
		seat.value = "&nbsp;<br>" + seat.ex;
		seat.stdItem = undefined;
		$(td.firstChild).html(seat.value);

		var item = self.oStudent.getselItem();
		if (item == undefined)
			return self.oStudent.SkipPage(1, true);
		seat.value = "<div id=S_" + item.RegID + " style=color:black>" + item.StdName + "</div>" + seat.ex;
		seat.stdItem = item;
		$(td.firstChild).html(seat.value);
		self.oStudent.removeItem(item);
		self.oStudent.SkipPage(1, true);
	};
	
	self.oStudent.ondblclick = function (e)
	{
		if (editmode == 0)
			return;
	};
	
	this.LoadCourse = function (item)
	{
		$("#SiteTitleDiv").html("<div style='font-size:14pt;padding-top:20px;'>" + item.class_id_ex + "</div><div style='font-size:18pt;padding-top:20px;'>" +
			item.Syllabuses_course_name + "</div><div style='font-size:16pt;padding-top:20px;'>" + item.Syllabuses_teacher_name + 
			"</div><div style='font-size:14pt;padding-top:20px;'>" + item.Syllabuses_date_ex + item.Syllabuses_AP);
		$("#BeginTime").html($.jcom.GetDateTimeString(item.BeginTime, 4));
		$("#EndTime").html($.jcom.GetDateTimeString(item.EndTime, 4));
		$("#bAttendance").prop("checked", item.bAttendance == 1);
		if (item.Syllabuses_ClassRoom == "")
			$("#ClassRoom").html("未设置地点");
		else
			$("#ClassRoom").html(item.Syllabuses_ClassRoom);
		$.get("../fvs/FormStudentRpt.jsp",{GetClassStudentList:1, ClassID: item.class_id}, loadStudentOK);
		courseItem = item;
	};
	
	function MapReady(items)
	{
		var stditems = self.oStudent.getdata();
		for (var x = stditems.length - 1; x >= 0; x--)
		{
			if ($("#S_" + stditems[x].RegID).length > 0)
				stditems.splice(x, 1);
		}
		self.oStudent.reload(stditems);		
	}
	
	function loadStudentOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		for (var x = 0; x < json.length; x++)
			json[x].item = json[x].StdNo + "-" + json[x].StdName;
		studentItem = $.extend(true, [], json);
		self.oStudent.reload(json);
		self.map.LoadCourseMap(courseItem, location.pathname);
	}
	
	this.attachEditor = function()
	{
		if (timeEdit == undefined)
		{
			timeEdit = new $.jcom.DynaEditor.Date(300, 300, {dateType:7});
			timeEdit.config({editorMode:4});
			roomtree = new $.jcom.TreeView(0, 0, {});
			roomEdit = new $.jcom.DynaEditor.TreeList(roomtree, 200, 200);
			roomEdit.valueChange = roomChange;
			$.get("../fvs/Place_Course.jsp", {GetTreeData:2}, LoadPlaceOK);
		}
		editmode = 1;
		timeEdit.attach($("#BeginTime")[0]);
		timeEdit.attach($("#EndTime")[0]);
		roomEdit.attach($("#ClassRoom")[0]);
		$("#bAttendance").prop("disabled", false);
		$("#HintDiv").css({display:""});
	};

	this.detachEditor = function ()
	{
		editmode = 0;
		timeEdit.detach($("#BeginTime")[0]);
		timeEdit.detach($("#EndTime")[0]);
		roomEdit.detach($("#ClassRoom")[0]);
		$("#bAttendance").prop("disabled", true);
		$("#HintDiv").css({display: "none"});
	};

	function roomChange(obj)
	{
		var item = roomtree.getTreeItem();
		if (typeof item != "object") 
			return;
		courseItem.Syllabuses_ClassRoom_id = item.ID;
		self.LoadSiteSeatMap();
	}

	function LoadPlaceOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		roomtree.setdata(json.data, json.head);
	}
	
	this.LoadSiteSeatMap = function ()
	{
		self.map.LoadMap(courseItem.Syllabuses_ClassRoom_id);
		var items = $.extend(true, [], studentItem);
		self.oStudent.reload(items);
	};
	
	this.getRecord = function()
	{
	
		var item = { courseID: courseItem.Syllabuses_id,
			Class_id: courseItem.class_id,
			BeginTime: $.jcom.GetDateTimeString(courseItem.Syllabuses_date_ex + " " + $("#BeginTime").html(), 2),
			EndTime: $.jcom.GetDateTimeString(courseItem.Syllabuses_date_ex + " " + $("#EndTime").html(), 2),
			bAttendance: $("#bAttendance").prop("checked") ? 1 : 0,
			ClassRoom: $("#ClassRoom").html(),
			ClassRoomID: courseItem.Syllabuses_ClassRoom_id,
			SeatMap: self.map.getMapData(),
			};
		return item;
	};
	
}

function OutWord(obj, item)	//导出到WORD文件
{
//

}



function OutExcel(obj, item)	//导出到EXCEL文件
{
//

}


var hostMenuDef, setupMode = 0;
function SetEditMode(obj, item)	//设置
{
//
		var child = book.getChild();
		var menu = child.toolObj;
		if (setupMode == 0)
		{
			setupMode = 1;
			hostMenuDef = menu.getmenu();
			var def = [{item:"自动安排", action:AutoArrange}, {item:"清除", action:ClearSeat},{item:"保存", img:"#59432", action:SaveArrange},{},
				{item:"结束",img:"#59470", action:SetEditMode}];
			menu.reload(def);
			book.Page.attachEditor();
		}
		else
		{
			if (window.confirm("是否确定要退出编辑模式?") == false)
				return;
			setupMode = 0;
			book.Page.detachEditor();
			menu.reload(hostMenuDef);
		}
		book.toggleEditMode();

}

function ClearSeat()
{
	if (window.confirm("是否清除座位安排？") == false)
		return;
	book.Page.LoadSiteSeatMap();
}

function AutoArrange()
{
	var stditems = book.Page.oStudent.getdata();
	var head = book.Page.map.getHead();
	var items = book.Page.map.getData();
	for (var y = 0; y < items.length; y++)
	{
		if (stditems.length == 0)
			break;
		for (var x = 0; x < head.length; x++)
		{
			if ((typeof items[y][head[x].FieldName] != "object") || (head[x].FieldName.substr(0, 3) != "Col") || (items[y][head[x].FieldName].value == ""))
				continue;
			if (items[y][head[x].FieldName].stdItem == undefined)
			{
				items[y][head[x].FieldName].stdItem = stditems[0];
				items[y][head[x].FieldName].value = "<div id=S_" + stditems[0].RegID + " style=color:black>" + stditems[0].StdName + "</div>" +
					items[y][head[x].FieldName].ex;
				stditems.splice(0, 1);
				if (stditems.length == 0)
					break;
			}
		}
	}
	book.Page.oStudent.reload(stditems);
	book.Page.map.reload(items);	
}

function SaveArrange()
{
	var item = book.Page.getRecord();
	$.jcom.submit(location.pathname + "?SaveCourseSeat=1", item);
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
