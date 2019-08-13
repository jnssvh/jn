<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
// ServerChapterPageStartCode
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	int loginType = WebChar.ToInt(WebUser.GetCookie(cookie, "loginType"));
	WebUser user = null;
	user = new SysUser();
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
			response.sendRedirect("../bia/login.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
	boolean isAdmin = user.isAdmin();
	String CodeName="SysComSet";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='SysComSet' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
%>
<!DOCTYPE html>
<html>
<head>
	<title>企业设置</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=2">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<link rel="stylesheet" type="text/css" href="../res/font/iconsfont.css">
<!-- 本代码由Jaguar开发平台自动生成 2019-4-28 -->
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
	<script type="text/javascript" src="local.js"></script>
<script type="text/javascript">
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"SysComSet", Role:<%=Purview%>};
var env = {com:"../com", proj:"../bia", fvs:"../biafvs", flow:"../biaflow", page:"../biapages"};
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
		{item:"查询", img:"#59111", action:SeekPage, info:"全文检索", Attrib:1, Param:1},
		{item:"筛选", img:"#59188", action:FilterPage, info:"多条件筛选", Attrib:1, Param:1},
		{item:"新增", img:"#59356", action:NewRecordPage, info:"增加一条记录", Attrib:2, Param:1},
		{item:"编辑", img:"#59357", action:EditRecordPage, info:"编辑当前记录", Attrib:2, Param:1},
		{item:"删除", img:"#58996", action:DelRecordPage, info:"删除当前记录", Attrib:4, Param:1},
		{item:"刷新", img:"#58976", action:RefreshPage, info:"重新加载", Attrib:1, Param:1},
		{item:"导入", img:"#59007", action:ImportExcelPage, info:"从Exel文件中导入", Attrib:16, Param:2},
		{item:"审核", img:"#59341", action:CheckPageRecord, info:"对填报的企业数据进行审核", Attrib:4, Param:1}
			];
	book.setTool(Tools);
//@@##123:客户端加载时(归档用注释,切勿删改)
//创建对象:Page
	var o = book.getDocObj("Page")[0];
	book.Page = new $.jcom.DBGrid(o,  env.fvs + "/company_view.jsp", {formitemstyle:"font:normal normal normal 16px 微软雅黑", formvalstyle:"width:400px"}, 
	{SeekKey:"", SeekParam:""}, {gridstyle:4, resizeflag:0});




//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##124:客户端自定义代码(归档用注释,切勿删改)
function SeekPage(obj, item)	//查询
{
//全文检索
book.Page.Seek();
}



function FilterPage(obj, item)	//筛选
{
//多条件筛选
book.Page.Filter();
}



function NewRecordPage(obj, item)	//新增
{
//增加一条记录
book.Page.NewItem();
}



function EditRecordPage(obj, item)	//编辑
{
//编辑当前记录
book.Page.EditItem();
}



function DelRecordPage(obj, item)	//删除
{
//删除当前记录
book.Page.DeleteItem();
}


function RefreshPage(obj, item)	//刷新
{
//重新加载
book.Page.ReloadGrid();
}

function ImportExcelPage(obj, item)	//导入
{
//从Exel文件中导入
book.Page.ImportExcel();
}




function CheckPageRecord(obj, item)	//审核
{
//对填报的企业数据进行审核
alert("暂未实现");
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
