<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
%>
<%
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();
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
			response.sendRedirect("com/error.jsp");
			return;
		}
		response.addCookie(ck[0]);
		response.addCookie(ck[1]);
		response.setHeader("P3P","CP=CAO PSA OUR");
	}
%>
<!Doctype html>
<head>
	<title>用户管理</title>
	<META http-equiv="Content-Type" content="text/html; charset=GBK">
	<meta http-equiv="MSThemeCompatible" content="Yes">
	<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
	<link rel="stylesheet" type="text/css" href="../forum.css">
	<script type="text/javascript" src="../com/jquery.js"></script>
	<script type="text/javascript" src="../com/jcom.js"></script>
	<script type="text/javascript" src="../com/page.js"></script>
	<script type="text/javascript" src="chapters.json"></script>
</head>
<body>Loading...
</body>
<script language=javascript>
var Member = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>"};
var book;
window.onload = function()
{
	var LayerConfig = {width:794,height:1123};
	var aFace = {};
	var cfg = {docwidth:LayerConfig.width, docheight:LayerConfig.height};
	book = new $.jcom.BookPage(aFace, Chapters, "user", cfg);
	book.initSysStatus(Member.CName + "-" + Member.EName);
	var Tools = [
		{item:"查询", img:"", action:Seek, info:"", Attrib:0},
		{item:"筛选", img:"", action:Filter, info:"", Attrib:0},
		{item:"新增", img:"", action:NewRecord, info:"", Attrib:0},
		{item:"编辑", img:"", action:EditRecord, info:"", Attrib:0},
		{item:"删除", img:"", action:DelRecord, info:"", Attrib:0},
		{item:"清除密码", img:"", action:ClearPass, info:"", Attrib:0}
			];
	book.setRight("页面工具", "ToolBox", Tools);
	book.setBottom("辅助说明", "HelpBox", "<P>&nbsp;</P>");
//@@##113:客户端加载时(归档用注释,切勿删改)
//
	grid = new $.jcom.DBGrid($("#Page")[0], "../fvs/Member_Edit_Admin.jsp",{}, {}, {gridstyle: 1, resizeflag:0});
	book.setPageObj(grid);
	grid.makeThumb = makeThumb;

//(归档用注释,切勿删改)ClientStartCode End##@@
}
//@@##114:客户端自定义代码(归档用注释,切勿删改)
function makeThumb(line, hint, index)
{
	var data = grid.getData();
	return "<div name=thumbdiv style='padding:4px;margin:0px;border-bottom:1px solid #e0e0e0;' node=" + index + ">" +
		"<span style='font:normal normal bolder 12pt 微软雅黑;width:120px;display:inline-block;'>" + data[index].CName + "</span>" +
		"<span style='width:60px;display:inline-block;'>" + data[index].EName + "</span>" +
		"<span style='font:normal normal bolder 12pt 楷体;width:120px;display:inline-block;'>" + data[index].Dept_ex + "</span>" +
		"<span style=width:120px;display:inline-block>" + data[index].Duty + "</span>" +
		"<span style=width:40px;display:inline-block;>" + data[index].Status_ex + "</span>" +
		"</div>";

}

function Seek(obj, item)	//查询
{
//

}



function Filter(obj, item)	//筛选
{
//

}



function NewRecord(obj, item)	//新增
{
//

}



function EditRecord(obj, item)	//编辑
{
//

}



function DelRecord(obj, item)	//删除
{
//

}



function ClearPass(obj, item)	//清除密码
{
//

}


//(归档用注释,切勿删改)ClientJSCode End##@@
</script>
</HTML>

<%
	jdb.closeDBCon();
%>
