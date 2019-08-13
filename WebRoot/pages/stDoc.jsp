<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="stDoc";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='stDoc' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##355:��������������(�鵵��ע��,����ɾ��)
	int Class_id = WebChar.RequestInt(request, "Class_id");
	int Term_id  = 0;
	if (Class_id > 0)
		Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>ѧ�����˱�</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"stDoc", Role:<%=Purview%>};
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
		{item:"ѧ���ǼǱ�", img:"", action:SetViewMode1, info:"", Attrib:1, Param:0},
		{item:"ѧ�����˱�", img:"", action:SetViewMode2, info:"", Attrib:1, Param:0},
		{item:"ѧ�����˵ǼǱ�", img:"", action:SetViewMode3, info:"", Attrib:1, Param:0},
		{item:"", img:"", action:null, info:"", Attrib:0, Param:0},
		{item:"����", img:"", action:ImportFile, info:"", Attrib:2, Param:0, child:[
			{item:"���뵥���ļ�", img:"", action:null, info:"", Attrib:0, Param:0},
			{item:"�����ļ���", img:"", action:null, info:"", Attrib:0, Param:0}]},
		{item:"����", img:"", action:OutputFile, info:"", Attrib:1, Param:0, child:[
			{item:"���������ļ�", img:"", action:null, info:"", Attrib:0, Param:0},
			{item:"�����������ļ���", img:"", action:null, info:"", Attrib:0, Param:0},
			{item:"��������ѧԱ��Ƭ", img:"", action:null, info:"", Attrib:0, Param:0}]},
		{item:"��ӡ", img:"", action:PrintPage, info:"", Attrib:1, Param:0},
		{item:"����", img:"", action:SavePage, info:"", Attrib:2, Param:0},
		{item:"���", img:"", action:DesignForm, info:"", Attrib:16, Param:0},
		{item:"����", img:"", action:null, info:"", Attrib:2, Param:0, child:[
			{item:"ͳһ���ÿ�����", img:"", action:TotalSet, info:"", Attrib:0, Param:0},
			{item:"����������ͳһ���浽��������ѧԱ", img:"", action:SavetoAll, info:"", Attrib:0, Param:0},
			{item:"�����ί��������", img:"", action:ImportClassNote, info:"", Attrib:0, Param:0}]}
			];
	book.setTool(Tools);
	var Links = [{item:"��ѧ�ƻ�", img:"#57418", Code:"deanPlan", info:"", Attrib:0},
{item:"�γ̱�", img:"#57401", Code:"deanCourse", info:"", Attrib:0},
{item:"ѧԱ����", img:"#57378", Code:"stFile", info:"", Attrib:0},
{item:"���ڹ���", img:"#57453", Code:"stCheck", info:"", Attrib:0},
{item:"���ι���", img:"#57445", Code:"stEvaluation", info:"", Attrib:0}];
	book.setLink(Links);
//@@##351:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//��������:Page
	var o = book.getDocObj("Page")[0];
	var box = new $.jcom.SlideBox(o, "StudentDiv");
	book.Page = new $.jcom.DBForm($("#StudentDiv")[0],  "../fvs/FormStudentRpt.jsp",{}, {itemstyle:"font:normal normal normal 15px ΢���ź�"});

//	$("#Page").css({padding: "20px 20px 20px 20px"});
//	book.Page = new $.jcom.DBForm(book.getDocObj("Page")[0], "../fvs/FormStudentRpt.jsp",{}, {});

	var o = book.setDocTop("������...", "Filter", "");
 	book.tcsFilter = new TCSFilter(o, {Term_id:<%=Term_id%>, Class_id:<%=Class_id%>, Student_id:0});
	book.setPageObj(book.tcsFilter);
	book.tcsFilter.onclickStudent = ClickStudent;
	
//	book.onLink = book.tcFilter.LinkAddParam;

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##352:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function ClickStudent(obj, item)
{
	$.get("../fvs/FormStudentRpt.jsp", {GetStudentInfo:1, RegID: item.RegID}, GetStudentOK);
}

function GetStudentOK(data)
{
	var items = $.jcom.eval(data);
	if (typeof items == "string")
		alert(items);
	if (items.Rewards != "")
		items._info[0].TrainingNote = items.Rewards;
	if (items.Resume != "")
		items._info[0].WorkNote = items.Resume;
	//  items._info[0].Mobile += " " + items._info[0].OfficePhone;
	var info = items._info[0];
	var sbjs = items._sbjs;
	var record = book.Page.getRecord();
	for (var key in record)
	{
		if (items[key] != undefined)
			record[key] = book.Page.TranslateValue(key, items[key]);
		else if (info[key] != undefined)
			record[key] = book.Page.TranslateValue(key, info[key]);
		else if (sbjs[key] != undefined)
			record[key] = sbjs[key];
		else
			record[key] = "";
		switch (key)
		{
		case "Photo":
			if (record[key] != "")
				record[key] = {value: record[key], ex: "<img width=100% src=" + record[key] + ">"};
			break;
		case "IDCard":
			if (record[key].substr(0, 1) == "-")
				record[key] = record[key].substr(1);
			break;
		}
	}
	record.FinishNo = record.STdNo;
	var SbjUnit = 0, SbjClassHours = 0, SbjClassNum = 0; 
	for (var x = 1; x < 10; x++)
	{
		if ((record["SbjClassHours" + x] == 0) || (record["SbjClassHours" + x] == ""))
		{
			record["SbjUnitNum" + x] = 0;
		}
		else
		{
			record["SbjUnitNum" + x] = 1;
			SbjUnit ++;
			SbjClassHours += parseInt(record["SbjClassHours" + x]);
			SbjClassNum += parseInt(record["SbjClassNums" + x]);
		}
	}
	record.SbjUnitNum = SbjUnit;
	record.SbjClassHours = SbjClassHours;
	record.SbjClassNums = SbjClassNum;
	book.Page.setRecord(record);
//	if (printing == 1)
//	    window.print();
//	  if (outflag == 1)
//		  OutOne();
}

function SetViewMode1(obj, item)	//ѧ���ǼǱ�
{
//

}



function SetViewMode2(obj, item)	//ѧ�����˱�
{
//

}



function SetViewMode3(obj, item)	//ѧ�����˵ǼǱ�
{
//

}



function ImportFile(obj, item)	//����
{
//

}



function OutputFile(obj, item)	//����
{
//

}



function PrintPage(obj, item)	//��ӡ
{
//

}



function SavePage(obj, item)	//����
{
//

}



function DesignForm(obj, item)	//��� 
{

	book.Page.DesignForm();
//	window.open("../fvs/UserDatas_viewExcel.jsp");
}



function TotalSet(obj, item)	//ͳһ���ÿ�����
{
//

}



function SavetoAll(obj, item)	//����������ͳһ���浽��������ѧԱ
{
//

}



function ImportClassNote(obj, item)	//�����ί��������
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
