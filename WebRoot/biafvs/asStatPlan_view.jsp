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
		Condition = "asStatPlan.sumRptName like '%" + SeekParam + 
			"%' or asStatPlan.status like '%" + SeekParam + 
			"%' or asStatPlan.ID like '%" + SeekParam + 
			"%' or asStatPlan.planName like '%" + SeekParam + 
			"%' or asStatPlan.beginTime like '%" + SeekParam + 
			"%' or asStatPlan.endTime like '%" + SeekParam + 
			"%' or asStatPlan.Info like '%" + SeekParam + 
			"%' or asStatPlan.scopeInfo like '%" + SeekParam + 
			"%' or asStatPlan.asSysMainId like '%" + SeekParam + 
			"%' or asStatPlan.companys like '%" + SeekParam + 
			"%' or asStatPlan.comCount like '%" + SeekParam + 
			"%' or asStatPlan.answerCount like '%" + SeekParam + 
			"%' or asStatPlan.createMan like '%" + SeekParam + 
			"%' or asStatPlan.createTime like '%" + SeekParam + 
			"%' or asSysMain.cName like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:正在统计中,2:统计完成,3:统计异常终止)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or asStatPlan.status in (" + ss + ")";
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
			sss[x] = "asStatPlan." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by asStatPlan.sumRptName desc";
	String fields = "asStatPlan.sumRptName,asStatPlan.status,asStatPlan.ID,asStatPlan.planName,asStatPlan.beginTime,asStatPlan.endTime,asStatPlan.Info,asStatPlan.scopeInfo,asStatPlan.asSysMainId,asStatPlan.companys,asStatPlan.comCount,asStatPlan.answerCount,asStatPlan.createMan,asStatPlan.createTime";
	id = "asStatPlan.ID";
	if ((!order.equals("")) && (order.toLowerCase().indexOf(id.toLowerCase()) < 0))
		order = order + "," + id;
	seekrun.TotalRec = seekrun.jdb.count(0, "asStatPlan left join asSysMain on asStatPlan.asSysMainId=asSysMain.ID", Condition);
	String RefFields = ",asSysMain.cName as cName_8";
	if (nPage < 1)
		nPage = 1;
	if ((nPage - 1) * nPageSize > seekrun.TotalRec)
		nPage = (seekrun.TotalRec  - nPageSize - 1) / nPageSize;
	sql = seekrun.jdb.SQLSelectPage(0, nPage, nPageSize, fields + RefFields, "asStatPlan left join asSysMain on asStatPlan.asSysMainId=asSysMain.ID", Condition, group, order, id);
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
		String rs_sumRptName = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_status = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_planName = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_beginTime = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_endTime = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_Info = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_scopeInfo = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_asSysMainId = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_companys = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_comCount = WebChar.isString(jdb.getRSString(0, rs, 11));
		String rs_answerCount = WebChar.isString(jdb.getRSString(0, rs, 12));
		String rs_createMan = WebChar.isString(jdb.getRSString(0, rs, 13));
		String rs_createTime = WebChar.isString(jdb.getRSString(0, rs, 14));
		jout.print("sumRptName:\"" + WebChar.toJson(rs_sumRptName) + "\"");
		jout.print(", status:\"" + rs_status + "\"");
		String rs_status_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:正在统计中,2:统计完成,3:统计异常终止)", rs_status, 0));
		jout.print(", status_ex:\"" + rs_status_ex + "\"");
		jout.print(", ID:\"" + rs_ID + "\"");
		jout.print(", planName:\"" + WebChar.toJson(rs_planName) + "\"");
		jout.print(", beginTime:\"" + rs_beginTime + "\"");
		String rs_beginTime_ex = WebChar.toJson(seekrun.ConvertFieldValue("&d:1", rs_beginTime, 0));
		jout.print(", beginTime_ex:\"" + rs_beginTime_ex + "\"");
		jout.print(", endTime:\"" + rs_endTime + "\"");
		String rs_endTime_ex = WebChar.toJson(seekrun.ConvertFieldValue("&d:1", rs_endTime, 0));
		jout.print(", endTime_ex:\"" + rs_endTime_ex + "\"");
		jout.print(", Info:\"" + WebChar.toJson(rs_Info) + "\"");
		jout.print(", scopeInfo:\"" + WebChar.toJson(rs_scopeInfo) + "\"");
		jout.print(", asSysMainId:\"" + rs_asSysMainId + "\"");
		String rs_asSysMainId_ex = WebChar.toJson(seekrun.jdb.getRSString(0, rs, 15));
		jout.print(", asSysMainId_ex:\"" + rs_asSysMainId_ex + "\"");
		jout.print(", companys:\"" + WebChar.toJson(rs_companys) + "\"");
		String rs_companys_ex = WebChar.toJson(seekrun.ConvertFieldValue("+company.ID,comName", rs_companys, 0));
		jout.print(", companys_ex:\"" + rs_companys_ex + "\"");
		jout.print(", comCount:\"" + rs_comCount + "\"");
		jout.print(", answerCount:\"" + rs_answerCount + "\"");
		jout.print(", createMan:\"" + WebChar.toJson(rs_createMan) + "\"");
		jout.print(", createTime:\"" + rs_createTime + "\"");
		String rs_createTime_ex = WebChar.toJson(seekrun.ConvertFieldValue("&d:2", rs_createTime, 0));
		jout.print(", createTime_ex:\"" + rs_createTime_ex + "\"");
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
	seekrun.strTable = "asStatPlan";
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
			String viewhead = "[{FieldName:\"sumRptName\", TitleName:\"汇总表名称\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:3, Quote:\"(1:正在统计中,2:统计完成,3:统计异常终止)\", FieldType:3}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"planName\", TitleName:\"方案名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"beginTime\", TitleName:\"开始时间\", nWidth:0, nShowMode:1, Quote:\"&d:1\", FieldType:4}," +
		"{FieldName:\"endTime\", TitleName:\"结束时间\", nWidth:0, nShowMode:1, Quote:\"&d:1\", FieldType:4}," +
		"{FieldName:\"Info\", TitleName:\"说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"scopeInfo\", TitleName:\"范围说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"asSysMainId\", TitleName:\"评估体系模板编号\", nWidth:0, nShowMode:1, Quote:\"asSysMain.ID,cName\", FieldType:3}," +
		"{FieldName:\"companys\", TitleName:\"统计企业\", nWidth:0, nShowMode:1, Quote:\"+company.ID,comName\", FieldType:1}," +
		"{FieldName:\"comCount\", TitleName:\"企业总数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"answerCount\", TitleName:\"答卷总数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:1, Quote:\"&d:2\", FieldType:4}]";
			out.print(", head:" + viewhead + ",TableName:\"asStatPlan\", TableCName:\"评估统计方案表\", EditForm:\"asStatPlan_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"asStatPlan\", TableCName:\"评估统计方案表\", Fields:\"sumRptName,status,ID,planName,beginTime,endTime,Info,scopeInfo,asSysMainId,companys,comCount,answerCount,createMan,createTime\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"planName\",ShowName:\"方案名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"beginTime\",ShowName:\"开始时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"endTime\",ShowName:\"结束时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"Info\",ShowName:\"说明\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"scopeInfo\",ShowName:\"范围说明\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"createMan\",ShowName:\"创建人\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"createTime\",ShowName:\"创建时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:2\"},{FieldName:\"asSysMainId\",ShowName:\"评估体系模板编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"asSysMain.ID,cName\"},{FieldName:\"companys\",ShowName:\"统计企业\",FieldType:1, FieldLen:3000,bPrimaryKey:0, bUnique:0, QuoteTable:\"+company.ID,comName\"},{FieldName:\"answerCount\",ShowName:\"答卷总数\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"comCount\",ShowName:\"企业总数\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"status\",ShowName:\"状态\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:正在统计中,2:统计完成,3:统计异常终止)\"},{FieldName:\"sumRptName\",ShowName:\"汇总表名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"sumRptName\", TitleName:\"汇总表名称\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:3, Quote:\"(1:正在统计中,2:统计完成,3:统计异常终止)\", FieldType:3}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"planName\", TitleName:\"方案名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"beginTime\", TitleName:\"开始时间\", nWidth:0, nShowMode:1, Quote:\"&d:1\", FieldType:4}," +
		"{FieldName:\"endTime\", TitleName:\"结束时间\", nWidth:0, nShowMode:1, Quote:\"&d:1\", FieldType:4}," +
		"{FieldName:\"Info\", TitleName:\"说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"scopeInfo\", TitleName:\"范围说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"asSysMainId\", TitleName:\"评估体系模板编号\", nWidth:0, nShowMode:1, Quote:\"asSysMain.ID,cName\", FieldType:3}," +
		"{FieldName:\"companys\", TitleName:\"统计企业\", nWidth:0, nShowMode:1, Quote:\"+company.ID,comName\", FieldType:1}," +
		"{FieldName:\"comCount\", TitleName:\"企业总数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"answerCount\", TitleName:\"答卷总数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:1, Quote:\"&d:2\", FieldType:4}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("统计方案", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
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
	head = $.jcom.eval("[{FieldName:\"sumRptName\", TitleName:\"汇总表名称\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:3, Quote:\"(1:正在统计中,2:统计完成,3:统计异常终止)\", FieldType:3}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"planName\", TitleName:\"方案名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"beginTime\", TitleName:\"开始时间\", nWidth:0, nShowMode:1, Quote:\"&d:1\", FieldType:4}," +
		"{FieldName:\"endTime\", TitleName:\"结束时间\", nWidth:0, nShowMode:1, Quote:\"&d:1\", FieldType:4}," +
		"{FieldName:\"Info\", TitleName:\"说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"scopeInfo\", TitleName:\"范围说明\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:2}," +
		"{FieldName:\"asSysMainId\", TitleName:\"评估体系模板编号\", nWidth:0, nShowMode:1, Quote:\"asSysMain.ID,cName\", FieldType:3}," +
		"{FieldName:\"companys\", TitleName:\"统计企业\", nWidth:0, nShowMode:1, Quote:\"+company.ID,comName\", FieldType:1}," +
		"{FieldName:\"comCount\", TitleName:\"企业总数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"answerCount\", TitleName:\"答卷总数\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:3}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:1, Quote:\"&d:2\", FieldType:4}]");
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
var ActionID = 272;
var ViewMode = <%=ViewMode%>;
var TableDefID = 203;
var PrepID = 0;
var FormAction="asStatPlan_form.jsp";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>