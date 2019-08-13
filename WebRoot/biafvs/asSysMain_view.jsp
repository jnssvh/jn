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
		Condition = "asSysMain.nType like '%" + SeekParam + 
			"%' or asSysMain.cName like '%" + SeekParam + 
			"%' or asSysMain.eName like '%" + SeekParam + 
			"%' or asSysMain.info like '%" + SeekParam + 
			"%' or asSysMain.status like '%" + SeekParam + 
			"%' or asSysMain.ID like '%" + SeekParam + 
			"%' or asSysMain.createMan like '%" + SeekParam + 
			"%' or asSysMain.createTime like '%" + SeekParam + 
			"%' or asSysMain.modifyMan like '%" + SeekParam + 
			"%' or asSysMain.modifyTime like '%" + SeekParam + 
			"%' or asSysMain.baseId like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:基础表,2:衍生表)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or asSysMain.nType in (" + ss + ")";
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
			sss[x] = "asSysMain." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by asSysMain.nType desc";
	String fields = "asSysMain.nType,asSysMain.cName,asSysMain.eName,asSysMain.info,asSysMain.status,asSysMain.ID,asSysMain.createMan,asSysMain.createTime,asSysMain.modifyMan,asSysMain.modifyTime,asSysMain.baseId";
	id = "asSysMain.ID";
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
		String rs_nType = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_cName = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_eName = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_info = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_status = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_createMan = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_createTime = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_modifyMan = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_modifyTime = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_baseId = WebChar.isString(jdb.getRSString(0, rs, 11));
		jout.print("nType:\"" + rs_nType + "\"");
		String rs_nType_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:基础表,2:衍生表)", rs_nType, 0));
		jout.print(", nType_ex:\"" + rs_nType_ex + "\"");
		jout.print(", cName:\"" + WebChar.toJson(rs_cName) + "\"");
		jout.print(", eName:\"" + WebChar.toJson(rs_eName) + "\"");
		jout.print(", info:\"" + WebChar.toJson(rs_info) + "\"");
		jout.print(", status:\"" + rs_status + "\"");
		jout.print(", ID:\"" + rs_ID + "\"");
		jout.print(", createMan:\"" + WebChar.toJson(rs_createMan) + "\"");
		jout.print(", createTime:\"" + rs_createTime + "\"");
		jout.print(", modifyMan:\"" + WebChar.toJson(rs_modifyMan) + "\"");
		jout.print(", modifyTime:\"" + rs_modifyTime + "\"");
		jout.print(", baseId:\"" + rs_baseId + "\"");
		String rs_baseId_ex = WebChar.toJson(seekrun.ConvertFieldValue("asSysMain.ID,cName", rs_baseId, 0));
		jout.print(", baseId_ex:\"" + rs_baseId_ex + "\"");
		jout.print("}");
		if (x ++ >= nPageSize - 1)
			break;
	}
	jdb.rsClose(0, rs);
	jout.print("]");
	return "";
}

public String GetTreeData(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, String Filters, String ParentItem, int nFormat) throws Exception
{
String value;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebEnum webenum = seekrun.we;
int nItem;
	nItem = 5;
	String ss, Condition = "";
	if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
	{
		String other = "";
		String [] sss = SeekParam.split("\\|\\|");
		if (sss.length > 1)
		{
			SeekParam = sss[0];
			other = sss[1];
		}
		Condition ="asSysMain.nType like '%" + SeekParam + 
			"%' or asSysMain.cName like '%" + SeekParam + 
			"%' or asSysMain.eName like '%" + SeekParam + 
			"%' or asSysMain.info like '%" + SeekParam + 
			"%' or asSysMain.status like '%" + SeekParam + 
			"%' or asSysMain.ID like '%" + SeekParam + 
			"%' or asSysMain.createMan like '%" + SeekParam + 
			"%' or asSysMain.createTime like '%" + SeekParam + 
			"%' or asSysMain.modifyMan like '%" + SeekParam + 
			"%' or asSysMain.modifyTime like '%" + SeekParam + 
			"%' or asSysMain.baseId like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:基础表,2:衍生表)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or nType in (" + ss + ")";
	}
	else
	{
		if (SeekKey.equals("$LoadSeek$"))
			Condition = seekrun.LoadSeekCondition(SeekParam, seekrun.strTable, 0);
		else
		{
			if (!SeekKey.equals("baseId"))
				Condition = seekrun.GetSeekCondition(SeekKey, SeekParam, seekrun.strTable, 0);
			else
				ParentItem = SeekParam;
		}
	}
	if (!Filters.equals(""))
	{
		if (!Condition.equals(""))
			Condition = Filters + " and " + "(" + Condition + ")";
		else
			Condition = Filters;
	}
	else
	{
		if (!Condition.equals(""))
			Condition = "(" + Condition + ")";
	}
	RunTreeData(seekrun, ParentItem, Condition, 0, 10, nItem, nFormat);
	return "";
}

public String RunTreeData(SeekRun seekrun, String ParentItem, String Filter, int Depth, int MaxDepth, int nItem, int nFormat) throws Exception
{
	String[][] aTreeDB;
	int x;
	aTreeDB = GetJSPTableTreeDB(seekrun, ParentItem, Filter);
	seekrun.jout.print("[");
	if (aTreeDB != null)
	{
		String dot = "";
		for (x = 0; x < aTreeDB[0].length; x++)
		{
			seekrun.jout.print(dot + "{" + GetTreeDataItem(seekrun, x, aTreeDB, nFormat) + ", child:");
			dot = ", ";
			if (MaxDepth > Depth + 1)
			{
				RunTreeData(seekrun, aTreeDB[nItem][x], Filter, Depth + 1, MaxDepth, nItem, nFormat);
			}
			else
				seekrun.jout.print("null");
			seekrun.jout.print("}");
		}
	}
	seekrun.jout.print("]");
	return "";
}

public String GetTreeDataItem(SeekRun seekrun, int x, String[][] aTreeDB, int nFormat)
{
String value, item = "";
JDatabase jdb = seekrun.jdb;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
String rs_nType = aTreeDB[0][x];
String rs_cName = aTreeDB[1][x];
String rs_eName = aTreeDB[2][x];
String rs_info = aTreeDB[3][x];
String rs_status = aTreeDB[4][x];
String rs_ID = aTreeDB[5][x];
String rs_createMan = aTreeDB[6][x];
String rs_createTime = aTreeDB[7][x];
String rs_modifyMan = aTreeDB[8][x];
String rs_modifyTime = aTreeDB[9][x];
String rs_baseId = aTreeDB[10][x];
		String rs_nType_ex = seekrun.ConvertFieldValue("(1:基础表,2:衍生表)", rs_nType, 0);
		String rs_baseId_ex = seekrun.ConvertFieldValue("asSysMain.ID,cName", rs_baseId, 0);
	if (nFormat == 0)
	{
			item += "nType:\"" + rs_nType + "\"";
			item += ", nType_ex:\"" + rs_nType_ex + "\"";
			item += ", cName:\"" + WebChar.toJson(rs_cName) + "\"";
			item += ", eName:\"" + WebChar.toJson(rs_eName) + "\"";
			item += ", info:\"" + WebChar.toJson(rs_info) + "\"";
			item += ", status:\"" + rs_status + "\"";
			item += ", ID:\"" + rs_ID + "\"";
			item += ", createMan:\"" + WebChar.toJson(rs_createMan) + "\"";
			item += ", createTime:\"" + rs_createTime + "\"";
			item += ", modifyMan:\"" + WebChar.toJson(rs_modifyMan) + "\"";
			item += ", modifyTime:\"" + rs_modifyTime + "\"";
			item += ", baseId:\"" + rs_baseId + "\"";
			item += ", baseId_ex:\"" + rs_baseId_ex + "\"";
		return item;
	}

	String hint = "", attach = "";
	hint += "模板类型" + ":" + rs_nType_ex + "\\n";
	item = rs_cName;
	hint += "英文名称" + ":" + rs_eName + "\\n";
	hint += "说明" + ":" + rs_info + "\\n";
	hint += "状态" + ":" + rs_status + "\\n";
	hint += "自动编号" + ":" + rs_ID + "\\n";
	hint += "创建人" + ":" + rs_createMan + "\\n";
	hint += "创建时间" + ":" + rs_createTime + "\\n";
	hint += "最后修改人" + ":" + rs_modifyMan + "\\n";
	hint += "最后修改时间" + ":" + rs_modifyTime + "\\n";
	hint += "基础表" + ":" + rs_baseId_ex + "\\n";
	if (item.toLowerCase().equals("[hidden]"))
		return "";
	return "item:\"" + item + "\", title:\"" + hint + "\"";
}

public String[][] GetJSPTableTreeDB(SeekRun seekrun, String ParentItem, String Filter)
{
String sql, f, Parent;
	if (!Filter.equals(""))
		f = " and (" + Filter + ")";
	else
		f = "";
	if (WebChar.ToInt(ParentItem) == 0)
		Parent = "(asSysMain.baseId=0 or asSysMain.baseId is null)";
	else
		Parent = "asSysMain.baseId=" + WebChar.ToInt(ParentItem);
	sql = "select asSysMain.nType,asSysMain.cName,asSysMain.eName,asSysMain.info,asSysMain.status,asSysMain.ID,asSysMain.createMan,asSysMain.createTime,asSysMain.modifyMan,asSysMain.modifyTime,asSysMain.baseId from " + seekrun.strTable + " where " + Parent + f;
	ResultSet rs = seekrun.jdb.rsSQL(0, sql);
	String[][] rsArray = seekrun.jdb.getRSData(rs, 1, 1000);
	seekrun.jdb.rsClose(0, rs);
	return rsArray;
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
		seekrun.jout.print("<TD node=nType nowrap  onclick=SetOrder(this) bTotal=0>" + "模板类型" + "</TD>");
		seekrun.jout.print("<TD node=cName nowrap  onclick=SetOrder(this) bTotal=0>" + "模板名称" + "</TD>");
		seekrun.jout.print("<TD node=eName nowrap  onclick=SetOrder(this) bTotal=0>" + "英文名称" + "</TD>");
		seekrun.jout.print("<TD node=info nowrap  onclick=SetOrder(this) bTotal=0>" + "说明" + "</TD>");
		seekrun.jout.print("<TD node=status nowrap  onclick=SetOrder(this) bTotal=0>" + "状态" + "</TD>");
		seekrun.jout.print("</TR>");
	}
	if (TotalRec == 0)
	{
		seekrun.jout.print("<tr><td style=color:#cccccc;border:none;padding-top:5px;padding-left:20px; clospan=4>当前视图没有数据</td><tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td></tr></table></DIV>");
	}
	else
	{
		int x = 0;
		while (rs.next())
		{
				String rs_nType = seekrun.jdb.getRSString(0, rs, 1);
				String rs_cName = seekrun.jdb.getRSString(0, rs, 2);
				String rs_eName = seekrun.jdb.getRSString(0, rs, 3);
				String rs_info = seekrun.jdb.getRSString(0, rs, 4);
				String rs_status = seekrun.jdb.getRSString(0, rs, 5);
				String rs_ID = seekrun.jdb.getRSString(0, rs, 6);
				String rs_createMan = seekrun.jdb.getRSString(0, rs, 7);
				String rs_createTime = seekrun.jdb.getRSString(0, rs, 8);
				String rs_modifyMan = seekrun.jdb.getRSString(0, rs, 9);
				String rs_modifyTime = seekrun.jdb.getRSString(0, rs, 10);
				String rs_baseId = seekrun.jdb.getRSString(0, rs, 11);
			if ((ViewMode % 100) == 1)
			{
				x ++;
				bkcolor = "";
				color = "";
				tr1 = "";
				tr2 = "";
				hint = "";
				attach = "";
				value0 = WebChar.isString(rs_nType);
				value = seekrun.ConvertFieldValue("(1:基础表,2:衍生表)", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_cName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_eName);
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

				value0 = WebChar.isString(rs_status);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_ID);
				value = value0;
				id = " node='" + WebChar.isString(rs_ID) + "'";
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "自动编号" + ":" + value + "\n";

				value0 = WebChar.isString(rs_createMan);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "创建人" + ":" + value + "\n";

				value0 = WebChar.isString(rs_createTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "创建时间" + ":" + value + "\n";

				value0 = WebChar.isString(rs_modifyMan);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "最后修改人" + ":" + value + "\n";

				value0 = WebChar.isString(rs_modifyTime);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "最后修改时间" + ":" + value + "\n";

				value0 = WebChar.isString(rs_baseId);
				value = seekrun.ConvertFieldValue("asSysMain.ID,cName", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "基础表" + ":" + value + "\n";

				tr1 = "<TR onclick=\"SelObject(this)\" oncontextmenu='ExSeekFunction(this);return false;'" + id + " title='" + hint + "' style='background-color:" + bkcolor + ";color:" + color + "'" + attach + ">" + tr1 + "</tr>";
				if (!tr2.equals(""))
					tr2 = "<TR id=Detail bgcolor=white style=display:none><TD colSpan=5>" + tr2 + "</td></tr>";
				seekrun.jout.print(tr1 + tr2);
			}
		}
		seekrun.jdb.rsClose(0, rs);
		seekrun.jout.print("<tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td></tr>");
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
	seekrun.strTable = "asSysMain";
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
			String viewhead = "[{FieldName:\"nType\", TitleName:\"模板类型\", nWidth:0, nShowMode:1, bTag:0, Quote:\"(1:基础表,2:衍生表)\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"cName\", TitleName:\"模板名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"eName\", TitleName:\"英文名称\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"info\", TitleName:\"说明\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyMan\", TitleName:\"最后修改人\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyTime\", TitleName:\"最后修改时间\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"baseId\", TitleName:\"基础表\", nWidth:0, nShowMode:3, bTag:0, Quote:\"asSysMain.ID,cName\", FieldType:3, bPrimaryKey:0, bSeek:0}]";
			out.print(", head:" + viewhead + ",TableName:\"asSysMain\", TableCName:\"评估体系模板主表\", EditForm:\"asSysMain_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	int ajaxGetTreeMode = WebChar.RequestInt(request, "GetTreeData");
	if (ajaxGetTreeMode > 0)
	{
		out.clear();
		int nFormat = WebChar.RequestInt(request, "nFormat");
		switch (ajaxGetTreeMode)
		{
		case 1:
			GetTreeData(seekrun, SeekKey, SeekParam, OrderField, bDesc, Filters, ParentNode, nFormat);
			break;
		case 2:
			out.print("{data:");
			GetTreeData(seekrun, SeekKey, SeekParam, OrderField, bDesc, Filters, ParentNode, nFormat);
			String viewhead = "[{FieldName:\"nType\", TitleName:\"模板类型\", nWidth:0, nShowMode:1, bTag:0, Quote:\"(1:基础表,2:衍生表)\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"cName\", TitleName:\"模板名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"eName\", TitleName:\"英文名称\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"info\", TitleName:\"说明\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyMan\", TitleName:\"最后修改人\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyTime\", TitleName:\"最后修改时间\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"baseId\", TitleName:\"基础表\", nWidth:0, nShowMode:3, bTag:0, Quote:\"asSysMain.ID,cName\", FieldType:3, bPrimaryKey:0, bSeek:0}]";
			out.print(", head:" + viewhead + ",TableName:\"asSysMain\", TableCName:\"评估体系模板主表\", EditForm:\"asSysMain_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"asSysMain\", TableCName:\"评估体系模板主表\", Fields:\"nType,cName,eName,info,status,ID,createMan,createTime,modifyMan,modifyTime,baseId\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"cName\",ShowName:\"模板名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"eName\",ShowName:\"英文名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"info\",ShowName:\"说明\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"status\",ShowName:\"状态\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"createMan\",ShowName:\"创建人\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"createTime\",ShowName:\"创建时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"modifyMan\",ShowName:\"最后修改人\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"modifyTime\",ShowName:\"最后修改时间\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"nType\",ShowName:\"模板类型\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:基础表,2:衍生表)\"},{FieldName:\"investCycle\",ShowName:\"采集周期\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"baseId\",ShowName:\"基础表\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"asSysMain.ID,cName\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"nType\", TitleName:\"模板类型\", nWidth:0, nShowMode:1, bTag:0, Quote:\"(1:基础表,2:衍生表)\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"cName\", TitleName:\"模板名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"eName\", TitleName:\"英文名称\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"info\", TitleName:\"说明\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"status\", TitleName:\"状态\", nWidth:0, nShowMode:1, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}," +
		"{FieldName:\"createMan\", TitleName:\"创建人\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"createTime\", TitleName:\"创建时间\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyMan\", TitleName:\"最后修改人\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"modifyTime\", TitleName:\"最后修改时间\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:4, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"baseId\", TitleName:\"基础表\", nWidth:0, nShowMode:3, bTag:0, Quote:\"asSysMain.ID,cName\", FieldType:3, bPrimaryKey:0, bSeek:0}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("评估体系模板", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
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
var ActionID = 266;
var ViewMode = <%=ViewMode%>;
var TableDefID = 198;
var PrepID = 0;
var FormAction="asSysMain_form.jsp";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>