<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="ssCheck";
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
	{//���cookie��ʧ���ʹ�������ȡ���˻�������cookie
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='ssCheck' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##576:��������������(�鵵��ע��,����ɾ��)
//GetAttendance

	if (WebChar.RequestInt(request, "GetAttendance") > 0)
	{
		String list = jdb.getJsonBySql(0, "select * from SS_Attendance_Detail where StudentID=" + user.UserID);
		out.print(list);
		jdb.closeDBCon();
		return;	
	}

	if (WebChar.RequestInt(request, "StudentCheckIn") > 0)
	{
		int SyllabusesId = WebChar.RequestInt(request, "courseID");
		int Status = WebChar.RequestInt(request, "Status");
		String pos = WebChar.requestStr(request, "pos");
		String userAgent = request.getHeader("user-agent");
		String ip = request.getRemoteAddr();
		int	STDID = WebChar.ToInt(jdb.GetTableValue(0, "SS_Attendance_Detail", "STDID", "SyllabusesId", SyllabusesId + " and StudentID=" + user.UserID));
		
		String sql = "insert into SS_Attendance_Detail(SyllabusesId, StudentID, StartTime, AttendanceMode, Status,IP, GPSInfo,ClientInfo) values (" + 
			SyllabusesId + "," + user.UserID + ",'" + VB.Now() + "',4," + Status + ",'" + ip + "','" + pos + "','" + userAgent + "')";
		if (STDID > 0)
			sql = "update SS_Attendance_Detail set GPSInfo='" + pos + "' where STDID=" + STDID;
		jdb.ExecuteSQL(0, sql);
		out.print("OK");
		jdb.closeDBCon();
		return;	
	}
	
//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>���ڹ���</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
<style id="css_526" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"ssCheck", Role:<%=Purview%>};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, sys, cfg);
	if (sys.Role == 0)
	{
		$("#Page").html("<div align=center style='color:red;padding-top:100px;font:normal normal normal 24px ΢���ź�'>û��Ȩ��ʹ�ñ�ҳ��</div>");
		$("#Page").css({background: "#e9ebee url(../res/skin/wall.jpg) repeat;"});
		return;
	}
//@@##528:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
	var o = book.setDocTop("���ص�ǰ�γ�", "CurrentCourse", {outline:false});
	book.oCourse = new StudentCoursePage(o, {viewmode:1, title:"���´ογ�"});
	var o = book.setDocTop("������...", "Filter");
	book.Filter = new $.jcom.DBCascade(o, "../fvs/CPB_Syllabuses_view.jsp", {}, {SeekKey:"CPB_Syllabuses.Class_id", SeekParam: "<%=user.MemberDept%>", OrderField:"BeginTime"}, {title:["�γ̱�"], itemimg:["TimeAxis.BeginTime"]});
	book.Filter.PrepareData = PrepareCourse;
	book.Filter.onclick = clickCourse;
	book.setPageObj(book.Filter);
	book.Page = new StudentCoursePage($("#Page")[0], {viewmode:2, title:"�γ���Ϣ"});
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##529:�ͻ����Զ������(�鵵��ע��,����ɾ��)
var courses;
var StatusEnum = "0:����,1:�ٵ�,2:����,3:�ٵ�����,4:�¼�,5:����,6:ȱ��,7:����,8δ����,9:����";
function getStatus(v)
{
	var e = StatusEnum.split(",");
	for (var x = 0; x < e.length; x++)
	{
		var ss = e[x].split(":");
		if (ss[0] == v)
			return ss[1];
	}
}

function PrepareCourse(items, head)
{
	courses = items;
	$.get(location.pathname, {GetAttendance:1}, GetAttendanceOK);
	return false;
}

function GetAttendanceOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		return alert(items);
		
	var now = NowDate();
	var courseItem;
	for (var x = 0; x < courses.length; x++)
	{
		var t = $.jcom.makeDateObj(courses[x].EndTime);
		courses[x].item = courses[x].Syllabuses_AP + " " + courses[x].Syllabuses_course_name +
				"(" + courses[x].Syllabuses_teacher_name + ") - " + courses[x].Syllabuses_ClassRoom;
		for (var y = 0; y < items.length; y++)
		{
			if (items[y].SyllabusesId == courses[x].Syllabuses_id)
			{
				courses[x].AttendObj = items[y];
				courses[x].item += "���ѿ���:" + getStatus(items[y].Status) + "��";
			}
		}
		if ((t > now) && (courseItem == undefined))
		{
			courseItem = courses[x];
			book.oCourse.LoadCourse(courses, x);
		}
	}
		
	book.Filter.reload(courses);
}

function clickCourse(obj, item)
{
	book.Page.LoadCourse(item);
}

function StudentCoursePage(domobj, cfg)
{
	var self = this;
	var courseItems, courseIndex, courseItem;
	
	var tag = "<fieldset><legend id=CourseLegend style='FONT-SIZE:9pt;padding:0px 10px 0px 10px'>" +
			"<span class=TitleButton style=font-size:16px;>��&nbsp;</span><span id=CnrrentCourseText>" + cfg.title + "</span>&nbsp;</legend>" +
			"<ul class=BodyDiv style='padding:0px 20px;overflow:hidden;display:none;'><div id=SiteTitleDiv align=center>�γ�����</div>" +
			"<div style='font-size:14pt;padding-top:20px;'>�Ͽ�ʱ��:&nbsp;<span class=spantext id=BeginTime style=width:60px></span>" +
			"�¿�ʱ��:&nbsp;<span class=spantext id=EndTime style=width:60px></span>�Ƿ���:&nbsp;<input id=bAttendance disabled type=checkbox></div>" +
			"<div id=ClassRoom align=center style='font-size:14pt;padding-top:20px;'>��ѧ����</div>" +
			"<div id=CheckCard align=center></div><div id=CheckinDiv align=center style=display:none;>" + 
			"<input id=CheckinButton style=font-size:20px;width:100px type=button value=ǩ��><div id=CheckinHint>��ʾ��ǩ����Ҫ��ȡ��ǰ����λ�ã��繦�ܱ���ֹ��ǩ���п���ʧЧ��</div></div>" +
			"</ul></fieldset><div id=SeatMapFrame style='font-size:14pt;padding-top:20px;display:none;'>��λ����ͼ<div id=SeatMapBox></div></div>";
	$(domobj).html(tag);
	var box = new $.jcom.SlideBox($("#SeatMapBox", domobj)[0], "SeatMapDiv");
	self.map = new SiteSeatMap($("#SeatMapDiv", domobj)[0]);
	self.map.loadCourseMapReady = MapReady;
	$("#CheckinButton", domobj).on("click", CheckIn);
	$("#CourseLegend", domobj).on("click", ExpandInfo);

	function ExpandInfo()
	{
		var b = $(".TitleButton", domobj);
		var o = $(".BodyDiv", domobj);
		var s = $("#SeatMapFrame", domobj);
		if (o.css("display") == "none")
		{
			o.css("display", "");
			s.css("display", "");
			b.html("&#9698&nbsp;");	//�� 
		}
		else
		{
			o.css("display", "none");
			s.css("display", "none");
			b.html("&#9655&nbsp;");
		}
	}
	
	this.LoadCourse = function (items, index)
	{
		if (index == undefined)
			var item = items;
		else
		{
			var item = items[index];
			courseItems = items;
			courseIndex = index;
		}
		$("#SiteTitleDiv", domobj).html("<div style='font-size:14pt;padding-top:20px;'>" + item.class_id_ex + "</div><div style='font-size:18pt;padding-top:20px;'>" +
			item.Syllabuses_course_name + "</div><div style='font-size:16pt;padding-top:20px;'>" + item.Syllabuses_teacher_name + 
			"</div><div style='font-size:14pt;padding-top:20px;'>" + item.Syllabuses_date_ex + item.Syllabuses_AP);

		$(".BodyDiv", domobj).css({display:""});
		$("#SeatMapFrame", domobj).css({display:""});
		$("#BeginTime", domobj).html($.jcom.GetDateTimeString(item.BeginTime, 4));
		$("#EndTime", domobj).html($.jcom.GetDateTimeString(item.EndTime, 4));
		$("#bAttendance", domobj).prop("checked", item.bAttendance == 1);
		if (item.Syllabuses_ClassRoom == "")
			$("#ClassRoom", domobj).html("δ���õص�");
		else
			$("#ClassRoom", domobj).html(item.Syllabuses_ClassRoom);
			
		self.map.LoadCourseMap(item, "stckSeat.jsp");
		courseItem = item;
		if (typeof item.AttendObj == "object")
		{
			$("#CheckinDiv", domobj).css({display:""});
			$("#CheckinButton", domobj).val("�ѿ���");
			$("#CheckinButton", domobj).prop("disabled", true);
			$("#CheckinHint", domobj).html(item.AttendObj.Status);
		}
		else
			$("#CheckinDiv", domobj).css({display:"none"});
		if (cfg.viewmode == 1)
			window.setInterval(timer, 1000);
	};
		
	function MapReady(items)
	{
//		alert(items);
	}
	
	function CheckIn()
	{
		$.get(location.pathname, {StudentCheckIn:1, pos:"", StartTime:$.jcom.GetDateTimeString(NowDate()), 
			Status:getCheckStatus(), courseID: courseItem.Syllabuses_id}, StudentCheckInOK);
		getLocation();
	}
	
	function getCheckStatus()
	{
		var d = NowDate();
		var b = $.jcom.makeDateObj(courseItem.BeginTime);
		if (b >= d)
			return 0;
		else
			return 1;
	}

	function getLocation()
	{
		if (navigator.geolocation)
		{
			navigator.geolocation.getCurrentPosition(showPosition, showError);
    	}
		else
		{
			$("#CheckinHint",domobj).html("Geolocation is not supported by this browser.");
		}
	}
	
	function showPosition(position)
	{
		$.get(location.pathname, {StudentCheckIn:2, pos: position.coords.latitude + "," + position.coords.longitude,
			StartTime:$.jcom.GetDateTimeString(NowDate()), Status:getCheckStatus(), courseID: courseItem.Syllabuses_id}, StudentCheckInOK);
		$("#CheckinButton", domobj).prop("disabled", true);	
  //		$("#CheckinHint", domobj).html("Latitude: " + position.coords.latitude +
  //		"<br />Longitude: " + position.coords.longitude);
  	}

	function StudentCheckInOK(data)
	{
		$("#CheckinButton", domobj).val("�ѿ���");
		$("#CheckinButton", domobj).prop("disabled", true);
	}
	
	function showError(error)
	{
		switch(error.code) 
		{
		case error.PERMISSION_DENIED:
			$("#CheckinHint", domobj).html("User denied the request for Geolocation.");
			break;
		case error.POSITION_UNAVAILABLE:
			$("#CheckinHint", domobj).html("Location information is unavailable.");
			break;
		case error.TIMEOUT:
			$("#CheckinHint", domobj).html("The request to get user location timed out.");
			break;
		case error.UNKNOWN_ERROR:
			$("#CheckinHint", domobj).html("An unknown error occurred.");
			break;
		}
	}

	function timer()
	{
		var d = NowDate();
		var b = $.jcom.makeDateObj(courseItem.BeginTime);
		var e = $.jcom.makeDateObj(courseItem.EndTime);
		var text = "��ǰʱ��:" + $.jcom.GetDateTimeString(d);
		if (b > d)
		{
			text += "<br>�����Ͽο�ʼʱ�仹��" + DateDiff(b, d);
		}
		else
		{
			if (d > e)
				return self.LoadCourse(courseItems, courseIndex + 1);
			text += "<br>�����ϿΣ����Ͽ�" + DateDiff(d, b) + ",���¿λ���:" + DateDiff(e, d);
		}

		b.setTime(b.getTime() - 30 * 60 * 1000);
		if (b > d)
		{
			$("#CnrrentCourseText", domobj).html("�´ογ�");
			$("#CheckinDiv").css({display:"none"});
		}
		else
		{
			$("#CnrrentCourseText", domobj).html("���ογ�");
			$("#CheckinDiv", domobj).css({display:""});
		}	
		$("#CheckCard", domobj).html(text);
	}
	
	function DateDiff(d1, d2)
	{
		var offset = parseInt((d1.getTime() - d2.getTime()) / 1000);
		return parseInt(offset / 3600) + "Сʱ" 	+ parseInt((offset % 3600) / 60) + "����" + (offset % 60) + "��";
	}
}



function NowDate()
{
	var d = new Date();
	d.setFullYear(2017);
	d.setMonth(8);
	d.setDate(11);
	d.setHours(8);
	return d;
}
//(�鵵��ע��,����ɾ��)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
