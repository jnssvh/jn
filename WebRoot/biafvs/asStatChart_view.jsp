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
		Condition = "asStatChart.ID like '%" + SeekParam + 
			"%' or asStatChart.chartName like '%" + SeekParam + 
			"%' or asStatChart.Title like '%" + SeekParam + 
			"%' or asStatChart.statPlanId like '%" + SeekParam + 
			"%' or asStatChart.Note like '%" + SeekParam + 
			"%' or asStatChart.width like '%" + SeekParam + 
			"%' or asStatChart.height like '%" + SeekParam + 
			"%' or asStatChart.chartType like '%" + SeekParam + 
			"%' or asStatChart.chartOption like '%" + SeekParam + 
			"%' or asStatChart.submitMan like '%" + SeekParam + 
			"%' or asStatChart.submitTime like '%" + SeekParam + 
			"%'" + other;
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
			sss[x] = "asStatChart." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by nSerial";
	String fields = "asStatChart.ID,asStatChart.chartName,asStatChart.Title,asStatChart.statPlanId,asStatChart.Note,asStatChart.width,asStatChart.height,asStatChart.chartType,asStatChart.chartOption,asStatChart.submitMan,asStatChart.submitTime";
	id = "asStatChart.ID";
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
		String rs_chartName = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_Title = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_statPlanId = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_Note = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_width = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_height = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_chartType = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_chartOption = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_submitMan = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_submitTime = WebChar.isString(jdb.getRSString(0, rs, 11));
		jout.print("ID:\"" + rs_ID + "\"");
		jout.print(", chartName:\"" + WebChar.toJson(rs_chartName) + "\"");
		jout.print(", Title:\"" + WebChar.toJson(rs_Title) + "\"");
		jout.print(", statPlanId:\"" + rs_statPlanId + "\"");
		jout.print(", Note:\"" + WebChar.toJson(rs_Note) + "\"");
		jout.print(", width:\"" + rs_width + "\"");
		jout.print(", height:\"" + rs_height + "\"");
		jout.print(", chartType:\"" + rs_chartType + "\"");
		jout.print(", chartOption:\"" + WebChar.toJson(rs_chartOption) + "\"");
		jout.print(", submitMan:\"" + WebChar.toJson(rs_submitMan) + "\"");
		jout.print(", submitTime:\"" + WebChar.toJson(rs_submitTime) + "\"");
		jout.print("}");
		if (x ++ >= nPageSize - 1)
			break;
	}
	jdb.rsClose(0, rs);
	jout.print("]");
	return "";
}

public String TableTreeView(SeekRun seekrun, int ViewMode, String SeekKey, String SeekParam, String OrderField,
	int bDesc, int nPage, int nPageSize, String Filters, String href, String ParentItem) throws Exception
{
	JspWriter jout = seekrun.jout;
	JDatabase jdb = seekrun.jdb;
	WebUser user = seekrun.user;
	WebEnum webenum = seekrun.we;
	HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	String Condition, order, sql, id, ss;
	int TotalRec = 0, Depth = 0;
	nPageSize = 1000;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
	TotalRec = seekrun.TotalRec;
	String[][] aTreeDB = seekrun.jdb.getRSData(rs, 1, 1000);
	seekrun.jout.print("<DIV id=TableDoc oncontextmenu='return ExSeekFunction(this);' ondblclick=DblClickSeekTable(this) style='height:400;'>");
	seekrun.jout.print("<IFRAME id=TableTreeSubDataFrame style=display:none;width:100%;height:200;></IFRAME>");
	if (aTreeDB != null)
	{
		for (int x = 0; x < aTreeDB[0].length; x++)
			seekrun.jout.print(GetJSPTableTreeItem(seekrun, x, aTreeDB, 0, "", 0, 1, ""));
	}
	seekrun.jout.print("</div>");
	return "";
}

public String GetJSPTableTreeItem(SeekRun seekrun, int x, String[][] aTreeDB, int Depth, String img, int nItem, int bDiv, String prop)
{
String div, value, item, hint = "", node="", attach = "";
	JspWriter jout = seekrun.jout;
	JDatabase jdb = seekrun.jdb;
	WebUser user = seekrun.user;
	WebEnum webenum = seekrun.we;
	HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
String rs_ID = aTreeDB[0][x];
String rs_chartName = aTreeDB[1][x];
String rs_Title = aTreeDB[2][x];
String rs_statPlanId = aTreeDB[3][x];
String rs_Note = aTreeDB[4][x];
String rs_width = aTreeDB[5][x];
String rs_height = aTreeDB[6][x];
String rs_chartType = aTreeDB[7][x];
String rs_chartOption = aTreeDB[8][x];
String rs_submitMan = aTreeDB[9][x];
String rs_submitTime = aTreeDB[10][x];
	if (bDiv == 1)
		div = "div";
	else
		div = "span";
	String id = "P_" + aTreeDB[nItem][x];
	value = seekrun.ConvertFieldValue("", rs_ID, 1);
	node = rs_ID;
	hint += "自动编号" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_chartName, 1);
	item = value;
	value = seekrun.ConvertFieldValue("", rs_Title, 1);
	hint += "标题" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_statPlanId, 1);
	hint += "所属统计方案" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_Note, 1);
	hint += "说明" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_width, 1);
	hint += "原始宽度" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_height, 1);
	hint += "原始高度" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_chartType, 1);
	hint += "图形类型" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_chartOption, 1);
	hint += "图形数据" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_submitMan, 1);
	hint += "提交人" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_submitTime, 1);
	hint += "提交时间" + ":" + value + "\n";
	if (item.toLowerCase().equals("[hidden]"))
		return "";
	if (VB.Left(item.toLowerCase(), 5).equals("[src="))
	{
		int pos = item.indexOf("]");
		if  (pos > 5)
		{
			value = VB.Mid(item, 6, pos - 5);
			if (value.equals("none"))
				img = "";
			else
			{
				String[] pics = value.split(",");
				if (pics.length > 1)
				{
					img = img.replaceAll("../com/pic/plus.gif", pics[0]);
					img = img.replaceAll("../com/pic/minus.gif", pics[1]);
				}
			}
			item = VB.Mid(item, pos + 2);
		}
	}
	if (!prop.equals(""))
		prop = prop + " ";
	return "<" + div + " id='" + id + "' nowrap onclick=\"SelObject(this)\" node='" + node + "' " + prop +
		"expand=1" + attach + "><SPAN id=SUB" + node + " style=cursor:hand;padding-left:" + Depth * seekrun.nTreeIndent + "px>" + img +
		"<SPAN id=TRText style='padding:1px;height:20px;' title='" + hint + "'>" +  item +
		"</SPAN></SPAN></" + div + ">";
}

public String SubTreeSeek(SeekRun seekrun, String ParentNode, int nDepth, String SeekKey, String SeekParam, String OrderField, int bDesc, int ViewMode, String Filters) throws Exception
{
int nItem;
String Condition, str = "", ss;
	JspWriter jout = seekrun.jout;
	JDatabase jdb = seekrun.jdb;
	WebUser user = seekrun.user;
	WebEnum webenum = seekrun.we;
	HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	if (ViewMode == 0)
		ViewMode = 1;
	String order, sql, id;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, 1, 1000, Filters);
	int TotalRec = seekrun.TotalRec;
	String[][] aTreeDB = seekrun.jdb.getRSData(rs, 1, 1000);
	if (aTreeDB != null)
	{
		for (int x = 0; x < aTreeDB[0].length; x++)
			str += GetJSPTableTreeItem(seekrun, x, aTreeDB, nDepth, "", 0, 1, "");
	}
	return str;
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
	seekrun.strTable = "asStatChart";
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
			String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"chartName\", TitleName:\"图表名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"Title\", TitleName:\"标题\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"statPlanId\", TitleName:\"所属统计方案\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"Note\", TitleName:\"说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"width\", TitleName:\"原始宽度\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"height\", TitleName:\"原始高度\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"chartType\", TitleName:\"图形类型\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"chartOption\", TitleName:\"图形数据\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"submitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"submitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}]";
			out.print(", head:" + viewhead + ",TableName:\"asStatChart\", TableCName:\"统计结果图\", EditForm:\"asStatChart_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "SubTree") == 1)
	{
		out.clear();
		int nDepth = WebChar.RequestInt(request, "nDepth");
		out.print(SubTreeSeek(seekrun, ParentNode, nDepth, SeekKey, SeekParam, OrderField, bDesc, ViewMode, Filters));
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"asStatChart\", TableCName:\"统计结果图\", Fields:\"ID,chartName,Title,statPlanId,Note,width,height,chartType,chartOption,submitMan,submitTime\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"Title\",ShowName:\"标题\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"statPlanId\",ShowName:\"所属统计方案\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Note\",ShowName:\"说明\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"width\",ShowName:\"原始宽度\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"height\",ShowName:\"原始高度\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"chartType\",ShowName:\"图形类型\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"chartOption\",ShowName:\"图形数据\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"submitMan\",ShowName:\"提交人\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"chartName\",ShowName:\"图表名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"submitTime\",ShowName:\"提交时间\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"nSerial\",ShowName:\"顺序号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"nType\",ShowName:\"分类\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"status\",ShowName:\"状态\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"chartName\", TitleName:\"图表名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"Title\", TitleName:\"标题\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"statPlanId\", TitleName:\"所属统计方案\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"Note\", TitleName:\"说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"width\", TitleName:\"原始宽度\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"height\", TitleName:\"原始高度\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"chartType\", TitleName:\"图形类型\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"chartOption\", TitleName:\"图形数据\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"submitMan\", TitleName:\"提交人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"submitTime\", TitleName:\"提交时间\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("统计图表", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<script language=javascript src=../com/psub.jsp></script>" + "\n" + 
		"<script language=javascript src=../com/common.js></script>" + "\n" + 
		"<script language=javascript src=../com/seek.jsp></script>" + "\n" +
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
	out.print("<div id=SeekMenubar style='with:100%;height:24px;padding:2px;background:'>载入中...</div>");
	}
	switch (ViewMode % 100)
	{
	case 5:
		out.print("<div id=FrameDoc style=width:100%;height:100%;><div id=LeftViewDiv>");
		TableTreeView(seekrun, 2, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters, href, ParentNode);
		out.print("</div><div onmousedown=ResizeSeekCol(this) style='position:absolute;width:8px;height:100%;left:196px;overflow:hidden;cursor:col-resize;filter:alpha(opacity=0);opacity:0.0;background-color:gray;'></div>" +
			"<div id=RightViewDiv>" +
			"<iframe name=SubSeekFrame style='width:100%;height:100%;' frameborder=0 scrolling=no></iframe></div></div>");
		break;
	default:
		TableTreeView(seekrun, ViewMode, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters, href, ParentNode);
	}
	out.print("<iframe name=FieldDataFrame style=display:none;></iframe>");

%>
<script language=javascript>
window.onload = function()
{
	window.menubar = new CommonMenubar([<%=sMenu%>], document.getElementById("SeekMenubar"), <%=title%>);
	InitSeekItemEvent();
	window.onresize=ResizeFrame;
	ResizeFrame();

<%
	switch (ViewMode)
	{
	case 3:
		out.print("InitTreeLine();" + "\n");
		break;
	case 4:
		out.print("InitHTreeLine();" + "\n");
		break;
	case 5:
		out.print("InitSubView()" + "\n");
		break;
	}

%>
	InitTitleOrder();
	var oSel = document.getElementsByName("PageFootSel");
	for (var x = 0; x < oSel.length; x++)
		MakeFootPage(oSel[x]);
}

function DblClickSeekTable(oTable)
{
	var obj = GetTableEventTR(oTable);
	if (obj == oTable)
		return;
	if ((typeof(obj) == "object") && (obj != null))
		DefaultDbClick(obj);
}

var href ="<%=href%>";
var SeekKey = "<%=SeekKey%>";
var SeekParam = "<%=SeekParam.replace('%', '*')%>";
var OrderField = "<%=OrderField%>";
var bDesc = <%=bDesc%>;
var ClassName = "";
var ActionID = 273;
var ViewMode = <%=ViewMode%>;
var TableDefID = 210;
var PrepID = 0;
var FormAction="asStatChart_form.jsp";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>