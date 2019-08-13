<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanCourse";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanCourse' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##215:��������������(�鵵��ע��,����ɾ��)
//
int Class_id = WebChar.RequestInt(request, "Class_id");
int Term_id  = 0;
if (Class_id > 0)
	Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>�γ̱�</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
<style id="css_273" type="text/css">
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanCourse", Role:<%=Purview%>};
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
		{item:"����οα�", img:"", action:OneClassCourseView, info:"", Attrib:1, Param:1},
		{item:"���οα�", img:"", action:MultiClassCourseView, info:"", Attrib:1, Param:1},
		{item:"ѧ���ܿα�", img:"", action:TermCourseView, info:"", Attrib:1, Param:2},
		{item:"", img:"", action:null, info:"", Attrib:0, Param:1},
		{item:"�����α�", img:"", action:null, info:"", Attrib:1, Param:2, child:[
			{item:"������WORD�ļ�", img:"", action:OutCourseWord, info:"", Attrib:1, Param:1},
			{item:"������EXCEL�ļ�", img:"", action:OutCourseEXCEL, info:"", Attrib:1, Param:1},
			{item:"����������������ĵ�", img:"", action:OutCourseServer, info:"", Attrib:2, Param:1}]},
		{item:"�༭�α�", img:"", action:EditCourse, info:"", Attrib:2, Param:2},
		{item:"����", img:"", action:CourseOption, info:"", Attrib:2, Param:1}
			];
	book.setTool(Tools);
	var Links = [{item:"��ѧ�ƻ�", img:"#57418", Code:"deanPlan", info:"", Attrib:0},
{item:"�γ��ʾ�", img:"#57406", Code:"deanEvCourse", info:"", Attrib:0}];
	book.setLink(Links);
//@@##193:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//
	var o = book.setDocTop("������...", "Filter", "");
 	book.tcFilter = new TermClassFilter(o,{Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tcFilter.onclickClass = ClickClass;
	book.tcFilter.onclickTerm = ClickTerm;
	
//	$("#Page").css({padding: "20px 60px 20px 60px"});
	book.setPageObj(book.tcFilter);
	book.onLink = book.tcFilter.LinkAddParam;
	var box = new $.jcom.SlideBox($("#Page")[0], "CourseBox");
	book.Page = new CourseTable($("#CourseBox")[0], []);

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##194:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//

//var openwin, classtree;
//var viewInfo = {nPage:1, PageSize:<%=WebChar.ToInt(sysApp.getSysParam(5, "CourseDefaultPageSize", "ÿҳ��ʾ�Ŀα������", "120"))%>, Records:0};
//var classID = 0;
//var coursePath = "../cps/jsp/course.jsp";
function ClickTerm(obj, item)
{
	var o = book.Page.getChild();
	if (o.cfg.viewMode != 2)
		return;
	book.Page.LoadTermCourse(item.Term_id, item.Term_Name + "�ܿα�");
}	

function ClickClass(obj, item)
{
	book.Page.LoadCourse(item.Class_id);
}

function OutCourse(obj, item)	//�����α�
{
//
}

function EditCourse(obj, item)	//�༭�α�
{
//
//window.open("../LY_CPB/CourseEditNew.jsp?EditMode=1&ClassID=" + classObj.Class_id);
//return;
	var mode = book.toggleEditMode();
	if (mode == 1)
	{
		book.Page.setDomObj();
		if (book.res == undefined)
		{
			var tag = "<div style='float:right;width:20px;padding-top:4px;'><img id=SearchButton src=../pic/search.png></div>" +
				"<div id=SearchInput title='�ڴ�������Ҫ�����Ŀγ����ݻ��ڿ���...' style='margin-left:20px;margin-right:20px;border-bottom:1px solid gray;'></div>";
			var o = book.setPageLeft(tag, "UserLeftTree");
			book.res = new CourseResTree(o);
			book.Editor = new CourseEditor($("#CourseBox")[0], [], {tree:book.res});
			book.Editor.onExit = EditCourse;
		}
		else
			book.Editor.setDomObj($("#CourseBox")[0]);
		var toolObj = book.getChild("toolObj");
		book.Editor.loadMenu(toolObj);
		var classObj = book.Page.getChild("classObj");
		book.Editor.LoadCourse(classObj.Class_id);
	}
	else
	{
		book.Editor.setDomObj();
		book.Page.setDomObj($("#CourseBox")[0]);
		var classObj = book.Page.getChild("classObj");
		book.Page.LoadCourse(classObj.Class_id);
	}
}

function CheckCourse(obj, item)	//��˿α�
{
//

}

function PublishCourse(obj, item)	//�����α�
{
//

}
function ChangeCourse(obj, item)	//����
{
//

}

function PrepareCourseUserData(courseGrid)
{
	return true;
}

function PrepareTermCourseUserData(courseGrid)
{
	return true;	
}

function OneClassCourseView(obj, item)	//����οα�
{
//
	book.setDocWidth(796);
	var tool = book.getChild("toolObj");
	def = tool.getmenu();
	def[0].img = "#8730";
	def[1].img = "";
	def[2].img = "";
	tool.setDisabled("�༭�α�", false);
	tool.setDisabled("����", false);
	tool.reload(def);
	
	book.tcFilter.AddLegend("���");
	$("#Filter").css({display:""});
	book.setPageObj(book.tcFilter);
	var sel = book.tcFilter.getsel(0);
	$(sel).click();

}



function MultiClassCourseView(obj, item)	//���οα�
{
//
	var o = book.Page.getChild();
	var dlg = new ManyClassCourseSetup(o.classObj, o.cfg.coursePath);
	dlg.show();
	dlg.setupOK = MultiClassCourseViewRun;
}

function MultiClassCourseViewRun(ClassIDs, beginTime, endTime, option)
{
	book.setDocWidth(1126);
	var tool = book.getChild("toolObj");
	def = tool.getmenu();
	def[0].img = "";
	def[1].img = "#8730";
	def[2].img = "";
	tool.setDisabled("�༭�α�", true);
	tool.setDisabled("����", true);
	tool.reload(def);
	$("#Filter").css({display:"none"});
	book.setPageObj();
	book.Page.LoadManyClassCourse(ClassIDs, beginTime, endTime, option)
}

function TermCourseView(obj, item)	//ѧ���ܿα�
{
//
	book.setDocWidth(796);
	var tool = book.getChild("toolObj");
	def = tool.getmenu();
	if (def[2].img == "")
	{
		def[0].img = "";
		def[1].img = "";
		def[2].img = "#8730";
		tool.setDisabled("�༭�α�", true);
		tool.setDisabled("����", true);
		tool.reload(def);
	
		var item = book.tcFilter.getselItem(0);
		book.tcFilter.RemoveLegend();
		$("#Filter").css({display:""});
		book.setPageObj(book.tcFilter);
	}
	book.Page.LoadTermCourse(item.Term_id, item.Term_Name + "�ܿα�");
}



function OutCourseWord(obj, item)	//������WORD�ļ�
{
//

}



function OutCourseEXCEL(obj, item)	//������EXCEL�ļ�
{
//

}



function OutCourseServer(obj, item)	//����������������ĵ�
{
//

}



function CourseOption(obj, item)	//����
{
//
	var dlg = new OptionSetup(book.Page);
	dlg.show();
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
