<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
public ResultSet GetSeekResult(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, int nPage, int nPageSize, String Filters)
{
String Condition, order, sql, id, ss;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebUser user = seekrun.user;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
	{
		String other = "";
		String [] sss = SeekParam.split("\\|\\|");
		if (sss.length > 1)
		{
			SeekParam = sss[0];
			other = sss[1];
		}
		Condition = "ObjRight.ID like '%" + SeekParam + 
			"%' or ObjRight.ObjType like '%" + SeekParam + 
			"%' or ObjRight.ObjParam like '%" + SeekParam + 
			"%' or ObjRight.ObjID like '%" + SeekParam + 
			"%' or ObjRight.GroupID like '%" + SeekParam + 
			"%' or ObjRight.Purview like '%" + SeekParam + 
			"%' or ObjRight.SubmitMan like '%" + SeekParam + 
			"%' or ObjRight.SubmitTime like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:知识文档,2:工作流,3:应用程序对象,4:问卷对象,5:项目对象,10:页面)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or ObjRight.ObjType in (" + ss + ")";
	}
	else
	{
		if (SeekKey.equals("$LoadSeek$"))
			Condition = seekrun.LoadSeekCondition(SeekParam, seekrun.strTable, 0);
		else
		{
			String [] param = SeekParam.split("\\|\\|");
			Condition = seekrun.GetSeekCondition(SeekKey, param[0], seekrun.strTable, 0);
		}
	}
	if (!Filters.equals(""))
	{
		if (!Condition.equals(""))
			Condition = " where (" + Filters + ") and " + "(" + Condition + ")";
		else
			Condition = " where (" + Filters + ")";
	}
	else
	{
		if (!Condition.equals(""))
			Condition = " where " + "(" + Condition + ")";
	}
	String group = "";
	if (!OrderField.equals(""))
	{
		String [] sss= OrderField.split(",");
		order = null;
		for (int x = 0; x < sss.length; x++)
		{
			if (sss[x].indexOf(".") <= 0)
			sss[x] = "ObjRight." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by ObjRight.ID desc";
	String fields = "ObjRight.ID,ObjRight.ObjType,ObjRight.ObjParam,ObjRight.ObjID,ObjRight.GroupID,ObjRight.Purview,ObjRight.SubmitMan,ObjRight.SubmitTime";
	id = "ObjRight.ID";
	if ((!order.equals("")) && (order.toLowerCase().indexOf(id.toLowerCase()) < 0))
		order = order + "," + id;
	seekrun.TotalRec = seekrun.jdb.count(0, seekrun.strTable, Condition);
	if (nPage < 1)
		nPage = 1;
	if ((nPage - 1) * nPageSize > seekrun.TotalRec)
		nPage = (seekrun.TotalRec + nPageSize - 1) / nPageSize;
	sql = seekrun.jdb.SQLSelectPage(0, nPage, nPageSize, fields, seekrun.strTable, Condition, group, order, id);
	ResultSet rs = seekrun.jdb.rsSQL(0, sql);
	seekrun.nPage = nPage;
	return rs;
}

public String GetGridData(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, int nPage, int nPageSize, String Filters) throws Exception
{
String value;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
	nPage = seekrun.nPage;
	if (seekrun.TotalRec == 0)
	{
		seekrun.jout.print("{info:{Records:0}, Data:[]");
		return "";
	}
	int x = 0;
	seekrun.jout.print("{info:{Records:" + seekrun.TotalRec + ",nPage:" + nPage + ", PageSize:" + nPageSize + ", Order:\"" + OrderField + "\", bDesc:" + bDesc + "}, Data:[");
	String dot = "";
	while (rs.next())
	{
		seekrun.jout.print(dot + "{");
		dot = ",";
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_ObjType = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_ObjParam = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_ObjID = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_GroupID = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_Purview = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_SubmitMan = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_SubmitTime = WebChar.isString(jdb.getRSString(0, rs, 8));
		jout.print("ID:\"" + rs_ID + "\"");
		jout.print(", ObjType:\"" + rs_ObjType + "\"");
		String rs_ObjType_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:知识文档,2:工作流,3:应用程序对象,4:问卷对象,5:项目对象,10:页面)", rs_ObjType, 0));
		jout.print(", ObjType_ex:\"" + rs_ObjType_ex + "\"");
		jout.print(", ObjParam:\"" + WebChar.toJson(rs_ObjParam) + "\"");
		jout.print(", ObjID:\"" + rs_ObjID + "\"");
		jout.print(", GroupID:\"" + rs_GroupID + "\"");
		jout.print(", Purview:\"" + rs_Purview + "\"");
		jout.print(", SubmitMan:\"" + WebChar.toJson(rs_SubmitMan) + "\"");
		jout.print(", SubmitTime:\"" + rs_SubmitTime + "\"");
		jout.print("}");
		if (x ++ >= nPageSize - 1)
			break;
	}
	jdb.rsClose(0, rs);
	jout.print("]");
	return "";
}

%>
<%
	String SeekKey = WebChar.requestStr(request, "SeekKey");
	String SeekParam = WebChar.requestStr(request, "SeekParam").replace('*','%');
	int PrepID = WebChar.RequestInt(request, "PrepID");
	int ModuleID = WebChar.RequestInt(request, "ModuleNo");
	int ViewMode = WebChar.RequestInt(request, "ViewMode");
	int nPage=WebChar.RequestInt(request, "Page");
	int RootID = WebChar.RequestInt(request, "RootID");
	String OrderField = WebChar.requestStr(request, "OrderField");
	int bDesc = WebChar.RequestInt(request, "bDesc");
	int ComplexSeek = WebChar.RequestInt(request, "ComplexSeek");
	String ParentNode = WebChar.requestStr(request, "ParentNode");
	String DisableMenus = "|";
	String MenuFilter = null;
	int BatchAction = WebChar.RequestInt(request, "BatchAction");
// +++++++++服务器全局页面启动代码开始++++++++
// ServerPageStartCode
if(request.getProtocol().compareTo("HTTP/1.0")==0)
	response.setHeader("Pragma","max-age=5");
if(request.getProtocol().compareTo("HTTP/1.1")==0)
	response.setHeader("Cache-Control","max-age=5");
response.setDateHeader("Expires",0);
	JDatabase jdb = new JDatabase();
	jdb.InitJDatabase();
	Cookie cookie[] = request.getCookies();
	WebUser user = new SysUser();

	if (user.initWebUser(jdb, cookie) != 1)
	{
		ServletContext sc = getServletContext();
		request.setAttribute("pagename", SysApp.scriptName(request));
		RequestDispatcher rd = sc.getRequestDispatcher("/com/error.jsp");
		rd.forward(request, response);
		out.clear();
		out = pageContext.pushBody();
		return;
	}

	WebEnum webenum = new WebEnum(jdb);
	SysApp sysApp = new SysApp(jdb);
	project.SystemLog sysLog = new project.SystemLog(jdb, user, request);
// ServerSeekPageStartCode
	SeekRun seekrun = new SeekRun(jdb, webenum, user, out, request);

// --------服务器全局页面启动代码结束--------
	seekrun.strTable = "ObjRight";
	if (ModuleID > 0)
	{
		int ModuleNo = WebChar.ToInt(jdb.GetTableValue(0, "RightObject", "auth_no", "auth_id", "" + ModuleID));
		if (ModuleNo > 0)
		{
			if (user.isModuleEnable(ModuleNo) == false)
			{
				out.println("页面没有权限");
				return;
			}
		}
	}
	String Filters = "ObjType=" + WebChar.RequestInt(request, "ObjType") + " and GroupID=" + WebChar.RequestInt(request, "GroupID");
	if (ViewMode == 0)
		ViewMode = 1;
	seekrun.ViewMode = ViewMode;
	int nPageSize = 100;
	if (nPage == 0)
		nPage = 1;
	int ajaxGetGridMode = WebChar.RequestInt(request, "GetGridData");
	if (ajaxGetGridMode > 0)
	{
		out.clear();
		switch (ajaxGetGridMode)
		{
		case 1:
			GetGridData(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
			out.print("}");
			break;
		case 2:
			GetGridData(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
			String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:1}," +
		"{FieldName:\"ObjType\", TitleName:\"对象类型\", nWidth:0, nShowMode:1, Quote:\"(1:知识文档,2:工作流,3:应用程序对象,4:问卷对象,5:项目对象,10:页面)\", FieldType:3}," +
		"{FieldName:\"ObjParam\", TitleName:\"对象参数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"ObjID\", TitleName:\"对象ID\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"GroupID\", TitleName:\"分组ID\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"Purview\", TitleName:\"权限\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"SubmitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"SubmitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:4}]";
			out.print(", head:" + viewhead + ",TableName:\"ObjRight\", TableCName:\"对象权限表\", EditForm:\"\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"ObjRight\", TableCName:\"对象权限表\", Fields:\"ID,ObjType,ObjParam,ObjID,GroupID,Purview,SubmitMan,SubmitTime\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"ObjType\",ShowName:\"对象类型\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:知识文档,2:工作流,3:应用程序对象,4:问卷对象,5:项目对象,10:页面)\"},{FieldName:\"ObjParam\",ShowName:\"对象参数\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"ObjID\",ShowName:\"对象ID\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"GroupID\",ShowName:\"分组ID\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Purview\",ShowName:\"权限\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"SubmitMan\",ShowName:\"提交人\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"SubmitTime\",ShowName:\"提交时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:1}," +
		"{FieldName:\"ObjType\", TitleName:\"对象类型\", nWidth:0, nShowMode:1, Quote:\"(1:知识文档,2:工作流,3:应用程序对象,4:问卷对象,5:项目对象,10:页面)\", FieldType:3}," +
		"{FieldName:\"ObjParam\", TitleName:\"对象参数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"ObjID\", TitleName:\"对象ID\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"GroupID\", TitleName:\"分组ID\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"Purview\", TitleName:\"权限\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"SubmitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"SubmitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:4}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("ObjRight_view", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<script language=javascript src=../com/psub.jsp></script>" + "\n" + 
		"<script language=javascript src=../com/jquery.js></script>" + "\n" +
		"<script language=javascript src=../com/jcom.js></script>" + "\n" +
		"<script language=javascript src=../com/view.js></script>" + "\n" +
		"<script language=javascript>\nnDefaultWinMode = 5;\n//FormFeatures = 'titlebar=0,toolbar=0,scrollbars=0,resizable=0,width=640,height=200,left=50,top=50';\n</script>" + "\n" + 
		"<body style='background:' alink=#333333 scroll=no vlink=#333333 link=#333333 topmargin=0 leftmargin=0>");
	String href = request.getRequestURI(), sMenu = "";
	if 	(WebChar.request(request) != null)
	{
		String s = WebChar.request(request).replaceAll("(?i)&?(?:SeekKey|SeekParam|OrderField|bDesc|ViewMode|PrepID|page)=[^&]*", "");
		if (!s.equals(""))
			href = request.getRequestURI() + "?" + s;
	}
	String title = "";
	if (SeekKey.equals("") && SeekParam.equals(""))
		title = "全部";
	else
	{
		if (SeekKey.equals(""))
			title = "<FONT title='" + SeekParam + "'>" + "复合查询" + "</FONT>";
		else
		{
			if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
				title = "<FONT title='" + "关键字" + "：" + SeekParam + "'>" + "全文检索" + "</FONT>";
			else
				title = SeekKey + "=" + SeekParam;
		}
			if (SeekKey.equals("$LoadSeek$"))
		{
				title = "检索方案：" + SeekParam;
		}
	}
	if (ViewMode < 100)
	{
	String submenu = "", exmenu1 = "", exmenu2 = "";
	sMenu = WebChar.joinStr(exmenu2, sMenu, ",");
	sMenu = WebChar.joinStr(sMenu, exmenu1, ",");
	title = "{nMode:1}";
	}
	out.print("<div id=MainView style=width:100%;height:100%;overflow:hidden;></div>\n");

%>
<script language=javascript>
window.onload = function()
{
	window.menubar = new $.jcom.CommonMenubar([<%=sMenu%>], null, <%=title%>);
	head = $.jcom.eval("[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:1}," +
		"{FieldName:\"ObjType\", TitleName:\"对象类型\", nWidth:0, nShowMode:1, Quote:\"(1:知识文档,2:工作流,3:应用程序对象,4:问卷对象,5:项目对象,10:页面)\", FieldType:3}," +
		"{FieldName:\"ObjParam\", TitleName:\"对象参数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"ObjID\", TitleName:\"对象ID\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"GroupID\", TitleName:\"分组ID\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"Purview\", TitleName:\"权限\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"SubmitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"SubmitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:4}]");
	if (typeof head == "string")
		return alert(head);
	InitView(head);
}

var href ="<%=href%>";
var SeekKey = "<%=SeekKey%>";
var SeekParam = "<%=SeekParam.replace('%', '*')%>";
var OrderField = "<%=OrderField%>";
var bDesc = <%=bDesc%>;
var ClassName = "";
var ActionID = 513;
var ViewMode = <%=ViewMode%>;
var TableDefID = 233;
var PrepID = 0;
var FormAction="";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>