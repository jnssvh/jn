<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanPlan";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanPlan' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##168:��������������(�鵵��ע��,����ɾ��)
	int ExcelFormID = WebChar.ToInt(jdb.getValueBySql(0, "select ID from UserDatas where Status=1 and EName='CPB_Class_Course'"));
	int Class_id = WebChar.RequestInt(request, "Class_id");
	int Term_id  = 0;
	if (Class_id > 0)
		Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>��ѧ�ƻ�</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
<style id="css_272" type="text/css">
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
<script type="text/javascript" src="../cps/js/CPtechPlan.js"></script>
<script type="text/javascript" src="../cps/js/plancourse.js"></script>

<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanPlan", Role:<%=Purview%>};
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
		{item:"�����ĵ�", img:"", action:OutFile, info:"", Attrib:1},
		{item:"�༭�ĵ�", img:"", action:EditFile, info:"", Attrib:2},
		{item:"����ĵ�", img:"", action:CheckFile, info:"", Attrib:0},
		{item:"�����ĵ�", img:"", action:PublishFile, info:"", Attrib:0}
			];
	book.setTool(Tools);
	var Links = [{item:"�γ̱�", img:"", Code:"deanCourse", info:"", Attrib:0}];
	book.setLink(Links);
//@@##169:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
	var o = book.setDocTop("������...", "Filter", "");
 	book.Filter = new TermClassFilter(o, {Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.Filter.onclickClass = ClickClass;
	$("#Page").css({padding: "20px 60px 20px 60px"});
	book.setPageObj(book.Filter);
	book.onLink = book.Filter.LinkAddParam;
	book.Page = new PlanDoc($("#Page")[0], {mode:0, TMPID:<%=ExcelFormID%>});

		
//	book.Page = new PlanCourseEditor($("#PlanCourseDoc")[0], jsonData, option, {mode:0});
//	book.Page.onClipChange = ReloadClip;
//	book.Page.onDblClick = DblClickPlan;
//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##170:�ͻ����Զ������(�鵵��ע��,����ɾ��)
var option = {
		CourseShowMode:<%=sysApp.getSysParam(5, "PlanCourseShowMode", "��ѧ�ƻ��γ���ʾ�ṹ", "1")%>,
		CourseNoMode: <%=sysApp.getSysParam(5, "PlanCourseNoMode", "��ѧ�ƻ��γ���ű��ŷ�ʽ", "1")%>,
		CourseNameMode: <%=sysApp.getSysParam(5, "PlanCourseNameMode", "��ѧ�ƻ��γ�������ʾ��ʽ", "0")%>,
		TeacherShowMode: <%=sysApp.getSysParam(5, "PlanTeacherShowMode", "��ѧ�ƻ���У�ڿ�����ʾ��ʽ", "0")%>,
		OuterTeacherShowMode: <%=sysApp.getSysParam(5, "PlanOuterTeacherShowMode", "��ѧ�ƻ������ڿ�����ʾ��ʽ", "0")%>,
		CourseNameEditEnable: <%=sysApp.getSysParam(5, "PlanCourseNameEditEnable", "��ѧ�ƻ��༭�γ���������", "2")%>,
		CourseTimeEnable: <%=sysApp.getSysParam(5, "PlanCourseTimeEnable", "��ѧ�ƻ��γ�ʱ����ʾ�༭����", "0")%>,
		TeacherEditEnable: <%=sysApp.getSysParam(5, "PlanTeacherEditEnable", "��ѧ�ƻ��༭�ڿ�������", "0")%>,
		TeacherUnitEditEnable: <%=sysApp.getSysParam(5, "PlanTeacherUnitEditEnable", "��ѧ�ƻ��༭�ڿ��˵�λ����", "0")%>,
		CourseLayerMode: <%=sysApp.getSysParam(5, "PlanCourseLayerMode", "��ѧ�ƻ��γ��Ű淽ʽ", "1")%>,
		CourseFreeInfo: <%=sysApp.getSysParam(5, "PlanCourseFreeInfo", "��ѧ�ƻ�ѡ�޿���ʾ����", "1")%>,
		ActivityMode: <%=sysApp.getSysParam(5, "PlanActivityMode", "��ѧ�ƻ���ѧ�����ʽ", "1")%>,
		CourseShowRed: <%=sysApp.getSysParam(5, "PlanCourseShowRed", "����ר����еĿγ� ", "1")%>,
		CommonUnitCourseEditEnable: <%=sysApp.getSysParam(5, "PlanCommonUnitCourseEditEnable", "�༭������Ԫ��γ� ", "0")%>
		};

function ClickClass(obj, item)
{
	book.Page.LoadPlanDoc(item.Class_id);
}

function OutFile(obj, item)	//�����ĵ�
{
//

}



function EditFile(obj, item)	//�༭�ĵ�
{
//
	var mode = book.toggleEditMode();
	if (mode == 1)
	{
		if (book.res == undefined)
		{
			var tag = "<div style='float:right;width:20px;padding-top:4px;'><img id=SearchButton src=../pic/search.png></div>" +
				"<div id=SearchInput title='�ڴ�������Ҫ�����Ŀγ����ݻ��ڿ���...' style='margin-left:20px;margin-right:20px;border-bottom:1px solid gray;'></div>";
			var o = book.setPageLeft(tag, "UserLeftTree");
			book.res = new PlanResTree(o);
		}
		var o = book.getChild();
		book.Page.LoadEditor(o.toolObj, book.res, o.sys);
//		var classObj = book.Page.getChild("classObj");
//		book.Editor.LoadCourse(classObj.Class_id);
	}
	else
	{
		book.Editor.setDomObj();
		book.Page.setDomObj($("#CourseBox")[0]);
		var classObj = book.Page.getChild("classObj");
		book.Page.LoadCourse(classObj.Class_id);
	}

}



function CheckFile(obj, item)	//����ĵ�
{
//

}



function PublishFile(obj, item)	//�����ĵ�
{
//

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
