<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="deanSite";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='deanSite' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
//@@##535:��������������(�鵵��ע��,����ɾ��)
//
	if (WebChar.RequestInt(request, "SaveMap") == 1)
	{
		String SeatMap = WebChar.requestStr(request, "SeatMap");
		int DataID = WebChar.RequestInt(request, "DataID");
		if (DataID > 0)
			jdb.ExecuteSQL(0, "update Place set SeatMap='" +SeatMap + "' where ID=" + DataID);
		out.print("OK");
		jdb.closeDBCon();
		return;
	}

//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
%>
<!Doctype html>
<html>
<head>
	<title>��ѧ����</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- ��������Jaguar����ƽ̨�Զ����� 2018-9-29 -->
<style id="css_268" type="text/css">
body{
background: gray;
}

</style>
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript" src="../cps/js/cp.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"deanSite", Role:<%=Purview%>};
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
		{item:"��������", img:"", action:NewSite, info:"", Attrib:0, Param:0},
		{item:"�༭����", img:"", action:EditSite, info:"", Attrib:0, Param:0},
		{item:"ɾ������", img:"", action:DeleSite, info:"", Attrib:0, Param:0},
		{item:"", img:"", action:null, info:"", Attrib:0, Param:1},
		{item:"��λ����", img:"", action:SetSiteSeat, info:"", Attrib:0, Param:0}
			];
	book.setTool(Tools);
//@@##310:�ͻ��˼���ʱ(�鵵��ע��,����ɾ��)
//��������:Filter
	var o = book.setDocTop("������...", "Filter", "");
//	$("#Page").css({padding: "0px 60px 0px 60px"});
	book.Filter = new $.jcom.DBCascade(o, "../fvs/Place_Archive.jsp", {}, {}, {title:["����"]});
	book.setPageObj(book.Filter);
	book.Filter.onclick = ClickSite;

//	book.Page = new SiteSeatMap(book.getDocObj("Page")[0], [],{});
	book.Page = new SitePage(book.getDocObj("Page")[0]);

//(�鵵��ע��,����ɾ��)ClientStartCode End##@@
};

//@@##311:�ͻ����Զ������(�鵵��ע��,����ɾ��)
//
function ClickSite(obj, item)
{
	book.Page.LoadSite(item);
}

function NewSite(obj, item)	//��������
{
//
	book.Filter.NewItem();
}



function EditSite(obj, item)	//�༭����
{
//
	book.Filter.EditItem();
}



function DeleSite(obj, item)	//ɾ������
{
//
	book.Filter.DeleteItem();
}

var seatEditMode = 0;
function SetSiteSeat(obj, item)	//��λ����
{
//
//	book.Page.map.SetMap();
	if (seatEditMode == 0)
	{
		book.toggleEditMode();
		var Menubar = book.getChild("toolObj");
		seatEditMode = 1;
		var def = [{item:"�½�", img:"#59356", action:book.Page.map.SetMap},
			{item:"����", img:"#59432", action:SaveMap},{item:"����",img:"#59470", action:SetSiteSeat}];
		Menubar.reload(def);
	}
	else
	{
		if (window.confirm("�Ƿ�ȷ��Ҫ�˳��༭ģʽ?") == false)
			return;
		seatEditMode = 0;
		book.toggleEditMode();
	}

}

function SaveMap()
{
	book.Page.map.SaveMap(location.pathname + "?SaveMap=1");
//	var item = book.Filter.getselItem();
//	alert(item.SeatMap);
	
}

function SitePage(domobj, cfg)
{
	var self = this;
	var tag = "<div id=SiteTitleDiv align=center style='font-size:18pt;padding-top:20px;'>��������</div>" +
		"<div style='font-size:14pt;padding-top:20px;'>������Ϣ</div><div id=SiteInfoDiv style=min-height:200px></div>" +
		"<div style='font-size:14pt;padding-top:20px;'>��λͼ</div><div id=SeatMapBox></div>";
	$(domobj).html(tag);
	var box = new $.jcom.SlideBox($("#SeatMapBox")[0], "SeatMapDiv");
	self.map  = new SiteSeatMap($("#SeatMapDiv")[0]);
	
	this.LoadSite = function (item)
	{
		$("#SiteTitleDiv").html(item.item);
		var tag = "<div style=width:90%;height:200px>����ͼƬδ����</div>";
		if (item.Image > 0)
		var tag = "<img src=../com/down.jsp?AffixID=" + item.Image + " style=width:90%><br>";
		tag += "���:" + item.Area + ", ��λ:" + item.Seats ;
		$("#SiteInfoDiv").html(tag);
		self.map.LoadMap(item);
	};
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
