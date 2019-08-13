<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
public String AjaxGetKeyword(SeekRun seekrun, int nSize, String SeekParam, String Filters)
{
	int cnt = 0;
	String result = "", Condition = "";
	SeekParam = SeekParam.replaceAll("'", "''");
	result = WebChar.joinStr(result, seekrun.GetEnumWordValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", SeekParam, 1), ",");
	result = WebChar.joinStr(result, seekrun.GetEnumWordValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", SeekParam, 1), ",");
	if (!Filters.equals(""))
		Condition = " where (" + Filters + ") and ";
	else
		Condition = " where ";
	String [] sqls = new String [15];
	String [] fields = {"itemCName","info","dataType","unit","weight","ID","asSysId","parentId","baseId","itemEName","value","fillName","fillInfo","method"};
	sqls[0] = seekrun.jdb.SQLSelectEx(0, nSize, "asSysMain.cName", "asSysDetail left join asSysMain on asSysDetail.asSysId=asSysMain.ID", Condition + "( + asSysMain.cName like '%" + SeekParam + "%')", "distinct", "");
	for (int x = 0; x < fields.length; x++)
		sqls[x + 1] = seekrun.jdb.SQLSelectEx(0, nSize, fields[x], "asSysDetail", Condition + "(" + fields[x] + " like '%" + SeekParam + "%')", "distinct", "");
	for (int x = 0; x < sqls.length; x++)
	{
		ResultSet rs = seekrun.jdb.rsSQL(0, sqls[x]);
		try {
			while (rs.next())
			{
				if (!result.equals(""))
					result += ",";
				result += rs.getString(1);
				if (cnt ++ >= nSize - 1)
				{
					seekrun.jdb.rsClose(0, rs);
					return result;
				}
			}
			seekrun.jdb.rsClose(0, rs);
		} catch (SQLException e) {
				return "";
		}
	}
	return result;
}

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
		Condition = "asSysDetail.itemCName like '%" + SeekParam + 
			"%' or asSysDetail.info like '%" + SeekParam + 
			"%' or asSysDetail.dataType like '%" + SeekParam + 
			"%' or asSysDetail.unit like '%" + SeekParam + 
			"%' or asSysDetail.weight like '%" + SeekParam + 
			"%' or asSysDetail.ID like '%" + SeekParam + 
			"%' or asSysDetail.asSysId like '%" + SeekParam + 
			"%' or asSysDetail.parentId like '%" + SeekParam + 
			"%' or asSysDetail.baseId like '%" + SeekParam + 
			"%' or asSysDetail.itemEName like '%" + SeekParam + 
			"%' or asSysDetail.value like '%" + SeekParam + 
			"%' or asSysDetail.fillName like '%" + SeekParam + 
			"%' or asSysDetail.fillInfo like '%" + SeekParam + 
			"%' or asSysDetail.method like '%" + SeekParam + 
			"%' or asSysMain.cName like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or asSysDetail.dataType in (" + ss + ")";
		ss = seekrun.GetEnumWordValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or asSysDetail.method in (" + ss + ")";
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
			sss[x] = "asSysDetail." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by nSerial";
	String fields = "asSysDetail.itemCName,asSysDetail.info,asSysDetail.dataType,asSysDetail.unit,asSysDetail.weight,asSysDetail.ID,asSysDetail.asSysId,asSysDetail.parentId,asSysDetail.baseId,asSysDetail.itemEName,asSysDetail.value,asSysDetail.fillName,asSysDetail.fillInfo,asSysDetail.method";
	id = "asSysDetail.ID";
	if ((!order.equals("")) && (order.toLowerCase().indexOf(id.toLowerCase()) < 0))
		order = order + "," + id;
	seekrun.TotalRec = seekrun.jdb.count(0, "asSysDetail left join asSysMain on asSysDetail.asSysId=asSysMain.ID", Condition);
	String RefFields = ",asSysMain.cName as cName_6";
	if (nPage < 1)
		nPage = 1;
	if ((nPage - 1) * nPageSize > seekrun.TotalRec)
		nPage = (seekrun.TotalRec  - nPageSize - 1) / nPageSize;
	sql = seekrun.jdb.SQLSelectPage(0, nPage, nPageSize, fields + RefFields, "asSysDetail left join asSysMain on asSysDetail.asSysId=asSysMain.ID", Condition, group, order, id);
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
		String rs_itemCName = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_info = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_dataType = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_unit = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_weight = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_asSysId = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_parentId = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_baseId = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_itemEName = WebChar.isString(jdb.getRSString(0, rs, 10));
		String rs_value = WebChar.isString(jdb.getRSString(0, rs, 11));
		String rs_fillName = WebChar.isString(jdb.getRSString(0, rs, 12));
		String rs_fillInfo = WebChar.isString(jdb.getRSString(0, rs, 13));
		String rs_method = WebChar.isString(jdb.getRSString(0, rs, 14));
		jout.print("itemCName:\"" + WebChar.toJson(rs_itemCName) + "\"");
		jout.print(", info:\"" + WebChar.toJson(rs_info) + "\"");
		jout.print(", dataType:\"" + rs_dataType + "\"");
		String rs_dataType_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", rs_dataType, 0));
		jout.print(", dataType_ex:\"" + rs_dataType_ex + "\"");
		jout.print(", unit:\"" + WebChar.toJson(rs_unit) + "\"");
		jout.print(", weight:\"" + rs_weight + "\"");
		jout.print(", ID:\"" + rs_ID + "\"");
		jout.print(", asSysId:\"" + rs_asSysId + "\"");
		String rs_asSysId_ex = WebChar.toJson(seekrun.jdb.getRSString(0, rs, 15));
		jout.print(", asSysId_ex:\"" + rs_asSysId_ex + "\"");
		jout.print(", parentId:\"" + rs_parentId + "\"");
		String rs_parentId_ex = WebChar.toJson(seekrun.ConvertFieldValue("asSysDetail.ID,itemCName", rs_parentId, 0));
		jout.print(", parentId_ex:\"" + rs_parentId_ex + "\"");
		jout.print(", baseId:\"" + rs_baseId + "\"");
		String rs_baseId_ex = WebChar.toJson(seekrun.ConvertFieldValue("asSysDetail.ID,itemCName", rs_baseId, 0));
		jout.print(", baseId_ex:\"" + rs_baseId_ex + "\"");
		jout.print(", itemEName:\"" + WebChar.toJson(rs_itemEName) + "\"");
		jout.print(", value:\"" + WebChar.toJson(rs_value) + "\"");
		jout.print(", fillName:\"" + WebChar.toJson(rs_fillName) + "\"");
		jout.print(", fillInfo:\"" + WebChar.toJson(rs_fillInfo) + "\"");
		jout.print(", method:\"" + rs_method + "\"");
		String rs_method_ex = WebChar.toJson(seekrun.ConvertFieldValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", rs_method, 0));
		jout.print(", method_ex:\"" + rs_method_ex + "\"");
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
		Condition ="asSysDetail.itemCName like '%" + SeekParam + 
			"%' or asSysDetail.info like '%" + SeekParam + 
			"%' or asSysDetail.dataType like '%" + SeekParam + 
			"%' or asSysDetail.unit like '%" + SeekParam + 
			"%' or asSysDetail.weight like '%" + SeekParam + 
			"%' or asSysDetail.ID like '%" + SeekParam + 
			"%' or asSysDetail.asSysId like '%" + SeekParam + 
			"%' or asSysDetail.parentId like '%" + SeekParam + 
			"%' or asSysDetail.baseId like '%" + SeekParam + 
			"%' or asSysDetail.itemEName like '%" + SeekParam + 
			"%' or asSysDetail.value like '%" + SeekParam + 
			"%' or asSysDetail.fillName like '%" + SeekParam + 
			"%' or asSysDetail.fillInfo like '%" + SeekParam + 
			"%' or asSysDetail.method like '%" + SeekParam + 
			"%' or asSysMain.cName like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.GetEnumWordValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or dataType in (" + ss + ")";
		ss = seekrun.GetEnumWordValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or method in (" + ss + ")";
	}
	else
	{
		if (SeekKey.equals("$LoadSeek$"))
			Condition = seekrun.LoadSeekCondition(SeekParam, seekrun.strTable, 0);
		else
		{
			if (!SeekKey.equals("parentId"))
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
	RunTreeData(seekrun, ParentItem, Condition, 0, 4, nItem, nFormat);
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
String rs_itemCName = aTreeDB[0][x];
String rs_info = aTreeDB[1][x];
String rs_dataType = aTreeDB[2][x];
String rs_unit = aTreeDB[3][x];
String rs_weight = aTreeDB[4][x];
String rs_ID = aTreeDB[5][x];
String rs_asSysId = aTreeDB[6][x];
String rs_parentId = aTreeDB[7][x];
String rs_baseId = aTreeDB[8][x];
String rs_itemEName = aTreeDB[9][x];
String rs_value = aTreeDB[10][x];
String rs_fillName = aTreeDB[11][x];
String rs_fillInfo = aTreeDB[12][x];
String rs_method = aTreeDB[13][x];
		String rs_dataType_ex = seekrun.ConvertFieldValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", rs_dataType, 0);
		String rs_asSysId_ex = aTreeDB[14][x];
		String rs_parentId_ex = seekrun.ConvertFieldValue("asSysDetail.ID,itemCName", rs_parentId, 0);
		String rs_baseId_ex = seekrun.ConvertFieldValue("asSysDetail.ID,itemCName", rs_baseId, 0);
		String rs_method_ex = seekrun.ConvertFieldValue("(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)", rs_method, 0);
	if (nFormat == 0)
	{
			item += "itemCName:\"" + WebChar.toJson(rs_itemCName) + "\"";
			item += ", info:\"" + WebChar.toJson(rs_info) + "\"";
			item += ", dataType:\"" + rs_dataType + "\"";
			item += ", dataType_ex:\"" + rs_dataType_ex + "\"";
			item += ", unit:\"" + WebChar.toJson(rs_unit) + "\"";
			item += ", weight:\"" + rs_weight + "\"";
			item += ", ID:\"" + rs_ID + "\"";
			item += ", asSysId:\"" + rs_asSysId + "\"";
			item += ", asSysId_ex:\"" + rs_asSysId_ex + "\"";
			item += ", parentId:\"" + rs_parentId + "\"";
			item += ", parentId_ex:\"" + rs_parentId_ex + "\"";
			item += ", baseId:\"" + rs_baseId + "\"";
			item += ", baseId_ex:\"" + rs_baseId_ex + "\"";
			item += ", itemEName:\"" + WebChar.toJson(rs_itemEName) + "\"";
			item += ", value:\"" + WebChar.toJson(rs_value) + "\"";
			item += ", fillName:\"" + WebChar.toJson(rs_fillName) + "\"";
			item += ", fillInfo:\"" + WebChar.toJson(rs_fillInfo) + "\"";
			item += ", method:\"" + rs_method + "\"";
			item += ", method_ex:\"" + rs_method_ex + "\"";
		return item;
	}

	String hint = "", attach = "";
	hint += "说明" + ":" + rs_info + "\\n";
	hint += "数据类型" + ":" + rs_dataType_ex + "\\n";
	hint += "单位" + ":" + rs_unit + "\\n";
	hint += "权重" + ":" + rs_weight + "\\n";
	hint += "自动编号" + ":" + rs_ID + "\\n";
	hint += "模板编号" + ":" + rs_asSysId_ex + "\\n";
	hint += "上级编号" + ":" + rs_parentId_ex + "\\n";
	hint += "基础指标编号" + ":" + rs_baseId_ex + "\\n";
	hint += "字段名称" + ":" + rs_itemEName + "\\n";
	hint += "指标值" + ":" + rs_value + "\\n";
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
		Parent = "(asSysDetail.parentId=0 or asSysDetail.parentId is null)";
	else
		Parent = "asSysDetail.parentId=" + WebChar.ToInt(ParentItem);
	sql = "select asSysDetail.itemCName,asSysDetail.info,asSysDetail.dataType,asSysDetail.unit,asSysDetail.weight,asSysDetail.ID,asSysDetail.asSysId,asSysDetail.parentId,asSysDetail.baseId,asSysDetail.itemEName,asSysDetail.value,asSysDetail.fillName,asSysDetail.fillInfo,asSysDetail.method,asSysMain.cName as cName_6 from asSysDetail left join asSysMain on asSysDetail.asSysId=asSysMain.ID where " + Parent + f + " order by nSerial";
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
		seekrun.jout.print("<TD node=info nowrap  width=350 onclick=SetOrder(this) bTotal=0>" + "说明" + "</TD>");
		seekrun.jout.print("<TD node=dataType nowrap  width=50 onclick=SetOrder(this) bTotal=0>" + "数据类型" + "</TD>");
		seekrun.jout.print("<TD node=unit nowrap  width=50 onclick=SetOrder(this) bTotal=0>" + "单位" + "</TD>");
		seekrun.jout.print("<TD node=weight nowrap  width=50 onclick=SetOrder(this) bTotal=0>" + "权重" + "</TD>");
		seekrun.jout.print("</TR>");
	}
	if (TotalRec == 0)
	{
		seekrun.jout.print("<tr><td style=color:#cccccc;border:none;padding-top:5px;padding-left:20px; clospan=3>当前视图没有数据</td><tr id=SeekTailTR><td></td><td></td><td></td><td></td></tr></table></DIV>");
	}
	else
	{
		int x = 0;
		while (rs.next())
		{
				String rs_itemCName = seekrun.jdb.getRSString(0, rs, 1);
				String rs_info = seekrun.jdb.getRSString(0, rs, 2);
				String rs_dataType = seekrun.jdb.getRSString(0, rs, 3);
				String rs_unit = seekrun.jdb.getRSString(0, rs, 4);
				String rs_weight = seekrun.jdb.getRSString(0, rs, 5);
				String rs_ID = seekrun.jdb.getRSString(0, rs, 6);
				String rs_asSysId = seekrun.jdb.getRSString(0, rs, 7);
				String rs_parentId = seekrun.jdb.getRSString(0, rs, 8);
				String rs_baseId = seekrun.jdb.getRSString(0, rs, 9);
				String rs_itemEName = seekrun.jdb.getRSString(0, rs, 10);
				String rs_value = seekrun.jdb.getRSString(0, rs, 11);
				String rs_fillName = seekrun.jdb.getRSString(0, rs, 12);
				String rs_fillInfo = seekrun.jdb.getRSString(0, rs, 13);
				String rs_method = seekrun.jdb.getRSString(0, rs, 14);
			if ((ViewMode % 100) == 1)
			{
				x ++;
				bkcolor = "";
				color = "";
				tr1 = "";
				tr2 = "";
				hint = "";
				attach = "";
				value0 = WebChar.isString(rs_itemCName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";

				value0 = WebChar.isString(rs_info);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_dataType);
				value = seekrun.ConvertFieldValue("(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_unit);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_weight);
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

				value0 = WebChar.isString(rs_asSysId);
				value = WebChar.isString(seekrun.jdb.getRSString(0, rs, 15));
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "模板编号" + ":" + value + "\n";

				value0 = WebChar.isString(rs_parentId);
				value = seekrun.ConvertFieldValue("asSysDetail.ID,itemCName", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "上级编号" + ":" + value + "\n";

				value0 = WebChar.isString(rs_baseId);
				value = seekrun.ConvertFieldValue("asSysDetail.ID,itemCName", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "基础指标编号" + ":" + value + "\n";

				value0 = WebChar.isString(rs_itemEName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "字段名称" + ":" + value + "\n";

				value0 = WebChar.isString(rs_value);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "指标值" + ":" + value + "\n";

				tr1 = "<TR onclick=\"SelObject(this)\" oncontextmenu='ExSeekFunction(this);return false;'" + id + " title='" + hint + "' style='background-color:" + bkcolor + ";color:" + color + "'" + attach + ">" + tr1 + "</tr>";
				if (!tr2.equals(""))
					tr2 = "<TR id=Detail bgcolor=white style=display:none><TD colSpan=4>" + tr2 + "</td></tr>";
				seekrun.jout.print(tr1 + tr2);
			}
		}
		seekrun.jdb.rsClose(0, rs);
		seekrun.jout.print("<tr id=SeekTailTR><td></td><td></td><td></td><td></td></tr>");
		seekrun.jout.print("</table>");
		seekrun.jout.print("</DIV>");
		seekrun.jout.print(seekrun.PagesFoot(TotalRec, WebChar.AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam.replace('%','*') + "&ViewMode=" + ViewMode + "&OrderField=" + OrderField + "&bDesc=" + bDesc), nPageSize, nPage, 0));
	}
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

public String RunComplexSeek(SeekRun seekrun) throws Exception
{
	int DeleteID = WebChar.RequestInt(seekrun.jreq, "DeleteID");
	if (DeleteID > 0)
	{
		String sql = "delete from UDBCabinet where srcName='asSysDetail_view' and ID=" + DeleteID;
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	String Title = WebChar.requestStr(seekrun.jreq, "Title");
	if (!Title.equals(""))
	{
		String Content = WebChar.unApostrophe(WebChar.requestStr(seekrun.jreq, "Content"));
		String sql = "insert into UDBCabinet(nType, srcName, Title, SubmitMan, SubmitTime, Content) values(1,'asSysDetail_view','" + Title + "','" + seekrun.user.CMemberName + "','" + VB.Now() + "','" + Content + "')";
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	seekrun.jout.print(WebFace.GetHTMLHead("复合查询选择", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<body alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0>");
	seekrun.jout.print("<div id=ContentDiv style=padding:8px>" + 
		"<table id=FilterTable cellpadding=0 cellspacing=0 border=0>" + 
		"<tr bgcolor=white><td width=150>字段</td><td width=40>条件</td><TD width=100>内容</td><td width=40>连接</td>" + 
		"<td bgcolor=white rowspan=2>&nbsp;<input type=button onclick=InsertCondition() value=添加></td>" + 
		"</tr><tr height=25px bgcolor=white><td><select id=FieldsSel style=width:150px; onchange=SelectFilterField(this)>");
	seekrun.jout.print("<option value=asSysDetail.itemCName node=1 quote=''>" + "指标名称" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.info node=1 quote=''>" + "说明" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.dataType node=3 quote='(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)'>" + "数据类型" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.unit node=1 quote=''>" + "单位" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.weight node=6 quote=''>" + "权重" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.ID node=5 quote=''>" + "自动编号" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.asSysId node=3 quote='asSysMain.ID,cName'>" + "模板编号" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.parentId node=3 quote='asSysDetail.ID,itemCName'>" + "上级编号" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.baseId node=3 quote='asSysDetail.ID,itemCName'>" + "基础指标编号" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.itemEName node=1 quote=''>" + "字段名称" + "</option>");
	seekrun.jout.print("<option value=asSysDetail.value node=1 quote=''>" + "指标值" + "</option>");
	seekrun.jout.print("</select><td><select id=ChoiceSel><option value=1>等于</option><option value=2>不等于</option>" + 
		"<option value=3>大于</option><option value=4>小于</option><option value=5>大于等于</option>" + 
		"<option value=6>小于等于</option><option value=7>左包含</option><option value=8>右包含</option>" + 
		"<option value=9>全包含</option></select></td><TD bgcolor=white><span style='border:1px solid #7b9ebd;height:20px;overflow:hidden;width:130px;'>" + 
		"<input name=Content type=text FieldType=1 onkeydown=PressKey(this) style=border:none;height:20px;width=110px;>" + 
		"<img id=ComboImg onclick=SelectFilterCombo(this) src=../com/pic/combo.jpg onmouseover=this.src='../com/pic/combo1.jpg' onmouseout=this.src='../com/pic/combo.jpg'></span></td>" + 
		"<td><select id=ConnectSel><option value=and>并且</option><option value=or>或者</option></select></td>" + 
		"</tr></table><table><tr><td id=ContentTitleTD colspan=2>已添加的查询条件:</td><tr><td><tr><td>" + 
		"<div id=SelectedDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray\">" + 
		"<table id=SelectedList width=400 border=0 style=table-layout:fixed></table></div>" +
		"<div id=LoadCatalogDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray;display:none;padding:4px;\">");
	String sql = "select ID, Title, Content from UDBCabinet where nType=1 and srcName='asSysDetail_view'";
	ResultSet rsCatalog = seekrun.jdb.rsSQL(0, sql);
	if (rsCatalog != null)
	{
		try
		{
			while (rsCatalog.next())
			{
				seekrun.jout.print("<div onclick=SelectCatalog(this) ondblclick=LoadSeek() node=" + rsCatalog.getString("ID") + 
					" style=cursor:default;>" + rsCatalog.getString("Title") + "</div>");
			}
		}
		catch(SQLException e)
		{
			System.out.println(e.getMessage());
			System.out.println(sql);
			return "error";
		}
	}
	seekrun.jout.print("</div></td><td valign=bottom>");
	if (rsCatalog != null)
	{
		seekrun.jout.print("<input name=LoadButton type=button onclick=LoadCondition() value=载入><br><br>" + 
			"<input name=SaveButton type=button disabled onclick=SaveCondition() value=保存><br><br>");
	}
	seekrun.jout.print("<input name=DeleteButton type=button disabled onclick=DeleteCondition() value=删除><br><br>" + 
		"<input name=SeekButton type=button onclick=ConfirmCondition() value=查询><br><br>" + 
		"<input name=CancelButton type=button onclick=CalcelSel() value=取消><br>" + 
		"</td></tr></table></div>" + 
		"<script language=javascript src=../com/psub.jsp></script>\n" +
		"<script language=javascript src=../com/Form.jsp></script>\n" +
		"<script language=javascript src=../com/seek.jsp></script>\n" +
		"<script language=javascript src=../com/common.js></script>\n" +
		"<script language=javascript>\n" +
		"window.onload = function()\n" +
		"{\n" +
		"	window.status = \"加载完成\";\n" + 
		"	SelectFilterField(document.getElementById(\"FieldsSel\"));\n" +
		"	if (parent.document.getElementById(\"InDlgTitle\") != null)\n" +
		"	{\n" + 
		"	if (parent.document.getElementById(\"InDlgTitle\").innerHTML == \"正在载入...\")\n" + 
		"		parent.document.getElementById(\"InDlgTitle\").innerHTML = document.title;\n" + 
		"	}\n" + 
		"}\n" +
		"</script></BODY></HTML>");
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
	seekrun.strTable = "asSysDetail";
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
	String Filters = "asSysId=" + WebChar.RequestInt(request, "asSysId");
	if (ViewMode == 0)
		ViewMode = 9;
	seekrun.ViewMode = ViewMode;
	int nPageSize = 100;
	if (nPage == 0)
		nPage = 1;
	if (SeekKey.equals("$AjaxGetKeyword$"))
	{
		out.clear();
		out.print(AjaxGetKeyword(seekrun, 50, SeekParam, Filters));
		jdb.closeDBCon();
		return;
	}
	if (ComplexSeek > 0)
	{
		out.clear();
		RunComplexSeek(seekrun);
		jdb.closeDBCon();
		return;
	}
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
			String viewhead = "[{FieldName:\"itemCName\", TitleName:\"指标名称\", nWidth:160, nShowMode:9, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"info\", TitleName:\"说明\", nWidth:350, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"dataType\", TitleName:\"数据类型\", nWidth:50, nShowMode:1, Quote:\"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)\", FieldType:3}," +
		"{FieldName:\"unit\", TitleName:\"单位\", nWidth:50, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"weight\", TitleName:\"权重\", nWidth:50, nShowMode:1, Quote:\"\", FieldType:6}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"asSysId\", TitleName:\"模板编号\", nWidth:0, nShowMode:3, Quote:\"asSysMain.ID,cName\", FieldType:3}," +
		"{FieldName:\"parentId\", TitleName:\"上级编号\", nWidth:0, nShowMode:3, Quote:\"asSysDetail.ID,itemCName\", FieldType:3}," +
		"{FieldName:\"baseId\", TitleName:\"基础指标编号\", nWidth:0, nShowMode:3, Quote:\"asSysDetail.ID,itemCName\", FieldType:3}," +
		"{FieldName:\"itemEName\", TitleName:\"字段名称\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"value\", TitleName:\"指标值\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"fillName\", TitleName:\"填报名称\", nWidth:50, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"fillInfo\", TitleName:\"填报说明\", nWidth:50, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"method\", TitleName:\"指数计算方法\", nWidth:80, nShowMode:6, Quote:\"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)\", FieldType:3}]";
			out.print(", head:" + viewhead + ",TableName:\"asSysDetail\", TableCName:\"评估体系模板明细表\", EditForm:\"asSysDetail_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
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
			String viewhead = "[{FieldName:\"itemCName\", TitleName:\"指标名称\", nWidth:160, nShowMode:9, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"info\", TitleName:\"说明\", nWidth:350, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"dataType\", TitleName:\"数据类型\", nWidth:50, nShowMode:1, Quote:\"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)\", FieldType:3}," +
		"{FieldName:\"unit\", TitleName:\"单位\", nWidth:50, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"weight\", TitleName:\"权重\", nWidth:50, nShowMode:1, Quote:\"\", FieldType:6}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"asSysId\", TitleName:\"模板编号\", nWidth:0, nShowMode:3, Quote:\"asSysMain.ID,cName\", FieldType:3}," +
		"{FieldName:\"parentId\", TitleName:\"上级编号\", nWidth:0, nShowMode:3, Quote:\"asSysDetail.ID,itemCName\", FieldType:3}," +
		"{FieldName:\"baseId\", TitleName:\"基础指标编号\", nWidth:0, nShowMode:3, Quote:\"asSysDetail.ID,itemCName\", FieldType:3}," +
		"{FieldName:\"itemEName\", TitleName:\"字段名称\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"value\", TitleName:\"指标值\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"fillName\", TitleName:\"填报名称\", nWidth:50, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"fillInfo\", TitleName:\"填报说明\", nWidth:50, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"method\", TitleName:\"指数计算方法\", nWidth:80, nShowMode:6, Quote:\"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)\", FieldType:3}]";
			out.print(", head:" + viewhead + ",TableName:\"asSysDetail\", TableCName:\"评估体系模板明细表\", EditForm:\"asSysDetail_form\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\"}");
			break;
		}
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetFieldInfo") == 1)
	{
		out.clear();
		out.print("[{TableName:\"asSysDetail\", TableCName:\"评估体系模板明细表\", Fields:\"itemCName,info,dataType,unit,weight,ID,asSysId,parentId,baseId,itemEName,value\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"asSysId\",ShowName:\"模板编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"asSysMain.ID,cName\"},{FieldName:\"parentId\",ShowName:\"上级编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"asSysDetail.ID,itemCName\"},{FieldName:\"itemCName\",ShowName:\"指标名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"itemEName\",ShowName:\"字段名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"info\",ShowName:\"说明\",FieldType:1, FieldLen:200,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"dataType\",ShowName:\"数据类型\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)\"},{FieldName:\"value\",ShowName:\"指标值\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"unit\",ShowName:\"单位\",FieldType:1, FieldLen:10,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"weight\",ShowName:\"权重\",FieldType:6, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"baseId\",ShowName:\"基础指标编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"asSysDetail.ID,itemCName\"},{FieldName:\"nSerial\",ShowName:\"顺序号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"maxValue\",ShowName:\"最大值\",FieldType:7, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"minValue\",ShowName:\"最小值\",FieldType:7, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"dotNum\",ShowName:\"小数点后位数\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillName\",ShowName:\"填报名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillInfo\",ShowName:\"填报说明\",FieldType:1, FieldLen:200,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"fillType\",ShowName:\"填报要求\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"method\",ShowName:\"指数计算方法\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)\"},{FieldName:\"methodInfo\",ShowName:\"指数计算说明\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"valMethod\",ShowName:\"指标计算方法\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:累加法,2:加权累加法,3:归一加权累加法,4:公式计算法,5:程序计算法)\"},{FieldName:\"valMethodExp\",ShowName:\"指标计算公式\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"sumMethod\",ShowName:\"汇总表计算方法\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(1:累加法,2:平均法,3:去零平均法,4:最新数据法,5:公式计算法.6:程序计算法)\"},{FieldName:\"sumMethodExp\",ShowName:\"汇总表计算公式\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"itemCName\", TitleName:\"指标名称\", nWidth:160, nShowMode:9, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"info\", TitleName:\"说明\", nWidth:350, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"dataType\", TitleName:\"数据类型\", nWidth:50, nShowMode:1, Quote:\"(1:文本,2:备注,3:整数,4:日期,7:浮点数,9:是否,13:正整数,17:正浮点数,23:负整数,27:负浮点数)\", FieldType:3}," +
		"{FieldName:\"unit\", TitleName:\"单位\", nWidth:50, nShowMode:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"weight\", TitleName:\"权重\", nWidth:50, nShowMode:1, Quote:\"\", FieldType:6}," +
		"{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:5, bPrimaryKey:1}," +
		"{FieldName:\"asSysId\", TitleName:\"模板编号\", nWidth:0, nShowMode:3, Quote:\"asSysMain.ID,cName\", FieldType:3}," +
		"{FieldName:\"parentId\", TitleName:\"上级编号\", nWidth:0, nShowMode:3, Quote:\"asSysDetail.ID,itemCName\", FieldType:3}," +
		"{FieldName:\"baseId\", TitleName:\"基础指标编号\", nWidth:0, nShowMode:3, Quote:\"asSysDetail.ID,itemCName\", FieldType:3}," +
		"{FieldName:\"itemEName\", TitleName:\"字段名称\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"value\", TitleName:\"指标值\", nWidth:0, nShowMode:3, Quote:\"\", FieldType:1}," +
		"{FieldName:\"fillName\", TitleName:\"填报名称\", nWidth:50, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"fillInfo\", TitleName:\"填报说明\", nWidth:50, nShowMode:6, Quote:\"\", FieldType:1}," +
		"{FieldName:\"method\", TitleName:\"指数计算方法\", nWidth:80, nShowMode:6, Quote:\"(1:平均值算法,2:最大值算法,3:最小值算法,4:极差算法,5:百分比算法,6:公式计算法,7:程序计算法,8:其它)\", FieldType:3}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("评估体系", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
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
var ActionID = 267;
var ViewMode = <%=ViewMode%>;
var TableDefID = 199;
var PrepID = 0;
var FormAction="asSysDetail_form.jsp";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>