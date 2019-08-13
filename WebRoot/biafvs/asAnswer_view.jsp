<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
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
		Condition = "asAnswer.comId like '%" + SeekParam + 
			"%' or asAnswer.checkTime like '%" + SeekParam + 
			"%' or asAnswer.ID like '%" + SeekParam + 
			"%' or asAnswer.planId like '%" + SeekParam + 
			"%' or asAnswer.planDetailId like '%" + SeekParam + 
			"%' or asAnswer.submitType like '%" + SeekParam + 
			"%' or asAnswer.status like '%" + SeekParam + 
			"%' or asAnswer.submitMan like '%" + SeekParam + 
			"%' or asAnswer.submitTime like '%" + SeekParam + 
			"%' or asAnswer.checkMan like '%" + SeekParam + 
			"%' or asAnswer.info like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:在线提交,2:录入,3:导入)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or asAnswer.submitType in (" + ss + ")";
		ss = seekrun.GetEnumWordValue("(1:已通知,2:已提交,3:已审核)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or asAnswer.status in (" + ss + ")";
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
			sss[x] = "asAnswer." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by asAnswer.comId desc";
	String fields = "asAnswer.comId,asAnswer.checkTime,asAnswer.ID,asAnswer.planId,asAnswer.planDetailId,asAnswer.submitType,asAnswer.status,asAnswer.submitMan,asAnswer.submitTime,asAnswer.checkMan,asAnswer.info";
	id = "asAnswer.ID";
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
		String rs_comId = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_checkTime = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_planId = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_planDetailId = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_submitType = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_status = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_submitMan = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_submitTime = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_checkMan = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_info = WebChar.isString(jdb.getRSString(0, rs, 11));
		jout.print("comId:\"" + WebChar.toJson(rs_comId) + "\"");
		jout.print(", checkTime:\"" + rs_checkTime + "\"");
		jout.print(", ID:\"" + rs_ID + "\"");
		jout.print(", planId:\"" + rs_planId + "\"");
		jout.print(", planDetailId:\"" + rs_planDetailId + "\"");
		jout.print(", submitType:\"" + rs_submitType + "\"");
		String rs_submitType_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:在线提交,2:录入,3:导入)", rs_submitType, 0));
		jout.print(", submitType_ex:\"" + rs_submitType_ex + "\"");
		jout.print(", status:\"" + rs_status + "\"");
		String rs_status_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:已通知,2:已提交,3:已审核)", rs_status, 0));
		jout.print(", status_ex:\"" + rs_status_ex + "\"");
		jout.print(", submitMan:\"" + WebChar.toJson(rs_submitMan) + "\"");
		jout.print(", submitTime:\"" + rs_submitTime + "\"");
		jout.print(", checkMan:\"" + WebChar.toJson(rs_checkMan) + "\"");
		jout.print(", info:\"" + WebChar.toJson(rs_info) + "\"");
		jout.print("}");
		if (x ++ >= nPageSize - 1)
			break;
	}
	jdb.rsClose(0, rs);
	jout.print("]");
	return "";
}

int RunBatAction(SeekRun seekrun, int BatchAction, String BatchValue, String BatchKey, String BatchParam)
{
String sql, sql1, sql2, FieldName, value;
String[] keys, params;
int x, y, FieldType, result = 0;
	switch (BatchAction)
	{
	case 1:			//删除
		sql = "delete from " + seekrun.strTable + " where ID in (" + BatchValue + ")";
		result = seekrun.jdb.ExecuteSQL(0, sql);
	 	SystemLog.setLog(seekrun.jdb, seekrun.user, seekrun.jreq, "6", "", seekrun.strTable, "");
		break;
	case 2:			//修改
		sql1 = "";
		keys = BatchKey.split(",");
		params = BatchParam.split(",");
		for (x = 0; x < params.length; x++)
		{
			FieldType = seekrun.jdb.GetTableFieldType(seekrun.strTable, 0, keys[x]);
			value = seekrun.jdb.GetFieldTypeValueEx(params[x], FieldType, 0);
			if (sql1.equals(""))
				sql1 = keys[x] + "=" + value;
			else
				sql1 = sql1 + ", " + keys[x] + "=" + value;
		}
		sql = "update " + seekrun.strTable + " set " + sql1 + " where ID in (" + BatchValue + ")";
		result = seekrun.jdb.ExecuteSQL(0, sql);
		break;
	case 3:			//复制后修改
		keys = BatchKey.split(",");
		params = BatchParam.split(",");
		sql = "select * from " + seekrun.strTable + " where ID in (" + BatchValue + ")";
		ResultSet rs = seekrun.jdb.rsSQL(0, sql);
		try
		{
			while (rs.next())
			{
				sql1 = "";
				sql2 = "";
				ResultSetMetaData rsmt = rs.getMetaData();
				int columnCount = rsmt.getColumnCount();
				for (x = 0; x < columnCount; x++)
				{
					FieldName = rsmt.getColumnName(x).toUpperCase();
					if (FieldName.equals("ID"))
					{
						if (sql1.equals(""))
							sql1 = FieldName;
						else
							sql1 = sql1 + "," + FieldName;
						FieldType = JDatabase.ConvertFieldType(rsmt.getColumnType(x), "", 
							rsmt.getColumnDisplaySize(x));
						value = seekrun.jdb.getRSString(0, rs, x);
						for (y = 0; y < keys.length; y++)
						{
							if (FieldName.equals(keys[y].toUpperCase()))
							{
								value = params[y];
								break;
							}
						}
						value = seekrun.jdb.GetFieldTypeValueEx(value, FieldType, 0);
						if (sql2.equals(""))
							sql2 = value;
						else
							sql2 = sql2 + "," + value;
					}
				}
				sql = "insert into " + seekrun.strTable + " (" + sql1 + ") values (" + sql2 + ")";
				result = seekrun.jdb.ExecuteSQL(0, sql);
			}
			seekrun.jdb.rsClose(0, rs);
		}
		catch(SQLException e)
		{
			System.out.println(e.getMessage());
			System.out.println(sql);
			return 0;
		}
		break;
	case 5:			//自定义删除
		result = seekrun.jdb.deleteAllData(BatchParam);
		break;
	}
	return result;
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
	seekrun.strTable = "asAnswer";
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
	String Filters = "";
	if (ViewMode == 0)
		ViewMode = 1;
	seekrun.ViewMode = ViewMode;
	int nPageSize = 100;
	if (nPage == 0)
		nPage = 1;
	if (BatchAction > 0)
	{
		String BatchValue =WebChar.requestStr(request, "BatchValue");
		String BatchKey = WebChar.requestStr(request, "BatchKey");
		String BatchParam = WebChar.requestStr(request, "BatchParam");
		int Ajax = WebChar.RequestInt(request, "Ajax");
		int result = RunBatAction(seekrun, BatchAction, BatchValue, BatchKey, BatchParam);
		jdb.closeDBCon();
		if (Ajax == 1)
		{
			if (result == 1)
				out.print("OK");
			else
				out.print("Error:" + result);
			return;
		}
		String href = request.getRequestURI();
		if 	(WebChar.request(request) != null)
		{
			String s = WebChar.request(request).replaceAll("(?i)&?(?:BatchAction|BatchValue|BatchKey|BatchParam)=[^&]*", "");
			if (!s.equals(""))
				href = request.getRequestURI() + "?" + s;
		}
		if (result == 1)
			response.sendRedirect(href);
		return;
	}
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
			String viewhead = "[{FieldName:\"comId\", TitleName:\"企业\", nWidth:400, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"checkTime\", TitleName:\"审核时间\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:4}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"planId\", TitleName:\"调查计划编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"planDetailId\", TitleName:\"调查计划明细编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"submitType\", TitleName:\"提交方式\", nWidth:0, nShowMode:6, Quote:\"(1:在线提交,2:录入,3:导入)\", FieldType:3}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:6, Quote:\"(1:已通知,2:已提交,3:已审核)\", FieldType:3}," +
		"{FieldName:\"submitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"submitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:4}," +
		"{FieldName:\"checkMan\", TitleName:\"审核人\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"info\", TitleName:\"备注\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:2}]";
			out.print(", head:" + viewhead + ",TableName:\"asAnswer\", TableCName:\"评估答卷表\", EditForm:\"\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"asAnswer\", TableCName:\"评估答卷表\", Fields:\"comId,ID\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"planId\",ShowName:\"调查计划编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"comId\",ShowName:\"企业编号\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"submitType\",ShowName:\"提交方式\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:在线提交,2:录入,3:导入)\"},{FieldName:\"status\",ShowName:\"状态\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:已通知,2:已提交,3:已审核)\"},{FieldName:\"submitMan\",ShowName:\"提交人\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"submitTime\",ShowName:\"提交时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"checkMan\",ShowName:\"审核人\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"checkTime\",ShowName:\"审核时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"info\",ShowName:\"备注\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"planDetailId\",ShowName:\"调查计划明细编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"comId\", TitleName:\"企业\", nWidth:400, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"checkTime\", TitleName:\"审核时间\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:4}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"planId\", TitleName:\"调查计划编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"planDetailId\", TitleName:\"调查计划明细编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"submitType\", TitleName:\"提交方式\", nWidth:0, nShowMode:6, Quote:\"(1:在线提交,2:录入,3:导入)\", FieldType:3}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:6, Quote:\"(1:已通知,2:已提交,3:已审核)\", FieldType:3}," +
		"{FieldName:\"submitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"submitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:4}," +
		"{FieldName:\"checkMan\", TitleName:\"审核人\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"info\", TitleName:\"备注\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:2}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("被调查企业列表", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
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
	head = $.jcom.eval("[{FieldName:\"comId\", TitleName:\"企业\", nWidth:400, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"checkTime\", TitleName:\"审核时间\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:4}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"planId\", TitleName:\"调查计划编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"planDetailId\", TitleName:\"调查计划明细编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"submitType\", TitleName:\"提交方式\", nWidth:0, nShowMode:6, Quote:\"(1:在线提交,2:录入,3:导入)\", FieldType:3}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:6, Quote:\"(1:已通知,2:已提交,3:已审核)\", FieldType:3}," +
		"{FieldName:\"submitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"submitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:4}," +
		"{FieldName:\"checkMan\", TitleName:\"审核人\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"info\", TitleName:\"备注\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:2}]");
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
var ActionID = 270;
var ViewMode = <%=ViewMode%>;
var TableDefID = 201;
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