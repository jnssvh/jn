<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	String CodeName="ssFile";
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
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='ssFile' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	SysApp sysApp = new SysApp(jdb);
%>
<!Doctype html>
<html>
<head>
	<title>学员档案</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2018-9-29 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", PhotoID:<%=user.PhotoID%>, PageName:"ssFile", Role:<%=Purview%>};
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
//@@##504:客户端加载时(归档用注释,切勿删改)
//创建对象:Page
	var o = book.getDocObj("Page")[0];
	var box = new $.jcom.SlideBox(o, "StudentDiv");

	book.Page = new $.jcom.DBForm($("#StudentDiv")[0],  "../fvs/FormStudentRpt.jsp",{}, {itemstyle:"font:normal normal normal 15px 微软雅黑",valstyle:"width:400px"});
	$.get("../fvs/FormStudentRpt.jsp", {GetStudentInfo:1, RegID: <%=user.UserID%>}, GetStudentOK);



//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##505:客户端自定义代码(归档用注释,切勿删改)
//
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
//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</head>
<body>Loading...
</body>
</html>
<%
	jdb.closeDBCon();
%>
