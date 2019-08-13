<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="stCkSet";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='stCkSet' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##540:��������������(�鵵��ע��,����ɾ��)
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

if (WebChar.RequestInt(request, "GetAttendance") == 1)
{
	int ClassID = WebChar.RequestInt(request, "ClassID");
	int TermID = WebChar.RequestInt(request, "TermID");
	String Course = "[]";
	if (ClassID > 0)
		Course = jdb.getJsonBySql(0, "select Syllabuses_id, bAttendance from CPB_Syllabuses where CPB_Syllabuses.class_id=" + ClassID);
	else
		Course = jdb.getJsonBySql(0, "select Syllabuses_id, bAttendance,from CPB_Syllabuses where CPB_Syllabuses.term_id=" + TermID);
	out.print(Course);
	jdb.closeDBCon();
	return;
}
if (WebChar.RequestInt(request, "SaveAttendence") == 1)
{
	int num = WebChar.RequestInt(request, "Num");
	for (int x = 0; x < num; x++)
	{
		int Syllabuses_id = WebChar.ToInt(WebChar.RequestForms(request, "Syllabuses_id", x));
		int bAttendance = WebChar.ToInt(WebChar.RequestForms(request, "bAttendance", x));
		String sql = "update CPB_Syllabuses set bAttendance=" + bAttendance + " where Syllabuses_id=" + Syllabuses_id;
		jdb.ExecuteSQL(0, sql);
	}
	out.print("����ɹ�,����" + num + "����¼");	
	jdb.closeDBCon();
	return;	
}
//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>��������</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
<style id="css_541" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"stCkSet", Role:<%=Purview%>};
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
	var Tools = [
		{item:"����", img:"", action:null, info:"", Attrib:0, Param:1, child:[
			{item:"������WORD�ļ�", img:"", action:OutWord, info:"", Attrib:0, Param:1},
			{item:"������EXCEL�ļ�", img:"", action:OutExcel, info:"", Attrib:0, Param:1}]},
		{item:"����", img:"", action:SetEditMode, info:"", Attrib:0, Param:1}
			];
	book.setTool(Tools);
//@@##543:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
	var o = book.setDocTop("������...", "Filter", "");
 	book.tcFilter = new TermClassFilter(o,{Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tcFilter.onclickClass = ClickClass;
//	$("#Page").css({padding: "20px 60px 20px 60px"});
	book.setPageObj(book.tcFilter);
	book.onLink = book.tcFilter.LinkAddParam;

	var o = book.getDocObj("Page")[0];
	var box = new $.jcom.SlideBox(o, "CourseDiv");
	book.Page = new CourseTable($("#CourseDiv")[0], []);
	book.Page.PrepareCourseUserData = PrepareCourseUserData;
	var viewhead = book.Page.getHead();
	viewhead[viewhead.length] = {FieldName:"bAttendance", TitleName:"�Ƿ���", nWidth:60, nShowMode:1};
	book.Page.reset([], {}, viewhead);	
	aTEdit = new $.jcom.DynaEditor.List("��,��", 300, 300);
	aTEdit.valueChange = AttendenceChange;
	
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##544:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function ClickClass(obj, item)
{
	book.Page.LoadCourse(item.Class_id);
}

function AttendenceChange(obj)
{
	var index = obj.parentNode.parentNode.rowIndex;
	if (index == undefined)
		index = obj.parentNode.parentNode.parentNode.rowIndex;
	var o = book.Page.getChild();
	o.courseGrid[index].bAttendance = obj.innerText;
	if (o.courseGrid[index].index >= 0)
	{
		if (obj.innerText == "��")
			o.courseObj[o.courseGrid[index].index].bAttendance = 1;
		else
			o.courseObj[o.courseGrid[index].index].bAttendance = 0;
		o.courseObj[o.courseGrid[index].index].EditFlag = 1;
	}
}

function PrepareCourseUserData(courseGrid, viewInfo, viewhead)
{
	function CourseUserDataOK(data)
	{
		var json = $.jcom.eval(data);
		if (typeof json == "string")
			return alert(json);
		PrepareAttendanceData(json);
		book.Page.reset(courseGrid, viewInfo, viewhead);
	}
	
	var o = book.Page.getChild();
	$.get(location.pathname, {GetAttendance:1, TermID: o.classObj.Term_id, ClassID:o.classObj.Class_id}, CourseUserDataOK);
	return true;
}


function PrepareAttendanceData(Course)
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
					if (Course[y].bAttendance == 1)
						o.courseGrid[x].bAttendance = "��";
					else
						o.courseGrid[x].bAttendance = "��";
					o.courseObj[o.courseGrid[x].index].bAttendance = Course[y].bAttendance;
				}
			}
			o.courseObj[o.courseGrid[x].index].EditFlag = 0;
		}
	}	
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
	var head = [{FieldName:"CourseTime", TitleName:"����", nWidth:66, nShowMode:1},
	    		{FieldName:"ap", TitleName:"���", nWidth:36, nShowMode:1},
	    		{FieldName:"Class_Name", TitleName:"���", nWidth:100, nShowMode:1},
	    	    {FieldName:"Course", TitleName:"����", nWidth:200, nShowMode:1},
	    	    {FieldName:"Teacher", TitleName:"�ڿ���", nWidth:60, nShowMode:1},
	    	    {FieldName:"ClassRoom", TitleName:"�ص�", nWidth:80, nShowMode:1},		
	    	    {FieldName:"evaluate_id", TitleName:"�����ʾ�", nWidth:160, nShowMode:1}];
	courseGrid[2].evaluate_id = "�����ʾ�";
	view.reset(courseGrid, viewInfo, head);
	view.attachEditor("evaluate_id", EvaEdit, false);
}


function OutExcel(obj, item)	//������EXCEL�ļ�
{
//

}

function OutWord(obj, item)	//������WORD�ļ�
{
//

}

var hostMenuDef, setupMode = 0;
function SetEditMode(obj, item)	//�����Ƿ���
{
//
		var child = book.getChild();
		var menu = child.toolObj;
		if (setupMode == 0)
		{
			setupMode = 1;
			hostMenuDef = menu.getmenu();
			var def = [{item:"��������", action:BatchAttendenceSet}, {item:"����", img:"#59432", action:SaveAttendence},{},{item:"����",img:"#59470", action:SetEditMode}];
			menu.reload(def);
			book.Page.attachEditor("bAttendance", aTEdit, false);
		}
		else
		{
			if (window.confirm("�Ƿ�ȷ��Ҫ�˳��༭ģʽ?") == false)
				return;
			setupMode = 0;
			book.Page.detachEditor("bAttendance");
			menu.reload(hostMenuDef);
		}
		book.toggleEditMode();
}


function BatchAttendenceSet()
{
	var obj = book.Page.getViewSelRows();
	if (obj.length == 0)
		return alert("����ѡ��һ��");

	var o = book.Page.getChild();		
	var index = o.courseGrid[obj[0].rowIndex].index;
	var val = o.courseGrid[obj[0].rowIndex].bAttendance;
	if (window.confirm("�Ƿ���������Ϊ��ǰֵ[" + val  + "]��") == false)
		return;
	var bAttendance = o.courseObj[index].bAttendance;
	for (var x = 0; x < o.courseGrid.length; x++)
	{
		if (o.courseGrid[x].index >= 0)
		{
			o.courseGrid[x].bAttendance = val;
			o.courseObj[o.courseGrid[x].index].bAttendance = bAttendance;
			o.courseObj[o.courseGrid[x].index].EditFlag = 1;
		}
	}
	book.Page.reload(o.courseGrid);	
}

function SaveAttendence()
{
	var data = "", cnt = 0;
	var o = book.Page.getChild();
	for (var x = 0; x < o.courseObj.length; x++)
	{
//		if (courseObj[x].EditFlag == 1)
		{
			data += "&Syllabuses_id=" + o.courseObj[x].Syllabuses_id + "&bAttendance=" + o.courseObj[x].bAttendance
			cnt ++;
		}
	}
	$.jcom.Ajax(location.pathname + "?SaveAttendence=1&Num=" + cnt, true, data, SaveAttendenceOK);
}

function SaveAttendenceOK(result)
{
	alert(result);
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
