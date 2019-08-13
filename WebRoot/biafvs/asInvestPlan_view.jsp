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
		Condition = "asInvestPlan.ID like '%" + SeekParam + 
			"%' or asInvestPlan.planName like '%" + SeekParam + 
			"%' or asInvestPlan.beginTime like '%" + SeekParam + 
			"%' or asInvestPlan.endTime like '%" + SeekParam + 
			"%' or asInvestPlan.fillBTime like '%" + SeekParam + 
			"%' or asInvestPlan.fillETime like '%" + SeekParam + 
			"%' or asInvestPlan.asSysMainId like '%" + SeekParam + 
			"%' or asInvestPlan.fillReq like '%" + SeekParam + 
			"%' or asInvestPlan.fillScope like '%" + SeekParam + 
			"%' or asInvestPlan.createMan like '%" + SeekParam + 
			"%' or asInvestPlan.createTime like '%" + SeekParam + 
			"%' or asInvestPlan.modifyMan like '%" + SeekParam + 
			"%' or asInvestPlan.modifyTime like '%" + SeekParam + 
			"%' or asInvestPlan.info like '%" + SeekParam + 
			"%' or asInvestPlan.askCount like '%" + SeekParam + 
			"%' or asInvestPlan.answerCount like '%" + SeekParam + 
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
			sss[x] = "asInvestPlan." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by asInvestPlan.ID desc";
	String fields = "asInvestPlan.ID,asInvestPlan.planName,asInvestPlan.beginTime,asInvestPlan.endTime,asInvestPlan.fillBTime,asInvestPlan.fillETime,asInvestPlan.asSysMainId,asInvestPlan.fillReq,asInvestPlan.fillScope,asInvestPlan.createMan,asInvestPlan.createTime,asInvestPlan.modifyMan,asInvestPlan.modifyTime,asInvestPlan.info,asInvestPlan.askCount,asInvestPlan.answerCount";
	id = "asInvestPlan.ID";
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
		String rs_planName = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_beginTime = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_endTime = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_fillBTime = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_fillETime = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_asSysMainId = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_fillReq = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_fillScope = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_createMan = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_createTime = WebChar.isString(jdb.getRSString(0, rs, 11));
		String rs_modifyMan = WebChar.isString(jdb.getRSString(0, rs, 12));
		String rs_modifyTime = WebChar.isString(jdb.getRSString(0, rs, 13));
		String rs_info = WebChar.isString(jdb.getRSString(0, rs, 14));
		String rs_askCount = WebChar.isString(jdb.getRSString(0, rs, 15));
		String rs_answerCount = WebChar.isString(jdb.getRSString(0, rs, 16));
		jout.print("ID:\"" + rs_ID + "\"");
		jout.print(", planName:\"" + WebChar.toJson(rs_planName) + "\"");
		jout.print(", beginTime:\"" + rs_beginTime + "\"");
		jout.print(", endTime:\"" + rs_endTime + "\"");
		jout.print(", fillBTime:\"" + rs_fillBTime + "\"");
		jout.print(", fillETime:\"" + rs_fillETime + "\"");
		jout.print(", asSysMainId:\"" + WebChar.toJson(rs_asSysMainId) + "\"");
		jout.print(", fillReq:\"" + WebChar.toJson(rs_fillReq) + "\"");
		jout.print(", fillScope:\"" + WebChar.toJson(rs_fillScope) + "\"");
		jout.print(", createMan:\"" + WebChar.toJson(rs_createMan) + "\"");
		jout.print(", createTime:\"" + rs_createTime + "\"");
		jout.print(", modifyMan:\"" + WebChar.toJson(rs_modifyMan) + "\"");
		jout.print(", modifyTime:\"" + rs_modifyTime + "\"");
		jout.print(", info:\"" + WebChar.toJson(rs_info) + "\"");
		jout.print(", askCount:\"" + rs_askCount + "\"");
		jout.print(", answerCount:\"" + rs_answerCount + "\"");
		jout.print("}");
		if (x ++ >= nPageSize - 1)
			break;
	}
	jdb.rsClose(0, rs);
	jout.print("]");
	return "";
}

public String TableSeekReport(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, int nPage, int nPageSize, String Filters, String href, int ViewMode) throws Exception
{
String tr1, tr2, hint, value, value0, node, id = "", bkcolor, color, item, ss, UserDefineValue, attach = "";
int TotalRec = 0, Depth=-1;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebUser user = seekrun.user;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters);
	TotalRec = seekrun.TotalRec;
	nPage = seekrun.nPage;
	seekrun.jout.print("<DIV id=TableDoc>");
	seekrun.jout.print("<table id=SeekTable width=100% cellpadding=3 cellspacing=0 border=0 oncontextmenu='return ExSeekFunction(this);' ondblclick=DblClickSeekTable(this)>");
	if ((ViewMode % 100) == 1)
	{
		seekrun.jout.print("<TR id=SeekTitleTR oncontextmenu='TitleMenu(this);return false;'>");
		seekrun.jout.print("<TD node=planName nowrap  onclick=SetOrder(this) bTotal=0>" + "计划名称" + "</TD>");
		seekrun.jout.print("<TD node=beginTime nowrap  onclick=SetOrder(this) bTotal=0>" + "开始时间" + "</TD>");
		seekrun.jout.print("<TD node=endTime nowrap  onclick=SetOrder(this) bTotal=0>" + "结束时间" + "</TD>");
		seekrun.jout.print("<TD node=fillBTime nowrap  onclick=SetOrder(this) bTotal=0>" + "填报开始时间" + "</TD>");
		seekrun.jout.print("<TD node=fillETime nowrap  onclick=SetOrder(this) bTotal=0>" + "填报结束时间" + "</TD>");
		seekrun.jout.print("<TD node=asSysMainId nowrap  onclick=SetOrder(this) bTotal=0>" + "评估体系模板编号" + "</TD>");
		seekrun.jout.print("<TD node=fillReq nowrap  onclick=SetOrder(this) bTotal=0>" + "填报要求" + "</TD>");
		seekrun.jout.print("<TD node=fillScope nowrap  onclick=SetOrder(this) bTotal=0>" + "填报范围" + "</TD>");
		seekrun.jout.print("<TD node=createMan nowrap  onclick=SetOrder(this) bTotal=0>" + "创建人" + "</TD>");
		seekrun.jout.print("<TD node=createTime nowrap  onclick=SetOrder(this) bTotal=0>" + "创建时间" + "</TD>");
		seekrun.jout.print("<TD node=modifyMan nowrap  onclick=SetOrder(this) bTotal=0>" + "修改人" + "</TD>");
		seekrun.jout.print("<TD node=modifyTime nowrap  onclick=SetOrder(this) bTotal=0>" + "修改时间" + "</TD>");
		seekrun.jout.print("<TD node=info nowrap  onclick=SetOrder(this) bTotal=0>" + "备注" + "</TD>");
		seekrun.jout.print("<TD node=askCount nowrap  onclick=SetOrder(this) bTotal=0>" + "问卷总数" + "</TD>");
		seekrun.jout.print("<TD node=answerCount nowrap  onclick=SetOrder(this) bTotal=0>" + "答卷总数" + "</TD>");
		seekrun.jout.print("</TR>");
	}
	if (TotalRec == 0)
	{
		seekrun.jout.print("<tr><td style=color:#cccccc;border:none;padding-top:5px;padding-left:20px; clospan=14>当前视图没有数据</td><tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr></table></DIV>");
	}
	else
	{
		int x = 0;
		while (rs.next())
		{
				String rs_ID = seekrun.jdb.getRSString(0, rs, 1);
				String rs_planName = seekrun.jdb.getRSString(0, rs, 2);
				String rs_beginTime = seekrun.jdb.getRSString(0, rs, 3);
				String rs_endTime = seekrun.jdb.getRSString(0, rs, 4);
				String rs_fillBTime = seekrun.jdb.getRSString(0, rs, 5);
				String rs_fillETime = seekrun.jdb.getRSString(0, rs, 6);
				String rs_asSysMainId = seekrun.jdb.getRSString(0, rs, 7);
				String rs_fillReq = seekrun.jdb.getRSString(0, rs, 8);
				String rs_fillScope = seekrun.jdb.getRSString(0, rs, 9);
				String rs_createMan = seekrun.jdb.getRSString(0, rs, 10);
				String rs_createTime = seekrun.jdb.getRSString(0, rs, 11);
				String rs_modifyMan = seekrun.jdb.getRSString(0, rs, 12);
				String rs_modifyTime = seekrun.jdb.getRSString(0, rs, 13);
				String rs_info = seekrun.jdb.getRSString(0, rs, 14);
				String rs_askCount = seekrun.jdb.getRSString(0, rs, 15);
				String rs_answerCount = seekrun.jdb.getRSString(0, rs, 16);
			if ((ViewMode % 100) == 1)
			{
				x ++;
				bkcolor = "";
				color = "";
				tr1 = "";
				tr2 = "";
				hint = "";
				attach = "";
				value0 = WebChar.isString(rs_ID);
				value = value0;
				id = " node='" + WebChar.isString(rs_ID) + "'";
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "自动编号" + ":" + value + "\n";

				value0 = WebChar.isString(rs_planName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_beginTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_endTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_fillBTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_fillETime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_asSysMainId);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_fillReq);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_fillScope);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_createMan);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_createTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_modifyMan);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_modifyTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_info);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_askCount);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_answerCount);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				tr1 = "<TR onclick=\"SelObject(this)\" oncontextmenu='ExSeekFunction(this);return false;'" + id + " title='" + hint + "' style='background-color:" + bkcolor + ";color:" + color + "'" + attach + ">" + tr1 + "</tr>";
				if (!tr2.equals(""))
					tr2 = "<TR id=Detail bgcolor=white style=display:none><TD colSpan=15>" + tr2 + "</td></tr>";
				seekrun.jout.print(tr1 + tr2);
			}
		}
		seekrun.jdb.rsClose(0, rs);
		seekrun.jout.print("<tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>");
		seekrun.jout.print("</table>");
		seekrun.jout.print("</DIV>");
		seekrun.jout.print(seekrun.PagesFoot(TotalRec, WebChar.AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam.replace('%','*') + "&ViewMode=" + ViewMode + "&OrderField=" + OrderField + "&bDesc=" + bDesc), nPageSize, nPage, 0));
	}
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
	seekrun.strTable = "asInvestPlan";
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
			String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}," +
		"{FieldName:\"planName\", TitleName:\"计划名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"beginTime\", TitleName:\"开始时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"endTime\", TitleName:\"结束时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillBTime\", TitleName:\"填报开始时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillETime\", TitleName:\"填报结束时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"asSysMainId\", TitleName:\"评估体系模板编号\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillReq\", TitleName:\"填报要求\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:2, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillScope\", TitleName:\"填报范围\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:2, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyMan\", TitleName:\"修改人\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyTime\", TitleName:\"修改时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"info\", TitleName:\"备注\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:2, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"askCount\", TitleName:\"问卷总数\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"answerCount\", TitleName:\"答卷总数\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}]";
			out.print(", head:" + viewhead + ",TableName:\"asInvestPlan\", TableCName:\"评估调查计划表\", EditForm:\"asInvestPlan_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"asInvestPlan\", TableCName:\"评估调查计划表\", Fields:\"ID,planName,beginTime,endTime,fillBTime,fillETime,asSysMainId,fillReq,fillScope,createMan,createTime,modifyMan,modifyTime,info,askCount,answerCount\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"beginTime\",ShowName:\"开始时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"endTime\",ShowName:\"结束时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillBTime\",ShowName:\"填报开始时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillETime\",ShowName:\"填报结束时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"asSysMainId\",ShowName:\"评估体系模板编号\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillReq\",ShowName:\"填报要求\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillScope\",ShowName:\"填报范围\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"createMan\",ShowName:\"创建人\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"createTime\",ShowName:\"创建时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"modifyMan\",ShowName:\"修改人\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"modifyTime\",ShowName:\"修改时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"info\",ShowName:\"备注\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"askCount\",ShowName:\"问卷总数\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"answerCount\",ShowName:\"答卷总数\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"planName\",ShowName:\"计划名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}," +
		"{FieldName:\"planName\", TitleName:\"计划名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"beginTime\", TitleName:\"开始时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"endTime\", TitleName:\"结束时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillBTime\", TitleName:\"填报开始时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillETime\", TitleName:\"填报结束时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"asSysMainId\", TitleName:\"评估体系模板编号\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillReq\", TitleName:\"填报要求\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:2, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"fillScope\", TitleName:\"填报范围\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:2, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyMan\", TitleName:\"修改人\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyTime\", TitleName:\"修改时间\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"info\", TitleName:\"备注\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:2, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"askCount\", TitleName:\"问卷总数\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"answerCount\", TitleName:\"答卷总数\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("制定调查计划", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
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
	case 1:
		TableSeekReport(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters, href, ViewMode);
		break;
	case 6:
		TableSeekReport(seekrun, SeekKey, SeekParam, OrderField, bDesc, nPage, nPageSize, Filters, href, ViewMode);
		break;
	case 7:
//		call MapView(TableDefID, TableStatus, FieldDB, SeekKey, SeekParam, ActionID, href, aAttrib);
		break;
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
var ActionID = 269;
var ViewMode = <%=ViewMode%>;
var TableDefID = 200;
var PrepID = 0;
var FormAction="asInvestPlan_form.jsp";
var FormViewAction = "asInvestPlan_form.jsp";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>