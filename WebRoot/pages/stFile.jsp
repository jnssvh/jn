<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="stFile";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='stFile' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##326:��������������(�鵵��ע��,����ɾ��)
	int Class_id = WebChar.RequestInt(request, "Class_id");
	int Term_id  = 0;
	if (Class_id > 0)
		Term_id = WebChar.ToInt(jdb.GetTableValue(0, "CPB_Class", "Term_id", "Class_id", "" + Class_id));

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>ѧԱ����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-8-29 -->
<style id="css_283" type="text/css">
body{
background: #e9ebee url(../res/skin/p3.jpg) no-repeat fixed;
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"stFile", Role:<%=Purview%>};
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
		{item:"ѧԱ����", img:"../pic/flow_end.png", action:SetView, info:"", Attrib:1},
		{item:"ѧ������", img:"", action:SetView, info:"", Attrib:1},
		{item:"���˻���", img:"", action:SetView, info:"", Attrib:1},
		{item:"ѧ������", img:"", action:SetView, info:"", Attrib:1},
		{item:"", img:"", action:null, info:"", Attrib:1},
		{item:"��ѯ", img:"../pic/c3.png", action:SeekPage, info:"ȫ�ļ���", Attrib:1},
		{item:"����", img:"../pic/new_folder.png", action:NewRecordPage, info:"����һ����¼", Attrib:2},
		{item:"�༭", img:"../pic/wendang.png", action:EditRecordPage, info:"�༭��ǰ��¼", Attrib:2},
		{item:"ɾ��", img:"../pic/lj.png", action:DelRecordPage, info:"ɾ����ǰ��¼", Attrib:2},
		{item:"ˢ��", img:"../pic/refur.gif", action:RefreshPage, info:"���¼���", Attrib:1},
		{item:"����", img:"", action:null, info:"", Attrib:2, child:[
			{item:"�����ϱʻ�����", img:"", action:null, info:"", Attrib:2},
			{item:"�Զ���������", img:"", action:null, info:"", Attrib:2},
			{item:"�Զ�����ѧ��", img:"", action:null, info:"", Attrib:2},
			{item:"����ѧԱѧ��", img:"", action:null, info:"", Attrib:2},
			{item:"�ֶ�����", img:"", action:null, info:"�ֶ�����ѧ�ţ���ţ���ְ��", Attrib:2},
			{item:"��ɲ�����", img:"", action:null, info:"", Attrib:2},
			{item:"ͳһ���ÿ�����", img:"", action:null, info:"", Attrib:2},
			{item:"�ֶ����ÿ�����", img:"", action:null, info:"", Attrib:2}]}
			];
	book.setTool(Tools);
	var Links = [{item:"��ѧ�ƻ�", img:"", Code:"deanPlan", info:"", Attrib:0},
{item:"�γ̱�", img:"", Code:"deanCourse", info:"", Attrib:0}];
	book.setLink(Links);
//@@##325:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
	$("#Page").css({padding: "20px 20px 20px 20px"});
	book.Page = new $.jcom.DBGrid(book.getDocObj("Page")[0], "../fvs/SS_Student2.jsp",{}, {}, {gridstyle:3, resizeflag:0});
	book.Page.makeThumb = makeThumb;

	var o = book.setDocTop("������...", "Filter", "");
 	book.tcFilter = new TermClassFilter(o, {Term_id:<%=Term_id%>, Class_id:<%=Class_id%>});
	book.tcFilter.onclickClass = ClickClass;
	book.setPageObj(book.tcFilter);
	book.onLink = book.tcFilter.LinkAddParam;

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
}
//@@##318:�ͻ����Զ������(�鵵��ע��,����ɾ��)
function SeekPage(obj, item)	//��ѯ
{
//ȫ�ļ���
	book.Page.Seek();

}



function NewRecordPage(obj, item)	//����
{
//����һ����¼
	book.Page.NewItem();

}



function EditRecordPage(obj, item)	//�༭
{
//�༭��ǰ��¼
	book.Page.EditItem();

}



function DelRecordPage(obj, item)	//ɾ��
{
//ɾ����ǰ��¼
	book.Page.DeleteItem();

}



function RefreshPage(obj, item)	//ˢ��
{
//���¼���
	book.Page.ReloadGrid();

}

function ClickClass(obj, item)
{
	book.Page.config({URLParam:"?ClassID=" + item.Class_id});
	book.Page.ReloadGrid();
}

var listname = "ѧԱ����";
function SetView(obj, item)	//ѧԱ����
{
//
	var o = book.getChild();
	var def = o.toolObj.getmenu();
	def[0].img = "";
	def[1].img = "";
	def[2].img = "";
	def[3].img = "";
	item.img = "../pic/flow_end.png";
	o.toolObj.show();
	listname = item.item;
	book.Page.ReloadGrid();
}

function makeThumb(line, hint, index, item)
{
	if (typeof item.RegID == "undefined")
		return "<div name=thumbdiv style='clear:both;padding:4px;margin:4px;' node=" + index + ">" + item.STdNo.value + "</div>";
	else if (typeof item.RegID == "object")
		return "";

	var img = "<img style='float:left;width:180px;height:180px' src=" + item.Photo + ">";
	var o = book.Page.getChildren();
	var h = o.gridhead;
	switch (listname)
	{
	case "ѧԱ����":
		return "<span name=thumbdiv style='float:left;width:200px;padding:4px;margin:4px;border:1px solid #c0c0c0;background-color:#fcfcfc;' node=" + index +
			"><div align=center style='width:180px;height:180px;overflow:hidden;'>" +img + "</div>" +
			"<div align=center><span style=color:gray>" + item.STdNo + "</span><span style='font:normal normal bolder 12pt ΢���ź�'>" +line + "</span></div>" +
			"<div style=height:45px;text-overflow:ellipsis;overflow:hidden;>" + item.WorkUnit + "</div></span>";
	default:
		var div1 = "", div2 = "", div3 = "", div4 = "", div5 = "", div6 = "";
		div1 = "<div style=float:left;width:180px;padding:4px;><span style=color:gray>ѧ��:" + item.STdNo + "</span><br>" + 
			"<span style=color:gray>����:</span><span style='font:normal normal bolder 12pt ΢���ź�'>" + item.StdName + "</span><br>" +
			"<span style=color:gray>�Ա�:" + h.getItemValue(item, "Gender") + "</span><br>" + 
			"<span style=color:gray>����:" + h.getItemValue(item, "Nation") + "</span><br>" + 
			"<span style=color:gray>��������:" + h.getItemValue(item, "Birthday") + "</span><br>" + 
			"<span style=color:gray>�ֻ�:" + item.Mobile + "</span><br>" + 
			"<span style=color:gray>��λ��ְ��:" + item.WorkUnit + "</span></div>";
		if (listname != "���˻���")
		{
			div2 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>������:" + h.getItemValue(item, "BirthPlace") + "</span><br>" + 
				"<span style='color:gray'>������ò:" + h.getItemValue(item, "PoliticalStatus") + "</span><br>" +
				"<span style=color:gray>�μӹ���ʱ��:" + h.getItemValue(item, "WorkDate") + "</span><br>" + 
				"<span style=color:gray>ѧ��:" + h.getItemValue(item, "Education") + "</span><br>" + 
				"<span style=color:gray>ѧλ:" + h.getItemValue(item, "Degree") + "</span><br>" + 
				"<span style=color:gray>��ѧרҵ:" + h.getItemValue(item, "Specialty") + "</span><br>" + 
				"<span style=color:gray>��ҵԺУ:" + h.getItemValue(item, "GraSchool") + "</span></div>";
			div3 = "<div style=float:left;width:190px;padding:4px;>" +
				"<span style=color:gray>��������:" + h.getItemValue(item, "GovLevel") + "</span><br>" + 
				"<span style='color:gray'>ְ��:" + h.getItemValue(item, "JobTitle") + "</span><br>" +
				"<span style=color:gray>֤����:" + h.getItemValue(item, "IDCard") + "</span><br>" + 
				"<span style=color:gray>����:" + h.getItemValue(item, "EMail") + "</span><br>" + 
				"<span style=color:gray>�ʱ�:" + h.getItemValue(item, "PostCode") + "</span><br>" + 
				"<span style=color:gray>����ְʱ��:" + h.getItemValue(item, "DutyDate") + "</span><br>" + 
				"<span style=color:gray>ͨ�ŵ�ַ:" + h.getItemValue(item, "WorkPlace") + "</span></div>";
		}
		if (listname != "ѧ������")
		{
			div4 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>�༶ְ��:" + h.getItemValue(item, "ClassDuty") + "</span><br>" + 
				"<span style='color:gray'>�����:" + h.getItemValue(item, "GroupNo") + "</span><br>" +
				"<span style=color:gray>���(��):" + h.getItemValue(item, "Check1") + "</span><br>" + 
				"<span style=color:gray>����(��):" + h.getItemValue(item, "Check2") + "</span><br>" + 
				"<span style=color:gray>�ٵ�����(��):" + h.getItemValue(item, "Check3") + "</span><br>" + 
				"<span style=color:gray>���ڵ÷�:" + h.getItemValue(item, "CheckScore") + "</span><br>" + 
				"<span style=color:gray>���ع涨���:" + h.getItemValue(item, "RuleNote") + "</span></div>";
			div5 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>����(����):" + h.getItemValue(item, "Score1") + "</span><br>" + 
				"<span style='color:gray'>����(ѧϰ�ĵ�):" + h.getItemValue(item, "Score2") + "</span><br>" +
				"<span style=color:gray>���б���:" + h.getItemValue(item, "Score3") + "</span><br>" + 
				"<span style=color:gray>�ۺ�ѧϰ���˵÷�:" + h.getItemValue(item, "Score4") + "</span><br>" + 
				"<span style=color:gray>ѧ���䶯���:" + h.getItemValue(item, "ChangeContent") + "</span><br>" + 
				"<span style=color:gray>�������:" + h.getItemValue(item, "PanishContent") + "</span></div>";
			div6 = "<div style=float:left;width:180px;padding:4px;>" +
				"<span style=color:gray>��У����:" + h.getItemValue(item, "LeaveDate") + "</span><br>" + 
				"<span style='color:gray'>��Уԭ��:" + h.getItemValue(item, "LeaveInfo") + "</span><br>" +
				"<span style=color:gray>��ע:" + h.getItemValue(item, "Note") + "</span></div>";
		}
			
		return "<div name=thumbdiv style='float:left;padding:4px;margin:0px;border-bottom:1px solid gray;background-color:#fcfcfc;' node=" + index + ">" +
			img + div1 + div2 + div3 + div4 + div5 + div6 + "</div>";
	}
	
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
