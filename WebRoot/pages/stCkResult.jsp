<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="stCkResult";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='stCkResult' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##577:服务器启动代码(归档用注释,切勿删改)
//
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));
	
	if (WebChar.RequestInt(request, "GetCourseAttendance") > 0)
	{
		int Syllabuses_id = WebChar.RequestInt(request, "courseid");
		String Attendance = jdb.getJsonBySql(0, "select * from SS_Attendance_Detail where SyllabusesId=" + Syllabuses_id);
		String Place = jdb.getJsonBySql(0, "select * from Place where ID in (select Syllabuses_ClassRoom_id from CPB_Syllabuses where Syllabuses_id=" + Syllabuses_id + ")");
		out.print("{Attendance:" + Attendance + ", Place:" + Place + "}");
		jdb.closeDBCon();
		return;	
	}
	if (WebChar.RequestInt(request, "SaveCourseAttendance") > 0)
	{
		int Syllabuses_id = WebChar.RequestInt(request, "courseid");
		int cnt = 0;
		String tmp[] = request.getParameterValues("RegID");
		if (tmp != null)
			cnt = tmp.length;
		for (int x = 0; x < cnt; x++)
		{
			int RegID = WebChar.ToInt(WebChar.RequestForms(request, "RegID", x));
			int Status = WebChar.ToInt(WebChar.RequestForms(request, "Status", x));
			String StartTime = WebChar.RequestForms(request, "StartTime", x);
			String EndTime = WebChar.RequestForms(request, "EndTime", x);
			String Info = WebChar.RequestForms(request, "Info", x);
			int STDID = WebChar.ToInt(jdb.GetTableValue(0, "SS_Attendance_Detail", "STDID", "SyllabusesId", Syllabuses_id + " and StudentID=" + RegID));
			String sql = "insert into SS_Attendance_Detail(SyllabusesId, StudentID, StartTime, EndTime, AttendanceMode, Status, Info) values (" + 
				Syllabuses_id + "," + RegID + ",'" +StartTime + "','" + EndTime + "',3," + Status + ",'" + Info + "')";
			if (STDID > 0)
				sql = "update SS_Attendance_Detail set StartTime='" + StartTime + "',EndTime='" + EndTime + "', AttendanceMode=3, Status=" + Status + ",Info='" + Info + "' where STDID=" + STDID;
			jdb.ExecuteSQL(0, sql);
		}	
		out.print("保存成功");
		jdb.closeDBCon();
		return;	
	}	
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>考勤结果</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
<style id="css_578" type="text/css">
.pcbody{
background: #e9ebee url(../res/skin/dx3.jpg) no-repeat fixed;
background-size:100% 100%;
}

.ResultTitle {
font-size:12pt;
padding-top:20px;
}
</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
	<script type="text/javascript" src="../cps/js/cp.js"></script>
	<script type="text/javascript" src="http://api.map.baidu.com/getscript?v=2.0&ak=BCGrysMslrTxq3G0urVGlyt4Xd9W38yL"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"stCkResult", Role:<%=Purview%>};
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
		{item:"考勤", img:"", action:SetEditMode, info:"", Attrib:2, Param:1}
			];
	book.setTool(Tools);
//@@##580:客户端加载时(归档用注释,切勿删改)
	var o = book.setDocTop("加载中...", "Filter", "");
 	book.tccFilter = new TCCFilter(o,{mode:2, Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tccFilter.onclickCourse = ClickCourse;
	$("#Page").css({padding: "20px 60px 20px 60px"});
	book.setPageObj(book.tccFilter);
	book.onLink = book.tccFilter.LinkAddParam;
	book.Page = new CourseCheckPage(book.getDocObj("Page")[0]);
//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##581:客户端自定义代码(归档用注释,切勿删改)
function ClickCourse(obj, item)
{
	book.Page.LoadCourse(item);
}

function CourseCheckPage(domobj, cfg)
{
	var self = this;
	var timeEdit, courseItem, studentItems;
	var editmode = 0;
	var bm,pos = null;
	var pointArr, pointBegin, pointEnd, convertor;
	
	var tag = "<div id=SiteTitleDiv align=center>课程信息</div>" +
		"<div style='font-size:14pt;padding-top:20px;'>上课时间:&nbsp;<span class=spantext id=BeginTime style=width:60px></span>" +
		"下课时间:&nbsp;<span class=spantext id=EndTime style=width:60px></span>是否考勤:&nbsp;<input id=bAttendance disabled type=checkbox></div>" +
		"<div id=ClassRoom align=center style='font-size:14pt;padding-top:20px;'>教学场所</div>" +
		"<div class=ResultTitle>◢&nbsp;座位安排图</div><div id=SeatMapBox></div>" +
		"<div class=ResultTitle>◢&nbsp;统计结果</div><div id=ResultDiv style=font-size:12pt;padding:8px;></div>" +
		"<div class=ResultTitle>◢&nbsp;考勤记录</div><div id=StudentBox></div>" +
		"<div class=ResultTitle>◢&nbsp;地理位置</div><div id=PosBox style=height:400px></div>";
	$(domobj).html(tag);
	var box1 = new $.jcom.SlideBox($("#SeatMapBox")[0], "SeatMapDiv");
	var box2 = new $.jcom.SlideBox($("#StudentBox")[0], "StudentDiv");
	self.map = new SiteSeatMap($("#SeatMapDiv")[0]);
	var head = [{FieldName:"StdNo", TitleName:"学号", nWidth:70, nShowMode:1},
				{FieldName:"StdName", TitleName:"姓名", nWidth:50, nShowMode:1},
				{FieldName:"Status", TitleName:"状态", nWidth:50, nShowMode:1, Quote:"(0:正常,1:迟到,2:早退,3:迟到早退,4:事假,5:病假,6:缺勤,7:公假,8:未考勤)"},
				{FieldName:"StartTime", TitleName:"进入时间", nWidth:50, nShowMode:1},
				{FieldName:"EndTime", TitleName:"离开时间", nWidth:50, nShowMode:1},
				{FieldName:"Info", TitleName:"备注", nWidth:150, nShowMode:1}];	
	self.oStudent = new $.jcom.GridView($("#StudentDiv")[0], head, [],{},{footstyle:4, resizeflag:0});
	$(".ResultTitle").on("click", ExpandTitle);
	bm = new BMap.Map("PosBox");
	//设置地图中心点和缩放级别
	bm.centerAndZoom("北京");
//	bm.centerAndZoom(new BMap.Point(116.47496938705444, 39.873154043017784), 19);
    bm.addControl(new BMap.NavigationControl());
	convertor = new BMap.Convertor();
	getLocation();
		
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
		self.map.LoadCourseMap(item, "stckSeat.jsp");
		courseItem = item;
	};

	function ExpandTitle(e)
	{
		var text = $(e.target).html().substr(1);
		var obj = $(e.target).next();
		if (obj.css("display") == "none")
		{
			$(e.target).html("&#9698" + text)	//◢
			obj.css("display", "");
		}
		else
		{
			$(e.target).html("&#9655" + text)
			obj.css("display", "none");
		}
	}
	
	function loadStudentOK(data)
	{
		studentItems = $.jcom.eval(data);
		if (typeof studentItems == "string")
			alert(studentItems);
		$.get(location.pathname, {GetCourseAttendance:1, courseid: courseItem.Syllabuses_id}, GetAttendanceOK);
	}
	
	function GetAttendanceOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			alert(json);
		var items = json.Attendance;
		
		var cnt = [0,0,0,0,0,0,0,0,0];
		for (var x = 0; x < studentItems.length; x++)
		{
			studentItems[x].Status = 8;			
			studentItems[x].StartTime = "";
			studentItems[x].EndTime = "";
			studentItems[x].Info = "";
			for (var y = 0; y < items.length; y++)
			{
				if (items[y].StudentID == studentItems[x].RegID)
				{
						studentItems[x].Status = items[y].Status;
						studentItems[x].StartTime = $.jcom.GetDateTimeString(items[y].StartTime, 14);
						studentItems[x].EndTime = $.jcom.GetDateTimeString(items[y].EndTime, 14);
						studentItems[x].Info = items[y].Info;
						studentItems[x].GPSInfo = items[y].GPSInfo;
						studentItems[x].IP = items[y].IP;
						studentItems[x].ClientInfo = items[y].ClientInfo;
//						studentItems[x].Info = GetInfo(json.Place, items[y].GPSInfo, items[y].IP, items[y].ClientInfo);
				
						break;
				}
			}
			if (studentItems[x].Status <= 8)
				cnt[studentItems[x].Status] ++;
		}
		var field = self.oStudent.getHead("Status");
		var enumlist = field.Quote.substr(1, field.Quote.length - 2).split(",");
		var str = "";
		for (var x = 0; x < enumlist.length; x++)
		{
			var ss = enumlist[x].split(":");
			if (cnt[x] > 0)
				str += "," + ss[1] + ":" + cnt[x];
		}
		
		$("#ResultDiv").html("总人数:" + studentItems.length + ", 考勤记录数:" + items.length + str);
		self.oStudent.reload(studentItems);
		viewPos(json.Place);
	}
	
	function GetInfo(Place, GPSInfo, IP, ClientInfo)
	{
		if (Place.length == 0)
			return "";
		var p0 = Place[0].Position.split(",");
		if (p0.length != 2)
			return "";
		var p1 = GPSInfo.split(",");
		if (p1.length != 2)
			return "";
		pointArr[pointArr.length] = new BMap.Point(p1[0], p1[1]);
//		var d = gpsDistance(p0[0], p0[1], p1[0], p1[1]);
		return d;
	}
	
	function viewPos(Place)
	{
		if (Place.length == 0)
			return;
		var pos = Place[0].Position.split(",");
		if (pos.length == 2)
		{
			var p = new BMap.Point(pos[0], pos[1]);
			bm.centerAndZoom(p, 19);
		}
		pointBegin = 0;
		translate();
    }
    
    function translate()
    {
    	pointArr = [];
		for (var x = pointBegin; x < studentItems.length; x++) 
    	{
    		if (typeof studentItems[x].GPSInfo == "string")
    		{
	    		var pos = studentItems[x].GPSInfo.split(",");
    			if (pos.length == 2)
					pointArr[pointArr.length] = new BMap.Point(pos[1], pos[0]);
				studentItems[x].pt = "?";
				if (pointArr.length >= 10)
					break;
			}
    	}
    	if (x < studentItems.length)
	    	pointEnd = x;
	    else
	    	pointEnd = studentItems.length - 1;
    	if (pointArr.length > 0)
			convertor.translate(pointArr, 1, 5, translateCallback);
    }
    
	function  translateCallback(data)
	{
		if(data.status === 0)
		{
			for (var y = 0; y < data.points.length; y++) 
			{
		    	for (var x = pointBegin; x <= pointEnd; x++) 
    			{
					if (studentItems[x].pt == "?")
					{
						studentItems[x].pt = data.points[y];
						pointBegin = x + 1;
					}
				}
			}
			
			if (pointEnd < studentItems.length - 1)
			{
				pointBegin = pointEnd + 1;
				translate();
				return;
			}
 		}
 		for (var x = 0; x < studentItems.length; x++)
 		{
 			if (typeof studentItems[x].pt == "object")
			{
				var markergg = new BMap.Marker(studentItems[x].pt);
				bm.addOverlay(markergg);
				var labelgg = new BMap.Label(studentItems[x].StdName, {offset:new BMap.Size(20,-10)});
				markergg.setLabel(labelgg); //添加GPS label
//				bm.setCenter(data.points[i]);
			}
		}
	}
    
	
	this.attachEditor = function()
	{
		if (timeEdit == undefined)
		{
			timeEdit = new $.jcom.DynaEditor.Date(300, 300, {dateType:7});
			timeEdit.config({editorMode:4});
		}
		editmode = 1;
		self.oStudent.attachEditor("StartTime", timeEdit);
		self.oStudent.attachEditor("EndTime", timeEdit);
		self.oStudent.attachEditor("Status");
		self.oStudent.attachEditor("Info");
	};

	this.detachEditor = function ()
	{
		editmode = 0;
		self.oStudent.detachEditor("StartTime");
		self.oStudent.detachEditor("EndTime");
		self.oStudent.detachEditor("Status");
		self.oStudent.detachEditor("Info");		
	};
	
	this.SaveStudents = function()
	{
		var items = self.oStudent.getData();
		var v = [];
		for (var x = 0; x < items.length; x++)
		{
			if (items[x]._Editflag == 1)
			{
				v[v.length] = {RegID:items[x].RegID, Status:items[x].Status, StartTime:items[x].StartTime, EndTime:items[x].EndTime, Info:items[x].Info};
			}
		}
		$.jcom.submit(location.pathname + "?SaveCourseAttendance=1&courseid=" + courseItem.Syllabuses_id, v);
	};
	
	function getLocation()
	{
		if (navigator.geolocation)
		{
			navigator.geolocation.getCurrentPosition(showPosition, showError);
    	}
		else
		{
			alert("not support gps function");
		}
	}
	
	function showPosition(position)
	{
		var p = [];
		p[0] = new BMap.Point(position.coords.longitude, position.coords.latitude);
		bm.setCenter(p[0]);
		bm.setZoom(19);
//	    var convertor = new BMap.Convertor();
//	    convertor.translate(p, 1, 5, transCallback);
  	}
	
	function transCallback(data)
	{
		if(data.status === 0)
		{
			bm.setCenter(data.points[0]);
			bm.setZoom(19);
		}
	}
	
	function showError(error)
	{
		switch(error.code) 
		{
		case error.PERMISSION_DENIED:
			alert("User denied the request for Geolocation.");
			break;
		case error.POSITION_UNAVAILABLE:
			alert("Location information is unavailable.");
			break;
		case error.TIMEOUT:
			alert("The request to get user location timed out.");
			break;
		case error.UNKNOWN_ERROR:
			alert("An unknown error occurred.");
			break;
		}
	}

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
		var def = [{item:"设为全勤", action:SetAllIn},{item:"异常检查", action:CheckData},{}, {item:"保存", img:"#59432", action:SaveCheck},{},
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

function CheckData()
{
	//alert("检查地理位置异常或IP地址异常的考勤记录，用来判断考勤作弊。敬请期待....");
	var item = book.tccFilter.getsel(1);
	var dataItems = book.tccFilter.getCasItems();
	var nodeAtt = item.getAttribute("node");
	var nodeDatas = nodeAtt.split(/,/);
	var itemData = dataItems[1][nodeDatas[1]];
	var classId = itemData.Class_id;
	item = book.tccFilter.getsel(2);
	nodeAtt = item.getAttribute("node");
	nodeDatas = nodeAtt.split(/,/);
	itemData = dataItems[2][nodeDatas[2]];
	
	var courseId = itemData.Syllabuses_id;
	var url = "ssVerifyGps.jsp?ClassId=" + classId + "&CourseId=" + courseId;
	window.open(url);
}

function SetAllIn()
{
	if (window.confirm("将设置所有的学员考勤状态为正常？") == false)
		return;
		var items = book.Page.oStudent.getData();
		for (var x = 0; x < items.length; x++)
		{
			if (items[x].Status > 0)
			{
				items[x]._Editflag = 1;
				items[x].Status = 0;
			}
		}
	book.Page.oStudent.reload(items);
}

function SaveCheck()
{
	book.Page.SaveStudents();
}
function gpsDistance(lat1, lng1, lat2, lng2)
{
	var lonRes = 102900, latRes = 110000;
    return Math.sqrt( Math.abs( lat1 - lat2 ) * latRes * Math.abs( lat1 - lat2 ) * latRes +
		Math.abs( lng1 - lng2 ) * lonRes * Math.abs( lng1 - lng2 ) * lonRes );
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
