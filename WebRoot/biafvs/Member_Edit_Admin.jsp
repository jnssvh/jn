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
	result = WebChar.joinStr(result, seekrun.FindEnumValue("MemberStatus", SeekParam, 1), ",");
	result = WebChar.joinStr(result, seekrun.FindEnumValue("Gender", SeekParam, 1), ",");
	if (!Filters.equals(""))
		Condition = " where (" + Filters + ") and ";
	else
		Condition = " where ";
	String [] sqls = new String [12];
	String [] fields = {"EName","CName","Dept","Duty","Status","SerialNo","NickName","Man","EMail","ID"};
	sqls[0] = seekrun.jdb.SQLSelectEx(0, nSize, "CName", "Member", Condition + "(pym like '" + SeekParam + "%')", "distinct", "");
	sqls[1] = seekrun.jdb.SQLSelectEx(0, nSize, "Dept.DeptName", "Member left join Dept on Member.Dept=Dept.DeptNo", Condition + "( + Dept.DeptName like '%" + SeekParam + "%')", "distinct", "");
	for (int x = 0; x < fields.length; x++)
		sqls[x + 2] = seekrun.jdb.SQLSelectEx(0, nSize, fields[x], "Member", Condition + "(" + fields[x] + " like '%" + SeekParam + "%')", "distinct", "");
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
		Condition = "Member.EName like '%" + SeekParam + 
			"%' or Member.CName like '%" + SeekParam + 
			"%' or Member.Dept like '%" + SeekParam + 
			"%' or Member.Duty like '%" + SeekParam + 
			"%' or Member.Status like '%" + SeekParam + 
			"%' or Member.SerialNo like '%" + SeekParam + 
			"%' or Member.NickName like '%" + SeekParam + 
			"%' or Member.Man like '%" + SeekParam + 
			"%' or Member.EMail like '%" + SeekParam + 
			"%' or Member.ID like '%" + SeekParam + 
			"%' or Dept.DeptName like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.FindEnumValue("MemberStatus", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or Member.Status in (" + ss + ")";
		ss = seekrun.FindEnumValue("Gender", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or Member.Man in (" + ss + ")";
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
			sss[x] = "Member." + sss[x];
			if (order == null)
				order = " order by " + sss[x];
			else
				order += "," + sss[x];
		}
		order +=  WebChar.isString(" desc", bDesc == 1);
	}
	else
		order = " order by   Status,Dept,Member.CName";
	String fields = "Member.EName,Member.CName,Member.Dept,Member.Duty,Member.Status,Member.SerialNo,Member.NickName,Member.Man,Member.EMail,Member.ID";
	id = "Member.ID";
	if ((!order.equals("")) && (order.toLowerCase().indexOf(id.toLowerCase()) < 0))
		order = order + "," + id;
	seekrun.TotalRec = seekrun.jdb.count(0, "Member left join Dept on Member.Dept=Dept.DeptNo", Condition);
	String RefFields = ",Dept.DeptName as DeptName_2";
	if (nPage < 1)
		nPage = 1;
	if ((nPage - 1) * nPageSize > seekrun.TotalRec)
		nPage = (seekrun.TotalRec  - nPageSize - 1) / nPageSize;
	sql = seekrun.jdb.SQLSelectPage(0, nPage, nPageSize, fields + RefFields, "Member left join Dept on Member.Dept=Dept.DeptNo", Condition, group, order, id);
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
		String rs_EName = WebChar.isString(jdb.getRSString(0, rs, 1));
		String rs_CName = WebChar.isString(jdb.getRSString(0, rs, 2));
		String rs_Dept = WebChar.isString(jdb.getRSString(0, rs, 3));
		String rs_Duty = WebChar.isString(jdb.getRSString(0, rs, 4));
		String rs_Status = WebChar.isString(jdb.getRSString(0, rs, 5));
		String rs_SerialNo = WebChar.isString(jdb.getRSString(0, rs, 6));
		String rs_NickName = WebChar.isString(jdb.getRSString(0, rs, 7));
		String rs_Man = WebChar.isString(jdb.getRSString(0, rs, 8));
		String rs_EMail = WebChar.isString(jdb.getRSString(0, rs, 9));
		String rs_ID = WebChar.isString(jdb.getRSString(0, rs, 10));
		jout.print("EName:\"" + WebChar.toJson(rs_EName) + "\"");
		jout.print(", CName:\"" + WebChar.toJson(rs_CName) + "\"");
		String rs_CName_ex = WebChar.toJson(seekrun.ConvertFieldValue("&pym:pym", rs_CName, 0));
		jout.print(", CName_ex:\"" + rs_CName_ex + "\"");
		jout.print(", Dept:\"" + rs_Dept + "\"");
		String rs_Dept_ex = WebChar.toJson(seekrun.jdb.getRSString(0, rs, 11));
		jout.print(", Dept_ex:\"" + rs_Dept_ex + "\"");
		jout.print(", Duty:\"" + WebChar.toJson(rs_Duty) + "\"");
		jout.print(", Status:\"" + rs_Status + "\"");
		String rs_Status_ex = WebChar.toJson(webenum.GetEnumResultItem(seekrun.enums.get("MemberStatus"), rs_Status, 0));
		jout.print(", Status_ex:\"" + rs_Status_ex + "\"");
		jout.print(", SerialNo:\"" + rs_SerialNo + "\"");
		jout.print(", NickName:\"" + WebChar.toJson(rs_NickName) + "\"");
		jout.print(", Man:\"" + rs_Man + "\"");
		String rs_Man_ex = WebChar.toJson(webenum.GetEnumResultItem(seekrun.enums.get("Gender"), rs_Man, 0));
		jout.print(", Man_ex:\"" + rs_Man_ex + "\"");
		jout.print(", EMail:\"" + WebChar.toJson(rs_EMail) + "\"");
		jout.print(", ID:\"" + rs_ID + "\"");
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
		seekrun.jout.print("<TD width=20><input type=checkbox style=width:18px;height:12px onclick=SelectAllItem(this)></TD>");
		seekrun.jout.print("<TD node=EName nowrap  width=112 onclick=SetOrder(this) bTotal=0>" + "��¼��" + "</TD>");
		seekrun.jout.print("<TD node=CName nowrap  width=91 onclick=SetOrder(this) bTotal=0>" + "����" + "</TD>");
		seekrun.jout.print("<TD node=Dept nowrap  width=231 onclick=SetOrder(this) bTotal=0>" + "����" + "</TD>");
		seekrun.jout.print("<TD node=Duty nowrap  width=165 onclick=SetOrder(this) bTotal=0>" + "ְ��" + "</TD>");
		seekrun.jout.print("<TD node=Status nowrap  width=49 onclick=SetOrder(this) bTotal=0>" + "״̬" + "</TD>");
		seekrun.jout.print("</TR>");
	}
	if (TotalRec == 0)
	{
		seekrun.jout.print("<tr><td style=color:#cccccc;border:none;padding-top:5px;padding-left:20px; clospan=5>��ǰ��ͼû������</td><tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td><td></td></tr></table></DIV>");
	}
	else
	{
		int x = 0;
		while (rs.next())
		{
				String rs_EName = seekrun.jdb.getRSString(0, rs, 1);
				String rs_CName = seekrun.jdb.getRSString(0, rs, 2);
				String rs_Dept = seekrun.jdb.getRSString(0, rs, 3);
				String rs_Duty = seekrun.jdb.getRSString(0, rs, 4);
				String rs_Status = seekrun.jdb.getRSString(0, rs, 5);
				String rs_SerialNo = seekrun.jdb.getRSString(0, rs, 6);
				String rs_NickName = seekrun.jdb.getRSString(0, rs, 7);
				String rs_Man = seekrun.jdb.getRSString(0, rs, 8);
				String rs_EMail = seekrun.jdb.getRSString(0, rs, 9);
				String rs_ID = seekrun.jdb.getRSString(0, rs, 10);
			if ((ViewMode % 100) == 1)
			{
				x ++;
				String str[] = {"#ffffff","#eeeeee"};
				bkcolor = str[x % 2];
				color = "black";
				tr1 = "";
				tr2 = "";
				hint = "";
				attach = "";
				value0 = WebChar.isString(rs_EName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_CName);
				value = seekrun.ConvertFieldValue("&pym:pym", value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_Dept);
				value = WebChar.isString(seekrun.jdb.getRSString(0, rs, 11));
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_Duty);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_Status);
				value = webenum.GetEnumResultItem(seekrun.enums.get("MemberStatus"), value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				tr1 += "<TD nowrap " + node + ">" + value + "</TD>";

				value0 = WebChar.isString(rs_SerialNo);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "Ա�����" + ":" + value + "\n";

				value0 = WebChar.isString(rs_NickName);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "�ǳ�" + ":" + value + "\n";

				value0 = WebChar.isString(rs_Man);
				value = webenum.GetEnumResultItem(seekrun.enums.get("Gender"), value0, 0);
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "�Ա�" + ":" + value + "\n";

				value0 = WebChar.isString(rs_EMail);
				value = value0;
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";
				hint += "����" + ":" + value + "\n";

				value0 = WebChar.isString(rs_ID);
				value = value0;
				id = " node='" + WebChar.isString(rs_ID) + "'";
				if (value0 == null || value0.equals(value))
					node = "";
				else
					node = " node='" + value0 + "'";

				tr1 = "<td><input name=SelectLineTD type=checkbox style=width:18px;height:12px></td>" + tr1;
				tr1 = "<TR onclick=\"SelObject(this)\" oncontextmenu='ExSeekFunction(this);return false;'" + id + " title='" + hint + "' style='background-color:" + bkcolor + ";color:" + color + "'" + attach + ">" + tr1 + "</tr>";
				if (!tr2.equals(""))
					tr2 = "<TR id=Detail bgcolor=white style=display:none><TD colSpan=6>" + tr2 + "</td></tr>";
				seekrun.jout.print(tr1 + tr2);
			}
		}
		seekrun.jdb.rsClose(0, rs);
		seekrun.jout.print("<tr id=SeekTailTR><td></td><td></td><td></td><td></td><td></td><td></td></tr>");
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
int nItem;
	nItem = 1;
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
		Condition ="Member.EName like '%" + SeekParam + 
			"%' or Member.CName like '%" + SeekParam + 
			"%' or Member.Dept like '%" + SeekParam + 
			"%' or Member.Duty like '%" + SeekParam + 
			"%' or Member.Status like '%" + SeekParam + 
			"%' or Member.SerialNo like '%" + SeekParam + 
			"%' or Member.NickName like '%" + SeekParam + 
			"%' or Member.Man like '%" + SeekParam + 
			"%' or Member.EMail like '%" + SeekParam + 
			"%' or Member.ID like '%" + SeekParam + 
			"%' or Dept.DeptName like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.FindEnumValue("MemberStatus", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or Status in (" + ss + ")";
		ss = seekrun.FindEnumValue("Gender", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or Man in (" + ss + ")";
	}
	else
	{
		if (SeekKey.equals("$LoadSeek$"))
			Condition = seekrun.LoadSeekCondition(SeekParam, seekrun.strTable, 0);
		else
		{
			if (!SeekKey.equals("Leader"))
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
	seekrun.jout.print("<DIV id=TableDoc oncontextmenu='return ExSeekFunction(this);' ondblclick=DblClickSeekTable(this) style='height:400;'>");
	seekrun.jout.print("<IFRAME id=TableTreeSubDataFrame style=display:none;width:100%;height:200;></IFRAME>");
	switch (ViewMode)
	{
	case 2:
		RunTableTree(seekrun, ParentItem, Condition, 0, 2, nItem);
		break;
	case 3:
		RunTableArbor(seekrun, ParentItem, Condition, 0, 2, nItem);
		break;
	case 4:
		RunTableHArbor(seekrun, ParentItem, Condition, 0, 2, nItem);
		break;
	}
	seekrun.jout.print("</div>");
	return "";
}

public String[][] GetJSPTableTreeDB(SeekRun seekrun, String ParentItem, String Filter)
{
String sql, f, Parent;
	if (!Filter.equals(""))
		f = " and (" + Filter + ")";
	else
		f = "";
	if (ParentItem.equals(""))
		Parent = "(Member.Leader='' or Member.Leader is null)";
	else
		Parent = "Member.Leader='" + ParentItem + "'";
	sql = "select Member.EName,Member.CName,Member.Dept,Member.Duty,Member.Status,Member.SerialNo,Member.NickName,Member.Man,Member.EMail,Member.ID,Dept.DeptName as DeptName_2 from Member left join Dept on Member.Dept=Dept.DeptNo where " + Parent + f + " order by   Status,Dept,Member.CName";
	ResultSet rs = seekrun.jdb.rsSQL(0, sql);
	String[][] rsArray = seekrun.jdb.getRSData(rs, 1, 1000);
	seekrun.jdb.rsClose(0, rs);
	return rsArray;
}

public String GetJSPTableTreeItem(SeekRun seekrun, int x, String[][] aTreeDB, int Depth, String img, int nItem, int bDiv, String prop)
{
String div, value, item, hint = "", node="", attach = "";
	JspWriter jout = seekrun.jout;
	JDatabase jdb = seekrun.jdb;
	WebUser user = seekrun.user;
	WebEnum webenum = seekrun.we;
	HttpServletRequest jreq = seekrun.jreq, request = seekrun.jreq;
String rs_EName = aTreeDB[0][x];
String rs_CName = aTreeDB[1][x];
String rs_Dept = aTreeDB[2][x];
String rs_Duty = aTreeDB[3][x];
String rs_Status = aTreeDB[4][x];
String rs_SerialNo = aTreeDB[5][x];
String rs_NickName = aTreeDB[6][x];
String rs_Man = aTreeDB[7][x];
String rs_EMail = aTreeDB[8][x];
String rs_ID = aTreeDB[9][x];
	if (bDiv == 1)
		div = "div";
	else
		div = "span";
	String id = "P_" + aTreeDB[nItem][x];
		item = WebChar.GetStringIndex(Math.abs(VB.CInt(rs_Man)), "<img src=pic/woman.gif>,<img src=pic/man.gif>") + " " + rs_CName;
	value = seekrun.ConvertFieldValue("", rs_EName, 1);
	hint += "��¼��" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("&pym:pym", rs_CName, 1);
	item = value;
	value = seekrun.ConvertFieldValue("Dept.DeptNo,DeptName", rs_Dept, 1);
	hint += "����" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_Duty, 1);
	hint += "ְ��" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("@MemberStatus", rs_Status, 1);
	hint += "״̬" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_SerialNo, 1);
	hint += "Ա�����" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_NickName, 1);
	hint += "�ǳ�" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("@Gender", rs_Man, 1);
	hint += "�Ա�" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_EMail, 1);
	hint += "����" + ":" + value + "\n";
	value = seekrun.ConvertFieldValue("", rs_ID, 1);
	node = rs_ID;
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

public String RunTableTree(SeekRun seekrun, String ParentItem, String Filter, int Depth, int MaxDepth, int nItem) throws Exception
{
	String img;
	String[][] aTreeDB;
	int x;
	aTreeDB = GetJSPTableTreeDB(seekrun, ParentItem, Filter);
	if (aTreeDB == null)
	return "";
	for (x = 0; x < aTreeDB[0].length; x++)
	{
		if (MaxDepth > Depth + 1)
			img = "<img id=BtExTree src=../com/pic/minus.gif s1=../com/pic/plus.gif s2=../com/pic/minus.gif onclick=ExpandTableTree(this) value=1 ready=1 title=չ���ӹ��� style=cursor:hand>&nbsp;";
		else
			img = "<img id=BtExTree src=../com/pic/plus.gif s1=../com/pic/plus.gif s2=../com/pic/minus.gif onclick=ExpandTableTree(this) value=1 ready=0 title=չ���ӹ���... style=cursor:hand>&nbsp;";
		seekrun.jout.print(GetJSPTableTreeItem(seekrun, x, aTreeDB, Depth, img, nItem, 1, ""));
		if (MaxDepth > Depth + 1)
		{
			seekrun.jout.print("<div style=display:inline;>");
			RunTableTree(seekrun, aTreeDB[nItem][x], Filter, Depth + 1, MaxDepth, nItem);
			seekrun.jout.print("</div>");
		}
	}
	return "";
}

public String RunTableArbor(SeekRun seekrun, String ParentItem, String Filter, int Depth, int MaxDepth, int nItem) throws Exception
{
	String[][] aTreeDB;
	int x = 0;
	String img, tabchar;
	aTreeDB = GetJSPTableTreeDB(seekrun, ParentItem, Filter);
	if (aTreeDB == null)
		return "";
	for (x = 0; x < aTreeDB[0].length; x++)
	{
		if (aTreeDB[0].length == 1)
			tabchar = "<SPAN id=TRLine>���� </SPAN>";
		else
		{
			if (x == 0)
				tabchar = "<SPAN id=TRLine>���� </SPAN>";
			else
			{
				if (x == aTreeDB[0].length - 1)
					tabchar = "<SPAN id=TRLine>���� </SPAN>";
				else
					tabchar = "<SPAN id=TRLine>���� </SPAN>";
			}
		}
		seekrun.jout.print("<TABLE cellSpacing=0 cellPadding=0 border=0><TR><TD NOWRAP node='" + aTreeDB[nItem][x] +
			"'><SPAN id=TRItem>");
		seekrun.jout.print(tabchar);
		if (MaxDepth > Depth + 1)
			img = "<img id=BtExTree src=../com/pic/minus.gif onclick=ExpandArbor(this) value=1 ready=1 title=չ���ӹ��� style=cursor:hand>";
		else
			img = "<img id=BtExTree src=../com/pic/plus.gif onclick=ExpandArbor(this) value=1 ready=0 title=չ���ӹ���... style=cursor:hand>";
		seekrun.jout.print(GetJSPTableTreeItem(seekrun, x, aTreeDB, 0, img, nItem, 0, ""));
		seekrun.jout.print("&nbsp;</SPAN></TD>");
		if (MaxDepth > Depth + 1)
		{
			seekrun.jout.print("<TD NOWRAP>");
			RunTableArbor(seekrun, aTreeDB[nItem][x], Filter, Depth + 1, MaxDepth, nItem);
			seekrun.jout.print("</TD>");
		}
		seekrun.jout.print("</TR></TABLE>");
	}
	return "";
}

public String RunTableHArbor(SeekRun seekrun, String ParentItem, String Filter, int Depth, int MaxDepth, int nItem) throws Exception
{
	int x = 0;
	String img, tabchar;
	String[][] aTreeDB;
	aTreeDB = GetJSPTableTreeDB(seekrun, ParentItem, Filter);
	seekrun.jout.print("<BR><TABLE cellSpacing=0 cellPadding=0 border=0><TR>");
	if (aTreeDB == null)
		return "";
	for (x = 0; x < aTreeDB[0].length; x++)
	{
		if (aTreeDB[0].length == 1)
			tabchar = "<SPAN id=HTRLine value=0>��</SPAN>";
		else
		{
			if (x == 0)
				tabchar = "<SPAN id=HTRLine value=1>��</SPAN>";
			else
			{
				if (x == aTreeDB[0].length - 1)
					tabchar = "<SPAN id=HTRLine value=2>��</SPAN>";
				else
					tabchar = "<SPAN id=HTRLine value=3>��</SPAN>";
			}
		}
		seekrun.jout.print("<TD align=center valign=top node='" + aTreeDB[nItem][x] + "'>" +
			"<SPAN id=HTRItem>" + tabchar + "<BR>");
		img = "<img src=../com/pic/minus.gif style=cursor:hand; title=չ�� onclick=ExpandHArbor(this) value=1>";
		seekrun.jout.print(GetJSPTableTreeItem(seekrun, x, aTreeDB, 0, img, nItem, 0, ""));
		seekrun.jout.print("&nbsp;</SPAN>");
		RunTableHArbor(seekrun, aTreeDB[nItem][x], Filter, Depth + 1, MaxDepth, nItem);
		seekrun.jout.print("</TD>");
	}
	seekrun.jout.print("</TR></TABLE>");
	return "";
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
	nItem = 1;
	if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
	{
		String other = "";
		String [] sss = SeekParam.split("\\|\\|");
		if (sss.length > 1)
		{
			SeekParam = sss[0];
			other = sss[1];
		}
		Condition ="Member.EName like '%" + SeekParam + 
			"%' or Member.CName like '%" + SeekParam + 
			"%' or Member.Dept like '%" + SeekParam + 
			"%' or Member.Duty like '%" + SeekParam + 
			"%' or Member.Status like '%" + SeekParam + 
			"%' or Member.SerialNo like '%" + SeekParam + 
			"%' or Member.NickName like '%" + SeekParam + 
			"%' or Member.Man like '%" + SeekParam + 
			"%' or Member.EMail like '%" + SeekParam + 
			"%' or Member.ID like '%" + SeekParam + 
			"%' or Dept.DeptName like '%" + SeekParam + 
			"%'" + other;
		ss = seekrun.FindEnumValue("MemberStatus", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or Status in (" + ss + ")";
		ss = seekrun.FindEnumValue("Gender", SeekParam, 0);
		if (!ss.equals(""))
			Condition += " or Man in (" + ss + ")";
	}
	else
	{
		if (SeekKey.equals("$LoadSeek$"))
			Condition = seekrun.LoadSeekCondition(SeekParam, seekrun.strTable, 0);
		else
			Condition = seekrun.GetSeekCondition(SeekKey, SeekParam, seekrun.strTable, 0);
	}
	if (!Condition.equals(""))
		Condition = "(" + Condition + ")";
	if (!Filters.equals("") && !Condition.equals(""))
		Condition = Filters + " and " + Condition;
	else
	{
		if (!Filters.equals("") || !Condition.equals(""))
			Condition = Filters + Condition;
	}
	switch(ViewMode)
	{
	case 2:
	case 5:
		str = RunTableTree(seekrun, ParentNode, Condition, nDepth, nDepth + 2, nItem);
		break;
	case 3:
		str = RunTableArbor(seekrun, ParentNode, Condition, nDepth, nDepth + 2, nItem);
		break;
	case 4:
		str = RunTableHArbor(seekrun, ParentNode, Condition, nDepth, nDepth + 2, nItem);
		break;
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
	case 1:			//ɾ��
		sql = "delete from " + seekrun.strTable + " where ID in (" + BatchValue + ")";
		result = seekrun.jdb.ExecuteSQL(0, sql);
	 	SystemLog.setLog(seekrun.jdb, seekrun.user, seekrun.jreq, "6", "", seekrun.strTable, "");
		break;
	case 2:			//�޸�
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
	case 3:			//���ƺ��޸�
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
	case 5:			//�Զ���ɾ��
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
		String sql = "delete from UDBCabinet where srcName='Member_Edit_Admin' and ID=" + DeleteID;
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	String Title = WebChar.requestStr(seekrun.jreq, "Title");
	if (!Title.equals(""))
	{
		String Content = WebChar.unApostrophe(WebChar.requestStr(seekrun.jreq, "Content"));
		String sql = "insert into UDBCabinet(nType, srcName, Title, SubmitMan, SubmitTime, Content) values(1,'Member_Edit_Admin','" + Title + "','" + seekrun.user.CMemberName + "','" + VB.Now() + "','" + Content + "')";
		seekrun.jdb.ExecuteSQL(0, sql);
		seekrun.jout.print("OK");
		return "OK";
	}
	seekrun.jout.print(WebFace.GetHTMLHead("���ϲ�ѯѡ��", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<body alink=#333333 vlink=#333333 link=#333333 topmargin=0 leftmargin=0>");
	seekrun.jout.print("<div id=ContentDiv style=padding:8px>" + 
		"<table id=FilterTable cellpadding=0 cellspacing=0 border=0>" + 
		"<tr bgcolor=white><td width=150>�ֶ�</td><td width=40>����</td><TD width=100>����</td><td width=40>����</td>" + 
		"<td bgcolor=white rowspan=2>&nbsp;<input type=button onclick=InsertCondition() value=���></td>" + 
		"</tr><tr height=25px bgcolor=white><td><select id=FieldsSel style=width:150px; onchange=SelectFilterField(this)>");
	seekrun.jout.print("<option value=Member.EName node=1 quote=''>" + "��¼��" + "</option>");
	seekrun.jout.print("<option value=Member.CName node=1 quote='&pym:pym'>" + "����" + "</option>");
	seekrun.jout.print("<option value=Member.Dept node=3 quote='Dept.DeptNo,DeptName'>" + "����" + "</option>");
	seekrun.jout.print("<option value=Member.Duty node=1 quote=''>" + "ְ��" + "</option>");
	seekrun.jout.print("<option value=Member.Leader node=1 quote='Member.CName,CName'>" + "����Ȩ�޷���" + "</option>");
	seekrun.jout.print("<option value=Member.Status node=3 quote='@MemberStatus'>" + "״̬" + "</option>");
	seekrun.jout.print("<option value=Member.SerialNo node=3 quote=''>" + "Ա�����" + "</option>");
	seekrun.jout.print("<option value=Member.Man node=3 quote='@Gender'>" + "�Ա�" + "</option>");
	seekrun.jout.print("<option value=Member.Phone node=1 quote=''>" + "�̶��绰" + "</option>");
	seekrun.jout.print("<option value=Member.Mobile node=1 quote=''>" + "�ƶ��绰" + "</option>");
	seekrun.jout.print("<option value=Member.MemberLevel node=1 quote=''>" + "����" + "</option>");
	seekrun.jout.print("<option value=Member.MemberRight node=3 quote='(11:��ʱ�û�,21:�����û�,31:�����û�)'>" + "Ȩ��" + "</option>");
	seekrun.jout.print("<option value=Member.IPAddress node=1 quote=''>" + "IP��ַ" + "</option>");
	seekrun.jout.print("<option value=Member.HomePhone node=1 quote=''>" + "��ͥ�绰" + "</option>");
	seekrun.jout.print("</select><td><select id=ChoiceSel><option value=1>����</option><option value=2>������</option>" + 
		"<option value=3>����</option><option value=4>С��</option><option value=5>���ڵ���</option>" + 
		"<option value=6>С�ڵ���</option><option value=7>�����</option><option value=8>�Ұ���</option>" + 
		"<option value=9>ȫ����</option></select></td><TD bgcolor=white><span style='border:1px solid #7b9ebd;height:20px;overflow:hidden;width:130px;'>" + 
		"<input name=Content type=text FieldType=1 onkeydown=PressKey(this) style=border:none;height:20px;width=110px;>" + 
		"<img id=ComboImg onclick=SelectFilterCombo(this) src=../com/pic/combo.jpg onmouseover=this.src='../com/pic/combo1.jpg' onmouseout=this.src='../com/pic/combo.jpg'></span></td>" + 
		"<td><select id=ConnectSel><option value=and>����</option><option value=or>����</option></select></td>" + 
		"</tr></table><table><tr><td id=ContentTitleTD colspan=2>����ӵĲ�ѯ����:</td><tr><td><tr><td>" + 
		"<div id=SelectedDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray\">" + 
		"<table id=SelectedList width=400 border=0 style=table-layout:fixed></table></div>" +
		"<div id=LoadCatalogDiv style=\"width:400px;height:200px;overflow-y:auto;border:1px solid gray;display:none;padding:4px;\">");
	String sql = "select ID, Title, Content from UDBCabinet where nType=1 and srcName='Member_Edit_Admin'";
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
		seekrun.jout.print("<input name=LoadButton type=button onclick=LoadCondition() value=����><br><br>" + 
			"<input name=SaveButton type=button disabled onclick=SaveCondition() value=����><br><br>");
	}
	seekrun.jout.print("<input name=DeleteButton type=button disabled onclick=DeleteCondition() value=ɾ��><br><br>" + 
		"<input name=SeekButton type=button onclick=ConfirmCondition() value=��ѯ><br><br>" + 
		"<input name=CancelButton type=button onclick=CalcelSel() value=ȡ��><br>" + 
		"</td></tr></table></div>" + 
		"<script language=javascript src=../com/psub.jsp></script>\n" +
		"<script language=javascript src=../com/Form.jsp></script>\n" +
		"<script language=javascript src=../com/seek.jsp></script>\n" +
		"<script language=javascript src=../com/common.js></script>\n" +
		"<script language=javascript>\n" +
		"window.onload = function()\n" +
		"{\n" +
		"	window.status = \"�������\";\n" + 
		"	SelectFilterField(document.getElementById(\"FieldsSel\"));\n" +
		"	if (parent.document.getElementById(\"InDlgTitle\") != null)\n" +
		"	{\n" + 
		"	if (parent.document.getElementById(\"InDlgTitle\").innerHTML == \"��������...\")\n" + 
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
// +++++++++������ȫ��ҳ���������뿪ʼ++++++++
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

// --------������ȫ��ҳ�������������--------
	seekrun.strTable = "Member";
	if (ModuleID > 0)
	{
		int ModuleNo = WebChar.ToInt(jdb.GetTableValue(0, "RightObject", "auth_no", "auth_id", "" + ModuleID));
		if (ModuleNo > 0)
		{
			if (user.isModuleEnable(ModuleNo) == false)
			{
				out.println("ҳ��û��Ȩ��");
				return;
			}
		}
	}
	seekrun.enums = new HashMap<String, String[][]>();
	seekrun.enums.put("MemberStatus", webenum.GetEnumResult("MemberStatus"));
	seekrun.enums.put("Gender", webenum.GetEnumResult("Gender"));
	String Filters = "MemberRight>20";
	if (ViewMode == 0)
		ViewMode = 1;
	seekrun.ViewMode = ViewMode;
	int nPageSize = 100;
	if (nPage == 0)
		nPage = 1;
//@@##732:��������������-ServerStartCode(�鵵��ע��,����ɾ��)
String type = WebChar.requestStr(request, "type");
if ( "ClearPassword".equals(type) ) {
    String userid = WebChar.requestStr(request, "userid");
    //��ʼ����
    String pwd = EUTPassWord.getDefaultPwd(jdb);
    String sql = "UPDATE Member SET sPassword='" + pwd + "' WHERE id IN (" + userid + ")";
    int count = jdb.ExecuteSQL(0, sql);
    userid = jdb.getValueBySql(0, "SELECT id,CName FROM Member WHERE  id IN (" + userid + ")");
    sysLog.setLog("5", "��ʼ���û�ID��" + userid + "��������Ϊ123456", "member", "");
    
    out.clear();
    out.print(count);
    jdb.closeDBCon();
    return;
}
//(�鵵��ע��,����ɾ��)ServerStartCode End##@@
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
			String viewhead = "[{FieldName:\"EName\", TitleName:\"��¼��\", nWidth:112, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"CName\", TitleName:\"����\", nWidth:91, nShowMode:1, bTag:1, Quote:\"&pym:pym\", FieldType:1, bPrimaryKey:0, bSeek:1, colstyle:\"font:normal normal bolder 12pt ΢���ź�\"}," +
		"{FieldName:\"Dept\", TitleName:\"����\", nWidth:231, nShowMode:1, bTag:0, Quote:\"Dept.DeptNo,DeptName\", FieldType:3, bPrimaryKey:0, bSeek:1, colstyle:\"font:normal normal bolder 12pt ����\"}," +
		"{FieldName:\"Duty\", TitleName:\"ְ��\", nWidth:165, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"Status\", TitleName:\"״̬\", nWidth:49, nShowMode:1, bTag:0, Quote:\"@MemberStatus\", FieldType:3, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"SerialNo\", TitleName:\"Ա�����\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"NickName\", TitleName:\"�ǳ�\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"Man\", TitleName:\"�Ա�\", nWidth:0, nShowMode:3, bTag:0, Quote:\"@Gender\", FieldType:3, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"EMail\", TitleName:\"����\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"ID\", TitleName:\"�Զ����\", nWidth:0, nShowMode:6, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}]";
			out.print(", head:" + viewhead + ",TableName:\"Member\", TableCName:\"Ա����\", EditForm:\"\", ViewForm:\"\", SeekForm:\"\", AllEditForm:\"\", ThumbNail:\"\"}");
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
		out.print("[{TableName:\"Member\", TableCName:\"Ա����\", Fields:\"EName,CName,Dept,Duty,Status,SerialNo,NickName,Man,EMail\"},{FieldName:\"ModifyTime\",ShowName:\"�޸�ʱ��\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"outerCode\",ShowName:\"ͬ������\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"pym\",ShowName:\"ƴ����\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"oaid\",ShowName:\"�û����\",FieldType:1, FieldLen:36,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"ICCardNo\",ShowName:\"IC����\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"AccNum\",ShowName:\"ʳ���û����\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"UserNation\",ShowName:\"����\",FieldType:1, FieldLen:10,bPrimaryKey:0, bUnique:0, QuoteTable:\"@SS_race\"},{FieldName:\"UserJobTitle\",ShowName:\"ְ������\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"UserName\",ShowName:\"����\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"nOrder\",ShowName:\"˳���\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"article_count\",ShowName:\"�ռ�������\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"WorkTime\",ShowName:\"�μӹ���ʱ��\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"Party\",ShowName:\"����\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"PartyTime\",ShowName:\"�뵳ʱ��\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"ID\",ShowName:\"�Զ����\",FieldType:5, FieldLen:4,bPrimaryKey:1, bUnique:1, QuoteTable:\"\"},{FieldName:\"SerialNo\",ShowName:\"Ա�����\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:1, QuoteTable:\"\"},{FieldName:\"EName\",ShowName:\"��¼��\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:1, QuoteTable:\"\"},{FieldName:\"CName\",ShowName:\"��ʾ����\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:1, QuoteTable:\"&pym:pym\"},{FieldName:\"Leader\",ShowName:\"�ϼ�\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"Member.CName,CName\"},{FieldName:\"Man\",ShowName:\"�Ա�\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"@Gender\"},{FieldName:\"Dept\",ShowName:\"����\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"Dept.DeptNo,DeptName\"},{FieldName:\"Duty\",ShowName:\"ְ��\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"MemberRight\",ShowName:\"Ȩ��\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(11:��ʱ�û�,21:�����û�,31:�����û�)\"},{FieldName:\"MemberLevel\",ShowName:\"����\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Status\",ShowName:\"״̬\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"@MemberStatus\"},{FieldName:\"Info\",ShowName:\"��Ҫ˵��\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"IPAddress\",ShowName:\"IP��ַ\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Phone\",ShowName:\"�̶��绰\",FieldType:1, FieldLen:120,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Mobile\",ShowName:\"�ƶ��绰\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"HomePhone\",ShowName:\"��ͥ�绰\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"EMail\",ShowName:\"����\",FieldType:1, FieldLen:120,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Birthday\",ShowName:\"����\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"EnterTime\",ShowName:\"��ְʱ��\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"LeaveTime\",ShowName:\"��ְʱ��\",FieldType:4, FieldLen:8,bPrimaryKey:0, bUnique:0, QuoteTable:\"&d:1\"},{FieldName:\"Culture\",ShowName:\"ѧ��\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Specialty\",ShowName:\"רҵ\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Native\",ShowName:\"����\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"College\",ShowName:\"��ҵԺУ\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Photo\",ShowName:\"��Ƭ\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"SelfResume\",ShowName:\"����\",FieldType:2, FieldLen:0,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Remark\",ShowName:\"����˵��\",FieldType:2, FieldLen:0,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"SPassword\",ShowName:\"��¼����\",FieldType:1, FieldLen:200,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"ClientBind\",ShowName:\"�ͻ��˰󶨷�ʽ\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"(0:δ��,1:������,2:IP��,3:����IP��,4:�ֻ���)\"},{FieldName:\"ClientInfo\",ShowName:\"�ͻ�����Ϣ\",FieldType:1, FieldLen:200,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"NickName\",ShowName:\"�ǳ�\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"IDCard\",ShowName:\"֤����\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"iosAPNsDeviceToken\",ShowName:\"ios�����豸��ʶ\",FieldType:1, FieldLen:250,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"MobileSessionID\",ShowName:\"�ֻ��˻ỰID\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"MobileDisabledPush\",ShowName:\"�ֻ���������\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"zkAttFingerprint\",ShowName:\"ָ��\",FieldType:1, FieldLen:4000,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"Direction\",ShowName:\"ȥ��\",FieldType:1, FieldLen:50,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"PcSessionID\",ShowName:\"Pc�˻ỰID\",FieldType:3, FieldLen:4,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"PlateNumber\",ShowName:\"���ƺ�\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"staff_establishing\",ShowName:\"��Ա����\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"},{FieldName:\"title_lever\",ShowName:\"ְ�Ƽ���\",FieldType:1, FieldLen:20,bPrimaryKey:0, bUnique:0, QuoteTable:\"\"}]");
		jdb.closeDBCon();
		return;
	}
	if (WebChar.RequestInt(request, "GetViewHead") > 0)
	{
		out.clear();
		String viewhead = "[{FieldName:\"EName\", TitleName:\"��¼��\", nWidth:112, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"CName\", TitleName:\"����\", nWidth:91, nShowMode:1, bTag:1, Quote:\"&pym:pym\", FieldType:1, bPrimaryKey:0, bSeek:1, colstyle:\"font:normal normal bolder 12pt ΢���ź�\"}," +
		"{FieldName:\"Dept\", TitleName:\"����\", nWidth:231, nShowMode:1, bTag:0, Quote:\"Dept.DeptNo,DeptName\", FieldType:3, bPrimaryKey:0, bSeek:1, colstyle:\"font:normal normal bolder 12pt ����\"}," +
		"{FieldName:\"Duty\", TitleName:\"ְ��\", nWidth:165, nShowMode:1, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"Status\", TitleName:\"״̬\", nWidth:49, nShowMode:1, bTag:0, Quote:\"@MemberStatus\", FieldType:3, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"SerialNo\", TitleName:\"Ա�����\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:3, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"NickName\", TitleName:\"�ǳ�\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"Man\", TitleName:\"�Ա�\", nWidth:0, nShowMode:3, bTag:0, Quote:\"@Gender\", FieldType:3, bPrimaryKey:0, bSeek:1}," +
		"{FieldName:\"EMail\", TitleName:\"����\", nWidth:0, nShowMode:3, bTag:0, Quote:\"\", FieldType:1, bPrimaryKey:0, bSeek:0}," +
		"{FieldName:\"ID\", TitleName:\"�Զ����\", nWidth:0, nShowMode:6, bTag:0, Quote:\"\", FieldType:5, bPrimaryKey:1, bSeek:0}]";
		out.print(viewhead);
		jdb.closeDBCon();
		return;
	}
	out.print(WebFace.GetHTMLHead("ά��Ա����", "<link rel='stylesheet' type='text/css' href='../forum.css'>") + "\n" +
		"<script language=javascript src=../com/psub.jsp></script>" + "\n" + 
		"<script language=javascript src=../com/common.js></script>" + "\n" + 
		"<script language=javascript src=../com/seek.jsp></script>" + "\n" +
		"<script language=javascript>\nnDefaultWinMode = 5;\n//FormFeatures = 'titlebar=0,toolbar=0,scrollbars=0,resizable=0,width=640,height=200,left=50,top=50';\n</script>" + "\n" + 
		"<script language=javascript src=../js/jaguar.js></script>" + "\n" + 
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
		title = "ȫ��";
	else
	{
		if (SeekKey.equals(""))
			title = "<FONT title='" + SeekParam + "'>" + "���ϲ�ѯ" + "</FONT>";
		else
		{
			if (SeekKey.equals("$WholeDoc$") || SeekKey.equals("$ClipSearch$"))
				title = "<FONT title='" + "�ؼ���" + "��" + SeekParam + "'>" + "ȫ�ļ���" + "</FONT>";
			else
				title = SeekKey + "=" + SeekParam;
		}
			if (SeekKey.equals("$LoadSeek$"))
		{
				title = "����������" + SeekParam;
		}
	}
	if (ViewMode < 100)
	{
	String submenu = "", exmenu1 = "", exmenu2 = "";
	if (MenuFilter == null)
	{
		if (DisableMenus.indexOf("|" + "��ѯ") < 0)
			sMenu = WebChar.joinStr(sMenu, "{item:\"" + "��ѯ" + "\", action:\"TableMenuComplexSeek()\"}", ",");
	}
	else
	{
		if (MenuFilter.matches("Enable:.*\\b��ѯ\\b.*"))
			sMenu = WebChar.joinStr(sMenu, "{item:\"" + "��ѯ" + "\", action:\"TableMenuComplexSeek()\"}", ",");
	}
	submenu = "";
	if (MenuFilter == null)
	{
		if (DisableMenus.indexOf("|" + "����") < 0)
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "����" + "\", img:\"\", action:SeekMenu_727}", ",");
	}
	else
	{
		if (MenuFilter.matches("Enable:.*\\b����\\b.*"))
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "����" + "\", img:\"\", action:SeekMenu_727}", ",");
	}
	submenu = "";
	if (MenuFilter == null)
	{
		if (DisableMenus.indexOf("|" + "�༭") < 0)
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "�༭" + "\", img:\"\", action:SeekMenu_729}", ",");
	}
	else
	{
		if (MenuFilter.matches("Enable:.*\\b�༭\\b.*"))
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "�༭" + "\", img:\"\", action:SeekMenu_729}", ",");
	}
	submenu = "";
	if (MenuFilter == null)
	{
		if (DisableMenus.indexOf("|" + "ɾ��") < 0)
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "ɾ��" + "\", img:\"\", action:SeekMenu_730}", ",");
	}
	else
	{
		if (MenuFilter.matches("Enable:.*\\bɾ��\\b.*"))
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "ɾ��" + "\", img:\"\", action:SeekMenu_730}", ",");
	}
	submenu = "";
	if (MenuFilter == null)
	{
		if (DisableMenus.indexOf("|" + "�������") < 0)
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "�������" + "\", img:\"\", action:SeekMenu_731}", ",");
	}
	else
	{
		if (MenuFilter.matches("Enable:.*\\b�������\\b.*"))
			exmenu1 = WebChar.joinStr(exmenu1, "{item:\"" + "�������" + "\", img:\"\", action:SeekMenu_731}", ",");
	}
	sMenu = WebChar.joinStr(exmenu2, sMenu, ",");
	sMenu = WebChar.joinStr(sMenu, exmenu1, ",");
	title = "\"<span>����<span style='font:normal small-caps normal 10pt webdings'>6</span></span><input type=text id=SearchInput>\"";
	out.print("<div id=SeekMenubar style='with:100%;height:24px;padding:2px;background:'>������...</div>");
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
//@@##728:ҳ������ű�-ClientLoad(�鵵��ע��,����ɾ��)
//alert(document.all.SearchInput.value);
//==�ڲ˵������һdiv��RPCɾ��ʱ��ʾ��
var divMsg=document.createElement("div");
divMsg.id="divRpcDelMsg";
divMsg.style.position="absolute";
divMsg.style.top="6px";
divMsg.style.left="260px";
divMsg.style.display="none";
divMsg.innerHTML="<span style='vertical-align:middle;'><img src='../images/416.gif'/></span>����ͬ�����Ժ�...";
document.body.appendChild(divMsg);
g_divMsg=divMsg;

//(�鵵��ע��,����ɾ��)CliendLoad End##@@
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
//@@##720:˫�������ű�-DblClick(�鵵��ע��,����ɾ��)
if(IsNetBoxRunning())
NewHref("EditMember_Form.jsp?DataID=" + oFocus.getAttribute("node"),
 "width=500,height=550,resizable=yes,titlebar=no,scrollbars=no",
        "�༭�û�", 5);
else
  parent.NewHref("fvs/EditMember_Form.jsp?DataID=" + oFocus.getAttribute("node"),
 "width=500,height=550,resizable=yes,scrollbars=no",
        "�༭�û�", 2);

//(�鵵��ע��,����ɾ��)UserDblClick End##@@
}
function SeekMenu_717(obj)
{
//@@##717:�˵�ִ�нű�-����ְ�����(�鵵��ע��,����ɾ��)
NewHref("SeekUserEnumTable.jsp?EnumNo=10", "width=320,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_718(obj)
{
//@@##718:�˵�ִ�нű�-���ü������(�鵵��ע��,����ɾ��)
NewHref("SeekUserEnumTable.jsp?EnumNo=75", "width=320,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_719(obj)
{
//@@##719:�˵�ִ�нű�-����ѧ������(�鵵��ע��,����ɾ��)
NewHref("SeekUserEnumTable.jsp?EnumNo=76","width=320,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_722(obj)
{
//@@##722:�˵�ִ�нű�-3:����ְ�����(�鵵��ע��,����ɾ��)
NewHref("/TableSeek.asp?ActionID=82&EnumNo=10", "width=320,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_723(obj)
{
//@@##723:�˵�ִ�нű�-1:���ü������(�鵵��ע��,����ɾ��)
NewHref("/TableSeek.asp?ActionID=82&EnumNo=75", "width=320,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_724(obj)
{
//@@##724:�˵�ִ�нű�-2:����ѧ������(�鵵��ע��,����ɾ��)
NewHref("/TableSeek.asp?ActionID=82&EnumNo=76","width=320,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_725(obj)
{
//@@##725:�˵�ִ�нű�-5:��ѯ��ְԱ��(�鵵��ע��,����ɾ��)
NewHref("TableSeek.asp?ActionID=47", "width=640,height=480,resizable=1");
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_727(obj)
{
//@@##727:�˵�ִ�нű�-100:����(�鵵��ע��,����ɾ��)
if (IsNetBoxRunning()){
NewHref("EditMember_Form.jsp",
        "width=500,height=550,resizable=yes,titlebar=no,scrollbars=no", "�����û�", 5);
}else{
parent.NewHref("fvs/EditMember_Form.jsp",
        "width=500,height=550,resizable=yes,scrollbars=no", "�����û�", 2);
}
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_729(obj)
{
//@@##729:�˵�ִ�нű�-200:�༭(�鵵��ע��,����ɾ��)
if (oFocus == undefined) {
    alert("��ѡ���û�");
    return;
}
UserDblClick(oFocus);
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_730(obj)
{
//@@##730:�˵�ִ�нű�-300:ɾ��(�鵵��ע��,����ɾ��)
var idStr=GetSelectNode();
if(idStr==""){
alert("��ѡ���¼�ٲ�����");
return;
}
var idArr=idStr.split(",");
var trArr=document.getElementById('SeekTable').getElementsByTagName("tr");
      for(var i=0; i<trArr.length; i++){
        for(var j=0; j<idArr.length; j++)
          if(trArr[i].node==idArr[j]){
            if(trArr[i].cells[1].innerHTML=="guest"){
              alert("����ɾ��ϵͳԤ�������ʺ�guest��");
              return;
            }
                else if(trArr[i].cells[1].innerHTML=="admin"){
                  alert("����ɾ��ϵͳԤ��ϵͳ����Ա�ʺ�admin��");
                  return;
                }
          }
      }
if(window.confirm("ȷ��ɾ����Ӧ�û���")){
     var url="../AjaxFunction?type=deleteMemberAndSyncGroup&memberID="+idStr;
    AjaxRequestPage(url, true, "",  function(str){
      if(unescape(str)=="true"){
      var trArr=document.getElementById('SeekTable').getElementsByTagName("tr");
      for(var i=0; i<trArr.length; i++){
        for(var j=0; j<idArr.length; j++)
        if(trArr[i].node==idArr[j]) trArr[i].style.display="none";
      }
      }else{
        alert("ɾ��ʧ�ܣ�ԭ��δ֪�����Ժ����ԣ�");
      }
    });
}
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

function SeekMenu_731(obj)
{
//@@##731:�˵�ִ�нű�-500:�������(�鵵��ע��,����ɾ��)
var users = GetSelectNode();
if (users == "") {
  if ( oFocus == undefined ) {
      alert("��ѡ���û���");
      return;
  } else {
      users = oFocus.getAttribute("node");
  }
}
if (!confirm("��������ѡ�û�������Ϊ��ʼ���룬��ȷ�ϡ�")) {
  return;
}
Ajax.request({url:"Member_Edit_Admin.jsp?type=ClearPassword&userid=" + users, rollback:function(str){
  alert("�ɹ�����" + str + "���û������롣");
}});
//(�鵵��ע��,����ɾ��)SeekMenu End##@@

}

//@@##721:�û��Զ���ű�-UserFunction(�鵵��ע��,����ɾ��)
var FormFeatures = "scrollbars=0,resizable=1,width=640,height=580,left=50,top=50";
var OldDelete = DeleteRecord;
var DeleteRecord = function ()
{
 if (oFocus != undefined && oFocus.innerText.replace(/^\s+|\s+$/, "") == "����Ա")
  {
    alert("����Ա���ܱ�ɾ����");
    return;
  }
  OldDelete();
};

function deleteUserForGroup(o) {
  var obj = o.nextSibling;
  
  var tr = WebFunc.getParent(o, "tr", "body");
  if (tr == null) {
    return;
  }

  if ( !confirm("ȷʵҪ���û���" + tr.cells[2].innerText + "���Ƴ������顾" + obj.nodeValue + "����") ) {
      return;
  }

  var groupName = obj.nodeValue;
  groupName = groupName.replace(/,.*/, "");
  var url = "../AjaxFunction?type=UserGroup_option&sub_type=delGroup&groupid=" + groupName
      + "&datas=" + tr.node;
  //alert(url)
  Ajax.request({url:url, rollback:function(str){
      location.reload();
  }});
  tr = null;
  obj = null;
}
//(�鵵��ע��,����ɾ��)UserJavaScript End##@@
var href ="<%=href%>";
var SeekKey = "<%=SeekKey%>";
var SeekParam = "<%=SeekParam.replace('%', '*')%>";
var OrderField = "<%=OrderField%>";
var bDesc = <%=bDesc%>;
var ClassName = "SeekHR";
var ActionID = 364;
var ViewMode = <%=ViewMode%>;
var TableDefID = 228;
var PrepID = 0;
var FormAction="EditMember.jsp";
var FormViewAction = "";
var nTreeIndent = <%=seekrun.nTreeIndent%>;
var treeParentNode = "";
</script>
<%
	jdb.closeDBCon();
	out.println("</body></html>");
%>