<%@ page language="java" pageEncoding="gbk"%>
<%@ page trimDirectiveWhitespaces="true" %> 
<%@ page import="com.jaguar.*, java.util.*,java.sql.*, project.*,java.net.URLEncoder,studentsystem.*"%>
<%@ taglib uri="/WEB-INF/jaguar.tld" prefix="j" %>

<%!
public String AjaxGetKeyword(SeekRun seekrun, int nSize, String SeekParam, String Filters)
{
	int cnt = 0;
	String result = "", Condition = "";
	SeekParam = SeekParam.replaceAll("'", "''");
	result = WebChar.joinStr(result, seekrun.FindEnumValue("UserLevel", SeekParam, 1), ",");
	result = WebChar.joinStr(result, seekrun.FindEnumValue("GroupState", SeekParam, 1), ",");
	if (!Filters.equals(""))
		Condition = " where (" + Filters + ") and ";
	else
		Condition = " where ";
	String [] sqls = new String [6];
	String [] fields = {"ID","GroupNo","GroupName","nLevel","Status","Leader"};
	for (int x = 0; x < fields.length; x++)
		sqls[x + 0] = seekrun.jdb.SQLSelectEx(0, nSize, fields[x], "WorkGroup", Condition + "(" + fields[x] + " like '%" + SeekParam + "%')", "distinct", "");
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
		Condition = "WorkGroup.ID like '%" + SeekParam + 
			"%' or WorkGroup.GroupNo like '%" + SeekParam + 
			"%' or WorkGroup.GroupName like '%" + SeekParam + 
			"%' or WorkGroup.nLevel like '%" + SeekParam + 
			"%' or WorkGroup.Status like '%" + SeekParam + 
			"%' or WorkGroup.Leader like '%" + SeekParam + 
			"%' or WorkGroup.Members like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.FindEnumValue("UserLevel", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or WorkGroup.nLevel in (" + ss + ")";
		ss = seekrun.FindEnumValue("GroupState", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or WorkGroup.Status in (" + ss + ")";
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
			sss[x] = "WorkGroup." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by WorkGroup.ID desc";
	String fields = "WorkGroup.ID,WorkGroup.GroupNo,WorkGroup.GroupName,WorkGroup.nLevel,WorkGroup.Status,WorkGroup.Leader,WorkGroup.Members";
	id = "WorkGroup.ID";
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

public String GetTreeData(SeekRun seekrun, String SeekKey, String SeekParam, String OrderField, int bDesc, String Filters, String ParentItem, int nFormat) throws Exception
{
String value;
JspWriter jout = seekrun.jout;
JDatabase jdb = seekrun.jdb;
WebEnum webenum = seekrun.we;
	ResultSet rs = GetSeekResult(seekrun, SeekKey, SeekParam, OrderField, bDesc, 1, 1000, Filters);
	String[][] aTreeDB = seekrun.jdb.getRSData(rs, 1, 1000);
	seekrun.jout.print("[");
	if (aTreeDB != null)
	{
		String dot = "";
		for (int x = 0; x < aTreeDB[0].length; x++)
		{
			seekrun.jout.print(dot + "{" + GetTreeDataItem(seekrun, x, aTreeDB, nFormat) + "}");
			dot = ", ";
		}
	}
	seekrun.jout.print("]");
	seekrun.jdb.rsClose(0, rs);
	return "";
}

public String GetTreeDataItem(SeekRun seekrun, int x, String[][] aTreeDB, int nFormat)
{
String value, item = "";
JDatabase jdb = seekrun.jdb;
WebEnum webenum = seekrun.we;
HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
String rs_ID = aTreeDB[0][x];
String rs_GroupNo = aTreeDB[1][x];
String rs_GroupName = aTreeDB[2][x];
String rs_nLevel = aTreeDB[3][x];
String rs_Status = aTreeDB[4][x];
String rs_Leader = aTreeDB[5][x];
String rs_Members = aTreeDB[6][x];
		value = rs_GroupName;
		value = "[" + rs_GroupName + "]";
		rs_GroupName = value;
		String rs_nLevel_ex = webenum.GetEnumResultItem(seekrun.enums.get("UserLevel"), rs_nLevel, 0);
		String rs_Status_ex = webenum.GetEnumResultItem(seekrun.enums.get("GroupState"), rs_Status, 0);
		String rs_Leader_ex = seekrun.ConvertFieldValue("Member.CName", rs_Leader, 0);
	if (nFormat == 0)
	{
			item += "ID:\"" + rs_ID + "\"";
			item += ", GroupNo:\"" + rs_GroupNo + "\"";
			item += ", GroupName:\"" + WebChar.toJson(rs_GroupName) + "\"";
			item += ", nLevel:\"" + rs_nLevel + "\"";
			item += ", nLevel_ex:\"" + rs_nLevel_ex + "\"";
			item += ", Status:\"" + rs_Status + "\"";
			item += ", Status_ex:\"" + rs_Status_ex + "\"";
			item += ", Leader:\"" + WebChar.toJson(rs_Leader) + "\"";
			item += ", Leader_ex:\"" + rs_Leader_ex + "\"";
			item += ", Members:\"" + WebChar.toJson(rs_Members) + "\"";
		return item;
	}

	String hint = "", attach = "";
	attach += " RS_ID='" + rs_ID + "'";
	item = rs_GroupName;
	attach += " RS_Members='" + rs_Members + "'";
	if (item.toLowerCase().equals("[hidden]"))
		return "";
	return "item:\"" + item + "\", title:\"" + hint + "\"";
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
		seekrun.jout.print("<TD node=GroupName onclick=SetOrder(this) bTotal=0>" + "工作组名称" + "</TD>");
		seekrun.jout.print("</TR>");
	}
	if (TotalRec == 0)
	{
		seekrun.jout.print("<tr><td style=color:#cccccc;border:none;padding-top:5px;padding-left:20px; clospan=0>当前视图没有数据</td><tr id=SeekTailTR><td></td></tr></table></DIV>");
	}
	else
	{
		int x = 0;
		while (rs.next())
		{
				String rs_ID = seekrun.jdb.getRSString(0, rs, 1);
				String rs_GroupNo = seekrun.jdb.getRSString(0, rs, 2);
				String rs_GroupName = seekrun.jdb.getRSString(0, rs, 3);
				String rs_nLevel = seekrun.jdb.getRSString(0, rs, 4);
				String rs_Status = seekrun.jdb.getRSString(0, rs, 5);
				String rs_Leader = seekrun.jdb.getRSString(0, rs, 6);
				String rs_Members = seekrun.jdb.getRSString(0, rs, 7);
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
				attach += " RS_ID='" + value + "'";

				value0 = WebChar.isString(rs_GroupName);
				value = value0;
		value = "[" + rs_GroupName + "]";
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD" + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_Members);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				attach += " RS_Members='" + value + "'";

				tr1 = "<TR onclick=\"SelObject(this)\" oncontextmenu='ExSeekFunction(this);return false;'" + id + " title='" + hint + "' style='background-color:" + bkcolor + ";color:" + color + "'" + attach + ">" + tr1 + "</tr>";
				if (!tr2.equals(""))
					tr2 = "<TR id=Detail bgcolor=white style=display:none><TD colSpan=1>" + tr2 + "</td></tr>";
				seekrun.jout.print(tr1 + tr2);
			}
		}
		seekrun.jdb.rsClose(0, rs);
		seekrun.jout.print("<tr id=SeekTailTR><td></td></tr>");
		seekrun.jout.print("</table>");
		seekrun.jout.print("</DIV>");
		seekrun.jout.print(seekrun.PagesFoot(TotalRec, WebChar.AppendURLParam(href, "SeekKey=" + SeekKey + "&SeekParam=" + SeekParam.replace('%','*') + "&ViewMode=" + ViewMode + "&OrderField=" + OrderField + "&bDesc=" + bDesc), nPageSize, nPage, 0));
	}
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
String rs_GroupNo = aTreeDB[1][x];
String rs_GroupName = aTreeDB[2][x];
String rs_nLevel = aTreeDB[3][x];
String rs_Status = aTreeDB[4][x];
String rs_Leader = aTreeDB[5][x];
String rs_Members = aTreeDB[6][x];
	if (bDiv == 1)
		div = "div";
	else
		div = "span";
	String id = "P_" + aTreeDB[nItem][x];
	value = seekrun.ConvertFieldValue("", rs_ID, 1);
	node = rs_ID;
	attach += " RS_ID='" + value + "'";
	value = seekrun.ConvertFieldValue("", rs_GroupNo, 1);
	value = seekrun.ConvertFieldValue("", rs_GroupName, 1);
		value = "[" + rs_GroupName + "]";
	item = value;
	value = seekrun.ConvertFieldValue("@UserLevel", rs_nLevel, 1);
	value = seekrun.ConvertFieldValue("@GroupState", rs_Status, 1);
	value = seekrun.ConvertFieldValue("Member.CName", rs_Leader, 1);
	value = seekrun.ConvertFieldValue("", rs_Members, 1);
	attach += " RS_Members='" + value + "'";
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
	return "<" + div + " id='" + id + "' onclick=\"SelObject(this)\" node='" + node + "' " + prop +
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
		ViewMode = 2;
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

public String RunComplexSeek(SeekRun seekrun) throws Exception
{
	int DeleteID = WebChar.RequestInt(seekrun.jreq, "DeleteID");
	if (DeleteID > 0)
	{
		String sql = "delete from UDBCabinet where srcName='WorkGroup_list_select' and ID=" + DeleteID;
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	String Title = WebChar.requestStr(seekrun.jreq, "Title");
	if (!Title.equals(""))
	{
		String Content = WebChar.unApostrophe(WebChar.requestStr(seekrun.jreq, "Content"));
		String sql = "insert into UDBCabinet(nType, srcName, Title, SubmitMan, SubmitTime, Content) values(1,'WorkGroup_list_select','" + Title + "','" + seekrun.user.CMemberName + "','" + VB.Now() + "','" + Content + "')";
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
	seekrun.jout.print("<option value=WorkGroup.ID node=5 quote=''>" + "自动编号" + "</option>");
	seekrun.jout.print("</select><td><select id=ChoiceSel><option value=1>等于</option><option value=2>不等于</option>" + 
		"<option value=3>大于</option><option value=4>小于</option><option value=5>大于等于</option>" + 
		"<option value=6>小于等于</option><option value=7>左包含</option><option value=8>右包含</option>" + 
		"<option value=9>全包含</option></select></td><TD bgcolor=white><span style='border:1px solid #7b9ebd;height:20px;overflow:hidden;width:130px;'>" + 
		"<input name=Content type=text FieldType=5 onkeydown=PressKey(this) style=border:none;height:20px;width=110px;>" + 
		"<img id=ComboImg onclick=SelectFilterCombo(this) src=../com/pic/combo.jpg onmouseover=this.src='../com/pic/combo1.jpg' onmouseout=this.src='../com/pic/combo.jpg'></span></td>" + 
		"<td><select id=ConnectSel><option value=and>并且</option><option value=or>或者</option></select></td>" + 
		"</tr></table><table><tr><td id=ContentTitleTD colspan=2>已添加的查询条件:</td><tr><td><tr><td>" + 
		"<div id=SelectedDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray\">" + 
		"<table id=SelectedList width=400 border=0 style=table-layout:fixed></table></div>" +
		"<div id=LoadCatalogDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray;display:none;padding:4px;\">");
	String sql = "select ID, Title, Content from UDBCabinet where nType=1 and srcName='WorkGroup_list_select'";
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
	seekrun.strTable = "WorkGroup";
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
	seekrun.enums = new HashMap<String, String[][]>();
	seekrun.enums.put("UserLevel", webenum.GetEnumResult("UserLevel"));
	seekrun.enums.put("GroupState", webenum.GetEnumResult("GroupState"));
	String Filters = "";
	if (ViewMode == 0)
		ViewMode = 2;
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
			String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:8, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:1}," +
		"{FieldName:\"GroupNo\", TitleName:\"工作组编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"GroupName\", TitleName:\"工作组名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"nLevel\", TitleName:\"级别\", nWidth:0, nShowMode:6, Quote:\"@UserLevel\", FieldType:3}," +
		"{FieldName:\"Status\", TitleName:\"状态\", nWidth:0, nShowMode:6, Quote:\"@GroupState\", FieldType:3}," +
		"{FieldName:\"Leader\", TitleName:\"负责人\", nWidth:0, nShowMode:6, Quote:\"Member.CName\", FieldType:1}," +
		"{FieldName:\"Members\", TitleName:\"成员\", nWidth:0, nShowMode:8, Quote:\"\", FieldType:2}]";
			out.print(", head:" + viewhead + ",TableName:\"WorkGroup\", TableCName:\"工作组\", EditForm:\"\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\"}");
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
		out.print("[{TableName:\"WorkGroup\", TableCName:\"工作组\", Fields:\"ID,GroupName,Members\"},{FieldName:\"ID\",ShowName:\"自动编号\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"GroupName\",ShowName:\"工作组名称\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:1, QuoteTable:\"\"},{FieldName:\"bAdmin\",ShowName:\"管理员\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"nLevel\",ShowName:\"级别\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"@UserLevel\"},{FieldName:\"Status\",ShowName:\"状态\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"@GroupState\"},{FieldName:\"Leader\",ShowName:\"负责人\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"Member.CName\"},{FieldName:\"Members\",ShowName:\"成员\",FieldType:2, FieldLen:536870910,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"GroupNo\",ShowName:\"工作组编号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:1, QuoteTable:\"\"},{FieldName:\"KMSize\",ShowName:\"文档最大容量\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"MailSize\",ShowName:\"邮箱最大容量\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"ParentId\",ShowName:\"上层节点\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"WorkGroup.ID,GroupName\"},{FieldName:\"OrderNo\",ShowName:\"顺序号\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"ID\", TitleName:\"自动编号\", nWidth:0, nShowMode:8, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:1}," +
		"{FieldName:\"GroupNo\", TitleName:\"工作组编号\", nWidth:0, nShowMode:6, Quote:\"\", FieldType:3}," +
		"{FieldName:\"GroupName\", TitleName:\"工作组名称\", nWidth:0, nShowMode:1, bTag:1, Quote:\"\", FieldType:1}," +
		"{FieldName:\"nLevel\", TitleName:\"级别\", nWidth:0, nShowMode:6, Quote:\"@UserLevel\", FieldType:3}," +
		"{FieldName:\"Status\", TitleName:\"状态\", nWidth:0, nShowMode:6, Quote:\"@GroupState\", FieldType:3}," +
		"{FieldName:\"Leader\", TitleName:\"负责人\", nWidth:0, nShowMode:6, Quote:\"Member.CName\", FieldType:1}," +
		"{FieldName:\"Members\", TitleName:\"成员\", nWidth:0, nShowMode:8, Quote:\"\", FieldType:2}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("权限分组列表", "<link rel='stylesheet' type='text/css' href='../forum.css'>\n<style>\n#SeekTable\n{\n	border-right:		0px solid #cccccc;\n	border-bottom:		0px solid #cccccc;\n}\n\n#SeekTable TR\n{\n	border-top:		0px solid gray;\n}\n\n#SeekTable TR TD\n{\n	border-left:		0px solid #cccccc;\n	border-bottom:		0px solid #cccccc;\n}\n#TableDoc{border:	none;overflow-x:hidden;overflow-y:auto;}\n\n</style>\n") + "\n" +
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
		title = null;
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
		UserDblClick(obj);
}

function UserDblClick(obj)
{ 
//@@##1077:双击操作脚本-DblClick(归档用注释,切勿删改)
try {
    parent.AppendMembers();
} catch(e){}
//(归档用注释,切勿删改)UserDblClick End##@@
}
var href ="<%=href%>";
var SeekKey = "<%=SeekKey%>";
var SeekParam = "<%=SeekParam.replace('%', '*')%>";
var OrderField = "<%=OrderField%>";
var bDesc = <%=bDesc%>;
var ClassName = "";
var ActionID = 449;
var ViewMode = <%=ViewMode%>;
var TableDefID = 256;
var PrepID = 0;
var FormAction="EditWorkGroup.jsp";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>