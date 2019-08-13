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
	String CodeName="AsSysTmpl";
	int Purview = 16;
	if (!isAdmin)
	{
		Purview = jdb.getIntBySql(0, "select top 1 Purview from ObjRight where ObjType=10 and ObjParam='AsSysTmpl' and GroupID in (" +
			user.MemberGroupIDs + ") order by Purview desc");
	}
	request.getSession().setAttribute("UserAgent", request.getHeader("User-Agent"));
	request.getSession().setAttribute("UserName", loginType + "." + user.EMemberName + "--" + user.CMemberName + "--" + user.PhotoID);
	request.getSession().setAttribute("UserIP", request.getRemoteAddr());
	SysApp sysApp = new SysApp(jdb);
//@@##137:服务器启动代码(归档用注释,切勿删改)
//
	if (WebChar.RequestInt(request, "InsertFromTmpl") == 1)
	{
		String DetailIds = WebChar.requestStr(request, "DetailIds");
		int asSysId = WebChar.RequestInt(request, "asSysId");
		ResultSet rs = jdb.rsSQL(0, "select * from asSysDetail where ID in (" + DetailIds + ")");
		while (rs.next())
		{
			int id = WebChar.ToInt(jdb.GetTableValue(0, "asSysDetail", "ID", "baseId", rs.getString("ID") + " and asSysId=" + asSysId));
			if (id == 0)
			{
				int parentId = rs.getInt("parentId");
				if (parentId > 0)
					parentId = WebChar.ToInt(jdb.GetTableValue(0, "asSysDetail", "ID", "baseId", parentId + " and asSysId=" + asSysId));
				
				String sql = "insert into asSysDetail(asSysId,parentId,itemCName,baseId,itemEName,info,dataType,value,unit,weight,nSerial,maxValue,minValue,dotNum,fillName,fillInfo,fillType) values(" + 
					asSysId + "," + parentId + ",'" + rs.getString("itemCName") + "'," + rs.getInt("ID") + ",'" + rs.getString("itemEName") + "','" + rs.getString("info") +"'," + rs.getInt("dataType") + 
					",'" + rs.getString("value") + "','" + rs.getString("unit") + "'," + rs.getFloat("weight") + "," + rs.getInt("nSerial") + "," + rs.getDouble("maxValue") +
					 "," + rs.getDouble("minValue") + "," + rs.getInt("dotNum") + ",'" + rs.getString("fillName") + "','" + rs.getString("fillInfo") + "'," + rs.getInt("fillType") + ")";
				jdb.ExecuteSQL(0, sql);
			}
			else
			{
				String sql = "update asSysDetail set asSysId=" + asSysId + ",itemCName='" + rs.getString("itemCName") + "',itemEName='" + rs.getString("itemEName") +
					"',info='" + rs.getString("info") +"',dataType=" + rs.getInt("dataType") + ",value='" + rs.getString("value") + "',unit='" + rs.getString("unit") +
					"',weight=" + rs.getFloat("weight") + ",nSerial=" + rs.getInt("nSerial") + ",maxValue=" + rs.getDouble("maxValue") + ", minValue=" + rs.getDouble("minValue") +
					",dotNum=" + rs.getInt("dotNum") + ",fillName='" + rs.getString("fillName") + "',fillInfo='" + rs.getString("fillInfo") + "',fillType=" + rs.getInt("fillType") +
					" where ID=" + id;
				jdb.ExecuteSQL(0, sql);
			}			
		}
		rs.close();
		jdb.closeDBCon();
		out.print("OK");
		return;
	}
//(归档用注释,切勿删改)ServerStartCode End##@@
%>
<!DOCTYPE html>
<html>
<head>
	<title>评估体系模板</title>
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
var sys = {EName:"<%=user.EMemberName%>", CName:"<%=user.CMemberName%>", nType:<%=loginType%>, PhotoID:<%=user.PhotoID%>, PageName:"AsSysTmpl", Role:<%=Purview%>};
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
		{item:"新增模板", img:"#59356", action:NewRecordFilter, info:"增加一条记录", Attrib:2, Param:1},
		{item:"编辑模板", img:"#59357", action:EditRecordFilter, info:"编辑当前记录", Attrib:2, Param:1},
		{item:"删除模板", img:"#58996", action:DelRecordFilter, info:"删除当前记录", Attrib:16, Param:1},
		{item:"", img:"", action:null, info:"", Attrib:0, Param:1},
		{item:"新增指标", img:"#59356", action:NewRecordPage, info:"增加一条记录", Attrib:2, Param:1},
		{item:"编辑指标", img:"#59357", action:EditRecordPage, info:"编辑当前记录", Attrib:2, Param:1},
		{item:"删除指标", img:"#58996", action:DelRecordPage, info:"删除当前记录", Attrib:16, Param:1},
		{item:"刷新", img:"#58976", action:RefreshFilter, info:"重新加载", Attrib:1, Param:1}
			];
	book.setTool(Tools);
//@@##39:客户端加载时(归档用注释,切勿删改)
//创建对象:Filter
	var o = book.setDocTop("加载中...", "Filter", "");
	book.Filter = new $.jcom.DBCascade(o, env.fvs + "/asSysMain_view.jsp", {}, {}, {title:["模板"]});
	book.setPageObj(book.Filter);
	book.Filter.onclick = ClickFilter;
	book.Filter.onReady = FilterReady;
//创建对象:Page




//(归档用注释,切勿删改)ClientStartCode End##@@
};

//@@##24:客户端自定义代码(归档用注释,切勿删改)
function FilterReady(items)
{
	if (items.length == 0)
		book.Filter.NewItem();
	else
		book.Filter.SkipPage(1, true);
}

function ClickFilter(obj, item)
{
	if (book.Page == undefined)
	{
		var o = book.getDocObj("Page")[0];
		book.Page = new $.jcom.DBGrid(o,  env.fvs + "/asSysDetail_view.jsp", 
			{URLParam:"?asSysId=" + item.ID, formitemstyle:"font:normal normal normal 16px 微软雅黑", formvalstyle:"width:400px",gridtree:2},
			{SeekKey:"", SeekParam:""}, {gridstyle:1, footstyle:4, initDepth:4, nowrap:0, resizeflag:0});
		book.Page.PrepareData = PrepareGrid;
		book.Page.onFormReady = WinFormReady;
	}
	else
	{
		book.Page.config({URLParam: "?asSysId=" + item.ID});
		book.Page.ReloadGrid();
	}
	book.Page.TitleBar("<h2 align=center>" + obj.innerText + "</h2>");
}

function WinFormReady(fields, record, title, winform)
{
	var field = winform.form.getFields("parentId");
	var item = book.Filter.getselItem();
	var tree = field.editor.TreeObj();
	tree.config({URLParam: "?asSysId=" + item.ID});
	tree.reload();
}

function PrepareGrid(items, head, depth)
{
	if (depth == undefined)
		depth = 0;
	for (var x = 0; x < items.length; x++)
	{
		items[x].itemCName = {value:items[x].itemCName, style:"font:normal normal normal " + (18 - depth * 2) + "px 微软雅黑;"}
		items[x].info = {value:items[x].info, color:"gray", style:"font:normal normal normal 13px 楷体;"};
		if (typeof items[x].child == "object")
		{
			if (items[x].child.length == 0)
				items[x].child = undefined;
			else
				PrepareGrid(items[x].child, head, depth + 1);
		}
	}
	return items;
}

function NewRecordFilter(obj, item)	//新增模板
{
//增加一条记录
		book.Filter.NewItem();
}



function EditRecordFilter(obj, item)	//编辑模板
{
//编辑当前记录
book.Filter.EditItem();
}



function DelRecordFilter(obj, item)	//删除模板
{
//删除当前记录
book.Filter.DeleteItem();
}



function RefreshPage(obj, item)	//刷新模板
{
//重新加载
book.Page.ReloadGrid();
}



function NewRecordPage(obj, item)	//新增指标
{
//增加一条记录
	var item = book.Filter.getselItem();
	if (item == undefined)
		return alert("请先选择模板");
	if (item.baseId == 0)
		book.Page.NewItem({URLParam:"?asSysId=" + item.ID});
	else
		SeleTmplRecord(item.baseId);
}

var TmplWin, TmplGrid;
function SeleTmplRecord(baseId)
{
	if (TmplWin == undefined)
	{
		TmplWin = new $.jcom.PopupWin("<div id=TmplGridDiv style=width:100%;height:400px;overflow:auto;></div><div style=float:right><input id=InsertFromTmpl type=button value=新增指标>&nbsp;&nbsp;</div>", 
				{title:"从基础模板中选择指标", width:640, height:480, mask:50,position:"fixed"});
		TmplGrid = new $.jcom.DBGrid($("#TmplGridDiv")[0],  env.fvs + "/asSysDetail_view.jsp", 
			{URLParam:"?asSysId=" + baseId, formitemstyle:"font:normal normal normal 16px 微软雅黑", formvalstyle:"width:400px",gridtree:2},
			{SeekKey:"", SeekParam:""}, {gridstyle:1, bodystyle:2, footstyle:4, initDepth:4, nowrap:0});
		TmplGrid.PrepareData = PrepareTmplGrid;
		TmplWin.close = TmplWin.hide;
		$("#InsertFromTmpl").on("click", InsertFromTmpl);
	}
	else
		TmplWin.show();
}

function InsertFromTmpl(e)
{
	var sels = TmplGrid.getsel();
	if (sels.length == 0)
		return alert("请先选择模板中的指标");
	var ids = "";
	for (var x = 0; x <sels.length; x++)
	{
		var item = TmplGrid.getItemData($(sels[x]).attr("node"));
		if (ids != "")
			ids += ",";
		ids += item.ID;
	}
	var item = book.Filter.getselItem();	
	$.get(location.pathname, {InsertFromTmpl:1, asSysId:item.ID, DetailIds: ids}, InsertFromTmplOK);
}

function InsertFromTmplOK(data)
{
	alert(data)
}

function PrepareTmplGrid(items, head, depth)
{
	if (depth == undefined)
		depth = 0;
	for (var x = 0; x < items.length; x++)
	{
		items[x].itemCName = {value:items[x].itemCName, style:"font:normal normal normal " + (18 - depth * 2) + "px 微软雅黑;"}
		items[x].info = {value:items[x].info, color:"gray", style:"font:normal normal normal 13px 楷体;"};
		if (typeof items[x].child == "object")
		{
			if (items[x].child.length == 0)
				items[x].child = undefined;
			else
				PrepareTmplGrid(items[x].child, head, depth + 1);
		}
	}
	for (var x = 0; x < head.length; x++)
	{
		if ((head[x].FieldName != "itemCName") && (head[x].FieldName != "info"))
			head[x].nShowMode = 3;
	}
	return items;
}


function EditRecordPage(obj, item)	//编辑指标
{
//编辑当前记录
book.Page.EditItem();
}



function DelRecordPage(obj, item)	//删除指标
{
//删除当前记录
book.Page.DeleteItem();
}



function FilterPage(obj, item)	//筛选
{
//多条件筛选
book.Page.Filter();
}



function SeekPage(obj, item)	//查询
{
//全文检索
book.Page.Seek();
}



function RefreshFilter(obj, item)	//刷新
{
//重新加载
book.Filter.reload();
}



function PageEditPage(obj, item)	//页面编辑
{
//对页面多记录进行编辑
book.Page.toggleEditMode(book);
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
